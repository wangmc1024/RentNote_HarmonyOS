/**
 * 首页 Tab 内容区 - 从原 Index.ets 抽取
 * 使用 @ComponentV2+@Local 装饰器
 * 通过 ViewModel 加载房源列表
 * @Consumer 获取 navPathStack 用于子页面跳转
 */
import { Colors, Fonts, FontSizes, Dimensions, Radius, Shadows, Spacing } from '../common/DesignTokens';
import { PropertyCard } from '../components/PropertyCard';
import { PropertyInfo } from '../model/PropertyModel';
import { HomeViewModel } from '../viewmodel/HomeViewModel';

@ComponentV2
export struct HomeContent {
  @Local viewModel: HomeViewModel = new HomeViewModel();
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.viewModel.loadData();
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column() {
          // ===== 标题栏 =====
          Row() {
            Text('租房台账')
              .fontSize(FontSizes.PAGE_TITLE)
              .fontColor(Colors.TEXT_PRIMARY)
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Bold)

            Blank()

            // 头像
            Row() {
              Text('子')
                .fontSize(14)
                .fontColor(Colors.TEXT_WHITE)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Bold)
            }
            .width(32)
            .height(32)
            .backgroundColor(Colors.PRIMARY)
            .borderRadius(16)
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height(Dimensions.HEADER_HEIGHT)
          .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })

          // ===== 月度租金概览卡片 =====
          Column() {
            Row() {
              Text('本月租金')
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(Colors.TEXT_SECONDARY)
                .fontFamily(Fonts.CN)
            }

            Text('¥' + this.viewModel.totalMonthlyExpense.toLocaleString())
              .fontSize(40)
              .fontColor(Colors.PRIMARY)
              .fontFamily(Fonts.NUMBER)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 8 })

            Row() {
              Text('2024.01 — 2026.01')
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(Colors.TEXT_MUTED)
                .fontFamily(Fonts.NUMBER)
            }
            .margin({ top: 8 })
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
          .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: 12 })

          // ===== 指标卡片行 =====
          Row() {
            // 在租房源
            Column() {
              Text(this.viewModel.properties.length.toString())
                .fontSize(22)
                .fontColor(Colors.SUCCESS)
                .fontFamily(Fonts.NUMBER)
                .fontWeight(FontWeight.Bold)

              Text('在租房源')
                .fontSize(FontSizes.CAPTION)
                .fontColor(Colors.TEXT_SECONDARY)
                .fontFamily(Fonts.CN)
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .height(72)
            .backgroundColor(Colors.CARD_BG)
            .borderRadius(Radius.CARD)
            .justifyContent(FlexAlign.Center)
            .shadow({
              radius: Shadows.CARD.radius,
              color: Shadows.CARD.color,
              offsetX: Shadows.CARD.offsetX,
              offsetY: Shadows.CARD.offsetY
            })

            Column().width(12)

            // 即将到期
            Column() {
              Text(this.viewModel.expiringCount.toString())
                .fontSize(22)
                .fontColor(Colors.WARNING)
                .fontFamily(Fonts.NUMBER)
                .fontWeight(FontWeight.Bold)

              Text('即将到期')
                .fontSize(FontSizes.CAPTION)
                .fontColor(Colors.TEXT_SECONDARY)
                .fontFamily(Fonts.CN)
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .height(72)
            .backgroundColor(Colors.CARD_BG)
            .borderRadius(Radius.CARD)
            .justifyContent(FlexAlign.Center)
            .shadow({
              radius: Shadows.CARD.radius,
              color: Shadows.CARD.color,
              offsetX: Shadows.CARD.offsetX,
              offsetY: Shadows.CARD.offsetY
            })

            Column().width(12)

            // 本月支出
            Column() {
              Text('¥' + this.viewModel.totalMonthlyExpense.toLocaleString())
                .fontSize(22)
                .fontColor(Colors.PRIMARY)
                .fontFamily(Fonts.NUMBER)
                .fontWeight(FontWeight.Bold)

              Text('本月支出')
                .fontSize(FontSizes.CAPTION)
                .fontColor(Colors.TEXT_SECONDARY)
                .fontFamily(Fonts.CN)
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .height(72)
            .backgroundColor(Colors.CARD_BG)
            .borderRadius(Radius.CARD)
            .justifyContent(FlexAlign.Center)
            .shadow({
              radius: Shadows.CARD.radius,
              color: Shadows.CARD.color,
              offsetX: Shadows.CARD.offsetX,
              offsetY: Shadows.CARD.offsetY
            })
          }
          .width('100%')
          .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })
          .margin({ top: 12 })

          // ===== 房源列表区域 =====
          Row() {
            Text('房源列表')
              .fontSize(FontSizes.SECTION_TITLE)
              .fontColor(Colors.TEXT_PRIMARY)
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Bold)
          }
          .width('100%')
          .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })
          .margin({ top: Spacing.SECTION_GAP })

          // 房源卡片列表 / 空状态
          if (this.viewModel.properties.length === 0) {
            // 空状态占位提示
            Column() {
              SymbolGlyph($r('sys.symbol.building'))
                .fontSize(48)
                .fontColor([Colors.TEXT_MUTED])

              Text('暂无房源，点击添加')
                .fontSize(FontSizes.BODY)
                .fontColor(Colors.TEXT_MUTED)
                .fontFamily(Fonts.CN)
                .margin({ top: 16 })
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
            .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })
          } else {
            ForEach(this.viewModel.properties, (property: PropertyInfo) => {
              PropertyCard({ property: property })
                .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, bottom: 12 })
            }, (item: PropertyInfo) => item.id)
          }

          // 底部留白
          Column().height(96)
        }
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.TopStart)

      // ===== FAB 添加按钮 =====
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
        this.navPathStack.pushPathByName('AddProperty', null);
      })
    }
    .layoutWeight(1)
  }
}
