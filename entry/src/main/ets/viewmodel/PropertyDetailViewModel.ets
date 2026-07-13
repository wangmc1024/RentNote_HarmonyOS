import { PropertyInfo } from '../model/PropertyModel';
import { PropertyRepository } from '../repository/PropertyRepository';

@ObservedV2
export class PropertyDetailViewModel {
  @Trace property: PropertyInfo | undefined = undefined;

  private repository: PropertyRepository = PropertyRepository.getInstance();

  async loadProperty(id: string): Promise<void> {
    await this.repository.reloadData();
    this.property = this.repository.getPropertyById(id);
  }

  async deleteProperty(id: string): Promise<void> {
    await this.repository.deleteProperty(id);
    this.property = undefined;
  }

  async toggleBillsPaid(id: string): Promise<void> {
    const current: PropertyInfo | undefined = this.repository.getPropertyById(id);
    if (current) {
      const newValue: number = current.billsPaid > 0 ? 0 : 1;
      await this.repository.updateBillsPaid(id, newValue);
      await this.loadProperty(id);
    }
  }

  async updateBillsPaid(id: string, billsPaid: number): Promise<void> {
    await this.repository.updateBillsPaid(id, billsPaid);
    await this.loadProperty(id);
  }
}
