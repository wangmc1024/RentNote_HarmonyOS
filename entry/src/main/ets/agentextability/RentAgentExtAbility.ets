import { AgentExtensionAbility, Want, common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PropertyRepository } from '../repository/PropertyRepository';
import { PropertyInfo } from '../model/PropertyModel';

const TAG: string = 'RentAgentExt';

export class AgentSkillResponse {
  code: number = 0;
  message: string = '';
  data: Record<string, Object> | null = null;
}

export class ExpiringItem {
  name: string = '';
  endDate: string = '';
  remainingDays: number = 0;
}

export class CandidateItem {
  name: string = '';
  address: string = '';
  district: string = '';
  monthlyRent: number = 0;
  notes: string = '';
}

export default class RentAgentExtAbility extends AgentExtensionAbility {
  private static readonly SKILL_QUERY_OVERVIEW: string = 'query_rental_overview';
  private static readonly SKILL_ADD_PROPERTY: string = 'add_property';
  private static readonly SKILL_QUERY_CANDIDATES: string = 'query_candidate_properties';
  private static readonly SKILL_DELETE_PROPERTY: string = 'delete_property';

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
    try {
      proxy.authorize('auth success');
    } catch (_e) {
      hilog.error(0, TAG, 'authorize failed');
    }
  }

  onData(proxy: common.AgentHostProxy, data: string): void {
    hilog.info(0, TAG, `onData: ${data}`);
    let skillId: string = '';
    let params: Record<string, Object> = {};
    try {
      const raw: Record<string, Object> = JSON.parse(data) as Record<string, Object>;
      skillId = (raw['skillId'] as string) ?? '';
      params = (raw['params'] as Record<string, Object>) ?? {};
    } catch (_e) {
      this.replyError(proxy, 'invalid request format');
      return;
    }
    if (skillId === RentAgentExtAbility.SKILL_QUERY_OVERVIEW) {
      void this.handleQueryOverview(proxy);
    } else if (skillId === RentAgentExtAbility.SKILL_ADD_PROPERTY) {
      void this.handleAddProperty(proxy, params);
    } else if (skillId === RentAgentExtAbility.SKILL_QUERY_CANDIDATES) {
      void this.handleQueryCandidates(proxy);
    } else if (skillId === RentAgentExtAbility.SKILL_DELETE_PROPERTY) {
      void this.handleDeleteProperty(proxy, params);
    } else {
      this.replyError(proxy, `unknown skill: ${skillId}`);
    }
  }

  onDestroy(): void {
    hilog.info(0, TAG, 'onDestroy');
  }

  private async handleQueryOverview(proxy: common.AgentHostProxy): Promise<void> {
    const repo: PropertyRepository = PropertyRepository.getInstance();
    await repo.reloadData();
    const overview = repo.getStatisticsOverview();
    const reminderDays: number = repo.getReminderDays();
    const expiring: PropertyInfo[] = repo.getExpiringProperties(reminderDays);
    const expiringItems: ExpiringItem[] = [];
    for (const p of expiring) {
      const item: ExpiringItem = new ExpiringItem();
      item.name = p.name;
      item.endDate = p.endDate;
      item.remainingDays = this.calcRemainingDays(p.endDate);
      expiringItems.push(item);
    }
    let suggestion: string = '';
    if (expiringItems.length === 0) {
      suggestion = `当前共${overview.rentingCount}套在租房源，平均月租${overview.monthlyAvgRent}元，暂无${reminderDays}天内到期的租约。`;
    } else {
      const nearest: ExpiringItem = expiringItems[0];
      suggestion = `有${expiringItems.length}套租约将在${reminderDays}天内到期，最近的是"${nearest.name}"（剩${nearest.remainingDays}天），建议尽快联系租客确认续约或安排退租交接。`;
    }
    const resp: AgentSkillResponse = new AgentSkillResponse();
    resp.code = 0;
    resp.message = 'ok';
    resp.data = {
      'rentingCount': overview.rentingCount,
      'monthlyAvgRent': overview.monthlyAvgRent,
      'reminderDays': reminderDays,
      'expiring': expiringItems,
      'suggestion': suggestion
    };
    this.reply(proxy, resp);
  }

  private async handleAddProperty(proxy: common.AgentHostProxy, params: Record<string, Object>): Promise<void> {
    const repo: PropertyRepository = PropertyRepository.getInstance();
    await repo.reloadData();
    const property: PropertyInfo = new PropertyInfo();
    property.name = (params['name'] as string) ?? '';
    property.address = (params['address'] as string) ?? '';
    property.district = (params['district'] as string) ?? '';
    property.monthlyRent = (params['monthlyRent'] as number) ?? 0;
    property.deposit = (params['deposit'] as number) ?? 0;
    property.startDate = (params['startDate'] as string) ?? '';
    property.endDate = (params['endDate'] as string) ?? '';
    property.notes = (params['notes'] as string) ?? '';
    const statusParam: string = (params['status'] as string) ?? '';
    property.status = statusParam === 'renting' ? 'renting' : 'candidate';
    if (property.name.length === 0) {
      this.replyError(proxy, 'params missing required field: name');
      return;
    }
    await repo.addProperty(property);
    const resp: AgentSkillResponse = new AgentSkillResponse();
    resp.code = 0;
    resp.message = 'ok';
    resp.data = {
      'propertyId': property.id,
      'status': property.status === 'candidate' ? '已记入备选' : '已记入在租'
    };
    this.reply(proxy, resp);
  }

  private async handleQueryCandidates(proxy: common.AgentHostProxy): Promise<void> {
    const repo: PropertyRepository = PropertyRepository.getInstance();
    await repo.reloadData();
    const candidates: PropertyInfo[] = repo.getCandidates();
    const items: CandidateItem[] = [];
    for (const p of candidates) {
      const item: CandidateItem = new CandidateItem();
      item.name = p.name;
      item.address = p.address;
      item.district = p.district;
      item.monthlyRent = p.monthlyRent;
      item.notes = p.notes;
      items.push(item);
    }
    let suggestion: string = '';
    if (items.length === 0) {
      suggestion = '当前没有记录备选房源，看房时可以让我帮你记录。';
    } else {
      suggestion = `共记录了${items.length}套备选房源，可以在备选页查看详情，确定租房后可转正在租。`;
    }
    const resp: AgentSkillResponse = new AgentSkillResponse();
    resp.code = 0;
    resp.message = 'ok';
    resp.data = {
      'count': items.length,
      'candidates': items,
      'suggestion': suggestion
    };
    this.reply(proxy, resp);
  }

  private async handleDeleteProperty(proxy: common.AgentHostProxy, params: Record<string, Object>): Promise<void> {
    const repo: PropertyRepository = PropertyRepository.getInstance();
    await repo.reloadData();
    const name: string = (params['name'] as string) ?? '';
    const statusFilter: string = (params['status'] as string) ?? '';
    if (name.length === 0) {
      this.replyError(proxy, 'params missing required field: name');
      return;
    }
    let pool: PropertyInfo[] = [...repo.getCandidates(), ...repo.getRentingProperties()];
    if (statusFilter === 'candidate' || statusFilter === 'renting') {
      pool = pool.filter((p: PropertyInfo) => {
        if (statusFilter === 'candidate') {
          return p.status === 'candidate';
        }
        return p.status === 'renting' || p.status === 'expiring';
      });
    }
    let matched: PropertyInfo[] = pool.filter((p: PropertyInfo) => p.name === name);
    if (matched.length === 0) {
      matched = pool.filter((p: PropertyInfo) => p.name.includes(name) || name.includes(p.name));
    }
    if (matched.length === 0) {
      this.replyError(proxy, `未找到名为"${name}"的房源记录`);
      return;
    }
    if (matched.length > 1) {
      const names: string[] = matched.map((p: PropertyInfo) => {
        return `${p.name}（${p.status === 'candidate' ? '备选' : '在租'}）`;
      });
      const resp: AgentSkillResponse = new AgentSkillResponse();
      resp.code = -1;
      resp.message = `找到${matched.length}套匹配的房源：${names.join('、')}，请说明要删除哪一套`;
      resp.data = {
        'matched': names
      };
      this.reply(proxy, resp);
      return;
    }
    const target: PropertyInfo = matched[0];
    const deletedName: string = target.name;
    const deletedStatusLabel: string = target.status === 'candidate' ? '备选' : '在租';
    await repo.deleteProperty(target.id);
    const resp: AgentSkillResponse = new AgentSkillResponse();
    resp.code = 0;
    resp.message = 'ok';
    resp.data = {
      'deletedName': deletedName,
      'status': deletedStatusLabel
    };
    this.reply(proxy, resp);
  }

  private calcRemainingDays(endDate: string): number {
    const parts: string[] = endDate.split('.');
    if (parts.length !== 3) {
      return 0;
    }
    const expiry: Date = new Date(
      parseInt(parts[0], 10),
      parseInt(parts[1], 10) - 1,
      parseInt(parts[2], 10)
    );
    const now: Date = new Date();
    now.setHours(0, 0, 0, 0);
    return Math.ceil((expiry.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
  }

  private reply(proxy: common.AgentHostProxy, resp: AgentSkillResponse): void {
    try {
      proxy.sendData(JSON.stringify(resp));
    } catch (_e) {
      hilog.error(0, TAG, 'sendData failed');
    }
  }

  private replyError(proxy: common.AgentHostProxy, message: string): void {
    const resp: AgentSkillResponse = new AgentSkillResponse();
    resp.code = -1;
    resp.message = message;
    this.reply(proxy, resp);
  }
}
