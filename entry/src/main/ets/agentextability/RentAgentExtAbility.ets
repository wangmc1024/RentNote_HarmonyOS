import { AgentExtensionAbility, Want, common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PropertyRepository } from '../repository/PropertyRepository';
import { RentAgentSkillHandler, SkillResult, SkillState } from './RentAgentSkillHandler';

const TAG: string = 'RentAgentExt';

/** 元服务端侧智能体应答信封（API 24 端侧A2A框架，AgentHostProxy 通道自定义协议） */
export class AgentSkillResponse {
  code: number = 0;
  message: string = '';
  data: Record<string, Object> | null = null;
}

/** 从请求数据中解析出的技能调用 */
export class AgentRequestParse {
  skillId: string = '';
  params: Record<string, Object> = {};
}

/**
 * 元服务（installationFree）不支持 @kit.AgentFrameworkKit 的 A2A 标准协议模块，
 * 按端侧A2A框架（API 24）开发指导使用 AgentExtensionAbility + AgentHostProxy 通道：
 * 请求数据为 JSON（{skillId, params}），无法解析时回退为用户话术启发式解析。
 */
export default class RentAgentExtAbility extends AgentExtensionAbility {
  onCreate(want: Want): void {
    hilog.info(0, TAG, 'onCreate');
    void PropertyRepository.getInstance().init(this.context);
  }

  onConnect(want: Want, proxy: common.AgentHostProxy): void {
    hilog.info(0, TAG, 'onConnect');
  }

  onDisconnect(want: Want, proxy: common.AgentHostProxy): void {
    hilog.info(0, TAG, 'onDisconnect');
  }

  onAuth(proxy: common.AgentHostProxy, handshakeData: string): void {
    hilog.info(0, TAG, 'onAuth');
    try {
      proxy.authorize('auth success');
    } catch (error) {
      hilog.error(0, TAG, `authorize failed: ${error}`);
    }
  }

  onData(proxy: common.AgentHostProxy, data: string): void {
    hilog.info(0, TAG, `onData: ${data}`);
    const req: AgentRequestParse = this.parseRequestData(data);
    if (req.skillId === RentAgentSkillHandler.SKILL_QUERY_OVERVIEW) {
      void this.executeSkill(proxy, RentAgentSkillHandler.queryOverview());
    } else if (req.skillId === RentAgentSkillHandler.SKILL_ADD_PROPERTY) {
      void this.executeSkill(proxy, RentAgentSkillHandler.addProperty(req.params));
    } else if (req.skillId === RentAgentSkillHandler.SKILL_QUERY_CANDIDATES) {
      void this.executeSkill(proxy, RentAgentSkillHandler.queryCandidates());
    } else if (req.skillId === RentAgentSkillHandler.SKILL_DELETE_PROPERTY) {
      void this.executeSkill(proxy, RentAgentSkillHandler.deleteProperty(req.params));
    } else {
      this.replyError(proxy, RentAgentSkillHandler.HELP_TEXT);
    }
  }

  onDestroy(): void {
    hilog.info(0, TAG, 'onDestroy');
  }

  private async executeSkill(proxy: common.AgentHostProxy, pending: Promise<SkillResult>): Promise<void> {
    let result: SkillResult = new SkillResult();
    try {
      result = await pending;
    } catch (error) {
      hilog.error(0, TAG, `execute skill failed: ${error}`);
      result = new SkillResult();
      result.state = SkillState.FAILED;
      result.summary = '处理请求时出现异常，请稍后再试。';
    }
    this.reply(proxy, this.toResponse(result));
  }

  private toResponse(result: SkillResult): AgentSkillResponse {
    const resp: AgentSkillResponse = new AgentSkillResponse();
    resp.data = result.data;
    resp.data['suggestion'] = result.summary;
    if (result.state === SkillState.COMPLETED) {
      resp.code = 0;
      resp.message = 'ok';
    } else if (result.state === SkillState.INPUT_REQUIRED) {
      resp.code = 1;
      resp.message = result.summary;
    } else {
      resp.code = -1;
      resp.message = result.summary;
    }
    return resp;
  }

  private reply(proxy: common.AgentHostProxy, resp: AgentSkillResponse): void {
    try {
      proxy.sendData(JSON.stringify(resp));
    } catch (error) {
      hilog.error(0, TAG, `sendData failed: ${error}`);
    }
  }

  private replyError(proxy: common.AgentHostProxy, message: string): void {
    const resp: AgentSkillResponse = new AgentSkillResponse();
    resp.code = -1;
    resp.message = message;
    this.reply(proxy, resp);
  }

  private parseRequestData(data: string): AgentRequestParse {
    const req: AgentRequestParse = new AgentRequestParse();
    try {
      const raw: Record<string, Object> = JSON.parse(data) as Record<string, Object>;
      req.skillId = (raw['skillId'] as string) ?? '';
      const params: Record<string, Object> = (raw['params'] as Record<string, Object>) ?? {};
      req.params = this.mergeFlatParams(raw, params);
    } catch (_e) {
      const text: string = data.trim();
      if (text.length > 0) {
        return this.parseFromText(text);
      }
    }
    return req;
  }

  private mergeFlatParams(raw: Record<string, Object>, params: Record<string, Object>): Record<string, Object> {
    const flatKeys: string[] = ['name', 'address', 'district', 'monthlyRent', 'deposit',
      'startDate', 'endDate', 'notes', 'status'];
    for (const key of flatKeys) {
      const val: Object | undefined = raw[key];
      if (val !== undefined) {
        params[key] = val;
      }
    }
    return params;
  }

  private parseFromText(t: string): AgentRequestParse {
    const req: AgentRequestParse = new AgentRequestParse();
    if (t.includes('删') || t.includes('移除') || t.includes('去掉') || t.includes('清掉')) {
      req.skillId = RentAgentSkillHandler.SKILL_DELETE_PROPERTY;
      req.params = this.extractDeleteParams(t);
      return req;
    }
    if (t.includes('记一套') || t.includes('记录一') || t.includes('记个') || t.includes('帮我记') ||
      t.includes('新增') || t.includes('添加') || t.includes('录入')) {
      req.skillId = RentAgentSkillHandler.SKILL_ADD_PROPERTY;
      req.params = this.extractAddParams(t);
      return req;
    }
    if ((t.includes('备选') || t.includes('候选') || t.includes('看房')) &&
      (t.includes('哪些') || t.includes('什么') || t.includes('查') || t.includes('看看') ||
      t.includes('列表') || t.includes('几个') || t.includes('多少') || t.includes('看了'))) {
      req.skillId = RentAgentSkillHandler.SKILL_QUERY_CANDIDATES;
      return req;
    }
    req.skillId = RentAgentSkillHandler.SKILL_QUERY_OVERVIEW;
    return req;
  }

  private extractDeleteParams(t: string): Record<string, Object> {
    const params: Record<string, Object> = {};
    if (t.includes('备选')) {
      params['status'] = 'candidate';
    } else if (t.includes('在租')) {
      params['status'] = 'renting';
    }
    let name: string = '';
    const baMatch: string[] | null = t.match(new RegExp('把(.+?)(删|移除|去掉|清掉)'));
    if (baMatch !== null && baMatch.length > 1) {
      name = baMatch[1];
    }
    if (name.length === 0) {
      const afterMatch: string[] | null = t.match(new RegExp('(?:删|移除|去掉|清掉)(.+)'));
      if (afterMatch !== null && afterMatch.length > 1) {
        name = afterMatch[1];
      }
    }
    name = this.cleanPropertyName(name);
    if (name.length > 0) {
      params['name'] = name;
    }
    return params;
  }

  private cleanPropertyName(name: string): string {
    let n: string = name.trim();
    n = n.replace(new RegExp('^(了|掉|备选里的|备选中的|备选的|在租里的|在租中的|在租的|台账里的|台账中的)', 'g'), '');
    n = n.replace(new RegExp('(那套房|那套|这套房|这套|的房源|的记录|房源|记录)$', 'g'), '');
    n = n.replace(new RegExp('的$', 'g'), '');
    return n.trim();
  }

  private extractAddParams(t: string): Record<string, Object> {
    const params: Record<string, Object> = {};
    const colonIdx: number = t.search(new RegExp('[:：]'));
    if (colonIdx >= 0) {
      const body: string = t.substring(colonIdx + 1);
      const segs: string[] = body.split(new RegExp('[，,]'));
      if (segs.length > 0) {
        const name: string = segs[0].trim();
        if (name.length > 0) {
          params['name'] = name;
        }
      }
    }
    const rentMatch: string[] | null =
      t.match(new RegExp('(月租金|月租|房租|租金)[：:]?(约为|约|是|大概|大约)?([0-9]+(\\.[0-9]+)?)'));
    if (rentMatch !== null && rentMatch.length > 3) {
      params['monthlyRent'] = parseFloat(rentMatch[3]);
    }
    const depositMatch: string[] | null =
      t.match(new RegExp('押金[：:]?(约为|约|是|大概|大约)?([0-9]+(\\.[0-9]+)?)'));
    if (depositMatch !== null && depositMatch.length > 2) {
      params['deposit'] = parseFloat(depositMatch[2]);
    }
    const dateMatches: string[] | null =
      t.match(new RegExp('[0-9]{4}[.年-][0-9]{1,2}[.月-][0-9]{1,2}日?', 'g'));
    if (dateMatches !== null) {
      const normalized: string[] = [];
      for (const d of dateMatches) {
        const nd: string = this.normalizeDate(d);
        if (nd.length > 0) {
          normalized.push(nd);
        }
      }
      if (normalized.length === 1 && t.includes('到期')) {
        params['endDate'] = normalized[0];
      } else if (normalized.length > 0) {
        params['startDate'] = normalized[0];
        if (normalized.length > 1) {
          params['endDate'] = normalized[1];
        }
      }
    }
    if (t.includes('租约') || t.includes('在租')) {
      params['status'] = 'renting';
    } else {
      params['status'] = 'candidate';
    }
    return params;
  }

  private normalizeDate(raw: string): string {
    let s: string = raw.replace(new RegExp('[年月-]', 'g'), '.');
    s = s.replace(new RegExp('日', 'g'), '');
    const parts: string[] = s.split('.');
    if (parts.length !== 3) {
      return '';
    }
    const year: string = parts[0];
    const month: string = parts[1].padStart(2, '0');
    const day: string = parts[2].padStart(2, '0');
    return `${year}.${month}.${day}`;
  }
}
