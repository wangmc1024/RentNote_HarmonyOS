import { InsightIntentEntry, InsightIntentEntryExecutor, insightIntent } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { WidgetNavigateState } from '../model/PropertyModel';

@InsightIntentEntry({
  intentName: 'AddRentalProperty',
  domain: 'RentalDomain',
  intentVersion: '1.0.0',
  displayName: '新增房源',
  displayDescription: '打开小寓台账新增房源页面，记录房源与租约信息',
  icon: $r('app.media.app_icon'),
  llmDescription: '在小寓台账中记录一套新房源或新租约，打开新增房源页面填写房源名称、地址、月租、押金与租期。触发语料需包含“小寓台账”，例如：打开小寓台账记一套房',
  keywords: ['记租金', '新增房源', '添加租约', '租房记账'],
  abilityName: 'EntryAbility',
  executeMode: [insightIntent.ExecuteMode.UI_ABILITY_FOREGROUND]
})
export default class AddRentalPropertyImpl extends InsightIntentEntryExecutor<string> {
  onExecute(): Promise<insightIntent.IntentResult<string>> {
    const state: WidgetNavigateState | undefined =
      AppStorageV2.connect(WidgetNavigateState, 'widgetNav', () => new WidgetNavigateState());
    if (state) {
      state.action = 'addProperty';
    }
    const result: insightIntent.IntentResult<string> = {
      code: 0,
      result: 'Intent execute succeed'
    };
    return Promise.resolve(result);
  }
}
