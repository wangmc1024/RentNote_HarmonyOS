import { InsightIntentEntry, InsightIntentEntryExecutor, insightIntent } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { WidgetNavigateState } from '../model/PropertyModel';

@InsightIntentEntry({
  intentName: 'DeleteProperty',
  domain: 'RentalDomain',
  intentVersion: '1.0.0',
  displayName: '删除房源',
  displayDescription: '打开小寓台账房源列表，删除已记录的房源记录',
  icon: $r('app.media.app_icon'),
  llmDescription: '打开小寓台账的房源列表页，找到要删除的房源记录并删除。触发语料需包含“小寓台账”，例如：打开小寓台账删除阳光小区那套房',
  keywords: ['删除房源', '移除房源', '删掉记录'],
  abilityName: 'EntryAbility',
  executeMode: [insightIntent.ExecuteMode.UI_ABILITY_FOREGROUND]
})
export default class DeletePropertyImpl extends InsightIntentEntryExecutor<string> {
  onExecute(): Promise<insightIntent.IntentResult<string>> {
    const state: WidgetNavigateState | undefined =
      AppStorageV2.connect(WidgetNavigateState, 'widgetNav', () => new WidgetNavigateState());
    if (state) {
      state.action = 'deleteProperty';
    }
    const result: insightIntent.IntentResult<string> = {
      code: 0,
      result: 'Intent execute succeed'
    };
    return Promise.resolve(result);
  }
}
