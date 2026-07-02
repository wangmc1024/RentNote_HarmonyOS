/**
 * 房源数据模型
 * 使用 @ObservedV2+@Trace V2 状态装饰器体系
 * 移除 TabItem 和 MenuItem 类（改用内联定义或直接使用系统组件）
 */

/** 房源基本信息 */
@ObservedV2
export class PropertyInfo {
  @Trace id: string = '';
  @Trace name: string = '';
  @Trace address: string = '';
  @Trace district: string = '';
  @Trace tags: string[] = [];
  @Trace monthlyRent: number = 0;
  @Trace deposit: number = 0;
  @Trace startDate: string = '';
  @Trace endDate: string = '';
  @Trace status: string = 'renting';
  @Trace billsPaid: number = 0;
  @Trace imageUrl: string = '';
  @Trace notes: string = '';
}

/** 统计概览数据 */
@ObservedV2
export class StatisticsOverview {
  @Trace yearlyExpense: number = 0;
  @Trace monthlyAvgRent: number = 0;
  @Trace rentingCount: number = 0;
}

/** 月度租金数据点 */
export class MonthlyRentItem {
  month: string = '';
  amount: number = 0;
}

/** 路由传参：房源 ID */
export class PropertyIdParam {
  propertyId: string = '';
}

/** 路由返回结果：保存成功 */
export class SaveResult {
  saved: boolean = false;
}

/** 路由返回结果：删除成功 */
export class DeleteResult {
  deleted: boolean = false;
  propertyId: string = '';
}
