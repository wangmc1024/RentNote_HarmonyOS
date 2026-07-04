import { Colors, Fonts, FontSizes, Radius, Shadows, Spacing, getTagTextColor, getTagBgColor } from '../common/DesignTokens';
import { PropertyInfo, PropertyIdParam } from '../model/PropertyModel';

@ComponentV2
export struct PropertyCard {
  @Param property: PropertyInfo = new PropertyInfo();
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  build() {
    Column() {
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

          Text(this.property.address)
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(Colors.TEXT_SECONDARY)
            .fontFamily(Fonts.CN)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .margin({ left: 12 })

        // 右侧租金
        Column() {
          Text('¥' + this.property.monthlyRent.toLocaleString())
            .fontSize(FontSizes.PAGE_TITLE)
            .fontColor(Colors.PRIMARY)
            .fontFamily(Fonts.NUMBER)
            .fontWeight(FontWeight.Bold)

          Text('/月')
            .fontSize(FontSizes.CAPTION)
            .fontColor(Colors.TEXT_MUTED)
            .fontFamily(Fonts.CN)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      // 标签 + 日期行
      Row() {
        // 标签
        if (this.property.tags.length > 0) {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.property.tags, (tag: string) => {
              Text(tag)
                .fontSize(FontSizes.CAPTION)
                .fontColor(getTagTextColor(tag))
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                .backgroundColor(getTagBgColor(tag))
                .borderRadius(Radius.TAG)
                .margin({ right: 6, top: 4 })
            }, (item: string) => item)
          }
        }

        Blank()

        // 日期
        Text(this.property.startDate + ' - ' + this.property.endDate)
          .fontSize(FontSizes.CAPTION)
          .fontColor(Colors.TEXT_MUTED)
          .fontFamily(Fonts.NUMBER)
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .backgroundColor(Colors.CARD_BG)
    .borderRadius(Radius.CARD)
    .padding(Spacing.CARD_PADDING)
    .shadow({
      radius: Shadows.CARD.radius,
      color: Shadows.CARD.color,
      offsetX: Shadows.CARD.offsetX,
      offsetY: Shadows.CARD.offsetY
    })
    .onClick(() => {
      const detailParam: PropertyIdParam = { propertyId: this.property.id, mode: '' };
      this.navPathStack.pushPathByName('PropertyDetail', detailParam);
    })
  }
}
