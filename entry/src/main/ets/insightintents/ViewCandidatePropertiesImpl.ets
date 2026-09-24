import { InsightIntentEntry, InsightIntentEntryExecutor, insightIntent } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { WidgetNavigateState } from '../model/PropertyModel';

@InsightIntentEntry({
  intentName: 'ViewCandidateProperties',
  domain: 'RentalDomain',
  intentVersion: '1.0.0',
  displayName: '查看备选房源',
  displayDescription: '打开小寓台账备选房源页，查看已记录的备选房源列表',
  icon: $r('app.media.app_icon'),
  llmDescription: '打开小寓台账的备选房源页，查看已记录的备选房源列表，包括名称、地址、区域、月租与备注。触发语料需包含“小寓台账”，例如：打开小寓台账看看备选房源',
  keywords: ['备选房源', '候选房源', '看房记录', '找房'],
  abilityName: 'EntryAbility',
  executeMode: [insightIntent.ExecuteMode.UI_ABILITY_FOREGROUND]
})
export default class ViewCandidatePropertiesImpl extends InsightIntentEntryExecutor<string> {
  onExecute(): Promise<insightIntent.IntentResult<string>> {
    const state: WidgetNavigateState | undefined =
      AppStorageV2.connect(WidgetNavigateState, 'widgetNav', () => new WidgetNavigateState());
    if (state) {
      state.action = 'viewCandidates';
    }
    const result: insightIntent.IntentResult<string> = {
      code: 0,
      result: 'Intent execute succeed'
    };
    return Promise.resolve(result);
  }
}
