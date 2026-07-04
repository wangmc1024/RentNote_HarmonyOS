/**
 * 我的 Tab 内容区 - 从原 MyPage.ets 改造
 * 使用 @ComponentV2+@Local 装饰器
 * @Consumer navPathStack 用于跳转设置/关于页
 * 移除 @State currentTab 和独立的 HeaderBar
 */
import { Colors, Fonts, FontSizes, Dimensions, Radius, Shadows, Spacing } from '../common/DesignTokens';
import { MenuItemRow } from '../components/MenuItemRow';
import { HomeViewModel } from '../viewmodel/HomeViewModel';

@ComponentV2
export struct MyContent {
  @Local viewModel: HomeViewModel = new HomeViewModel();
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.viewModel.loadData();
  }

  build() {
    Scroll() {
      Column() {
        // 标题栏
        Row() {
          Text('我的')
            .fontSize(FontSizes.PAGE_TITLE)
            .fontColor(Colors.TEXT_PRIMARY)
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Bold)

          Blank()
        }
        .width('100%')
        .height(Dimensions.HEADER_HEIGHT)
        .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })

        // ===== 个人资料卡片 =====
        Column() {
          // 头像行
          Row() {
            Row() {
              Text('子')
                .fontSize(26)
                .fontColor(Colors.TEXT_WHITE)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Bold)
            }
            .width(Dimensions.AVATAR_SIZE)
            .height(Dimensions.AVATAR_SIZE)
            .backgroundColor(Colors.PRIMARY)
            .borderRadius(Radius.AVATAR)
            .justifyContent(FlexAlign.Center)

            Column() {
              Text('子悦')
                .fontSize(20)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Bold)

              Text('华为开发者 · 个人商用')
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(Colors.TEXT_SECONDARY)
                .fontFamily(Fonts.CN)
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .margin({ left: Spacing.CONTENT_GAP })
          }
          .width('100%')
          .padding({ left: 24, right: 24, top: 24 })

          // 分割线
          Divider()
            .color(Colors.DIVIDER_DARK)
            .strokeWidth(0.5)
            .margin({ left: 24, right: 24, top: 16, bottom: 16 })

          // 统计数字行
          Row() {
            Column() {
              Text(this.viewModel.rentingProperties.length.toString())
                .fontSize(22)
                .fontColor(Colors.PRIMARY)
                .fontFamily(Fonts.NUMBER)
                .fontWeight(FontWeight.Bold)

              Text('在租房源')
                .fontSize(FontSizes.CAPTION)
                .fontColor(Colors.TEXT_SECONDARY)
                .fontFamily(Fonts.CN)
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Column()
              .width(1)
              .height(40)
              .backgroundColor(Colors.DIVIDER_DARK)

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
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Column()
              .width(1)
              .height(40)
              .backgroundColor(Colors.DIVIDER_DARK)

            Column() {
              Text('12')
                .fontSize(22)
                .fontColor(Colors.SUCCESS)
                .fontFamily(Fonts.NUMBER)
                .fontWeight(FontWeight.Bold)

              Text('历史房源')
                .fontSize(FontSizes.CAPTION)
                .fontColor(Colors.TEXT_SECONDARY)
                .fontFamily(Fonts.CN)
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .padding({ left: 24, right: 24, bottom: 24 })
        }
        .width('100%')
        .backgroundColor(Colors.CARD_BG)
        .borderRadius(Radius.CARD)
        .shadow({
          radius: Shadows.CARD.radius,
          color: Shadows.CARD.color,
          offsetX: Shadows.CARD.offsetX,
          offsetY: Shadows.CARD.offsetY
        })
        .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: 12 })

        // ===== 菜单卡片 1 =====
        Column() {
          MenuItemRow({
            iconName: 'sys.symbol.tray_and_arrow_down',
            label: '数据导入',
            onAction: () => {
              this.navPathStack.pushPathByName('DataImport', null);
            }
          })
          Divider().color(Colors.DIVIDER_LIGHT).strokeWidth(0.5).margin({ left: 20, right: 20 })
          MenuItemRow({
            iconName: 'sys.symbol.arrow_clockwise',
            label: '数据恢复',
            onAction: () => {
              this.navPathStack.pushPathByName('DataRestore', null);
            }
          })
          Divider().color(Colors.DIVIDER_LIGHT).strokeWidth(0.5).margin({ left: 20, right: 20 })
          MenuItemRow({
            iconName: 'sys.symbol.share',
            label: '导出数据',
            onAction: () => {
              this.navPathStack.pushPathByName('DataExport', null);
            }
          })
        }
        .width('100%')
        .backgroundColor(Colors.CARD_BG)
        .borderRadius(Radius.CARD)
        .shadow({
          radius: Shadows.LIST_ITEM.radius,
          color: Shadows.LIST_ITEM.color,
          offsetX: Shadows.LIST_ITEM.offsetX,
          offsetY: Shadows.LIST_ITEM.offsetY
        })
        .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: Spacing.ITEM_GAP })

        // ===== 菜单卡片 2 =====
        Column() {
          MenuItemRow({
            iconName: 'sys.symbol.gear',
            label: '设置',
            onAction: () => {
              this.navPathStack.pushPathByName('Settings', null);
            }
          })
          Divider().color(Colors.DIVIDER_LIGHT).strokeWidth(0.5).margin({ left: 20, right: 20 })
          MenuItemRow({
            iconName: 'sys.symbol.info',
            label: '关于',
            onAction: () => {
              this.navPathStack.pushPathByName('About', null);
            }
          })
        }
        .width('100%')
        .backgroundColor(Colors.CARD_BG)
        .borderRadius(Radius.CARD)
        .shadow({
          radius: Shadows.LIST_ITEM.radius,
          color: Shadows.LIST_ITEM.color,
          offsetX: Shadows.LIST_ITEM.offsetX,
          offsetY: Shadows.LIST_ITEM.offsetY
        })
        .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: 16 })

        // 页脚
        Text('租房台账 v1.0 · 华为鸿蒙元服务')
          .fontSize(FontSizes.CAPTION)
          .fontColor(Colors.TEXT_MUTED)
          .fontFamily(Fonts.CN)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: 28, bottom: 32 })
      }
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(1)
  }
}
