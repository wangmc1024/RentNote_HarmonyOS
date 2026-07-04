import { Colors, Fonts, FontSizes, Dimensions, Radius, Shadows, Spacing, getTagTextColor, getTagBgColor } from '../common/DesignTokens';
import { PropertyInfo, PropertyIdParam } from '../model/PropertyModel';
import { HomeViewModel } from '../viewmodel/HomeViewModel';

@ComponentV2
export struct HomeContent {
  @Local viewModel: HomeViewModel = new HomeViewModel();
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @Consumer('refreshFlag') refreshFlag: number = 0;

  @Monitor('refreshFlag')
  onRefreshFlagChange(): void {
    this.viewModel.loadData();
  }

  aboutToAppear(): void {
    this.viewModel.loadData();
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

  build() {
    Scroll() {
      Column() {
        Row() {
          Text('Home')
            .fontSize(FontSizes.PAGE_TITLE)
            .fontColor(Colors.TEXT_PRIMARY)
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Bold)

          Blank()

          Row() {
            Text('子')
              .fontSize(14)
              .fontColor(Colors.TEXT_WHITE)
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Bold)
          }
          .width(32)
          .height(32)
          .backgroundColor(Colors.PRIMARY)
          .borderRadius(16)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .height(Dimensions.HEADER_HEIGHT)
        .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })

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

      Text('在备选中选定一套房源开始租期')
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(Colors.TEXT_MUTED)
        .fontFamily(Fonts.CN)
        .margin({ top: 8 })
    }
    .width('100%')
    .height(320)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  RentingState() {
    Column() {
      Row() {
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

        Column() {
          Text(this.viewModel.rentingProperties[0].name)
            .fontSize(FontSizes.TITLE_LARGE)
            .fontColor(Colors.TEXT_PRIMARY)
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (this.viewModel.rentingProperties[0].address.length > 0) {
            Text(this.viewModel.rentingProperties[0].address)
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

        Text(this.getRenewalLabel(this.viewModel.rentingProperties[0].renewalStatus))
          .fontSize(FontSizes.CAPTION)
          .fontColor(this.getRenewalColor(this.viewModel.rentingProperties[0].renewalStatus))
          .fontFamily(Fonts.CN)
          .fontWeight(FontWeight.Medium)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor(this.getRenewalBgColor(this.viewModel.rentingProperties[0].renewalStatus))
          .borderRadius(Radius.TAG)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row() {
        Column() {
          Text('月租金')
            .fontSize(FontSizes.CAPTION)
            .fontColor(Colors.TEXT_MUTED)
            .fontFamily(Fonts.CN)

          Text('¥' + this.viewModel.rentingProperties[0].monthlyRent.toLocaleString())
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

          Text('¥' + this.viewModel.rentingProperties[0].deposit.toLocaleString())
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

      if (this.viewModel.rentingProperties[0].tags.length > 0) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.viewModel.rentingProperties[0].tags, (tag: string) => {
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
    .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: 12 })
    .onClick(() => {
      const editParam: PropertyIdParam = { propertyId: this.viewModel.rentingProperties[0].id, mode: '' };
      this.navPathStack.pushPathByName('AddProperty', editParam);
    })

    Column() {
      Row() {
        Text('租期进度')
          .fontSize(FontSizes.SECTION_TITLE)
          .fontColor(Colors.TEXT_PRIMARY)
          .fontFamily(Fonts.CN)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text(this.getElapsedDays(this.viewModel.rentingProperties[0].startDate,
          this.viewModel.rentingProperties[0].endDate) + ' / ' +
          this.getTotalDays(this.viewModel.rentingProperties[0].startDate,
            this.viewModel.rentingProperties[0].endDate) + ' 天')
          .fontSize(FontSizes.CAPTION)
          .fontColor(Colors.TEXT_MUTED)
          .fontFamily(Fonts.NUMBER)
      }
      .width('100%')
      .margin({ bottom: 12 })

      Progress({
        value: this.getLeaseProgress(this.viewModel.rentingProperties[0].startDate,
          this.viewModel.rentingProperties[0].endDate),
        total: 100,
        type: ProgressType.Linear
      })
        .width('100%')
        .height(12)
        .color(this.getDaysRemaining(this.viewModel.rentingProperties[0].endDate) <= 30 ?
          Colors.WARNING : Colors.PRIMARY)
        .backgroundColor(this.getDaysRemaining(this.viewModel.rentingProperties[0].endDate) <= 30 ?
          Colors.WARNING_LIGHT : Colors.PRIMARY_LIGHT)
        .style({ strokeWidth: 12 })

      Row() {
        Text(this.viewModel.rentingProperties[0].startDate)
          .fontSize(10)
          .fontColor(Colors.TEXT_MUTED)
          .fontFamily(Fonts.NUMBER)

        Blank()

        Text(this.viewModel.rentingProperties[0].endDate)
          .fontSize(10)
          .fontColor(this.getDaysRemaining(this.viewModel.rentingProperties[0].endDate) <= 30 ?
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
    .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: Spacing.ITEM_GAP })

    Column() {
      Text(this.getDaysRemaining(this.viewModel.rentingProperties[0].endDate) < 0 ? '已过期' : '到期倒计时')
        .fontSize(FontSizes.CAPTION)
        .fontColor(Colors.TEXT_MUTED)
        .fontFamily(Fonts.CN)

      Row() {
        Text(Math.abs(this.getDaysRemaining(this.viewModel.rentingProperties[0].endDate)).toString())
          .fontSize(56)
          .fontColor(this.getDaysRemaining(this.viewModel.rentingProperties[0].endDate) < 0 ?
            Colors.DANGER :
            this.getDaysRemaining(this.viewModel.rentingProperties[0].endDate) <= 30 ?
              Colors.WARNING : Colors.PRIMARY)
          .fontFamily(Fonts.NUMBER)
          .fontWeight(FontWeight.Bold)

        Text(this.getDaysRemaining(this.viewModel.rentingProperties[0].endDate) < 0 ?
          '天前到期' : '天')
          .fontSize(FontSizes.BODY_LARGE)
          .fontColor(this.getDaysRemaining(this.viewModel.rentingProperties[0].endDate) < 0 ?
            Colors.DANGER :
            this.getDaysRemaining(this.viewModel.rentingProperties[0].endDate) <= 30 ?
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
    .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: Spacing.ITEM_GAP })
  }
}
