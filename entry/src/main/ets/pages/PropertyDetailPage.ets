/**
 * 房源详情页 - NavDestination 页面
 * 使用 @ComponentV2 装饰器
 * 通过 NavDestination 的 onReady 回调获取传入的 propertyId 参数
 * 从 PropertyDetailViewModel 加载对应房源数据
 * 统一使用 HeaderBar 组件
 */
import { Colors, Fonts, FontSizes, Dimensions, Radius, Shadows, Spacing, getTagTextColor, getTagBgColor } from '../common/DesignTokens';
import { HeaderBar } from '../components/HeaderBar';
import { PropertyDetailViewModel } from '../viewmodel/PropertyDetailViewModel';
import { PropertyInfo, PropertyIdParam, DeleteResult } from '../model/PropertyModel';

@Builder
export function PropertyDetailBuilder() {
  PropertyDetailPage()
}

@ComponentV2
export struct PropertyDetailPage {
  @Local viewModel: PropertyDetailViewModel = new PropertyDetailViewModel();
  @Local propertyId: string = '';
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    // 通过 onReady 获取参数后加载房源数据
  }

  build() {
    NavDestination() {
      Column() {
        HeaderBar({
          title: '房源详情',
          showBack: true,
          onBack: () => {
            this.navPathStack.pop();
          },
          rightContent: (): void => { this.EditRightContent() }
        })

        // 内容区
        if (this.viewModel.property) {
          this.ContentArea(this.viewModel.property as PropertyInfo)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Colors.BG_PRIMARY)
    }
    .onReady((context: NavDestinationContext) => {
      const param: Object = context.pathInfo.param as Object;
      const paramObj: PropertyIdParam = param as PropertyIdParam;
      if (paramObj.propertyId) {
        this.propertyId = paramObj.propertyId;
        this.viewModel.loadProperty(this.propertyId);
      }
    })
    .hideTitleBar(true)
  }

  @Builder
  EditRightContent() {
    Text('编辑')
      .fontSize(FontSizes.BODY_LARGE)
      .fontColor(Colors.PRIMARY)
      .fontFamily(Fonts.CN)
      .fontWeight(FontWeight.Medium)
      .onClick(() => {
        if (this.viewModel.property) {
          const editParam: PropertyIdParam = { propertyId: this.viewModel.property.id, mode: '' };
          this.navPathStack.pushPathByName('AddProperty', editParam);
        }
      })
  }

  @Builder
  ContentArea(property: PropertyInfo) {
    Scroll() {
      Column() {
        // ===== 标题区域 =====
        Column() {
          Text(property.name)
            .fontSize(FontSizes.TITLE)
            .fontColor(Colors.TEXT_PRIMARY)
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start)

          Text(property.address)
            .fontSize(FontSizes.BODY)
            .fontColor(Colors.TEXT_SECONDARY)
            .fontFamily(Fonts.CN)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 8 })

          // 标签
          Row() {
            ForEach(property.tags, (tag: string) => {
              Text(tag)
                .fontSize(FontSizes.CAPTION)
                .fontColor(getTagTextColor(tag))
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .padding({ left: 12, right: 12, top: 5, bottom: 5 })
                .backgroundColor(getTagBgColor(tag))
                .borderRadius(Radius.TAG)
                .margin({ right: Spacing.ITEM_GAP_SM })
            }, (item: string) => item)
          }
          .margin({ top: 8 })
        }
        .width('100%')
        .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })
        .margin({ top: 12 })

        // ===== 地图卡片 =====
        Column() {
          SymbolGlyph($r('sys.symbol.building'))
            .fontSize(36)
            .fontColor([Colors.PRIMARY])

          Text('地图位置')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(Colors.TEXT_SECONDARY)
            .fontFamily(Fonts.CN)
            .margin({ top: 4 })
        }
        .width('100%')
        .height(Dimensions.MAP_CARD_HEIGHT)
        .backgroundColor(Colors.PRIMARY_LIGHT)
        .borderRadius(Radius.CARD)
        .justifyContent(FlexAlign.Center)
        .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: Spacing.ITEM_GAP })

        // ===== 租期信息卡片 =====
        Column() {
          Text('租期信息')
            .fontSize(FontSizes.SECTION_TITLE)
            .fontColor(Colors.TEXT_PRIMARY)
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start)
            .margin({ left: Spacing.CARD_PADDING, top: Spacing.CARD_PADDING })

          Row() {
            Column() {
              this.LeaseItem('月租金', '¥' + property.monthlyRent.toLocaleString(), Colors.PRIMARY)
              this.LeaseItem('押金', '¥' + property.deposit.toLocaleString(), Colors.TEXT_PRIMARY)
            }
            .layoutWeight(1)
            .margin({ left: Spacing.CARD_PADDING })

            Column() {
              this.LeaseItem('入住时间', property.startDate, Colors.TEXT_PRIMARY)
              this.LeaseItem('到期时间', property.endDate,
                property.status === 'expiring' ? Colors.WARNING : Colors.TEXT_PRIMARY)
            }
            .layoutWeight(1)
          }
          .width('100%')
          .margin({ top: 16, bottom: Spacing.CARD_PADDING })
        }
        .width('100%')
        .backgroundColor(Colors.CARD_BG)
        .borderRadius(Radius.CARD)
        .shadow({
          radius: Shadows.CARD.radius,
          color: Shadows.CARD.color,
          offsetX: Shadows.CARD.offsetX,
          offsetY: Shadows.CARD.offsetY
        })
        .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: Spacing.ITEM_GAP })

        // ===== 账单卡片 =====
        if (property.status !== 'candidate') {
          Row() {
            Column() {
              Text('本月应缴')
                .fontSize(FontSizes.BODY)
                .fontColor(Colors.TEXT_SECONDARY)
                .fontFamily(Fonts.CN)

              Text('¥' + property.monthlyRent.toLocaleString())
                .fontSize(FontSizes.TITLE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.NUMBER)
                .fontWeight(FontWeight.Bold)
                .margin({ top: 4 })
            }

            Blank()

            Text(property.billsPaid > 0 ? '已缴纳' : '待缴纳')
              .fontSize(FontSizes.BODY_SMALL)
              .fontColor(property.billsPaid > 0 ? Colors.SUCCESS : Colors.WARNING)
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Medium)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(property.billsPaid > 0 ? Colors.SUCCESS_LIGHT : Colors.WARNING_LIGHT)
              .borderRadius(Radius.CARD)
          }
          .width('100%')
          .height(Dimensions.BILL_CARD_HEIGHT)
          .backgroundColor(Colors.CARD_BG)
          .borderRadius(Radius.CARD)
          .padding({ left: Spacing.CARD_PADDING, right: Spacing.CARD_PADDING })
          .shadow({
            radius: Shadows.CARD.radius,
            color: Shadows.CARD.color,
            offsetX: Shadows.CARD.offsetX,
            offsetY: Shadows.CARD.offsetY
          })
          .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: Spacing.ITEM_GAP })
        }

        // ===== 操作按钮 =====
        Row() {
          Button('编辑房源')
            .layoutWeight(1)
            .height(Dimensions.BUTTON_HEIGHT)
            .fontSize(FontSizes.SECTION_TITLE)
            .fontColor(Colors.TEXT_WHITE)
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(Colors.PRIMARY)
            .borderRadius(Radius.BUTTON)
            .onClick(() => {
              const editParam: PropertyIdParam = { propertyId: property.id, mode: '' };
              this.navPathStack.pushPathByName('AddProperty', editParam);
            })

          Column().width(12)

          Button('删除房源')
            .layoutWeight(1)
            .height(Dimensions.BUTTON_HEIGHT)
            .fontSize(FontSizes.SECTION_TITLE)
            .fontColor(Colors.DANGER)
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(Colors.DANGER_LIGHT)
            .borderRadius(Radius.BUTTON)
            .border({ width: 1, color: Colors.DANGER_BORDER })
            .onClick(() => {
              this.showDeleteDialog(property.id);
            })
        }
        .width('100%')
        .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: Spacing.ITEM_GAP })

        Column().height(32)
      }
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1)
  }

  /** 显示删除确认弹窗 */
  private showDeleteDialog(id: string): void {
    AlertDialog.show({
      message: '确认删除此房源？删除后无法恢复。',
      primaryButton: {
        value: '确认删除',
        action: () => {
          this.viewModel.deleteProperty(id).then(() => {
            const deleteResult: DeleteResult = { deleted: true, propertyId: id };
            this.navPathStack.pop({ result: deleteResult });
          });
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    });
  }

  @Builder
  LeaseItem(label: string, value: string, valueColor: string) {
    Column() {
      Text(label)
        .fontSize(FontSizes.BODY_SMALL)
        .fontColor(Colors.TEXT_SECONDARY)
        .fontFamily(Fonts.CN)

      Text(value)
        .fontSize(FontSizes.PAGE_TITLE)
        .fontColor(valueColor)
        .fontFamily(Fonts.NUMBER)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 4 })
    }
    .width('100%')
    .height(56)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
  }
}
