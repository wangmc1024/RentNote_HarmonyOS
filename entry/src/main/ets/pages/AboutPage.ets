/**
 * 关于页 - NavDestination 页面
 * 使用 @ComponentV2 装饰器
 * 统一使用 HeaderBar 组件
 * Emoji 替换为 SymbolGlyph
 * 通过 @Consumer 获取 navPathStack 用于返回操作
 */
import { Colors, Fonts, FontSizes, Dimensions, Radius } from '../common/DesignTokens';
import { AppInfo } from '../common/AppInfo';
import { HeaderBar } from '../components/HeaderBar';

@Builder
export function AboutBuilder() {
  AboutPage()
}
@Entry
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
            Image($r('app.media.app_icon'))
              .width(100)
              .height(100)
          }
          .borderRadius(Radius.APP_ICON)
          .justifyContent(FlexAlign.Center)
          .margin({ top: 120 })

          // App 名称
          Text(AppInfo.NAME)
            .fontSize(FontSizes.TITLE_LARGE)
            .fontColor(Colors.TEXT_PRIMARY)
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 16 })

          // 版本号
          Text(AppInfo.VERSION_LABEL)
            .fontSize(FontSizes.BODY)
            .fontColor(Colors.TEXT_MUTED)
            .fontFamily(Fonts.CN)
            .margin({ top: 16 })

          // 描述
          Text(AppInfo.DESCRIPTION)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(Colors.TEXT_SECONDARY)
            .fontFamily(Fonts.CN)
            .textAlign(TextAlign.Center)
            .lineHeight(20)
            .width(195)
            .margin({ top: 16 })

          // 版权信息
          Text(AppInfo.COPYRIGHT)
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
