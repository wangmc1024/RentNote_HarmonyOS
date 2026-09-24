import { PropertyRepository } from '../repository/PropertyRepository';
import { PropertyInfo, StatisticsOverview } from '../model/PropertyModel';

/** 技能执行结果状态（元服务不可用 @kit.AgentFrameworkKit 的 TaskState，使用本地枚举） */
export enum SkillState {
  COMPLETED = 0,
  INPUT_REQUIRED = 1,
  FAILED = 2
}

/** 技能执行结果 */
export class SkillResult {
  state: SkillState = SkillState.COMPLETED;
  summary: string = '';
  data: Record<string, Object> = {};
}

/** 即将到期的租约条目 */
export class ExpiringItem {
  name: string = '';
  endDate: string = '';
  remainingDays: number = 0;
}

/** 备选房源条目 */
export class CandidateItem {
  name: string = '';
  address: string = '';
  district: string = '';
  monthlyRent: number = 0;
  notes: string = '';
}

/** 感知建议 chip */
export class SuggestionChip {
  text: string = '';
  reply: string = '';
}

export class RentAgentSkillHandler {
  static readonly SKILL_QUERY_OVERVIEW: string = 'query_rental_overview';
  static readonly SKILL_ADD_PROPERTY: string = 'add_property';
  static readonly SKILL_QUERY_CANDIDATES: string = 'query_candidate_properties';
  static readonly SKILL_DELETE_PROPERTY: string = 'delete_property';
  static readonly GREETING: string = '你好，我是小寓租务助手，可以帮你查看租约概况、查询备选房源、记录新房源或删除记录。';
  static readonly HELP_TEXT: string = '我可以帮你：查看租约概况（如"哪些房子快到期了"）、查询备选房源、记录新房源（如"帮我记一套房：阳光小区2栋301，月租2500"）、删除房源记录。';

  static buildSuggestionChips(): SuggestionChip[] {
    const chips: SuggestionChip[] = [];
    const texts: string[] = ['查看租约概况', '查询备选房源', '记一套新房源', '删除房源记录'];
    for (const t of texts) {
      const chip: SuggestionChip = new SuggestionChip();
      chip.text = t;
      chip.reply = t;
      chips.push(chip);
    }
    return chips;
  }

  static async queryOverview(): Promise<SkillResult> {
    const result: SkillResult = new SkillResult();
    const repo: PropertyRepository = PropertyRepository.getInstance();
    await repo.reloadData();
    const overview: StatisticsOverview = repo.getStatisticsOverview();
    const reminderDays: number = repo.getReminderDays();
    const expiring: PropertyInfo[] = repo.getExpiringProperties(reminderDays);
    const expiringItems: ExpiringItem[] = [];
    for (const p of expiring) {
      const item: ExpiringItem = new ExpiringItem();
      item.name = p.name;
      item.endDate = p.endDate;
      item.remainingDays = RentAgentSkillHandler.calcRemainingDays(p.endDate);
      expiringItems.push(item);
    }
    if (expiringItems.length === 0) {
      result.summary = `当前共${overview.rentingCount}套在租房源，平均月租${overview.monthlyAvgRent}元，暂无${reminderDays}天内到期的租约。`;
    } else {
      const nearest: ExpiringItem = expiringItems[0];
      result.summary = `有${expiringItems.length}套租约将在${reminderDays}天内到期，最近的是"${nearest.name}"（剩${nearest.remainingDays}天），建议尽快联系租客确认续约或安排退租交接。`;
    }
    result.data = {
      'rentingCount': overview.rentingCount,
      'monthlyAvgRent': overview.monthlyAvgRent,
      'reminderDays': reminderDays,
      'expiring': expiringItems
    };
    return result;
  }

  static async addProperty(params: Record<string, Object>): Promise<SkillResult> {
    const result: SkillResult = new SkillResult();
    const name: string = ((params['name'] as string) ?? '').trim();
    if (name.length === 0) {
      result.state = SkillState.INPUT_REQUIRED;
      result.summary = '请提供房源名称，例如"帮我记一套房：阳光小区2栋301，月租2500，押金5000"。';
      return result;
    }
    const repo: PropertyRepository = PropertyRepository.getInstance();
    await repo.reloadData();
    const property: PropertyInfo = new PropertyInfo();
    property.name = name;
    property.address = (params['address'] as string) ?? '';
    property.district = (params['district'] as string) ?? '';
    property.monthlyRent = (params['monthlyRent'] as number) ?? 0;
    property.deposit = (params['deposit'] as number) ?? 0;
    property.startDate = (params['startDate'] as string) ?? '';
    property.endDate = (params['endDate'] as string) ?? '';
    property.notes = (params['notes'] as string) ?? '';
    const statusParam: string = (params['status'] as string) ?? '';
    property.status = statusParam === 'renting' ? 'renting' : 'candidate';
    await repo.addProperty(property);
    const statusLabel: string = property.status === 'candidate' ? '已记入备选' : '已记入在租';
    let summary: string = `${statusLabel}房源"${property.name}"`;
    if (property.monthlyRent > 0) {
      summary = summary + `，月租${property.monthlyRent}元`;
    }
    if (property.deposit > 0) {
      summary = summary + `，押金${property.deposit}元`;
    }
    if (property.endDate.length > 0) {
      summary = summary + `，到期日${property.endDate}`;
    }
    result.summary = summary + '。';
    result.data = {
      'propertyId': property.id,
      'name': property.name,
      'status': statusLabel
    };
    return result;
  }

  static async queryCandidates(): Promise<SkillResult> {
    const result: SkillResult = new SkillResult();
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
    if (items.length === 0) {
      result.summary = '当前没有记录备选房源，看房时可以让我帮你记录。';
    } else {
      const names: string[] = [];
      for (const item of items) {
        if (item.monthlyRent > 0) {
          names.push(`${item.name}（月租${item.monthlyRent}元）`);
        } else {
          names.push(item.name);
        }
      }
      result.summary = `共记录了${items.length}套备选房源：${names.join('、')}。可以在备选页查看详情，确定租房后可转正在租。`;
    }
    result.data = {
      'count': items.length,
      'candidates': items
    };
    return result;
  }

  static async deleteProperty(params: Record<string, Object>): Promise<SkillResult> {
    const result: SkillResult = new SkillResult();
    const name: string = ((params['name'] as string) ?? '').trim();
    if (name.length === 0) {
      result.state = SkillState.INPUT_REQUIRED;
      result.summary = '请告诉我要删除的房源名称，例如"把阳光小区2栋301删了"。';
      return result;
    }
    const repo: PropertyRepository = PropertyRepository.getInstance();
    await repo.reloadData();
    const statusFilter: string = (params['status'] as string) ?? '';
    let pool: PropertyInfo[] = [...repo.getCandidates(), ...repo.getRentingProperties()];
    if (statusFilter === 'candidate' || statusFilter === 'renting') {
      pool = pool.filter((p: PropertyInfo): boolean => {
        if (statusFilter === 'candidate') {
          return p.status === 'candidate';
        }
        return p.status === 'renting' || p.status === 'expiring';
      });
    }
    let matched: PropertyInfo[] = pool.filter((p: PropertyInfo): boolean => p.name === name);
    if (matched.length === 0) {
      matched = pool.filter((p: PropertyInfo): boolean => p.name.includes(name) || name.includes(p.name));
    }
    if (matched.length === 0) {
      result.state = SkillState.FAILED;
      result.summary = `未找到名为"${name}"的房源记录。`;
      return result;
    }
    if (matched.length > 1) {
      const names: string[] = matched.map((p: PropertyInfo): string => {
        return `${p.name}（${p.status === 'candidate' ? '备选' : '在租'}）`;
      });
      result.state = SkillState.INPUT_REQUIRED;
      result.summary = `找到${matched.length}套匹配的房源：${names.join('、')}，请说明要删除哪一套。`;
      result.data = {
        'matched': names
      };
      return result;
    }
    const target: PropertyInfo = matched[0];
    const deletedName: string = target.name;
    const deletedStatusLabel: string = target.status === 'candidate' ? '备选' : '在租';
    await repo.deleteProperty(target.id);
    result.summary = `已删除${deletedStatusLabel}房源"${deletedName}"。`;
    result.data = {
      'deletedName': deletedName,
      'status': deletedStatusLabel
    };
    return result;
  }

  static calcRemainingDays(endDate: string): number {
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
}
