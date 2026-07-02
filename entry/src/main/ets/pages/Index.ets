/**
 * 首页 - Navigation+Tabs 容器入口
 * 使用 @ComponentV2+@Local 装饰器
 * 创建 NavPathStack 并通过 @Provider 共享给子组件
 * 底部 Tab 栏使用 Tabs 内置 tabBar 配合 SymbolGlyph 系统图标
 * 路由通过 route_map.json 配置，不再使用 navDestination
 */
import { Colors, Fonts, FontSizes, Dimensions, Radius, Spacing } from '../common/DesignTokens';
import { HomeContent } from './HomeContent';
import { StatisticsContent } from './StatisticsContent';
import { MyContent } from './MyContent';
import { PropertyRepository } from '../repository/PropertyRepository';
import { AppStorageV2 } from '@kit.ArkUI';

@Entry
@ComponentV2
struct Index {
  @Provider('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @Local currentTab: number = 0;

  // 初始化全局 Repository
  private repository: PropertyRepository = AppStorageV2.connect(PropertyRepository, () => new PropertyRepository())!;

  build() {
    Navigation(this.navPathStack) {
      Tabs({ barPosition: BarPosition.End, index: this.currentTab }) {
        TabContent() {
          HomeContent()
        }
        .tabBar(this.TabBuilder(0, $r('sys.symbol.house'), '首页'))

        TabContent() {
          StatisticsContent()
        }
        .tabBar(this.TabBuilder(1, $r('sys.symbol.calendar'), '统计'))

        TabContent() {
          MyContent()
        }
        .tabBar(this.TabBuilder(2, $r('sys.symbol.person'), '我的'))
      }
      .barWidth(Dimensions.TAB_PILL_WIDTH)
      .barHeight(Dimensions.TAB_PILL_HEIGHT)
      .barBackgroundColor(Colors.CARD_BG)
      .borderRadius(Radius.TAB_PILL_OUTER)
      .margin({ bottom: Dimensions.TAB_PILL_MARGIN })
      .onChange((index: number) => {
        this.currentTab = index;
      })
    }
    .hideToolBar(true)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }

  @Builder
  TabBuilder(index: number, icon: Resource, label: string) {
    Column() {
      SymbolGlyph(icon)
        .fontSize(16)
        .fontColor([this.currentTab === index ? Colors.TEXT_WHITE : Colors.TEXT_SECONDARY])

      Text(label)
        .fontSize(FontSizes.TAB_LABEL)
        .fontFamily(Fonts.CN)
        .fontColor(this.currentTab === index ? Colors.TEXT_WHITE : Colors.TEXT_SECONDARY)
        .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)
        .margin({ top: 2 })
    }
    .width(54)
    .height(54)
    .justifyContent(FlexAlign.Center)
    .borderRadius(Radius.TAB_PILL_INNER)
    .backgroundColor(this.currentTab === index ? Colors.PRIMARY : Color.Transparent)
  }
}
