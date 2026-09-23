import { InsightIntentExecutor, insightIntent } from '@kit.AbilityKit';
import { window, AppStorageV2 } from '@kit.ArkUI';
import { WidgetNavigateState } from '../model/PropertyModel';

export default class InsightIntentExecutorImpl extends InsightIntentExecutor {
  private static readonly ADD_RENTAL_PROPERTY: string = 'AddRentalProperty';
  private static readonly VIEW_LEASE_OVERVIEW: string = 'ViewLeaseOverview';
  private static readonly VIEW_CANDIDATE_PROPERTIES: string = 'ViewCandidateProperties';
  private static readonly DELETE_PROPERTY: string = 'DeleteProperty';

  async onExecuteInUIAbilityForegroundMode(intentName: string, params: Record<string, Object>,
    windowStage: window.WindowStage): Promise<insightIntent.ExecuteResult> {
    const state: WidgetNavigateState | undefined =
      AppStorageV2.connect(WidgetNavigateState, 'widgetNav', () => new WidgetNavigateState());
    if (state) {
      if (intentName === InsightIntentExecutorImpl.ADD_RENTAL_PROPERTY) {
        state.action = 'addProperty';
      } else if (intentName === InsightIntentExecutorImpl.VIEW_LEASE_OVERVIEW) {
        state.action = 'viewOverview';
      } else if (intentName === InsightIntentExecutorImpl.VIEW_CANDIDATE_PROPERTIES) {
        state.action = 'viewCandidates';
      } else if (intentName === InsightIntentExecutorImpl.DELETE_PROPERTY) {
        state.action = 'deleteProperty';
      }
    }
    const result: insightIntent.ExecuteResult = {
      code: 0,
      result: {
        'message': 'Intent execute succeed'
      }
    };
    return Promise.resolve(result);
  }
}
