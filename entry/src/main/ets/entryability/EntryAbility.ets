/**
 * 应用入口 Ability
 * 租房台账 - 鸿蒙元服务
 * 与 Navigation 容器兼容，移除不必要的背景色硬编码
 */
import { UIAbility, Want, AbilityConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { PropertyRepository } from '../repository/PropertyRepository';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    console.info('[RentalTracker] EntryAbility onCreate');
    const repository: PropertyRepository = PropertyRepository.getInstance();
    await repository.init(this.context);
  }

  onDestroy(): void {
    console.info('[RentalTracker] EntryAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 设置主窗口
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        console.error('[RentalTracker] Failed to load content: ' + JSON.stringify(err));
        return;
      }
      console.info('[RentalTracker] Succeeded in loading content: ' + JSON.stringify(data));
    });
  }

  onWindowStageDestroy(): void {
    console.info('[RentalTracker] EntryAbility onWindowStageDestroy');
  }

  onForeground(): void {
    console.info('[RentalTracker] EntryAbility onForeground');
  }

  onBackground(): void {
    console.info('[RentalTracker] EntryAbility onBackground');
  }
}
