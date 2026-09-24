import { FormExtensionAbility, formBindingData, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { PropertyRepository } from '../repository/PropertyRepository';
import { PropertyInfo } from '../model/PropertyModel';
import { preferences } from '@kit.ArkData';

class ExpiryInfo {
  propertyName: string = '';
  endDate: string = '';
  diffDays: number = 0;
}

class RentWidgetCountdownHelper {
  static getNearestExpiry(properties: PropertyInfo[], now: Date): ExpiryInfo | null {
    let nearest: ExpiryInfo | null = null;
    for (let i: number = 0; i < properties.length; i++) {
      const item: PropertyInfo = properties[i];
      if (item.status !== 'renting' && item.status !== 'expiring') {
        continue;
      }
      if (!item.endDate || item.endDate.length === 0) {
        continue;
      }
      const parts: string[] = item.endDate.split('.');
      if (parts.length !== 3) {
        continue;
      }
      const expiry: Date = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10));
      const diff: number = Math.ceil((expiry.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
      if (nearest === null || diff < nearest.diffDays) {
        const info: ExpiryInfo = new ExpiryInfo();
        info.propertyName = item.name;
        info.endDate = item.endDate;
        info.diffDays = diff;
        nearest = info;
      }
    }
    return nearest;
  }
}

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

  static buildWidgetFormData(): Record<string, Object> {
    const repo: PropertyRepository = PropertyRepository.getInstance();
    const overview = repo.getStatisticsOverview();
    const renting = repo.getRentingProperties();
    const totalRent: number = overview.monthlyAvgRent * overview.rentingCount;

    const now: Date = new Date();
    now.setHours(0, 0, 0, 0);
    const nearest: ExpiryInfo | null = RentWidgetCountdownHelper.getNearestExpiry(renting, now);

    const hasRenting: boolean = renting.length > 0;

    let expiryLabel: string = '暂无到期';
    let countdownDays: string = '';
    let expiryColor: string = '#9CA3AF';
    let propertyName: string = hasRenting ? renting[0].name : '';
    let hasExpiry: string = 'false';

    if (nearest !== null) {
      propertyName = nearest.propertyName;
      countdownDays = Math.abs(nearest.diffDays).toString();
      hasExpiry = 'true';
      if (nearest.diffDays < 0) {
        expiryLabel = '已过期';
        expiryColor = '#EF4444';
      } else if (nearest.diffDays === 0) {
        expiryLabel = '今天到期';
        expiryColor = '#EF4444';
      } else if (nearest.diffDays <= 7) {
        expiryLabel = '即将到期';
        expiryColor = '#F59E0B';
      } else if (nearest.diffDays <= 30) {
        expiryLabel = '天后到期';
        expiryColor = '#F59E0B';
      } else {
        expiryLabel = '天后到期';
        expiryColor = '#10B981';
      }
    }

    return {
      'totalRent': totalRent > 0 ? '¥' + totalRent.toLocaleString() : '暂无',
      'rentLabel': overview.rentingCount > 0 ? '本月租金（' + overview.rentingCount + '套）' : '本月租金',
      'propertyName': propertyName,
      'expiryLabel': expiryLabel,
      'expiryColor': expiryColor,
      'countdownDays': countdownDays,
      'hasExpiry': hasExpiry ? 'true' : 'false'
    };
  }

  private buildFormData(): Record<string, Object> {
    PropertyRepository.getInstance().initSync(this.context);
    return EntryFormAbility.buildWidgetFormData();
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
      const formData: Record<string, Object> = EntryFormAbility.buildWidgetFormData();
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
