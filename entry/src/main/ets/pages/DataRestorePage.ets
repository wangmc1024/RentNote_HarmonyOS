import { Colors, Fonts, FontSizes, Radius, Shadows, Spacing } from '../common/DesignTokens';
import { HeaderBar } from '../components/HeaderBar';
import { MenuItemRow } from '../components/MenuItemRow';

@Builder
export function DataRestoreBuilder() {
  DataRestorePage()
}

@ComponentV2
export struct DataRestorePage {
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        HeaderBar({
          title: '数据恢复',
          showBack: true,
          onBack: () => {
            this.navPathStack.pop();
          }
        })

        Scroll() {
          Column() {
            Column() {
              MenuItemRow({
                iconName: 'sys.symbol.cloud',
                label: '从云端恢复',
                onAction: () => {}
              })
              Divider().color(Colors.DIVIDER_LIGHT).strokeWidth(0.5).margin({ left: 20, right: 20 })
              MenuItemRow({
                iconName: 'sys.symbol.internaldrive',
                label: '从本地备份恢复',
                onAction: () => {}
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
              Text('恢复说明')
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)

              Text('1. 云端恢复：从华为云备份中恢复房源数据\n2. 本地恢复：从设备本地备份文件恢复\n3. 恢复操作将覆盖当前所有数据，请谨慎操作\n4. 建议在恢复前先导出当前数据作为备份')
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
}
