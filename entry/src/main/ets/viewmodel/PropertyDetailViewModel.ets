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
}
