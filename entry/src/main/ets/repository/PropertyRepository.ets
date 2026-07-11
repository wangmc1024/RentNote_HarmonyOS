import { preferences } from '@kit.ArkData';
import { PropertyInfo, PropertyDTO, StatisticsOverview, MonthlyRentItem, LeaseTimelineItem, UserProfileDTO, UserProfile } from '../model/PropertyModel';
import EntryFormAbility from '../widget/EntryFormAbility';

const PREFS_NAME: string = 'RentNotePrefs';
const KEY_PROPERTIES: string = 'properties';
const KEY_NEXT_ID: string = 'next_id';
const KEY_VERSION: string = 'data_version';
const KEY_USER_PROFILE: string = 'user_profile';
const KEY_REMINDER_ENABLED: string = 'reminder_enabled';
const KEY_REMINDER_DAYS: string = 'reminder_days';
const KEY_PUSH_ENABLED: string = 'push_enabled';
const KEY_SOUND_ENABLED: string = 'sound_enabled';
const KEY_VIBRATE_ENABLED: string = 'vibrate_enabled';
const DATA_VERSION: number = 4;

@ObservedV2
export class PropertyRepository {
  @Trace properties: PropertyInfo[] = [];
  private prefs: preferences.Preferences | null = null;
  private static instance: PropertyRepository | null = null;
  private initContext: Context | null = null;
  private isInitialized: boolean = false;

  static getInstance(): PropertyRepository {
    if (!PropertyRepository.instance) {
      PropertyRepository.instance = new PropertyRepository();
    }
    return PropertyRepository.instance;
  }

  constructor() {
  }

  private safeGetSync(key: string, defaultValue: Object): Object {
    try {
      return this.prefs!.getSync(key, defaultValue);
    } catch (_e) {
      return defaultValue;
    }
  }

  private safePutSync(key: string, value: Object): void {
    try {
      this.prefs!.putSync(key, value);
    } catch (_e) {
    }
  }

  private async safeFlush(): Promise<void> {
    try {
      await this.prefs!.flush();
    } catch (_e) {
    }
  }

  async init(context: Context): Promise<void> {
    this.initContext = context;
    try {
      this.prefs = await preferences.getPreferences(context, PREFS_NAME);
    } catch (_e) {
      return;
    }
    const storedVersion: number = this.safeGetSync(KEY_VERSION, 0) as number;
    if (storedVersion === 0) {
      this.safePutSync(KEY_PROPERTIES, '[]');
      this.safePutSync(KEY_NEXT_ID, 1);
      this.safePutSync(KEY_VERSION, DATA_VERSION);
      await this.safeFlush();
      await this.insertMockData();
    } else if (storedVersion < DATA_VERSION) {
      this.loadFromPrefs();
      this.safePutSync(KEY_VERSION, DATA_VERSION);
      const dtoList: PropertyDTO[] = [];
      for (const p of this.properties) {
        dtoList.push(p.toDTO());
      }
      this.safePutSync(KEY_PROPERTIES, JSON.stringify(dtoList));
      await this.safeFlush();
    }
    this.loadFromPrefs();
    this.isInitialized = true;
  }

  private async ensureInit(): Promise<void> {
    if (this.isInitialized) {
      return;
    }
    for (let i: number = 0; i < 100; i++) {
      await new Promise<void>((resolve: Function) => setTimeout(() => { resolve(); }, 50));
      if (this.isInitialized) {
        return;
      }
    }
  }

  private loadFromPrefs(): void {
    if (!this.prefs) {
      return;
    }
    const json: string = this.safeGetSync(KEY_PROPERTIES, '[]') as string;
    if (json.length === 0 || json === '[]') {
      this.properties = [];
      return;
    }
    const cleaned: string = json.replace(/"__ob_/g, '"');
    const rawList: Object[] = JSON.parse(cleaned) as Object[];
    const list: PropertyInfo[] = [];
    for (const rawObj of rawList) {
      const raw: Record<string, Object> = rawObj as Record<string, Object>;
      const p: PropertyInfo = new PropertyInfo();
      p.id = (raw['id'] as string) ?? '';
      p.name = (raw['name'] as string) ?? '';
      p.address = (raw['address'] as string) ?? '';
      p.district = (raw['district'] as string) ?? '';
      p.tags = (raw['tags'] as string[]) ?? [];
      p.monthlyRent = (raw['monthlyRent'] as number) ?? 0;
      p.deposit = (raw['deposit'] as number) ?? 0;
      p.startDate = (raw['startDate'] as string) ?? '';
      p.endDate = (raw['endDate'] as string) ?? '';
      p.status = (raw['status'] as string) ?? 'renting';
      p.billsPaid = (raw['billsPaid'] as number) ?? 0;
      const imageUrls: string[] = (raw['imageUrls'] as string[]) ?? [];
      const imageUrl: string = (raw['imageUrl'] as string) ?? '';
      if (imageUrls.length > 0) {
        p.imageUrls = imageUrls;
      } else if (imageUrl.length > 0) {
        p.imageUrls = [imageUrl];
      }
      p.notes = (raw['notes'] as string) ?? '';
      p.renewalStatus = (raw['renewalStatus'] as string) ?? '';
      p.latitude = (raw['latitude'] as number) ?? 0;
      p.longitude = (raw['longitude'] as number) ?? 0;
      list.push(p);
    }
    this.properties = list;
  }

  private async saveToPrefs(): Promise<void> {
    const dtoList: PropertyDTO[] = [];
    for (const p of this.properties) {
      dtoList.push(p.toDTO());
    }
    const json: string = JSON.stringify(dtoList);
    this.safePutSync(KEY_PROPERTIES, json);
    await this.safeFlush();
  }

  private notifyWidgetUpdate(): void {
    if (this.initContext) {
      EntryFormAbility.notifyUpdate(this.initContext);
    }
  }

  private async insertMockData(): Promise<void> {
    const mockList: PropertyInfo[] = [];
    const p1: PropertyInfo = new PropertyInfo();
    p1.id = '1';
    p1.name = '碧水湾公寓';
    p1.address = '朝阳区望京西园 2栋301';
    p1.district = '朝阳区';
    p1.tags = ['近地铁', '精装修', '押一付三', '民水民电', '有电梯'];
    p1.monthlyRent = 6200;
    p1.deposit = 6200;
    p1.startDate = '2024.03.01';
    p1.endDate = '2024.12.31';
    p1.status = 'candidate';
    p1.billsPaid = 0;
    p1.imageUrls = [];
    p1.notes = '';
    p1.renewalStatus = '';
    p1.latitude = 39.994;
    p1.longitude = 116.474;
    mockList.push(p1);

    const p2: PropertyInfo = new PropertyInfo();
    p2.id = '2';
    p2.name = '阳光花园小区';
    p2.address = '朝阳区望京街道 3栋502';
    p2.district = '朝阳区';
    p2.tags = ['学区房', '南北通透', '整租', '包物业', '朝南'];
    p2.monthlyRent = 4500;
    p2.deposit = 9000;
    p2.startDate = '2024.03.15';
    p2.endDate = '2025.03.15';
    p2.status = 'renting';
    p2.billsPaid = 6;
    p2.imageUrls = [];
    p2.notes = '';
    p2.renewalStatus = 'renew';
    p2.latitude = 39.988;
    p2.longitude = 116.471;
    mockList.push(p2);

    const p3: PropertyInfo = new PropertyInfo();
    p3.id = '3';
    p3.name = '翠竹苑';
    p3.address = '海淀区中关村南大街 12号';
    p3.district = '海淀区';
    p3.tags = ['科技园区', '新小区', '整租', '精装修', '可短租', '有电梯'];
    p3.monthlyRent = 7800;
    p3.deposit = 7800;
    p3.startDate = '2024.01.01';
    p3.endDate = '2026.01.01';
    p3.status = 'candidate';
    p3.billsPaid = 12;
    p3.imageUrls = [];
    p3.notes = '';
    p3.renewalStatus = '';
    p3.latitude = 39.959;
    p3.longitude = 116.316;
    mockList.push(p3);

    const p4: PropertyInfo = new PropertyInfo();
    p4.id = '4';
    p4.name = '望京SOHO公寓';
    p4.address = '';
    p4.district = '';
    p4.tags = ['近地铁', '精装修', '整租', '民水民电'];
    p4.monthlyRent = 0;
    p4.deposit = 0;
    p4.startDate = '';
    p4.endDate = '';
    p4.status = 'candidate';
    p4.billsPaid = 0;
    p4.imageUrls = [];
    p4.notes = '';
    p4.renewalStatus = '';
    p4.latitude = 39.993;
    p4.longitude = 116.477;
    mockList.push(p4);

    const p5: PropertyInfo = new PropertyInfo();
    p5.id = '5';
    p5.name = '回龙观新村';
    p5.address = '';
    p5.district = '';
    p5.tags = ['整租', '南北通透', '新小区', '房东好说话'];
    p5.monthlyRent = 0;
    p5.deposit = 0;
    p5.startDate = '';
    p5.endDate = '';
    p5.status = 'candidate';
    p5.billsPaid = 0;
    p5.imageUrls = [];
    p5.notes = '';
    p5.renewalStatus = '';
    p5.latitude = 40.074;
    p5.longitude = 116.344;
    mockList.push(p5);

    this.properties = mockList;
    this.safePutSync(KEY_NEXT_ID, 6);
    await this.saveToPrefs();
  }

  private getNextId(): string {
    const nextId: number = (this.safeGetSync(KEY_NEXT_ID, 1) as number);
    return String(nextId);
  }

  private async consumeNextId(): Promise<string> {
    const id: string = this.getNextId();
    const nextVal: number = (this.safeGetSync(KEY_NEXT_ID, 1) as number) + 1;
    this.safePutSync(KEY_NEXT_ID, nextVal);
    await this.safeFlush();
    return id;
  }

  async reloadData(): Promise<void> {
    await this.ensureInit();
    this.loadFromPrefs();
  }

  getAllProperties(): PropertyInfo[] {
    return this.properties;
  }

  getPropertyById(id: string): PropertyInfo | undefined {
    return this.properties.find((item: PropertyInfo) => item.id === id);
  }

  async addProperty(property: PropertyInfo): Promise<void> {
    if (!property.id) {
      property.id = await this.consumeNextId();
    }
    this.properties = [...this.properties, property];
    await this.saveToPrefs();
    this.notifyWidgetUpdate();
  }

  async updateProperty(property: PropertyInfo): Promise<void> {
    const index: number = this.properties.findIndex((item: PropertyInfo) => item.id === property.id);
    if (index >= 0) {
      const newList: PropertyInfo[] = [...this.properties];
      newList[index] = property;
      this.properties = newList;
      await this.saveToPrefs();
      this.notifyWidgetUpdate();
    }
  }

  async deleteProperty(id: string): Promise<void> {
    this.properties = this.properties.filter((item: PropertyInfo) => item.id !== id);
    await this.saveToPrefs();
    this.notifyWidgetUpdate();
  }

  getCandidates(): PropertyInfo[] {
    return this.properties.filter((item: PropertyInfo) => item.status === 'candidate');
  }

  getRentingProperties(): PropertyInfo[] {
    return this.properties.filter(
      (item: PropertyInfo) => item.status === 'renting' || item.status === 'expiring'
    );
  }

  async promoteCandidate(id: string): Promise<void> {
    const newList: PropertyInfo[] = [...this.properties];
    for (let i: number = 0; i < newList.length; i++) {
      if (newList[i].status === 'renting' || newList[i].status === 'expiring') {
        const demoted: PropertyInfo = newList[i].clone();
        demoted.status = 'candidate';
        demoted.startDate = '';
        demoted.endDate = '';
        demoted.renewalStatus = '';
        newList[i] = demoted;
      }
    }
    const index: number = newList.findIndex((item: PropertyInfo) => item.id === id);
    if (index >= 0) {
      const promoted: PropertyInfo = newList[index].clone();
      promoted.status = 'renting';
      newList[index] = promoted;
    }
    this.properties = newList;
    await this.saveToPrefs();
    this.notifyWidgetUpdate();
  }

  async demoteRenting(id: string): Promise<void> {
    const index: number = this.properties.findIndex((item: PropertyInfo) => item.id === id);
    if (index >= 0) {
      const current: PropertyInfo = this.properties[index];
      if (current.status !== 'renting' && current.status !== 'expiring') {
        return;
      }
      const newList: PropertyInfo[] = [...this.properties];
      const demoted: PropertyInfo = newList[index].clone();
      demoted.status = 'candidate';
      demoted.startDate = '';
      demoted.endDate = '';
      demoted.renewalStatus = '';
      newList[index] = demoted;
      this.properties = newList;
      await this.saveToPrefs();
      this.notifyWidgetUpdate();
    }
  }

  async batchDelete(ids: string[]): Promise<void> {
    this.properties = this.properties.filter((item: PropertyInfo) => !ids.includes(item.id));
    await this.saveToPrefs();
    this.notifyWidgetUpdate();
  }

  async clearAll(): Promise<void> {
    this.properties = [];
    this.safePutSync(KEY_NEXT_ID, 1);
    this.safePutSync(KEY_USER_PROFILE, '');
    await this.saveToPrefs();
    this.notifyWidgetUpdate();
  }

  getStatisticsOverview(): StatisticsOverview {
    const renting: PropertyInfo[] = this.properties.filter(
      (item: PropertyInfo) => item.status === 'renting' || item.status === 'expiring'
    );
    const totalRent: number = renting.reduce((sum: number, item: PropertyInfo) => sum + item.monthlyRent, 0);
    const count: number = renting.length;

    const overview: StatisticsOverview = new StatisticsOverview();
    overview.yearlyExpense = totalRent * 12;
    overview.monthlyAvgRent = count > 0 ? Math.round(totalRent / count) : 0;
    overview.rentingCount = count;
    return overview;
  }

  getMonthlyRentItems(): MonthlyRentItem[] {
    const months: string[] = ['2月', '3月', '4月', '5月', '6月', '7月'];
    const renting: PropertyInfo[] = this.properties.filter(
      (item: PropertyInfo) => item.status === 'renting' || item.status === 'expiring'
    );
    const totalRent: number = renting.reduce((sum: number, item: PropertyInfo) => sum + item.monthlyRent, 0);

    const items: MonthlyRentItem[] = [];
    for (let i: number = 0; i < months.length; i++) {
      const variation: number = Math.round(totalRent * (0.7 + i * 0.06));
      const item: MonthlyRentItem = new MonthlyRentItem();
      item.month = months[i];
      item.amount = variation;
      items.push(item);
    }
    return items;
  }

  getExpiringProperties(days: number): PropertyInfo[] {
    const now: Date = new Date();
    now.setHours(0, 0, 0, 0);
    return this.properties.filter((item: PropertyInfo) => {
      if (item.status !== 'renting' && item.status !== 'expiring') {
        return false;
      }
      if (!item.endDate || item.endDate.length === 0) {
        return false;
      }
      const parts: string[] = item.endDate.split('.');
      if (parts.length !== 3) {
        return false;
      }
      const expiry: Date = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10));
      const diff: number = expiry.getTime() - now.getTime();
      const remainingDays: number = Math.ceil(diff / (1000 * 60 * 60 * 24));
      return remainingDays >= 0 && remainingDays <= days;
    });
  }

  getLeaseTimelineItems(): LeaseTimelineItem[] {
    const items: LeaseTimelineItem[] = [];
    const renting: PropertyInfo[] = this.properties.filter(
      (item: PropertyInfo) => item.status === 'renting' || item.status === 'expiring'
    );
    for (const property of renting) {
      const startParts: string[] = property.startDate.split('.');
      const endParts: string[] = property.endDate.split('.');
      if (startParts.length >= 2 && endParts.length >= 2) {
        const item: LeaseTimelineItem = new LeaseTimelineItem();
        item.propertyId = property.id;
        item.name = property.name;
        item.monthlyRent = property.monthlyRent;
        item.startYear = parseInt(startParts[0], 10) || 2024;
        item.startMonth = parseInt(startParts[1], 10) || 1;
        item.endYear = parseInt(endParts[0], 10) || 2025;
        item.endMonth = parseInt(endParts[1], 10) || 1;
        item.isExpiring = property.status === 'expiring';
        items.push(item);
      }
    }
    return items;
  }

  getUserProfile(): UserProfile {
    const profile: UserProfile = new UserProfile();
    if (!this.prefs) {
      return profile;
    }
    const json: string = this.safeGetSync(KEY_USER_PROFILE, '') as string;
    if (json.length === 0) {
      return profile;
    }
    const dto: UserProfileDTO = JSON.parse(json) as UserProfileDTO;
    profile.name = dto.name ?? '';
    profile.subtitle = dto.subtitle ?? '';
    profile.avatarUri = dto.avatarUri ?? '';
    return profile;
  }

  async saveUserProfile(profile: UserProfile): Promise<void> {
    const dto: UserProfileDTO = new UserProfileDTO();
    dto.name = profile.name;
    dto.subtitle = profile.subtitle;
    dto.avatarUri = profile.avatarUri;
    const json: string = JSON.stringify(dto);
    this.safePutSync(KEY_USER_PROFILE, json);
    await this.safeFlush();
  }

  async importFromJson(jsonStr: string): Promise<number> {
    let imported: number = 0;
    try {
      const rawList: Object[] = JSON.parse(jsonStr) as Object[];
      if (!Array.isArray(rawList)) {
        return 0;
      }
      const existingIds: Set<string> = new Set<string>();
      for (const p of this.properties) {
        existingIds.add(p.id);
      }
      let hasRentingImport: boolean = false;
      for (const rawObj of rawList) {
        const raw: Record<string, Object> = rawObj as Record<string, Object>;
        const name: string = (raw['name'] as string) ?? '';
        if (!name || name.trim().length === 0) {
          continue;
        }
        const rawId: string = (raw['id'] as string) ?? '';
        if (rawId.length > 0 && existingIds.has(rawId)) {
          continue;
        }
        const p: PropertyInfo = new PropertyInfo();
        p.id = rawId.length > 0 ? rawId : Date.now().toString() + '_' + imported;
        p.name = name;
        p.address = (raw['address'] as string) ?? '';
        p.district = (raw['district'] as string) ?? '';
        p.tags = (raw['tags'] as string[]) ?? [];
        p.monthlyRent = (raw['monthlyRent'] as number) ?? 0;
        p.deposit = (raw['deposit'] as number) ?? 0;
        p.startDate = (raw['startDate'] as string) ?? '';
        p.endDate = (raw['endDate'] as string) ?? '';
        p.status = (raw['status'] as string) ?? 'candidate';
        p.billsPaid = (raw['billsPaid'] as number) ?? 0;
        const imgUrls: string[] = (raw['imageUrls'] as string[]) ?? [];
        const imgUrl: string = (raw['imageUrl'] as string) ?? '';
        if (imgUrls.length > 0) {
          p.imageUrls = imgUrls;
        } else if (imgUrl.length > 0) {
          p.imageUrls = [imgUrl];
        }
        p.notes = (raw['notes'] as string) ?? '';
        p.renewalStatus = (raw['renewalStatus'] as string) ?? '';
        p.latitude = (raw['latitude'] as number) ?? 0;
        p.longitude = (raw['longitude'] as number) ?? 0;
        if (p.status === 'renting' || p.status === 'expiring') {
          hasRentingImport = true;
        }
        this.properties = [...this.properties, p];
        existingIds.add(p.id);
        imported++;
      }
      if (imported > 0) {
        if (hasRentingImport) {
          const rentingList: PropertyInfo[] = this.getRentingProperties();
          if (rentingList.length > 1) {
            const toDemote: PropertyInfo[] = rentingList.slice(0, rentingList.length - 1);
            for (const r of toDemote) {
              const idx: number = this.properties.findIndex((item: PropertyInfo) => item.id === r.id);
              if (idx >= 0) {
                const d: PropertyInfo = this.properties[idx].clone();
                d.status = 'candidate';
                d.startDate = '';
                d.endDate = '';
                d.renewalStatus = '';
                const newList: PropertyInfo[] = [...this.properties];
                newList[idx] = d;
                this.properties = newList;
              }
            }
          }
        }
        await this.saveToPrefs();
        this.notifyWidgetUpdate();
      }
    } catch (_e) {
      return 0;
    }
    return imported;
  }

  exportToJson(): string {
    const dtoList: PropertyDTO[] = [];
    for (const p of this.properties) {
      dtoList.push(p.toDTO());
    }
    return JSON.stringify(dtoList, null, 2);
  }

  getReminderEnabled(): boolean {
    if (!this.prefs) {
      return true;
    }
    return this.safeGetSync(KEY_REMINDER_ENABLED, true) as boolean;
  }

  async saveReminderEnabled(enabled: boolean): Promise<void> {
    this.safePutSync(KEY_REMINDER_ENABLED, enabled);
    await this.safeFlush();
  }

  getReminderDays(): number {
    if (!this.prefs) {
      return 30;
    }
    return this.safeGetSync(KEY_REMINDER_DAYS, 30) as number;
  }

  async saveReminderDays(days: number): Promise<void> {
    this.safePutSync(KEY_REMINDER_DAYS, days);
    await this.safeFlush();
  }

  getPushEnabled(): boolean {
    if (!this.prefs) {
      return true;
    }
    return this.safeGetSync(KEY_PUSH_ENABLED, true) as boolean;
  }

  async savePushEnabled(enabled: boolean): Promise<void> {
    this.safePutSync(KEY_PUSH_ENABLED, enabled);
    await this.safeFlush();
  }

  getSoundEnabled(): boolean {
    if (!this.prefs) {
      return true;
    }
    return this.safeGetSync(KEY_SOUND_ENABLED, true) as boolean;
  }

  async saveSoundEnabled(enabled: boolean): Promise<void> {
    this.safePutSync(KEY_SOUND_ENABLED, enabled);
    await this.safeFlush();
  }

  getVibrateEnabled(): boolean {
    if (!this.prefs) {
      return false;
    }
    return this.safeGetSync(KEY_VIBRATE_ENABLED, false) as boolean;
  }

  async saveVibrateEnabled(enabled: boolean): Promise<void> {
    this.safePutSync(KEY_VIBRATE_ENABLED, enabled);
    await this.safeFlush();
  }
}
