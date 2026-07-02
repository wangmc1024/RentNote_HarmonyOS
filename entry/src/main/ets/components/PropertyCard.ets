/**
 * 房源列表卡片组件
 * 迁移为 @ComponentV2+@Param 装饰器体系
 * 点击时通过 @Consumer 获取 navPathStack 并调用 pushPathByName
 */
import { Colors, Fonts, FontSizes, Radius, Shadows, Spacing } from '../common/DesignTokens';
import { PropertyInfo, PropertyIdParam } from '../model/PropertyModel';

@ComponentV2
export struct PropertyCard {
  @Param property: PropertyInfo = new PropertyInfo();
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  build() {
    Row() {
      // 左侧图标
      Row() {
        SymbolGlyph($r('sys.symbol.building'))
          .fontSize(22)
          .fontColor([Colors.PRIMARY])
      }
      .width(48)
      .height(48)
      .backgroundColor(Colors.PRIMARY_LIGHT)
      .borderRadius(Radius.ICON_BG)
      .justifyContent(FlexAlign.Center)

      // 中间信息
      Column() {
        Text(this.property.name)
          .fontSize(FontSizes.BODY_LARGE)
          .fontColor(Colors.TEXT_PRIMARY)
          .fontFamily(Fonts.CN)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(this.property.address)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(Colors.TEXT_SECONDARY)
            .fontFamily(Fonts.CN)

          Blank()

          Text(this.property.startDate + ' - ' + this.property.endDate)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(Colors.TEXT_SECONDARY)
            .fontFamily(Fonts.NUMBER)
        }
        .width('100%')
        .margin({ top: 4 })
      }
      .layoutWeight(1)
      .margin({ left: 12 })

      // 右侧租金
      Text('¥' + this.property.monthlyRent.toLocaleString())
        .fontSize(FontSizes.PAGE_TITLE)
        .fontColor(Colors.PRIMARY)
        .fontFamily(Fonts.NUMBER)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .height(80)
    .backgroundColor(Colors.CARD_BG)
    .borderRadius(Radius.CARD)
    .padding({ left: Spacing.CARD_PADDING, right: Spacing.CARD_PADDING })
    .shadow({
      radius: Shadows.CARD.radius,
      color: Shadows.CARD.color,
      offsetX: Shadows.CARD.offsetX,
      offsetY: Shadows.CARD.offsetY
    })
    .onClick(() => {
      const detailParam: PropertyIdParam = { propertyId: this.property.id };
      this.navPathStack.pushPathByName('PropertyDetail', detailParam);
    })
  }
}
