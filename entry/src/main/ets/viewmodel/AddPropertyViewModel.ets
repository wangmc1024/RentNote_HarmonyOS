import { PropertyInfo } from '../model/PropertyModel';
import { PropertyRepository } from '../repository/PropertyRepository';

@ObservedV2
export class AddPropertyViewModel {
  @Trace isEditMode: boolean = false;
  @Trace editPropertyId: string = '';
  @Trace isCandidateMode: boolean = false;
  @Trace validationError: string = '';

  private repository: PropertyRepository = PropertyRepository.getInstance();

  setEditMode(propertyId: string): void {
    this.isEditMode = true;
    this.editPropertyId = propertyId;
  }

  setAddMode(): void {
    this.isEditMode = false;
    this.editPropertyId = '';
  }

  loadProperty(): PropertyInfo | undefined {
    if (this.editPropertyId) {
      return this.repository.getPropertyById(this.editPropertyId);
    }
    return undefined;
  }

  validateForm(data: PropertyInfo): boolean {
    if (!data.name || data.name.trim().length === 0) {
      this.validationError = '请输入小区名称';
      return false;
    }
    if (!this.isCandidateMode) {
      if (data.monthlyRent <= 0) {
        this.validationError = '请输入有效的月租金';
        return false;
      }
    }
    this.validationError = '';
    return true;
  }

  async saveProperty(data: PropertyInfo): Promise<boolean> {
    if (!this.validateForm(data)) {
      return false;
    }

    if (this.isEditMode && this.editPropertyId) {
      data.id = this.editPropertyId;
      await this.repository.updateProperty(data);
    } else {
      data.id = Date.now().toString();
      if (this.isCandidateMode) {
        data.status = 'candidate';
      } else {
        data.status = 'renting';
      }
      await this.repository.addProperty(data);
    }
    return true;
  }

  async deleteProperty(id: string): Promise<void> {
    await this.repository.deleteProperty(id);
  }

  async demoteRenting(id: string): Promise<void> {
    await this.repository.demoteRenting(id);
  }
}
