/**
 * 首页视图模型 - 封装首页业务逻辑
 * 从 Repository 获取房源列表、计算到期提醒数和月度总支出
 */
import { PropertyInfo } from '../model/PropertyModel';
import { PropertyRepository } from '../repository/PropertyRepository';
import { AppStorageV2 } from '@kit.ArkUI';

@ObservedV2
export class HomeViewModel {
  @Trace properties: PropertyInfo[] = [];
  @Trace expiringCount: number = 0;
  @Trace totalMonthlyExpense: number = 0;

  private repository: PropertyRepository = AppStorageV2.connect(PropertyRepository)!;

  /** 加载数据 */
  loadData(): void {
    this.properties = this.repository.getAllProperties();
    this.expiringCount = this.repository.getExpiringProperties(30).length;
    this.totalMonthlyExpense = this.properties
      .filter((item: PropertyInfo) => item.status === 'renting' || item.status === 'expiring')
      .reduce((sum: number, item: PropertyInfo) => sum + item.monthlyRent, 0);
  }

  /** 刷新数据 */
  refreshData(): void {
    this.loadData();
  }
}
