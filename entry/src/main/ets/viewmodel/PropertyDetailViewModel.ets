/**
 * 房源详情视图模型 - 封装房源详情业务逻辑
 * 根据 ID 加载房源、删除房源确认
 */
import { PropertyInfo } from '../model/PropertyModel';
import { PropertyRepository } from '../repository/PropertyRepository';
import { AppStorageV2 } from '@kit.ArkUI';

@ObservedV2
export class PropertyDetailViewModel {
  @Trace property: PropertyInfo | undefined = undefined;

  private repository: PropertyRepository = AppStorageV2.connect(PropertyRepository)!;

  /** 加载房源数据 */
  loadProperty(id: string): void {
    this.property = this.repository.getPropertyById(id);
  }

  /** 删除房源 */
  deleteProperty(id: string): void {
    this.repository.deleteProperty(id);
    this.property = undefined;
  }
}
