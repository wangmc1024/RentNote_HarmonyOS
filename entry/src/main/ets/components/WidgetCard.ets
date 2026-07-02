/**
 * 桌面卡片组件 - 鸿蒙 Form Widget
 * 设计尺寸: 350×160
 * 横向布局：左侧快捷添加按钮 + 右侧租金/到期信息
 *
 * 此组件用于 FormExtensionAbility 中的 Widget 卡片渲染
 * 需要在项目中单独配置 form_config.json
 */
import { Colors, Fonts, FontSizes, Radius, Spacing } from '../common/DesignTokens';

@Component
export struct WidgetCard {
  build() {
    Row() {
      // 左侧：快捷添加按钮
      Column() {
        Text('+')
          .fontSize(32)
          .fontColor(Colors.TEXT_WHITE)
          .fontFamily(Fonts.NUMBER)
          .fontWeight(FontWeight.Light)

        Text('快捷添加')
          .fontSize(FontSizes.CAPTION)
          .fontColor(Colors.TEXT_WHITE)
          .fontFamily(Fonts.CN)
          .margin({ top: 4 })
      }
      .width(80)
      .height(120)
      .backgroundColor(Colors.PRIMARY)
      .borderRadius(24)
      .justifyContent(FlexAlign.Center)
      .margin({ left: Spacing.CARD_PADDING })

      // 右侧：租金信息
      Column() {
        Text('¥6,250')
          .fontSize(32)
          .fontColor(Colors.TEXT_PRIMARY)
          .fontFamily(Fonts.NUMBER)
          .fontWeight(FontWeight.Bold)

        Text('本月租金')
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(Colors.TEXT_SECONDARY)
          .fontFamily(Fonts.CN)
          .margin({ top: 4 })

        Text('2024.12.31 到期')
          .fontSize(FontSizes.CAPTION)
          .fontColor(Colors.WARNING)
          .fontFamily(Fonts.NUMBER)
          .margin({ top: 6 })
      }
      .layoutWeight(1)
      .height(120)
      .margin({ left: Spacing.CONTENT_GAP })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
    }
    .width(350)
    .height(160)
    .backgroundColor(Colors.CARD_BG)
    .borderRadius(Radius.CARD)
    .shadow({
      radius: 20,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 4
    })
  }
}
