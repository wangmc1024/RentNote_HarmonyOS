// ReminderService - atomicservice 不支持 notificationManager.publish 和 reminderAgentManager
// 当前保留 Toast + 振动 作为前台提醒方式
// 如需通知栏提醒，需配置 AGC 云函数 + 服务通知 REST API

import { vibrator } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { window, AppStorageV2 } from '@kit.ArkUI';
import { PropertyInfo } from '../model/PropertyModel';
import { PropertyRepository } from '../repository/PropertyRepository';

@ObservedV2
export class ReminderState {
  @Trace pendingNotify: boolean = false;
}

export class ReminderService {
  private static instance: ReminderService | null = null;

  static getInstance(): ReminderService {
    if (!ReminderService.instance) {
      ReminderService.instance = new ReminderService();
    }
    return ReminderService.instance;
  }

  markPending(): void {
    const state: ReminderState | undefined = AppStorageV2.connect(ReminderState, 'reminderState', () => new ReminderState());
    if (state) {
      state.pendingNotify = true;
    }
  }

  async checkAndNotify(): Promise<void> {
    const repo: PropertyRepository = PropertyRepository.getInstance();
    const reminderEnabled: boolean = repo.getReminderEnabled();
    if (!reminderEnabled) {
      return;
    }
    const reminderDays: number = repo.getReminderDays();
    const properties: PropertyInfo[] = repo.getExpiringProperties(reminderDays);
    if (properties.length === 0) {
      return;
    }

    const vibrateEnabled: boolean = repo.getVibrateEnabled();

    await this.showToastFallback(properties);

    if (vibrateEnabled) {
      this.triggerVibration();
    }
  }

  private triggerVibration(): void {
    try {
      vibrator.startVibration({
        type: 'time',
        duration: 300
      }, {
        usage: 'notification'
      }).catch((_e: BusinessError) => {
      });
    } catch (_e) {
    }
  }

  private async showToastFallback(properties: PropertyInfo[]): Promise<void> {
    const first: PropertyInfo = properties[0];
    const parts: string[] = first.endDate.split('.');
    if (parts.length !== 3) {
      return;
    }
    const expiry: Date = new Date(
      parseInt(parts[0], 10),
      parseInt(parts[1], 10) - 1,
      parseInt(parts[2], 10)
    );
    const now: Date = new Date();
    now.setHours(0, 0, 0, 0);
    const diff: number = expiry.getTime() - now.getTime();
    const remainingDays: number = Math.ceil(diff / (1000 * 60 * 60 * 24));

    let message: string = '';
    if (remainingDays < 0) {
      message = `${first.name}的租约已过期${Math.abs(remainingDays)}天`;
    } else if (remainingDays === 0) {
      message = `${first.name}的租约今天到期`;
    } else {
      message = `${first.name}的租约还剩${remainingDays}天到期`;
    }
    if (properties.length > 1) {
      message = message + `，共${properties.length}条到期提醒`;
    }
    try {
      const context: Context | null = PropertyRepository.getInstance().getContext();
      if (context === null) {
        return;
      }
      const win: window.Window = await window.getLastWindow(context);
      win.getUIContext().getPromptAction().showToast({
        message: message,
        duration: 4000
      });
    } catch (_e) {
    }
  }
}
