/**
 * 关于页 - NavDestination 页面
 * 使用 @ComponentV2 装饰器
 * 统一使用 HeaderBar 组件
 * Emoji 替换为 SymbolGlyph
 * 通过 @Consumer 获取 navPathStack 用于返回操作
 */
import { Colors, Fonts, FontSizes, Dimensions, Radius, Spacing } from '../common/DesignTokens';
import { HeaderBar } from '../components/HeaderBar';

@Builder
export function AboutBuilder() {
  AboutPage()
}

@ComponentV2
export struct AboutPage {
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        HeaderBar({
          title: '关于',
          showBack: true,
          onBack: () => {
            this.navPathStack.pop();
          }
        })

        // 居中内容
        Column() {
          // App 图标
          Row() {
            SymbolGlyph($r('sys.symbol.house'))
              .fontSize(36)
              .fontColor([Colors.TEXT_WHITE])
          }
          .width(Dimensions.APP_ICON_SIZE)
          .height(Dimensions.APP_ICON_SIZE)
          .backgroundColor(Colors.PRIMARY)
          .borderRadius(Radius.APP_ICON)
          .justifyContent(FlexAlign.Center)
          .margin({ top: 120 })

          // App 名称
          Text('租房台账')
            .fontSize(FontSizes.TITLE_LARGE)
            .fontColor(Colors.TEXT_PRIMARY)
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 16 })

          // 版本号
          Text('版本 1.0.0')
            .fontSize(FontSizes.BODY)
            .fontColor(Colors.TEXT_MUTED)
            .fontFamily(Fonts.CN)
            .margin({ top: 16 })

          // 描述
          Text('华为鸿蒙租房记录元服务\n轻松管理租房台账，到期智能提醒')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(Colors.TEXT_SECONDARY)
            .fontFamily(Fonts.CN)
            .textAlign(TextAlign.Center)
            .lineHeight(20)
            .width(195)
            .margin({ top: 16 })

          // 版权信息
          Text('© 2026 子悦 · 个人商用\n保留所有权利')
            .fontSize(FontSizes.CAPTION)
            .fontColor(Colors.TEXT_MUTED)
            .fontFamily(Fonts.CN)
            .textAlign(TextAlign.Center)
            .lineHeight(18)
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Colors.BG_PRIMARY)
    }
    .hideTitleBar(true)
  }
}
