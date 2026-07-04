import { Colors, Fonts, FontSizes, Radius, Shadows, Spacing } from '../common/DesignTokens';
import { HeaderBar } from '../components/HeaderBar';
import { MenuItemRow } from '../components/MenuItemRow';

@Builder
export function DataExportBuilder() {
  DataExportPage()
}

@ComponentV2
export struct DataExportPage {
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        HeaderBar({
          title: '导出数据',
          showBack: true,
          onBack: () => {
            this.navPathStack.pop();
          }
        })

        Scroll() {
          Column() {
            Column() {
              MenuItemRow({
                iconName: 'sys.symbol.doc_text',
                label: '导出为 JSON',
                onAction: () => {}
              })
              Divider().color(Colors.DIVIDER_LIGHT).strokeWidth(0.5).margin({ left: 20, right: 20 })
              MenuItemRow({
                iconName: 'sys.symbol.tablecells',
                label: '导出为 CSV',
                onAction: () => {}
              })
              Divider().color(Colors.DIVIDER_LIGHT).strokeWidth(0.5).margin({ left: 20, right: 20 })
              MenuItemRow({
                iconName: 'sys.symbol.share',
                label: '分享到其他应用',
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
              Text('导出说明')
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)

              Text('1. JSON 格式保留完整数据结构，适合备份和导入\n2. CSV 格式可用 Excel 打开，适合数据分析和打印\n3. 分享功能可将数据发送到其他应用\n4. 导出包含所有在租和历史房源数据')
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
