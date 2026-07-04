import { FormExtensionAbility, formBindingData, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { PropertyRepository } from '../repository/PropertyRepository';

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const formData: Record<string, Object> = this.buildFormData();
    return formBindingData.createFormBindingData(formData);
  }

  onCastToNormalForm(formId: string): void {
    this.updateFormData(formId);
  }

  onUpdateForm(formId: string): void {
    this.updateFormData(formId);
  }

  onRemoveForm(formId: string): void {
  }

  onAcquireFormState(want: Want): formInfo.FormState {
    return formInfo.FormState.READY;
  }

  private buildFormData(): Record<string, Object> {
    const repo: PropertyRepository = PropertyRepository.getInstance();
    const overview = repo.getStatisticsOverview();
    const expiring = repo.getExpiringProperties(30);
    const totalRent: number = overview.monthlyAvgRent * overview.rentingCount;
    const nextExpiry: string = expiring.length > 0 ? expiring[0].endDate : '';

    return {
      'totalRent': totalRent > 0 ? '¥' + totalRent.toLocaleString() : '暂无',
      'rentLabel': overview.rentingCount > 0 ? '本月租金（' + overview.rentingCount + '套）' : '本月租金',
      'nextExpiry': nextExpiry !== '' ? nextExpiry + ' 到期' : '暂无到期',
      'expiryColor': expiring.length > 0 ? '#F59E0B' : '#9CA3AF'
    };
  }

  private updateFormData(formId: string): void {
    const formData: Record<string, Object> = this.buildFormData();
    const formBindingDataObj: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
    try {
      formProvider.updateForm(formId, formBindingDataObj);
    } catch (e) {
    }
  }
}
