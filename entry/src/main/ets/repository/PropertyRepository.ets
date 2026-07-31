import { preferences } from '@kit.ArkData';
import { util } from '@kit.ArkTS';
import { fileIo as fs } from '@kit.CoreFileKit';
import { PropertyInfo, PropertyDTO, StatisticsOverview, UserProfileDTO, UserProfile, ImportResult } from '../model/PropertyModel';
import EntryFormAbility from '../widget/EntryFormAbility';
import { ReminderService } from '../service/ReminderService';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'PropertyRepo';

const PREFS_NAME: string = 'RentNotePrefs';
const KEY_PROPERTIES: string = 'properties';
const KEY_VERSION: string = 'data_version';
const KEY_USER_PROFILE: string = 'user_profile';
const KEY_REMINDER_ENABLED: string = 'reminder_enabled';
const KEY_REMINDER_DAYS: string = 'reminder_days';
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

  private uriToPath(uri: string): string {
    if (uri.startsWith('file://')) {
      const idx1: number = uri.indexOf('/data/');
      const idx2: number = uri.indexOf('/storage/');
      if (idx1 >= 0) {
        return uri.substring(idx1);
      }
      if (idx2 >= 0) {
        return uri.substring(idx2);
      }
    }
    return uri;
  }

  private deleteImageFiles(property: PropertyInfo): void {
    for (const uri of property.imageUrls) {
      try {
        const filePath: string = this.uriToPath(uri);
        if (filePath.startsWith('/data/') || filePath.startsWith('/storage/')) {
          if (fs.accessSync(filePath)) {
            fs.unlinkSync(filePath);
          }
        }
      } catch (_e) {
      }
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
      this.safePutSync(KEY_VERSION, DATA_VERSION);
      await this.safeFlush();
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
    const cleaned: string = json.replace(new RegExp('"__ob_', 'g'), '"');
    let rawList: Object[];
    try {
      rawList = JSON.parse(cleaned) as Object[];
    } catch (_e) {
      hilog.error(0, TAG, 'loadFromPrefs: JSON parse failed, resetting data');
      this.properties = [];
      this.safePutSync(KEY_PROPERTIES, '[]');
      this.safeFlush();
      return;
    }
    const list: PropertyInfo[] = [];
    for (const rawObj of rawList) {
      try {
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
        p.lastBillsResetMonth = (raw['lastBillsResetMonth'] as string) ?? '';
        list.push(p);
      } catch (_e) {
        hilog.error(0, TAG, 'loadFromPrefs: skipping corrupted entry');
      }
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

  private refreshReminders(): void {
    ReminderService.getInstance().markPending();
  }

  async reloadData(): Promise<void> {
    await this.ensureInit();
    this.loadFromPrefs();
  }

  getPropertyById(id: string): PropertyInfo | undefined {
    return this.properties.find((item: PropertyInfo) => item.id === id);
  }

  async addProperty(property: PropertyInfo): Promise<void> {
    if (!property.id) {
      property.id = Date.now().toString();
    }
    this.properties = [...this.properties, property];
    await this.saveToPrefs();
    this.notifyWidgetUpdate();
    this.refreshReminders();
  }

  async updateProperty(property: PropertyInfo): Promise<void> {
    const index: number = this.properties.findIndex((item: PropertyInfo) => item.id === property.id);
    if (index >= 0) {
      const old: PropertyInfo = this.properties[index];
      const newUrls: Set<string> = new Set(property.imageUrls);
      for (const uri of old.imageUrls) {
        if (!newUrls.has(uri)) {
          try {
            const filePath: string = this.uriToPath(uri);
            if (filePath.startsWith('/data/') || filePath.startsWith('/storage/')) {
              if (fs.accessSync(filePath)) {
                fs.unlinkSync(filePath);
              }
            }
          } catch (_e) {
          }
        }
      }
      const newList: PropertyInfo[] = [...this.properties];
      newList[index] = property;
      this.properties = newList;
      await this.saveToPrefs();
      this.notifyWidgetUpdate();
      this.refreshReminders();
    }
  }

  async deleteProperty(id: string): Promise<void> {
    const target: PropertyInfo | undefined = this.properties.find((item: PropertyInfo) => item.id === id);
    if (target) {
      this.deleteImageFiles(target);
    }
    this.properties = this.properties.filter((item: PropertyInfo) => item.id !== id);
    await this.saveToPrefs();
    this.notifyWidgetUpdate();
    this.refreshReminders();
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
    hilog.info(0, TAG, 'promoteCandidate: id=' + id + ' total=' + this.properties.length);
    const targetIndex: number = this.properties.findIndex((item: PropertyInfo) => item.id === id);
    hilog.info(0, TAG, 'promoteCandidate: findIndex=' + targetIndex);
    if (targetIndex < 0) {
      hilog.error(0, TAG, 'promoteCandidate: id not found in list!');
      return;
    }
    const newList: PropertyInfo[] = [...this.properties];
    for (let i: number = 0; i < newList.length; i++) {
      if (newList[i].status === 'renting' || newList[i].status === 'expiring') {
        hilog.info(0, TAG, 'promoteCandidate: demoting existing renting id=' + newList[i].id);
        const demoted: PropertyInfo = newList[i].clone();
        demoted.status = 'candidate';
        demoted.startDate = '';
        demoted.endDate = '';
        demoted.renewalStatus = '';
        newList[i] = demoted;
      }
    }
    const promoted: PropertyInfo = newList[targetIndex].clone();
    promoted.status = 'renting';
    newList[targetIndex] = promoted;
    hilog.info(0, TAG, 'promoteCandidate: promoted id=' + id + ' status=' + newList[targetIndex].status);
    this.properties = newList;
    await this.saveToPrefs();
    this.notifyWidgetUpdate();
    this.refreshReminders();
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
      this.refreshReminders();
    }
  }

  async updateBillsPaid(id: string, billsPaid: number): Promise<void> {
    const index: number = this.properties.findIndex((item: PropertyInfo) => item.id === id);
    if (index >= 0) {
      const newList: PropertyInfo[] = [...this.properties];
      const updated: PropertyInfo = newList[index].clone();
      updated.billsPaid = billsPaid;
      if (billsPaid > 0) {
        const now: Date = new Date();
        updated.lastBillsResetMonth = now.getFullYear().toString() + '.' + (now.getMonth() + 1).toString().padStart(2, '0');
      }
      newList[index] = updated;
      this.properties = newList;
      await this.saveToPrefs();
      this.notifyWidgetUpdate();
      this.refreshReminders();
    }
  }

  async checkAndResetBillsPaidMonthly(): Promise<void> {
    const now: Date = new Date();
    const currentMonth: string = now.getFullYear().toString() + '.' + (now.getMonth() + 1).toString().padStart(2, '0');
    let needSave: boolean = false;
    const newList: PropertyInfo[] = [...this.properties];
    for (let i: number = 0; i < newList.length; i++) {
      const p: PropertyInfo = newList[i];
      if (p.status === 'renting' || p.status === 'expiring') {
        if (p.lastBillsResetMonth !== currentMonth) {
          const updated: PropertyInfo = p.clone();
          updated.billsPaid = 0;
          updated.lastBillsResetMonth = currentMonth;
          newList[i] = updated;
          needSave = true;
        }
      }
    }
    if (needSave) {
      this.properties = newList;
      await this.saveToPrefs();
      this.notifyWidgetUpdate();
      this.refreshReminders();
    }
  }

  async clearAll(): Promise<void> {
    for (const p of this.properties) {
      this.deleteImageFiles(p);
    }
    this.properties = [];
    this.safePutSync(KEY_USER_PROFILE, '');
    await this.saveToPrefs();
    this.notifyWidgetUpdate();
    this.refreshReminders();
  }

  getStatisticsOverview(): StatisticsOverview {
    const renting: PropertyInfo[] = this.properties.filter(
      (item: PropertyInfo) => item.status === 'renting' || item.status === 'expiring'
    );
    const totalRent: number = renting.reduce((sum: number, item: PropertyInfo) => sum + item.monthlyRent, 0);
    const count: number = renting.length;

    const overview: StatisticsOverview = new StatisticsOverview();
    overview.monthlyAvgRent = count > 0 ? Math.round(totalRent / count) : 0;
    overview.rentingCount = count;
    return overview;
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

  getUserProfile(): UserProfile {
    const profile: UserProfile = new UserProfile();
    if (!this.prefs) {
      return profile;
    }
    const json: string = this.safeGetSync(KEY_USER_PROFILE, '') as string;
    if (json.length === 0) {
      return profile;
    }
    let dto: UserProfileDTO;
    try {
      dto = JSON.parse(json) as UserProfileDTO;
    } catch (_e) {
      return profile;
    }
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

  async importFromJson(jsonStr: string): Promise<ImportResult> {
    const result: ImportResult = new ImportResult();
    try {
      const rawList: Object[] = JSON.parse(jsonStr) as Object[];
      if (!Array.isArray(rawList)) {
        return result;
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
          const existIdx: number = this.properties.findIndex((item: PropertyInfo) => item.id === rawId);
          if (existIdx >= 0) {
            const updated: PropertyInfo = this.properties[existIdx].clone();
            updated.name = name;
            const addr: string = (raw['address'] as string) ?? '';
            if (addr.length > 0) {
              updated.address = addr;
            }
            const district: string = (raw['district'] as string) ?? '';
            if (district.length > 0) {
              updated.district = district;
            }
            const tags: string[] = (raw['tags'] as string[]) ?? [];
            if (tags.length > 0) {
              updated.tags = tags;
            }
            updated.monthlyRent = (raw['monthlyRent'] as number) ?? 0;
            updated.deposit = (raw['deposit'] as number) ?? 0;
            const startDate: string = (raw['startDate'] as string) ?? '';
            if (startDate.length > 0) {
              updated.startDate = startDate;
            }
            const endDate: string = (raw['endDate'] as string) ?? '';
            if (endDate.length > 0) {
              updated.endDate = endDate;
            }
            const status: string = (raw['status'] as string) ?? '';
            if (status.length > 0) {
              updated.status = status;
            }
            updated.billsPaid = (raw['billsPaid'] as number) ?? 0;
            const imgUrls: string[] = (raw['imageUrls'] as string[]) ?? [];
            const imgUrl: string = (raw['imageUrl'] as string) ?? '';
            if (imgUrls.length > 0) {
              updated.imageUrls = imgUrls;
            } else if (imgUrl.length > 0) {
              updated.imageUrls = [imgUrl];
            }
            const notes: string = (raw['notes'] as string) ?? '';
            if (notes.length > 0) {
              updated.notes = notes;
            }
            const renewalStatus: string = (raw['renewalStatus'] as string) ?? '';
            if (renewalStatus.length > 0) {
              updated.renewalStatus = renewalStatus;
            }
            updated.latitude = (raw['latitude'] as number) ?? 0;
            updated.longitude = (raw['longitude'] as number) ?? 0;
            const lastBillsResetMonth: string = (raw['lastBillsResetMonth'] as string) ?? '';
            if (lastBillsResetMonth.length > 0) {
              updated.lastBillsResetMonth = lastBillsResetMonth;
            }
            if (updated.status === 'renting' || updated.status === 'expiring') {
              hasRentingImport = true;
            }
            const newList: PropertyInfo[] = [...this.properties];
            newList[existIdx] = updated;
            this.properties = newList;
            result.updated++;
          }
          continue;
        }
        const p: PropertyInfo = new PropertyInfo();
        p.id = rawId.length > 0 ? rawId : Date.now().toString() + '_' + result.imported;
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
        p.lastBillsResetMonth = (raw['lastBillsResetMonth'] as string) ?? '';
        if (p.status === 'renting' || p.status === 'expiring') {
          hasRentingImport = true;
        }
        this.properties = [...this.properties, p];
        existingIds.add(p.id);
        result.imported++;
      }
      if (result.imported > 0 || result.updated > 0) {
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
      return result;
    }
    return result;
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

  getDataSizeMB(): string {
    if (!this.prefs) {
      return '0.00 MB';
    }
    try {
      const propsJson: string = this.safeGetSync(KEY_PROPERTIES, '[]') as string;
      const profileJson: string = this.safeGetSync(KEY_USER_PROFILE, '') as string;
      const allData: string = propsJson + profileJson;
      const encoder: util.TextEncoder = new util.TextEncoder();
      const bytes: number = encoder.encodeInto(allData).byteLength;
      const mb: number = bytes / (1024 * 1024);
      return mb < 0.01 ? '0.01 MB' : `${mb.toFixed(2)} MB`;
    } catch (_e) {
      return '0.00 MB';
    }
  }
}
