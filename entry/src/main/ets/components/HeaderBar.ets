/**
 * 通用页面标题栏 - 高度 56px
 * 迁移为 @ComponentV2+@Param 装饰器体系
 * 返回按钮使用 SymbolGlyph
 * @Event onBack 替代组件内部直接调用 router
 * @BuilderParam rightContent 支持自定义右侧内容
 */
import { Colors, Fonts, FontSizes, Dimensions, Spacing } from '../common/DesignTokens';

@ComponentV2
export struct HeaderBar {
  @Param title: string = '';
  @Param showBack: boolean = false;
  @Event onBack: () => void = () => {};
  @BuilderParam rightContent: () => void = this.DefaultRightContent;

  @Builder
  DefaultRightContent() {
    Row().width(24)
  }

  build() {
    Row() {
      if (this.showBack) {
        // 返回按钮
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(20)
            .fontColor([Colors.PRIMARY])
        }
        .padding({ left: Spacing.CARD_PADDING_SM })
        .onClick(() => {
          this.onBack();
        })
      }

      Text(this.title)
        .fontSize(FontSizes.PAGE_TITLE)
        .fontColor(Colors.TEXT_PRIMARY)
        .fontFamily(Fonts.CN)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(this.showBack ? TextAlign.Center : TextAlign.Start)
        .margin({ left: this.showBack ? 0 : Spacing.PAGE_HORIZONTAL })

      // 右侧自定义内容
      this.rightContent()
    }
    .width('100%')
    .height(Dimensions.HEADER_HEIGHT)
    .padding({ right: Spacing.PAGE_HORIZONTAL })
    .alignItems(VerticalAlign.Center)
  }
}
