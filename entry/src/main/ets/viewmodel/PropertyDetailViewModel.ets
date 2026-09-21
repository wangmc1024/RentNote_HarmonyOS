import { PropertyInfo } from '../model/PropertyModel';
import { PropertyRepository } from '../repository/PropertyRepository';

@ObservedV2
export class PropertyDetailViewModel {
  /** 当前详情页对应的房源 id（@Trace，变更时联动 property 派生值） */
  @Trace propertyId: string = '';
  /** 详情数据版本号，用于触发地图标记等非数据绑定逻辑 */
  @Trace propertyVersion: number = 0;

  private repository: PropertyRepository = PropertyRepository.getInstance();

  /** 当前房源（响应式派生自仓库，编辑保存后自动更新，无需手动刷新） */
  @Computed
  get property(): PropertyInfo | undefined {
    if (this.propertyId.length === 0) {
      return undefined;
    }
    return this.repository.getPropertyById(this.propertyId);
  }

  async loadProperty(id: string): Promise<void> {
    await this.repository.reloadData();
    this.propertyId = id;
    this.propertyVersion++;
  }

  refreshProperty(id: string): void {
    this.propertyId = id;
    this.propertyVersion++;
  }

  async deleteProperty(id: string): Promise<void> {
    await this.repository.deleteProperty(id);
    this.propertyId = '';
    this.propertyVersion++;
  }

  async updateBillsPaid(id: string, billsPaid: number): Promise<void> {
    await this.repository.updateBillsPaid(id, billsPaid);
    this.propertyVersion++;
  }
}
