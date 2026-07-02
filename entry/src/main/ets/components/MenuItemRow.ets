/**
 * 通用菜单项组件
 * Emoji 图标参数改为 SymbolGlyph 系统图标资源名
 * 内部使用 SymbolGlyph 组件渲染
 * 迁移为 @ComponentV2+@Param+@Event 装饰器体系
 * 点击事件通过 @Event 回调触发 navPathStack 操作
 */
import { Colors, Fonts, FontSizes, Spacing } from '../common/DesignTokens';

@ComponentV2
export struct MenuItemRow {
  @Param iconName: string = '';
  @Param label: string = '';
  @Param value: string = '';
  @Param showArrow: boolean = true;
  @Event onAction: () => void = () => {};

  build() {
    Row() {
      // 图标
      if (this.iconName) {
        SymbolGlyph($r(this.iconName))
          .fontSize(18)
          .fontColor([Colors.TEXT_PRIMARY])
      }

      // 标签
      Text(this.label)
        .fontSize(FontSizes.BODY_LARGE)
        .fontColor(Colors.TEXT_PRIMARY)
        .fontFamily(Fonts.CN)
        .fontWeight(FontWeight.Medium)
        .margin({ left: Spacing.ITEM_GAP })

      Blank()

      // 右侧数值
      if (this.value) {
        Text(this.value)
          .fontSize(FontSizes.BODY_SMALL)
          .fontColor(Colors.TEXT_MUTED)
          .fontFamily(Fonts.CN)
          .margin({ right: Spacing.ITEM_GAP })
      }

      // 箭头
      if (this.showArrow) {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(20)
          .fontColor([Colors.TEXT_MUTED])
          .rotate({ angle: 180 })
      }
    }
    .width('100%')
    .height(52)
    .padding({ left: Spacing.CARD_PADDING, right: Spacing.CARD_PADDING })
    .onClick(() => {
      this.onAction();
    })
  }
}
