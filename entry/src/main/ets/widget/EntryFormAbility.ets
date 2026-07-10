import { FormExtensionAbility, formBindingData, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { PropertyRepository } from '../repository/PropertyRepository';
import { preferences } from '@kit.ArkData';

const FORM_PREFS_NAME: string = 'RentNoteFormPrefs';
const KEY_FORM_IDS: string = 'active_form_ids';

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const formData: Record<string, Object> = this.buildFormData();
    return formBindingData.createFormBindingData(formData);
  }

  onCastToNormalForm(formId: string): void {
    this.addFormId(formId);
    this.updateFormData(formId);
  }

  onUpdateForm(formId: string): void {
    this.addFormId(formId);
    this.updateFormData(formId);
  }

  onRemoveForm(formId: string): void {
    this.removeFormId(formId);
  }

  onAcquireFormState(want: Want): formInfo.FormState {
    return formInfo.FormState.READY;
  }

  private buildFormData(): Record<string, Object> {
    const repo: PropertyRepository = PropertyRepository.getInstance();
    const overview = repo.getStatisticsOverview();
    const expiring = repo.getExpiringProperties(30);
    const renting = repo.getRentingProperties();
    const totalRent: number = overview.monthlyAvgRent * overview.rentingCount;
    const nextExpiry: string = expiring.length > 0 ? expiring[0].endDate : '';
    const propertyName: string = renting.length > 0 ? renting[0].name : '';
    let countdownDays: string = '';
    if (nextExpiry.length > 0) {
      const parts: string[] = nextExpiry.split('.');
      if (parts.length === 3) {
        const expiry: Date = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10));
        const now: Date = new Date();
        now.setHours(0, 0, 0, 0);
        const diff: number = Math.ceil((expiry.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
        if (diff >= 0) {
          countdownDays = diff.toString();
        }
      }
    }

    return {
      'totalRent': totalRent > 0 ? '¥' + totalRent.toLocaleString() : '暂无',
      'rentLabel': overview.rentingCount > 0 ? '本月租金（' + overview.rentingCount + '套）' : '本月租金',
      'propertyName': propertyName,
      'nextExpiry': nextExpiry !== '' ? nextExpiry + ' 到期' : '暂无到期',
      'expiryColor': expiring.length > 0 ? '#F59E0B' : '#9CA3AF',
      'countdownDays': countdownDays
    };
  }

  private updateFormData(formId: string): void {
    const formData: Record<string, Object> = this.buildFormData();
    const formBindingDataObj: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
    try {
      formProvider.updateForm(formId, formBindingDataObj);
    } catch (_e) {
    }
  }

  private async addFormId(formId: string): Promise<void> {
    try {
      const prefs: preferences.Preferences = await preferences.getPreferences(this.context, FORM_PREFS_NAME);
      const json: string = prefs.getSync(KEY_FORM_IDS, '[]') as string;
      const ids: string[] = JSON.parse(json) as string[];
      if (!ids.includes(formId)) {
        ids.push(formId);
        prefs.putSync(KEY_FORM_IDS, JSON.stringify(ids));
        await prefs.flush();
      }
    } catch (_e) {
    }
  }

  private async removeFormId(formId: string): Promise<void> {
    try {
      const prefs: preferences.Preferences = await preferences.getPreferences(this.context, FORM_PREFS_NAME);
      const json: string = prefs.getSync(KEY_FORM_IDS, '[]') as string;
      const ids: string[] = JSON.parse(json) as string[];
      const filtered: string[] = ids.filter((id: string) => id !== formId);
      prefs.putSync(KEY_FORM_IDS, JSON.stringify(filtered));
      await prefs.flush();
    } catch (_e) {
    }
  }

  static async notifyUpdate(context: Context): Promise<void> {
    try {
      const prefs: preferences.Preferences = await preferences.getPreferences(context, FORM_PREFS_NAME);
      const json: string = prefs.getSync(KEY_FORM_IDS, '[]') as string;
      const ids: string[] = JSON.parse(json) as string[];
      const repo: PropertyRepository = PropertyRepository.getInstance();
      const overview = repo.getStatisticsOverview();
      const expiring = repo.getExpiringProperties(30);
      const renting = repo.getRentingProperties();
      const totalRent: number = overview.monthlyAvgRent * overview.rentingCount;
      const nextExpiry: string = expiring.length > 0 ? expiring[0].endDate : '';
      const propertyName: string = renting.length > 0 ? renting[0].name : '';
      let countdownDays: string = '';
      if (nextExpiry.length > 0) {
        const parts: string[] = nextExpiry.split('.');
        if (parts.length === 3) {
          const expiry: Date = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10));
          const now: Date = new Date();
          now.setHours(0, 0, 0, 0);
          const diff: number = Math.ceil((expiry.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
          if (diff >= 0) {
            countdownDays = diff.toString();
          }
        }
      }
      const formData: Record<string, Object> = {
        'totalRent': totalRent > 0 ? '¥' + totalRent.toLocaleString() : '暂无',
        'rentLabel': overview.rentingCount > 0 ? '本月租金（' + overview.rentingCount + '套）' : '本月租金',
        'propertyName': propertyName,
        'nextExpiry': nextExpiry !== '' ? nextExpiry + ' 到期' : '暂无到期',
        'expiryColor': expiring.length > 0 ? '#F59E0B' : '#9CA3AF',
        'countdownDays': countdownDays
      };
      const formBindingDataObj: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
      for (const formId of ids) {
        try {
          formProvider.updateForm(formId, formBindingDataObj);
        } catch (_e) {
        }
      }
    } catch (_e) {
    }
  }
}
