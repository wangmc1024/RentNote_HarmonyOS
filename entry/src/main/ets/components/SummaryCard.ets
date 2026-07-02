/**
 * 统计概览卡片 - 3 列等宽
 * 迁移为 @ComponentV2+@Param 装饰器体系
 * 参数类型从 string 改为 number，显示时格式化为千分位
 */
import { Colors, Fonts, FontSizes, Radius, Shadows, Spacing } from '../common/DesignTokens';

@ComponentV2
export struct SummaryCard {
  @Param yearlyExpense: number = 0;
  @Param monthlyAvgRent: number = 0;
  @Param rentingCount: number = 0;

  /** 格式化数字为千分位 */
  private formatNumber(value: number): string {
    return value.toLocaleString();
  }

  build() {
    Row() {
      // 年度支出
      Column() {
        Text('年度支出')
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(Colors.TEXT_SECONDARY)
          .fontFamily(Fonts.CN)

        Text('¥' + this.formatNumber(this.yearlyExpense))
          .fontSize(FontSizes.PAGE_TITLE)
          .fontColor(Colors.PRIMARY)
          .fontFamily(Fonts.NUMBER)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .height(77)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .padding({ left: Spacing.CARD_PADDING_SM })

      // 月均租金
      Column() {
        Text('月均租金')
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(Colors.TEXT_SECONDARY)
          .fontFamily(Fonts.CN)

        Text('¥' + this.formatNumber(this.monthlyAvgRent))
          .fontSize(FontSizes.PAGE_TITLE)
          .fontColor(Colors.SUCCESS)
          .fontFamily(Fonts.NUMBER)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .height(77)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .padding({ left: Spacing.CARD_PADDING_SM })

      // 在租房源
      Column() {
        Text('在租房源')
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(Colors.TEXT_SECONDARY)
          .fontFamily(Fonts.CN)

        Text(this.rentingCount.toString() + '套')
          .fontSize(FontSizes.PAGE_TITLE)
          .fontColor(Colors.WARNING)
          .fontFamily(Fonts.NUMBER)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .height(77)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .padding({ left: Spacing.CARD_PADDING_SM })
    }
    .width('100%')
    .height(77)
    .backgroundColor(Colors.CARD_BG)
    .borderRadius(Radius.CARD)
    .shadow({
      radius: Shadows.CARD.radius,
      color: Shadows.CARD.color,
      offsetX: Shadows.CARD.offsetX,
      offsetY: Shadows.CARD.offsetY
    })
  }
}
