import { InsightIntentEntry, InsightIntentEntryExecutor, insightIntent } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { WidgetNavigateState } from '../model/PropertyModel';

@InsightIntentEntry({
  intentName: 'ViewLeaseOverview',
  domain: 'RentalDomain',
  intentVersion: '1.0.0',
  displayName: '查看租约概览',
  displayDescription: '打开小寓台账首页，查看租金收缴与租约到期概览',
  icon: $r('app.media.app_icon'),
  llmDescription: '打开小寓台账首页查看租约概览，包括在租数量、平均月租、租金收缴情况与即将到期的租约提醒。触发语料需包含“小寓台账”，例如：看看小寓台账的收租情况',
  keywords: ['租约', '到期提醒', '收租', '租金统计'],
  abilityName: 'EntryAbility',
  executeMode: [insightIntent.ExecuteMode.UI_ABILITY_FOREGROUND]
})
export default class ViewLeaseOverviewImpl extends InsightIntentEntryExecutor<string> {
  onExecute(): Promise<insightIntent.IntentResult<string>> {
    const state: WidgetNavigateState | undefined =
      AppStorageV2.connect(WidgetNavigateState, 'widgetNav', () => new WidgetNavigateState());
    if (state) {
      state.action = 'viewOverview';
    }
    const result: insightIntent.IntentResult<string> = {
      code: 0,
      result: 'Intent execute succeed'
    };
    return Promise.resolve(result);
  }
}
