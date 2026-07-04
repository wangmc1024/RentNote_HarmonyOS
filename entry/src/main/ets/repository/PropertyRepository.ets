import { preferences } from '@kit.ArkData';
import { PropertyInfo, PropertyDTO, StatisticsOverview, MonthlyRentItem, LeaseTimelineItem } from '../model/PropertyModel';

const PREFS_NAME: string = 'RentNotePrefs';
const KEY_PROPERTIES: string = 'properties';
const KEY_NEXT_ID: string = 'next_id';
const KEY_VERSION: string = 'data_version';
const DATA_VERSION: number = 2;

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

  async init(context: Context): Promise<void> {
    this.initContext = context;
    this.prefs = await preferences.getPreferences(context, PREFS_NAME);
    const storedVersion: number = this.prefs.getSync(KEY_VERSION, 0) as number;
    if (storedVersion < DATA_VERSION) {
      this.prefs.putSync(KEY_PROPERTIES, '[]');
      this.prefs.putSync(KEY_NEXT_ID, 1);
      this.prefs.putSync(KEY_VERSION, DATA_VERSION);
      await this.prefs.flush();
      await this.insertMockData();
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
    const json: string = this.prefs.getSync(KEY_PROPERTIES, '[]') as string;
    if (json.length === 0 || json === '[]') {
      this.properties = [];
      return;
    }
    const cleaned: string = json.replace(/"__ob_/g, '"');
    const rawList: PropertyDTO[] = JSON.parse(cleaned) as PropertyDTO[];
    const list: PropertyInfo[] = [];
    for (const raw of rawList) {
      const p: PropertyInfo = new PropertyInfo();
      p.id = raw.id ?? '';
      p.name = raw.name ?? '';
      p.address = raw.address ?? '';
      p.district = raw.district ?? '';
      p.tags = raw.tags ?? [];
      p.monthlyRent = raw.monthlyRent ?? 0;
      p.deposit = raw.deposit ?? 0;
      p.startDate = raw.startDate ?? '';
      p.endDate = raw.endDate ?? '';
      p.status = raw.status ?? 'renting';
      p.billsPaid = raw.billsPaid ?? 0;
      p.imageUrl = raw.imageUrl ?? '';
      p.notes = raw.notes ?? '';
      p.renewalStatus = raw.renewalStatus ?? '';
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
    this.prefs!.putSync(KEY_PROPERTIES, json);
    await this.prefs!.flush();
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
    p1.status = 'expiring';
    p1.billsPaid = 3;
    p1.imageUrl = '';
    p1.notes = '';
    p1.renewalStatus = 'undecided';
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
    p2.imageUrl = '';
    p2.notes = '';
    p2.renewalStatus = 'renew';
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
    p3.status = 'renting';
    p3.billsPaid = 12;
    p3.imageUrl = '';
    p3.notes = '';
    p3.renewalStatus = '';
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
    p4.imageUrl = '';
    p4.notes = '';
    p4.renewalStatus = '';
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
    p5.imageUrl = '';
    p5.notes = '';
    p5.renewalStatus = '';
    mockList.push(p5);

    this.properties = mockList;
    this.prefs!.putSync(KEY_NEXT_ID, 6);
    await this.saveToPrefs();
  }

  private getNextId(): string {
    const nextId: number = (this.prefs!.getSync(KEY_NEXT_ID, 1) as number);
    return String(nextId);
  }

  private async consumeNextId(): Promise<string> {
    const id: string = this.getNextId();
    const nextVal: number = (this.prefs!.getSync(KEY_NEXT_ID, 1) as number) + 1;
    this.prefs!.putSync(KEY_NEXT_ID, nextVal);
    await this.prefs!.flush();
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
  }

  async updateProperty(property: PropertyInfo): Promise<void> {
    const index: number = this.properties.findIndex((item: PropertyInfo) => item.id === property.id);
    if (index >= 0) {
      const newList: PropertyInfo[] = [...this.properties];
      newList[index] = property;
      this.properties = newList;
      await this.saveToPrefs();
    }
  }

  async deleteProperty(id: string): Promise<void> {
    this.properties = this.properties.filter((item: PropertyInfo) => item.id !== id);
    await this.saveToPrefs();
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
    const index: number = this.properties.findIndex((item: PropertyInfo) => item.id === id);
    if (index >= 0) {
      const newList: PropertyInfo[] = [...this.properties];
      const p: PropertyInfo = new PropertyInfo();
      p.id = newList[index].id;
      p.name = newList[index].name;
      p.address = newList[index].address;
      p.district = newList[index].district;
      p.tags = newList[index].tags;
      p.monthlyRent = newList[index].monthlyRent;
      p.deposit = newList[index].deposit;
      p.startDate = newList[index].startDate;
      p.endDate = newList[index].endDate;
      p.status = 'renting';
      p.billsPaid = newList[index].billsPaid;
      p.imageUrl = newList[index].imageUrl;
      p.notes = newList[index].notes;
      p.renewalStatus = newList[index].renewalStatus;
      newList[index] = p;
      this.properties = newList;
      await this.saveToPrefs();
    }
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
    return this.properties.filter((item: PropertyInfo) => item.status === 'expiring');
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
}
