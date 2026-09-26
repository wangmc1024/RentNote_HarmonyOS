import { UIAbility, Want, AbilityConstant, common } from '@kit.AbilityKit';
import { window, AppStorageV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { PropertyRepository } from '../repository/PropertyRepository';
import { WidgetNavigateState } from '../model/PropertyModel';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    console.info('[RentalTracker] EntryAbility onCreate');
    const repository: PropertyRepository = PropertyRepository.getInstance();
    await repository.init(this.context);
    this.handleWidgetAction(want);
  }

  onDestroy(): void {
    console.info('[RentalTracker] EntryAbility onDestroy');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.info('[RentalTracker] EntryAbility onNewWant');
    this.handleWidgetAction(want);
  }

  private handleWidgetAction(want: Want): void {
    const params: Record<string, Object> | undefined = want.parameters;
    if (params) {
      const action: string = (params['action'] as string) ?? '';
      if (action === 'addProperty') {
        const state: WidgetNavigateState | undefined = AppStorageV2.connect(WidgetNavigateState, 'widgetNav', () => new WidgetNavigateState());
        if (state) {
          state.action = 'addProperty';
        }
      }
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    this.setupImmersiveWindow(windowStage);
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        console.error('[RentalTracker] Failed to load content: ' + JSON.stringify(err));
        return;
      }
      console.info('[RentalTracker] Succeeded in loading content: ' + JSON.stringify(data));
    });
  }

  /**
   * 元服务系统栏适配（AGC审核"导航栏"检测项）：
   * 开启沉浸式全屏布局，页面背景延伸至状态栏与导航条区域；
   * 内容避让由 Index 根节点按避让区动态 padding 完成。
   */
  private setupImmersiveWindow(windowStage: window.WindowStage): void {
    try {
      const mainWindow: window.Window = windowStage.getMainWindowSync();
      mainWindow.setWindowLayoutFullScreen(true).catch((err: BusinessError) => {
        console.error('[RentalTracker] setWindowLayoutFullScreen failed: ' + JSON.stringify(err));
      });
      const barProps: window.SystemBarProperties = {
        statusBarContentColor: '#0F1419'
      };
      mainWindow.setWindowSystemBarProperties(barProps).catch((err: BusinessError) => {
        console.error('[RentalTracker] setWindowSystemBarProperties failed: ' + JSON.stringify(err));
      });
    } catch (error) {
      console.error('[RentalTracker] setup immersive window failed: ' + JSON.stringify(error));
    }
  }

  onWindowStageDestroy(): void {
    console.info('[RentalTracker] onWindowStageDestroy');
  }

  onForeground(): void {
    console.info('[RentalTracker] onForeground');
    PropertyRepository.getInstance().checkAndResetBillsPaidMonthly();
  }

  onBackground(): void {
    console.info('[RentalTracker] onBackground');
  }
}
