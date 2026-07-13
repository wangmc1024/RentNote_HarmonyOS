import { UIAbility, Want, AbilityConstant } from '@kit.AbilityKit';
import { window, AppStorageV2 } from '@kit.ArkUI';
import { PropertyRepository } from '../repository/PropertyRepository';
import { WidgetNavigateState } from '../model/PropertyModel';
// import { ReminderService } from '../service/ReminderService';

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
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        console.error('[RentalTracker] Failed to load content: ' + JSON.stringify(err));
        return;
      }
      console.info('[RentalTracker] Succeeded in loading content: ' + JSON.stringify(data));
    });
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
