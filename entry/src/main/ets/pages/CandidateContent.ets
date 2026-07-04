import { Colors, Fonts, FontSizes, Dimensions, Radius, Shadows, Spacing, getTagTextColor, getTagBgColor } from '../common/DesignTokens';
import { PropertyInfo, PropertyIdParam } from '../model/PropertyModel';
import { HomeViewModel } from '../viewmodel/HomeViewModel';

@ComponentV2
export struct CandidateContent {
  @Local viewModel: HomeViewModel = new HomeViewModel();
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @Consumer('refreshFlag') refreshFlag: number = 0;

  @Monitor('refreshFlag')
  onRefreshFlagChange(): void {
    this.viewModel.loadData();
  }

  aboutToAppear(): void {
    this.viewModel.loadData();
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column() {
          Row() {
            Text('备选房源')
              .fontSize(FontSizes.PAGE_TITLE)
              .fontColor(Colors.TEXT_PRIMARY)
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Bold)

            Blank()
          }
          .width('100%')
          .height(Dimensions.HEADER_HEIGHT)
          .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })

          Column() {
            Row() {
              SymbolGlyph($r('sys.symbol.map'))
                .fontSize(32)
                .fontColor([Colors.TEXT_MUTED])

              Text('地图组件占位')
                .fontSize(FontSizes.BODY)
                .fontColor(Colors.TEXT_MUTED)
                .fontFamily(Fonts.CN)
                .margin({ left: 12 })
            }
            .width('100%')
            .height(Dimensions.MAP_CARD_HEIGHT)
            .backgroundColor(Colors.BG_PRIMARY)
            .borderRadius(Radius.CARD)
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })

          if (this.viewModel.candidateProperties.length === 0) {
            Column() {
              SymbolGlyph($r('sys.symbol.magnifyingglass'))
                .fontSize(36)
                .fontColor([Colors.TEXT_MUTED])

              Text('暂无备选，点击 + 添加看房候选')
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(Colors.TEXT_MUTED)
                .fontFamily(Fonts.CN)
                .margin({ top: 12 })
            }
            .width('100%')
            .height(120)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Colors.CARD_BG)
            .borderRadius(Radius.CARD)
            .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: Spacing.ITEM_GAP })
          } else {
            List({ space: 12 }) {
              ForEach(this.viewModel.candidateProperties, (property: PropertyInfo) => {
                ListItem() {
                  CandidateCard({ property: property })
                }
                .swipeAction({ end: { builder: () => { this.candidateSwipeAction(property.id) } } })
              }, (item: PropertyInfo) => item.id)
            }
            .width('100%')
            .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })
            .margin({ top: Spacing.ITEM_GAP })
            .listDirection(Axis.Vertical)
            .scrollBar(BarState.Off)
            .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
          }

          Column().height(96)
        }
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.TopStart)

      Button() {
        SymbolGlyph($r('sys.symbol.plus'))
          .fontSize(24)
          .fontColor([Colors.TEXT_WHITE])
      }
      .width(Dimensions.FAB_SIZE)
      .height(Dimensions.FAB_SIZE)
      .backgroundColor(Colors.PRIMARY)
      .borderRadius(28)
      .shadow({
        radius: Shadows.TAB_BAR.radius,
        color: 'rgba(80,70,229,0.4)',
        offsetX: 0,
        offsetY: 4
      })
      .margin({ right: Spacing.PAGE_HORIZONTAL, bottom: 20 })
      .onClick(() => {
        const addParam: PropertyIdParam = new PropertyIdParam();
        addParam.mode = 'candidate';
        this.navPathStack.pushPathByName('AddProperty', addParam);
      })
    }
    .layoutWeight(1)
  }

  @Builder
  candidateSwipeAction(propertyId: string) {
    Row() {
      Button('选定')
        .fontSize(FontSizes.BODY)
        .fontColor(Colors.TEXT_WHITE)
        .fontFamily(Fonts.CN)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(Colors.SUCCESS)
        .borderRadius(0)
        .height('100%')
        .width(72)
        .onClick(() => {
          this.viewModel.promoteCandidate(propertyId);
        })

      Button('删除')
        .fontSize(FontSizes.BODY)
        .fontColor(Colors.TEXT_WHITE)
        .fontFamily(Fonts.CN)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(Colors.DANGER)
        .borderRadius(0)
        .height('100%')
        .width(72)
        .onClick(() => {
          this.viewModel.deleteProperty(propertyId);
        })
    }
  }
}

@ComponentV2
struct CandidateCard {
  @Param property: PropertyInfo = new PropertyInfo();
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  build() {
    Column() {
      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.house'))
            .fontSize(22)
            .fontColor([Colors.WARNING])
        }
        .width(48)
        .height(48)
        .backgroundColor(Colors.WARNING_LIGHT)
        .borderRadius(Radius.ICON_BG)
        .justifyContent(FlexAlign.Center)

        Column() {
          Text(this.property.name)
            .fontSize(FontSizes.BODY_LARGE)
            .fontColor(Colors.TEXT_PRIMARY)
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (this.property.address.length > 0) {
            Text(this.property.address)
              .fontSize(FontSizes.BODY_SMALL)
              .fontColor(Colors.TEXT_SECONDARY)
              .fontFamily(Fonts.CN)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: 4 })
          }
        }
        .layoutWeight(1)
        .margin({ left: 12 })

        Text('备选')
          .fontSize(FontSizes.CAPTION)
          .fontColor(Colors.TEXT_MUTED)
          .fontFamily(Fonts.CN)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

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
        .width('100%')
        .margin({ top: 10 })
      }
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
