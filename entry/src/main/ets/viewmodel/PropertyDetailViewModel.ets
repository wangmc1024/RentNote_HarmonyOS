import { PropertyInfo } from '../model/PropertyModel';
import { PropertyRepository } from '../repository/PropertyRepository';

@ObservedV2
export class PropertyDetailViewModel {
  @Trace property: PropertyInfo | undefined = undefined;
  @Trace propertyVersion: number = 0;

  private repository: PropertyRepository = PropertyRepository.getInstance();

  async loadProperty(id: string): Promise<void> {
    await this.repository.reloadData();
    const found: PropertyInfo | undefined = this.repository.getPropertyById(id);
    if (found) {
      this.property = found.clone();
    } else {
      this.property = undefined;
    }
    this.propertyVersion++;
  }

  refreshProperty(id: string): void {
    const found: PropertyInfo | undefined = this.repository.getPropertyById(id);
    if (found) {
      this.property = found.clone();
    } else {
      this.property = undefined;
    }
    this.propertyVersion++;
  }

  async deleteProperty(id: string): Promise<void> {
    await this.repository.deleteProperty(id);
    this.property = undefined;
    this.propertyVersion++;
  }

  async updateBillsPaid(id: string, billsPaid: number): Promise<void> {
    await this.repository.updateBillsPaid(id, billsPaid);
    this.refreshProperty(id);
  }
}
