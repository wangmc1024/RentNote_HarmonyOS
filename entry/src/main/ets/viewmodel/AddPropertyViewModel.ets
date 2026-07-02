/**
 * 新增/编辑房源视图模型 - 封装新增/编辑房源业务逻辑
 * 区分新增/编辑模式（通过 propertyId）、保存房源到 Repository、表单验证
 */
import { PropertyInfo } from '../model/PropertyModel';
import { PropertyRepository } from '../repository/PropertyRepository';
import { AppStorageV2 } from '@kit.ArkUI';

@ObservedV2
export class AddPropertyViewModel {
  @Trace isEditMode: boolean = false;
  @Trace editPropertyId: string = '';
  @Trace validationError: string = '';

  private repository: PropertyRepository = AppStorageV2.connect(PropertyRepository)!;

  /** 设置编辑模式 */
  setEditMode(propertyId: string): void {
    this.isEditMode = true;
    this.editPropertyId = propertyId;
  }

  /** 设置新增模式 */
  setAddMode(): void {
    this.isEditMode = false;
    this.editPropertyId = '';
  }

  /** 加载编辑房源数据 */
  loadProperty(): PropertyInfo | undefined {
    if (this.editPropertyId) {
      return this.repository.getPropertyById(this.editPropertyId);
    }
    return undefined;
  }

  /** 表单验证 */
  validateForm(data: PropertyInfo): boolean {
    if (!data.name || data.name.trim().length === 0) {
      this.validationError = '请输入小区名称';
      return false;
    }
    if (data.monthlyRent <= 0) {
      this.validationError = '请输入有效的月租金';
      return false;
    }
    this.validationError = '';
    return true;
  }

  /** 保存房源（新增或更新） */
  saveProperty(data: PropertyInfo): boolean {
    if (!this.validateForm(data)) {
      return false;
    }

    if (this.isEditMode && this.editPropertyId) {
      data.id = this.editPropertyId;
      this.repository.updateProperty(data);
    } else {
      // 新增模式：生成唯一 ID
      data.id = Date.now().toString();
      this.repository.addProperty(data);
    }
    return true;
  }
}
