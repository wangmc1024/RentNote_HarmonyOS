/**
 * 柱状图组件 - 按数据比例渲染柱高
 * 月标签在底部，柱子高度与金额成正比
 * 迁移为 @ComponentV2+@Param 装饰器体系
 */
import { Colors, Fonts, FontSizes, Radius, Spacing } from '../common/DesignTokens';
import { MonthlyRentItem } from '../model/PropertyModel';

@ComponentV2
export struct BarChart {
  @Param data: MonthlyRentItem[] = [];
  // 图表最大高度（柱子区域）
  private readonly chartMaxHeight: number = 100;
  // 金额为 0 时的最小高度
  private readonly minHeight: number = 4;

  /** 计算最大金额 */
  private getMaxAmount(): number {
    let max: number = 0;
    for (const item of this.data) {
      if (item.amount > max) {
        max = item.amount;
      }
    }
    return max;
  }

  /** 计算柱高 */
  private getBarHeight(amount: number, maxAmount: number): number {
    if (maxAmount <= 0) {
      return this.minHeight;
    }
    if (amount <= 0) {
      return this.minHeight;
    }
    const height: number = (amount / maxAmount) * this.chartMaxHeight;
    return Math.max(height, this.minHeight);
  }

  build() {
    Row() {
      ForEach(this.data, (item: MonthlyRentItem) => {
        Column() {
          // 柱子
          Column()
            .width('100%')
            .height(this.getBarHeight(item.amount, this.getMaxAmount()))
            .backgroundColor(Colors.PRIMARY)
            .borderRadius(Radius.BAR)

          // 月份标签
          Text(item.month)
            .fontSize(FontSizes.CAPTION)
            .fontColor(Colors.TEXT_SECONDARY)
            .fontFamily(Fonts.CN)
            .margin({ top: 6 })
            .textAlign(TextAlign.Center)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.End)
      }, (item: MonthlyRentItem) => item.month)
    }
    .width('100%')
    .height(140)
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(VerticalAlign.Bottom)
    .padding({ left: Spacing.CARD_PADDING, right: Spacing.CARD_PADDING })
  }
}
