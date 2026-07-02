/**
 * 统计页视图模型 - 封装统计页业务逻辑
 * 从 Repository 计算统计概览和月度租金数据、获取即将到期房源列表
 */
import { StatisticsOverview, MonthlyRentItem, PropertyInfo } from '../model/PropertyModel';
import { PropertyRepository } from '../repository/PropertyRepository';
import { AppStorageV2 } from '@kit.ArkUI';

@ObservedV2
export class StatisticsViewModel {
  @Trace overview: StatisticsOverview = new StatisticsOverview();
  @Trace monthlyData: MonthlyRentItem[] = [];
  @Trace expiringProperties: PropertyInfo[] = [];

  private repository: PropertyRepository = AppStorageV2.connect(PropertyRepository)!;

  /** 加载统计数据 */
  loadData(): void {
    this.overview = this.repository.getStatisticsOverview();
    this.monthlyData = this.repository.getMonthlyRentItems();
    this.expiringProperties = this.repository.getExpiringProperties(30);
  }
}
