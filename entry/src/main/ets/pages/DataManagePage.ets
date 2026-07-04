import { Colors, Fonts, FontSizes, Radius, Shadows, Spacing } from '../common/DesignTokens';
import { HeaderBar } from '../components/HeaderBar';
import { MenuItemRow } from '../components/MenuItemRow';

@Builder
export function DataManageBuilder() {
  DataManagePage()
}

@ComponentV2
export struct DataManagePage {
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        HeaderBar({
          title: '数据管理',
          showBack: true,
          onBack: () => {
            this.navPathStack.pop();
          }
        })

        Scroll() {
          Column() {
            Column() {
              MenuItemRow({
                iconName: 'sys.symbol.tray_and_arrow_down',
                label: '数据导入',
                onAction: () => {
                  this.navPathStack.pushPathByName('DataImport', null);
                }
              })
              Divider().color(Colors.DIVIDER_LIGHT).strokeWidth(0.5).margin({ left: 20, right: 20 })
              MenuItemRow({
                iconName: 'sys.symbol.share',
                label: '导出数据',
                onAction: () => {
                  this.navPathStack.pushPathByName('DataExport', null);
                }
              })
              Divider().color(Colors.DIVIDER_LIGHT).strokeWidth(0.5).margin({ left: 20, right: 20 })
              MenuItemRow({
                iconName: 'sys.symbol.arrow_clockwise',
                label: '数据恢复',
                onAction: () => {
                  this.navPathStack.pushPathByName('DataRestore', null);
                }
              })
            }
            .width('100%')
            .backgroundColor(Colors.CARD_BG)
            .borderRadius(Radius.CARD)
            .shadow({
              radius: Shadows.LIST_ITEM.radius,
              color: Shadows.LIST_ITEM.color,
              offsetX: Shadows.LIST_ITEM.offsetX,
              offsetY: Shadows.LIST_ITEM.offsetY
            })
            .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: 12 })

            Column() {
              MenuItemRow({
                iconName: 'sys.symbol.trash',
                label: '清除所有数据',
                showArrow: false,
                onAction: () => {
                  this.showClearDialog();
                }
              })
            }
            .width('100%')
            .backgroundColor(Colors.CARD_BG)
            .borderRadius(Radius.CARD)
            .shadow({
              radius: Shadows.LIST_ITEM.radius,
              color: Shadows.LIST_ITEM.color,
              offsetX: Shadows.LIST_ITEM.offsetX,
              offsetY: Shadows.LIST_ITEM.offsetY
            })
            .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: Spacing.ITEM_GAP })

            Column() {
              Text('数据管理说明')
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)

              Text('您可以导入、导出和恢复房源数据。所有数据存储在本地设备中，清除操作不可恢复，请谨慎操作。')
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(Colors.TEXT_SECONDARY)
                .fontFamily(Fonts.CN)
                .lineHeight(22)
                .margin({ top: 12 })
                .alignSelf(ItemAlign.Start)
            }
            .width('100%')
            .backgroundColor(Colors.CARD_BG)
            .borderRadius(Radius.CARD)
            .padding(Spacing.CARD_PADDING)
            .shadow({
              radius: Shadows.LIST_ITEM.radius,
              color: Shadows.LIST_ITEM.color,
              offsetX: Shadows.LIST_ITEM.offsetX,
              offsetY: Shadows.LIST_ITEM.offsetY
            })
            .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: Spacing.ITEM_GAP })
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Colors.BG_PRIMARY)
    }
    .hideTitleBar(true)
  }

  private showClearDialog(): void {
    AlertDialog.show({
      message: '确认清除所有房源数据？此操作不可恢复。',
      primaryButton: {
        value: '确认清除',
        action: () => {}
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    });
  }
}
