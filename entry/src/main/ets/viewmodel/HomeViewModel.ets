import { PropertyInfo } from '../model/PropertyModel';
import { PropertyRepository } from '../repository/PropertyRepository';

@ObservedV2
export class HomeViewModel {
  @Trace rentingProperties: PropertyInfo[] = [];
  @Trace candidateProperties: PropertyInfo[] = [];
  @Trace expiringCount: number = 0;
  @Trace totalMonthlyExpense: number = 0;

  private repository: PropertyRepository = PropertyRepository.getInstance();

  async loadData(): Promise<void> {
    await this.repository.reloadData();
    this.rentingProperties = this.repository.getRentingProperties();
    this.candidateProperties = this.repository.getCandidates();
    this.expiringCount = this.repository.getExpiringProperties(30).length;
    this.totalMonthlyExpense = this.rentingProperties
      .reduce((sum: number, item: PropertyInfo) => sum + item.monthlyRent, 0);
  }

  async deleteProperty(id: string): Promise<void> {
    await this.repository.deleteProperty(id);
    await this.loadData();
  }

  async promoteCandidate(id: string): Promise<void> {
    await this.repository.promoteCandidate(id);
    await this.loadData();
  }

  async demoteRenting(id: string): Promise<void> {
    await this.repository.demoteRenting(id);
    await this.loadData();
  }

  async batchDeleteCandidates(ids: string[]): Promise<void> {
    await this.repository.batchDelete(ids);
    await this.loadData();
  }
}
