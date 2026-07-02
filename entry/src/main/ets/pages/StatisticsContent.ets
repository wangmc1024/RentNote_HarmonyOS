/**
 * 统计 Tab 内容区 - 从原 StatisticsPage.ets 改造
 * 使用 @ComponentV2+@Local 装饰器
 * 通过 StatisticsViewModel 加载统计概览和月度数据
 * 移除 @State currentTab 和 HeaderBar（Tab 内容不需要）
 */
import { Colors, Fonts, FontSizes, Dimensions, Radius, Shadows, Spacing } from '../common/DesignTokens';
import { SummaryCard } from '../components/SummaryCard';
import { BarChart } from '../components/BarChart';
import { StatisticsViewModel } from '../viewmodel/StatisticsViewModel';
import { PropertyInfo } from '../model/PropertyModel';

@ComponentV2
export struct StatisticsContent {
  @Local viewModel: StatisticsViewModel = new StatisticsViewModel();

  aboutToAppear(): void {
    this.viewModel.loadData();
  }

  build() {
    Scroll() {
      Column() {
        // 标题栏
        Row() {
          Text('统计')
            .fontSize(FontSizes.PAGE_TITLE)
            .fontColor(Colors.TEXT_PRIMARY)
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Bold)

          Blank()
        }
        .width('100%')
        .height(Dimensions.HEADER_HEIGHT)
        .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })

        // 概览卡片行
        SummaryCard({
          yearlyExpense: this.viewModel.overview.yearlyExpense,
          monthlyAvgRent: this.viewModel.overview.monthlyAvgRent,
          rentingCount: this.viewModel.overview.rentingCount
        })
          .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: 12 })

        // 图表卡片
        Column() {
          Text('近6个月租金趋势')
            .fontSize(FontSizes.SECTION_TITLE)
            .fontColor(Colors.TEXT_PRIMARY)
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start)
            .margin({ left: Spacing.CARD_PADDING, top: Spacing.CARD_PADDING })

          BarChart({
            data: this.viewModel.monthlyData
          })
            .margin({ top: 16 })
        }
        .width('100%')
        .backgroundColor(Colors.CARD_BG)
        .borderRadius(Radius.CARD)
        .padding({ bottom: Spacing.CARD_PADDING })
        .shadow({
          radius: Shadows.CARD.radius,
          color: Shadows.CARD.color,
          offsetX: Shadows.CARD.offsetX,
          offsetY: Shadows.CARD.offsetY
        })
        .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: Spacing.ITEM_GAP })

        // 即将到期区域
        if (this.viewModel.expiringProperties.length > 0) {
          Text('即将到期')
            .fontSize(FontSizes.SECTION_TITLE)
            .fontColor(Colors.TEXT_PRIMARY)
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start)
            .margin({ left: Spacing.PAGE_HORIZONTAL, top: Spacing.SECTION_GAP })

          // 到期卡片列表
          ForEach(this.viewModel.expiringProperties, (property: PropertyInfo) => {
            Row() {
              // 图标
              Row() {
                SymbolGlyph($r('sys.symbol.calendar'))
                  .fontSize(20)
                  .fontColor([Colors.WARNING])
              }
              .width(44)
              .height(44)
              .backgroundColor(Colors.WARNING_LIGHT)
              .borderRadius(Radius.ICON_BG)
              .justifyContent(FlexAlign.Center)

              // 信息
              Column() {
                Text(property.name)
                  .fontSize(FontSizes.BODY_LARGE)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .fontFamily(Fonts.CN)
                  .fontWeight(FontWeight.Medium)

                Text(property.endDate + ' 到期')
                  .fontSize(FontSizes.BODY_SMALL)
                  .fontColor(Colors.WARNING)
                  .fontFamily(Fonts.NUMBER)
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              .margin({ left: Spacing.ITEM_GAP })
            }
            .width('100%')
            .height(77)
            .backgroundColor(Colors.CARD_BG)
            .borderRadius(Radius.CARD_SM)
            .padding({ left: Spacing.CARD_PADDING_SM, right: Spacing.CARD_PADDING_SM })
            .shadow({
              radius: Shadows.LIST_ITEM.radius,
              color: Shadows.LIST_ITEM.color,
              offsetX: Shadows.LIST_ITEM.offsetX,
              offsetY: Shadows.LIST_ITEM.offsetY
            })
            .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: Spacing.ITEM_GAP })
          }, (item: PropertyInfo) => item.id)
        }

        // 底部留白
        Column().height(96)
      }
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(1)
  }
}
