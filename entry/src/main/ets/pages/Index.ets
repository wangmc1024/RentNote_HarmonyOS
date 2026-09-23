import { Colors, Fonts, FontSizes, Dimensions, Radius } from '../common/DesignTokens';
import { HomeContent } from './HomeContent';
import { CandidateContent } from './CandidateContent';
import { MyContent } from './MyContent';
import { PropertyRepository } from '../repository/PropertyRepository';
import { PropertyIdParam, WidgetNavigateState } from '../model/PropertyModel';
import { ReminderService, ReminderState } from '../service/ReminderService';
import { AppStorageV2 } from '@kit.ArkUI';

@Entry
@ComponentV2
struct Index {
  @Provider('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @Provider('refreshFlag') refreshFlag: number = 0;
  @Local currentTab: number = 1;
  @Local widgetState: WidgetNavigateState = AppStorageV2.connect(WidgetNavigateState, 'widgetNav', () => new WidgetNavigateState())!;
  @Local reminderState: ReminderState = AppStorageV2.connect(ReminderState, 'reminderState', () => new ReminderState())!;

  private repository: PropertyRepository = PropertyRepository.getInstance();

  aboutToAppear(): void {
    this.navPathStack.setInterception({
      didShow: (from: NavDestinationContext | "navBar", to: NavDestinationContext | "navBar",
        operation: NavigationOperation, isAnimated: boolean) => {
        if (to === 'navBar') {
          this.refreshFlag++;
        }
      }
    });
    this.repository.checkAndResetBillsPaidMonthly();
    if (this.widgetState.action.length > 0) {
      this.onWidgetActionChange();
    }
    this.reminderState.pendingNotify = false;
    void ReminderService.getInstance().checkAndNotify();
  }

  onPageShow(): void {
    this.refreshFlag++;
  }


  @Monitor('widgetState.action')
  onWidgetActionChange(): void {
    if (this.widgetState.action === 'addProperty') {
      this.widgetState.action = '';
      const addParam: PropertyIdParam = new PropertyIdParam();
      addParam.mode = 'candidate';
      this.navPathStack.pushPathByName('AddProperty', addParam);
    } else if (this.widgetState.action === 'viewOverview') {
      this.widgetState.action = '';
      this.currentTab = 1;
      this.refreshFlag++;
    } else if (this.widgetState.action === 'viewCandidates') {
      this.widgetState.action = '';
      this.currentTab = 0;
      this.refreshFlag++;
    } else if (this.widgetState.action === 'deleteProperty') {
      this.widgetState.action = '';
      this.currentTab = 0;
      this.refreshFlag++;
    }
  }

  @Monitor('reminderState.pendingNotify')
  onReminderPendingChange(): void {
    if (this.reminderState.pendingNotify) {
      this.reminderState.pendingNotify = false;
      void ReminderService.getInstance().checkAndNotify();
    }
  }

  build() {
    Navigation(this.navPathStack) {
      Tabs({ barPosition: BarPosition.End, index: this.currentTab }) {
        TabContent() {
          CandidateContent()
        }
        .tabBar(this.TabBuilder(0, $r('sys.symbol.magnifyingglass'), '备选'))

        TabContent() {
          HomeContent()
        }
        .tabBar(this.TabBuilder(1, $r('sys.symbol.house'), 'Home'))

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
        this.refreshFlag++;
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
    .width(46)
    .height(46)
    .justifyContent(FlexAlign.Center)
    .borderRadius(Radius.TAB_PILL_INNER)
    .backgroundColor(this.currentTab === index ? Colors.PRIMARY : Color.Transparent)
  }
}
