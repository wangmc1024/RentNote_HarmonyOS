import { Colors, Fonts, FontSizes, Radius, Shadows, Spacing } from '../common/DesignTokens';
import { HeaderBar } from '../components/HeaderBar';
import { MenuItemRow } from '../components/MenuItemRow';

@Builder
export function DataImportBuilder() {
  DataImportPage()
}

@ComponentV2
export struct DataImportPage {
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        HeaderBar({
          title: '数据导入',
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
                label: '从 JSON 文件导入',
                onAction: () => {}
              })
              Divider().color(Colors.DIVIDER_LIGHT).strokeWidth(0.5).margin({ left: 20, right: 20 })
              MenuItemRow({
                iconName: 'sys.symbol.tablecells',
                label: '从 CSV 文件导入',
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
              Text('导入说明')
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)

              Text('1. 选择要导入的文件格式\n2. 文件需包含房源名称、地址、月租金等必填字段\n3. 导入数据将与现有数据合并，重复项自动跳过\n4. 导入完成后可在首页查看新增房源')
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
