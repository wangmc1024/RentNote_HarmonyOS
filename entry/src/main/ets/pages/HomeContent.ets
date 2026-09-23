import { Colors, Fonts, FontSizes, Dimensions, Radius, Shadows, Spacing, getTagTextColor, getTagBgColor } from '../common/DesignTokens';
import { PropertyInfo, PropertyIdParam } from '../model/PropertyModel';
import { HomeViewModel } from '../viewmodel/HomeViewModel';
import { formProvider, formInfo } from '@kit.FormKit';
import { Want, common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';


@ComponentV2
export struct HomeContent {
  @Local viewModel: HomeViewModel = new HomeViewModel();
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @Consumer('refreshFlag') refreshFlag: number = 0;
  @Local showWidgetTip: boolean = false;

  aboutToAppear(): void {
    this.viewModel.loadData();
    this.checkWidgetTip();
  }

  private async checkWidgetTip(): Promise<void> {
    try {
      const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const prefs: preferences.Preferences = preferences.getPreferencesSync(context, { name: 'RentNotePrefs' });
      const dismissed: boolean = prefs.getSync('widget_tip_dismissed', false) as boolean;
      if (dismissed) {
        this.showWidgetTip = false;
        return;
      }
      const forms: Array<formInfo.RunningFormInfo> = await formProvider.getPublishedRunningFormInfos();
      this.showWidgetTip = forms.length === 0;
    } catch (_e) {
      const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const prefs: preferences.Preferences = preferences.getPreferencesSync(context, { name: 'RentNotePrefs' });
      const dismissed: boolean = prefs.getSync('widget_tip_dismissed', false) as boolean;
      this.showWidgetTip = !dismissed;
    }
  }

  private async dismissWidgetTip(): Promise<void> {
    this.showWidgetTip = false;
    try {
      const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const prefs: preferences.Preferences = preferences.getPreferencesSync(context, { name: 'RentNotePrefs' });
      prefs.putSync('widget_tip_dismissed', true);
      await prefs.flush();
    } catch (_e) {
    }
  }

  private addWidgetFromTip(): void {
    try {
      const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const want: Want = {
        bundleName: context.abilityInfo.bundleName,
        abilityName: 'EntryFormAbility',
        parameters: {
          'ohos.extra.param.key.module_name': 'entry',
          'ohos.extra.param.key.form_name': 'RentWidget',
          'ohos.extra.param.key.form_dimension': formInfo.FormDimension.Dimension_2_4 as Object,
        }
      };
      formProvider.openFormManager(want);
    } catch (_e) {
    }
  }

  private getDaysRemaining(endDate: string): number {
    const parts: string[] = endDate.split('.');
    if (parts.length !== 3) {
      return 0;
    }
    const year: number = parseInt(parts[0], 10);
    const month: number = parseInt(parts[1], 10) - 1;
    const day: number = parseInt(parts[2], 10);
    const expiry: Date = new Date(year, month, day);
    const today: Date = new Date();
    today.setHours(0, 0, 0, 0);
    const diff: number = expiry.getTime() - today.getTime();
    return Math.ceil(diff / (1000 * 60 * 60 * 24));
  }

  private getLeaseProgress(startDate: string, endDate: string): number {
    const startParts: string[] = startDate.split('.');
    const endParts: string[] = endDate.split('.');
    if (startParts.length < 3 || endParts.length < 3) {
      return 0;
    }
    const startMs: number = new Date(
      parseInt(startParts[0], 10),
      parseInt(startParts[1], 10) - 1,
      parseInt(startParts[2], 10)
    ).getTime();
    const endMs: number = new Date(
      parseInt(endParts[0], 10),
      parseInt(endParts[1], 10) - 1,
      parseInt(endParts[2], 10)
    ).getTime();
    const nowMs: number = Date.now();
    if (endMs <= startMs) {
      return 0;
    }
    const pct: number = Math.floor(((nowMs - startMs) / (endMs - startMs)) * 100);
    return Math.max(0, Math.min(pct, 100));
  }

  private getTotalDays(startDate: string, endDate: string): number {
    const startParts: string[] = startDate.split('.');
    const endParts: string[] = endDate.split('.');
    if (startParts.length < 3 || endParts.length < 3) {
      return 0;
    }
    const startMs: number = new Date(
      parseInt(startParts[0], 10),
      parseInt(startParts[1], 10) - 1,
      parseInt(startParts[2], 10)
    ).getTime();
    const endMs: number = new Date(
      parseInt(endParts[0], 10),
      parseInt(endParts[1], 10) - 1,
      parseInt(endParts[2], 10)
    ).getTime();
    return Math.max(1, Math.ceil((endMs - startMs) / (1000 * 60 * 60 * 24)));
  }

  private getElapsedDays(startDate: string, endDate: string): number {
    const total: number = this.getTotalDays(startDate, endDate);
    const remaining: number = Math.max(0, this.getDaysRemaining(endDate));
    return total - remaining;
  }

  private getRenewalLabel(status: string): string {
    if (status === 'renew') {
      return '续租';
    }
    if (status === 'no_renew') {
      return '不租';
    }
    return '待定';
  }

  private getRenewalColor(status: string): string {
    if (status === 'renew') {
      return Colors.SUCCESS;
    }
    if (status === 'no_renew') {
      return Colors.DANGER;
    }
    return Colors.WARNING;
  }

  private getRenewalBgColor(status: string): string {
    if (status === 'renew') {
      return Colors.SUCCESS_LIGHT;
    }
    if (status === 'no_renew') {
      return Colors.DANGER_LIGHT;
    }
    return Colors.WARNING_LIGHT;
  }

  private hasLeaseInfo(p: PropertyInfo): boolean {
    return p.startDate.length > 0 && p.endDate.length > 0;
  }

  private showDemoteDialog(propertyId: string): void {
    this.getUIContext().showAlertDialog({
      message: '取消选定后，该房源将退回备选列表，租期信息将被清除。',
      primaryButton: {
        value: '确认取消',
        action: () => {
          this.viewModel.demoteRenting(propertyId).then(() => {
            this.refreshFlag++;
          });
        }
      },
      secondaryButton: {
        value: '返回',
        action: () => {}
      }
    });
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Text('Home')
            .fontSize(FontSizes.PAGE_TITLE)
            .fontColor(Colors.TEXT_PRIMARY)
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .height(Dimensions.HEADER_HEIGHT)
        .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })

        if (this.showWidgetTip) {
          Row() {
            SymbolGlyph($r('sys.symbol.square_grid_2x2'))
              .fontSize(20)
              .fontColor([Colors.PRIMARY])

            Text('添加桌面小组件，实时查看租金与到期提醒')
              .fontSize(FontSizes.BODY_SMALL)
              .fontColor(Colors.TEXT_SECONDARY)
              .fontFamily(Fonts.CN)
              .layoutWeight(1)
              .margin({ left: 8 })

            Text('添加')
              .fontSize(FontSizes.CAPTION)
              .fontColor(Colors.PRIMARY)
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Medium)
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor(Colors.PRIMARY_LIGHT)
              .borderRadius(Radius.TAG)
              .onClick(() => {
                this.addWidgetFromTip();
              })

            SymbolGlyph($r('sys.symbol.xmark'))
              .fontSize(14)
              .fontColor([Colors.TEXT_MUTED])
              .margin({ left: 8 })
              .onClick(() => {
                this.dismissWidgetTip();
              })
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .padding({ left: 16, right: 12, top: 10, bottom: 10 })
          .backgroundColor(Colors.PRIMARY_LIGHT)
          .borderRadius(Radius.CARD_SM)
          .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })
        }

        if (this.viewModel.rentingProperties.length === 0) {
          this.EmptyState()
        } else {
          this.RentingState()
        }

        Column().height(96)
      }
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(1)
  }

  @Builder
  EmptyState() {
    Column() {
      SymbolGlyph($r('sys.symbol.house'))
        .fontSize(48)
        .fontColor([Colors.TEXT_MUTED])

      Text('暂无在租房源')
        .fontSize(FontSizes.BODY_LARGE)
        .fontColor(Colors.TEXT_SECONDARY)
        .fontFamily(Fonts.CN)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 16 })

      Column({ space: 6 }) {
        Row() {
          Row() {
            Text('1')
              .fontSize(10)
              .fontColor(Colors.PRIMARY)
              .fontFamily(Fonts.NUMBER)
              .fontWeight(FontWeight.Bold)
          }
          .width(18)
          .height(18)
          .backgroundColor(Colors.PRIMARY_LIGHT)
          .borderRadius(9)
          .justifyContent(FlexAlign.Center)

          Text('切换到「备选」标签添加房源')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(Colors.TEXT_SECONDARY)
            .fontFamily(Fonts.CN)
            .margin({ left: 8 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Row() {
          Row() {
            Text('2')
              .fontSize(10)
              .fontColor(Colors.PRIMARY)
              .fontFamily(Fonts.NUMBER)
              .fontWeight(FontWeight.Bold)
          }
          .width(18)
          .height(18)
          .backgroundColor(Colors.PRIMARY_LIGHT)
          .borderRadius(9)
          .justifyContent(FlexAlign.Center)

          Text('左滑备选卡片点击「选定」')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(Colors.TEXT_SECONDARY)
            .fontFamily(Fonts.CN)
            .margin({ left: 8 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Row() {
          Row() {
            Text('3')
              .fontSize(10)
              .fontColor(Colors.PRIMARY)
              .fontFamily(Fonts.NUMBER)
              .fontWeight(FontWeight.Bold)
          }
          .width(18)
          .height(18)
          .backgroundColor(Colors.PRIMARY_LIGHT)
          .borderRadius(9)
          .justifyContent(FlexAlign.Center)

          Text('选定后可在此查看租期进度')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(Colors.TEXT_SECONDARY)
            .fontFamily(Fonts.CN)
            .margin({ left: 8 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Row() {
          Row() {
            Text('4')
              .fontSize(10)
              .fontColor(Colors.PRIMARY)
              .fontFamily(Fonts.NUMBER)
              .fontWeight(FontWeight.Bold)
          }
          .width(18)
          .height(18)
          .backgroundColor(Colors.PRIMARY_LIGHT)
          .borderRadius(9)
          .justifyContent(FlexAlign.Center)

          Text('左滑在租卡片可「取消选定」')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(Colors.TEXT_SECONDARY)
            .fontFamily(Fonts.CN)
            .margin({ left: 8 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding({ left: 40, right: 40 })
      .margin({ top: 12 })
    }
    .width('100%')
    .height(320)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  RentingState() {
    Column() {
      List({ space: 16 }) {
        ForEach(this.viewModel.rentingProperties, (property: PropertyInfo) => {
          ListItem() {
            Column() {
              this.RentingCardContent(property)

              if (this.hasLeaseInfo(property)) {
                this.LeaseProgressCard(property)
                this.CountdownCard(property)
              }
            }
          }
          .swipeAction({ end: { builder: () => { this.SwipeDemoteBuilder(property.id) } } })
        }, (item: PropertyInfo) => item.id + '_' + this.viewModel.dataVersion.toString())
      }
      .scrollBar(BarState.Off)
      .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })
    }
  }

  @Builder
  RentingCardContent(property: PropertyInfo) {
    Column() {
      Row() {
        if (property.getFirstImage().length > 0) {
          Image(property.getFirstImage())
            .width(56)
            .height(56)
            .objectFit(ImageFit.Cover)
            .borderRadius(28)
        } else {
          Row() {
            SymbolGlyph($r('sys.symbol.building'))
              .fontSize(28)
              .fontColor([Colors.PRIMARY])
          }
          .width(56)
          .height(56)
          .backgroundColor(Colors.PRIMARY_LIGHT)
          .borderRadius(Radius.ICON_BG)
          .justifyContent(FlexAlign.Center)
        }

        Column() {
          Text(property.name)
            .fontSize(FontSizes.TITLE_LARGE)
            .fontColor(Colors.TEXT_PRIMARY)
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (property.address.length > 0) {
            Text(property.address)
              .fontSize(FontSizes.BODY_SMALL)
              .fontColor(Colors.TEXT_SECONDARY)
              .fontFamily(Fonts.CN)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: 4 })
          }
        }
        .layoutWeight(1)
        .margin({ left: 16 })

        if (property.renewalStatus.length > 0) {
          Text(this.getRenewalLabel(property.renewalStatus))
            .fontSize(FontSizes.CAPTION)
            .fontColor(this.getRenewalColor(property.renewalStatus))
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Medium)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor(this.getRenewalBgColor(property.renewalStatus))
            .borderRadius(Radius.TAG)
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row() {
        Column() {
          Text('月租金')
            .fontSize(FontSizes.CAPTION)
            .fontColor(Colors.TEXT_MUTED)
            .fontFamily(Fonts.CN)

          Text('¥' + property.monthlyRent.toLocaleString())
            .fontSize(28)
            .fontColor(Colors.PRIMARY)
            .fontFamily(Fonts.NUMBER)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Column() {
          Text('押金')
            .fontSize(FontSizes.CAPTION)
            .fontColor(Colors.TEXT_MUTED)
            .fontFamily(Fonts.CN)

          Text('¥' + property.deposit.toLocaleString())
            .fontSize(28)
            .fontColor(Colors.TEXT_SECONDARY)
            .fontFamily(Fonts.NUMBER)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .margin({ top: 20, left: 8, right: 8 })

      if (property.tags.length > 0) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(property.tags, (tag: string) => {
            Text(tag)
              .fontSize(FontSizes.CAPTION)
              .fontColor(getTagTextColor(tag))
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Medium)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .backgroundColor(getTagBgColor(tag))
              .borderRadius(Radius.TAG)
              .margin({ right: 6, top: 6 })
          }, (item: string) => item)
        }
        .width('100%')
        .margin({ top: 12 })
      }

      if (property.notes.length > 0) {
        Text(property.notes)
          .fontSize(FontSizes.CAPTION)
          .fontColor(Colors.TEXT_MUTED)
          .fontFamily(Fonts.CN)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 8 })
          .width('100%')
      }
    }
    .width('100%')
    .backgroundColor(Colors.CARD_BG)
    .borderRadius(Radius.CARD)
    .padding(Spacing.CARD_PADDING)
    .shadow({
      radius: Shadows.CARD.radius,
      color: Shadows.CARD.color,
      offsetX: Shadows.CARD.offsetX,
      offsetY: Shadows.CARD.offsetY
    })
    .margin({ top: 4 })
    .onClick(() => {
      const detailParam: PropertyIdParam = new PropertyIdParam();
      detailParam.propertyId = property.id;
      this.navPathStack.pushPathByName('PropertyDetail', detailParam);
    })
  }

  @Builder
  SwipeDemoteBuilder(propertyId: string) {
    Row() {
      Column() {
        SymbolGlyph($r('sys.symbol.xmark_circle'))
          .fontSize(24)
          .fontColor([Colors.TEXT_WHITE])

        Text('取消选定')
          .fontSize(FontSizes.CAPTION)
          .fontColor(Colors.TEXT_WHITE)
          .fontFamily(Fonts.CN)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 4 })
      }
      .width(80)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Colors.WARNING)
      .onClick(() => {
        this.showDemoteDialog(propertyId);
      })
    }
  }

  @Builder
  LeaseProgressCard(property: PropertyInfo) {
    Column() {
      Row() {
        Text('租期进度')
          .fontSize(FontSizes.SECTION_TITLE)
          .fontColor(Colors.TEXT_PRIMARY)
          .fontFamily(Fonts.CN)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text(this.getElapsedDays(property.startDate, property.endDate) + ' / ' +
          this.getTotalDays(property.startDate, property.endDate) + ' 天')
          .fontSize(FontSizes.CAPTION)
          .fontColor(Colors.TEXT_MUTED)
          .fontFamily(Fonts.NUMBER)
      }
      .width('100%')
      .margin({ bottom: 12 })

      Progress({
        value: this.getLeaseProgress(property.startDate, property.endDate),
        total: 100,
        type: ProgressType.Linear
      })
        .width('100%')
        .height(12)
        .color(this.getDaysRemaining(property.endDate) <= 30 ?
          Colors.WARNING : Colors.PRIMARY)
        .backgroundColor(this.getDaysRemaining(property.endDate) <= 30 ?
          Colors.WARNING_LIGHT : Colors.PRIMARY_LIGHT)
        .style({ strokeWidth: 12 })

      Row() {
        Text(property.startDate)
          .fontSize(10)
          .fontColor(Colors.TEXT_MUTED)
          .fontFamily(Fonts.NUMBER)

        Blank()

        Text(property.endDate)
          .fontSize(10)
          .fontColor(this.getDaysRemaining(property.endDate) <= 30 ?
            Colors.WARNING : Colors.TEXT_MUTED)
          .fontFamily(Fonts.NUMBER)
      }
      .width('100%')
      .margin({ top: 6 })
    }
    .width('100%')
    .backgroundColor(Colors.CARD_BG)
    .borderRadius(Radius.CARD)
    .padding(Spacing.CARD_PADDING)
    .shadow({
      radius: Shadows.CARD.radius,
      color: Shadows.CARD.color,
      offsetX: Shadows.CARD.offsetX,
      offsetY: Shadows.CARD.offsetY
    })
    .margin({ top: Spacing.ITEM_GAP })
  }

  @Builder
  CountdownCard(property: PropertyInfo) {
    Column() {
      Text(this.getDaysRemaining(property.endDate) < 0 ? '已过期' : '到期倒计时')
        .fontSize(FontSizes.CAPTION)
        .fontColor(Colors.TEXT_MUTED)
        .fontFamily(Fonts.CN)

      Row() {
        Text(Math.abs(this.getDaysRemaining(property.endDate)).toString())
          .fontSize(56)
          .fontColor(this.getDaysRemaining(property.endDate) < 0 ?
            Colors.DANGER :
            this.getDaysRemaining(property.endDate) <= 30 ?
              Colors.WARNING : Colors.PRIMARY)
          .fontFamily(Fonts.NUMBER)
          .fontWeight(FontWeight.Bold)

        Text(this.getDaysRemaining(property.endDate) < 0 ?
          '天前到期' : '天')
          .fontSize(FontSizes.BODY_LARGE)
          .fontColor(this.getDaysRemaining(property.endDate) < 0 ?
            Colors.DANGER :
            this.getDaysRemaining(property.endDate) <= 30 ?
              Colors.WARNING : Colors.TEXT_SECONDARY)
          .fontFamily(Fonts.CN)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 4, bottom: 8 })
      }
      .alignItems(VerticalAlign.Bottom)
      .margin({ top: 8 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Colors.CARD_BG)
    .borderRadius(Radius.CARD)
    .padding({ top: 20, bottom: 20, left: Spacing.CARD_PADDING, right: Spacing.CARD_PADDING })
    .shadow({
      radius: Shadows.CARD.radius,
      color: Shadows.CARD.color,
      offsetX: Shadows.CARD.offsetX,
      offsetY: Shadows.CARD.offsetY
    })
    .margin({ top: Spacing.ITEM_GAP })
  }
}
