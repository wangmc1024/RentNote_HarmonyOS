/**
 * 房源数据仓库 - 内存 Mock 实现
 * 使用 @ObservedV2 装饰器确保数据可观察
 * 预置示例数据，提供 CRUD 和统计计算接口
 */
import { PropertyInfo, StatisticsOverview, MonthlyRentItem } from '../model/PropertyModel';

@ObservedV2
export class PropertyRepository {
  @Trace properties: PropertyInfo[] = [];

  constructor() {
    this.initMockData();
  }

  /** 初始化预置示例数据 */
  private initMockData(): void {
    const p1: PropertyInfo = new PropertyInfo();
    p1.id = '1';
    p1.name = '碧水湾公寓';
    p1.address = '朝阳区望京西园 2栋301';
    p1.district = '朝阳区';
    p1.tags = ['近地铁', '精装修', '押一付三'];
    p1.monthlyRent = 6200;
    p1.deposit = 6200;
    p1.startDate = '2024.03.01';
    p1.endDate = '2024.12.31';
    p1.status = 'expiring';
    p1.billsPaid = 3;
    p1.imageUrl = '';
    p1.notes = '';

    const p2: PropertyInfo = new PropertyInfo();
    p2.id = '2';
    p2.name = '阳光花园小区';
    p2.address = '朝阳区望京街道 3栋502';
    p2.district = '朝阳区';
    p2.tags = ['学区房', '南北通透', '整租'];
    p2.monthlyRent = 4500;
    p2.deposit = 9000;
    p2.startDate = '2024.03.15';
    p2.endDate = '2025.03.15';
    p2.status = 'renting';
    p2.billsPaid = 6;
    p2.imageUrl = '';
    p2.notes = '';

    const p3: PropertyInfo = new PropertyInfo();
    p3.id = '3';
    p3.name = '翠竹苑';
    p3.address = '海淀区中关村南大街 12号';
    p3.district = '海淀区';
    p3.tags = ['科技园区', '新小区', '整租'];
    p3.monthlyRent = 7800;
    p3.deposit = 7800;
    p3.startDate = '2024.01.01';
    p3.endDate = '2026.01.01';
    p3.status = 'renting';
    p3.billsPaid = 12;
    p3.imageUrl = '';
    p3.notes = '';

    this.properties = [p1, p2, p3];
  }

  /** 获取全部房源 */
  getAllProperties(): PropertyInfo[] {
    return this.properties;
  }

  /** 按 ID 获取房源 */
  getPropertyById(id: string): PropertyInfo | undefined {
    return this.properties.find((item: PropertyInfo) => item.id === id);
  }

  /** 新增房源 */
  addProperty(property: PropertyInfo): void {
    this.properties = [...this.properties, property];
  }

  /** 更新房源 */
  updateProperty(property: PropertyInfo): void {
    const index: number = this.properties.findIndex((item: PropertyInfo) => item.id === property.id);
    if (index !== -1) {
      const updated: PropertyInfo[] = [...this.properties];
      updated[index] = property;
      this.properties = updated;
    }
  }

  /** 删除房源 */
  deleteProperty(id: string): void {
    this.properties = this.properties.filter((item: PropertyInfo) => item.id !== id);
  }

  /** 计算统计概览 */
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

  /** 获取月度租金数据（近6个月） */
  getMonthlyRentItems(): MonthlyRentItem[] {
    const months: string[] = ['2月', '3月', '4月', '5月', '6月', '7月'];
    const renting: PropertyInfo[] = this.properties.filter(
      (item: PropertyInfo) => item.status === 'renting' || item.status === 'expiring'
    );
    const totalRent: number = renting.reduce((sum: number, item: PropertyInfo) => sum + item.monthlyRent, 0);

    // Mock: 模拟近6个月趋势，基于当前总月租上下浮动
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

  /** 获取即将到期房源 */
  getExpiringProperties(days: number): PropertyInfo[] {
    return this.properties.filter((item: PropertyInfo) => item.status === 'expiring');
  }
}
