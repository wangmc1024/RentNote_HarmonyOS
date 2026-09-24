import { FunctionComponent, FunctionController, FunctionOptions } from '@kit.AgentFrameworkKit';
import { BuilderNode, FrameNode, NodeController, UIContext } from '@kit.ArkUI';
import { BusinessError, Available, deviceInfo } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';

const TAG: string = 'AgentEntryCard';

export class AgentEntryConfig {
  agentId: string = '';
  functionOptions: FunctionOptions = {
    title: '',
    queryText: '',
    isShowShadow: true
  };
}

@Builder
export function AgentEntryBuilder(config: AgentEntryConfig) {
  if (deviceInfo.sdkApiVersion >= 20) {
    FunctionComponent({
      agentId: config.agentId,
      onError: (err: BusinessError) => {
        hilog.error(0, TAG, `FunctionComponent error, code: ${err.code}, message: ${err.message}`);
      },
      options: config.functionOptions
    })
  }
}

export class AgentEntryNodeController extends NodeController {
  private rootNode: BuilderNode<[AgentEntryConfig]> | null = null;

  constructor(uiContext: UIContext, config: AgentEntryConfig) {
    super();
    this.rootNode = new BuilderNode<[AgentEntryConfig]>(uiContext);
    this.rootNode.build(wrapBuilder(AgentEntryBuilder), [config]);
  }

  makeNode(uiContext: UIContext): FrameNode | null {
    return this.rootNode === null ? null : this.rootNode.getFrameNode();
  }
}

@Available({minApiVersion: 'HarmonyOS 6.0.0'})
export async function createAgentEntryController(uiContext: UIContext,
  context: common.UIAbilityContext, agentId: string,
  title: string, queryText: string): Promise<AgentEntryNodeController | null> {
  if (deviceInfo.sdkApiVersion >= 20) {
    const kit = await import('@kit.AgentFrameworkKit');
    const controller: FunctionController = new kit.FunctionController();
    const supported: boolean = await controller.isAgentSupport(context, agentId);
    if (!supported) {
      return null;
    }
    const config: AgentEntryConfig = new AgentEntryConfig();
    config.agentId = agentId;
    config.functionOptions.title = title;
    config.functionOptions.queryText = queryText;
    return new AgentEntryNodeController(uiContext, config);
  }
  return null;
}
