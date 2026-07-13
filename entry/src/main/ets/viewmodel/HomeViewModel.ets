import { PropertyInfo } from '../model/PropertyModel';
import { PropertyRepository } from '../repository/PropertyRepository';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'HomeViewModel';

@ObservedV2
export class HomeViewModel {
  @Trace rentingProperties: PropertyInfo[] = [];
  @Trace candidateProperties: PropertyInfo[] = [];
  @Trace expiringCount: number = 0;
  @Trace totalMonthlyExpense: number = 0;

  private repository: PropertyRepository = PropertyRepository.getInstance();

  async loadData(): Promise<void> {
    await this.repository.reloadData();
    this.refreshFromRepository();
  }

  refreshFromRepository(): void {
    this.rentingProperties = [...this.repository.getRentingProperties()];
    this.candidateProperties = [...this.repository.getCandidates()];
    this.expiringCount = this.repository.getExpiringProperties(30).length;
    this.totalMonthlyExpense = this.rentingProperties
      .reduce((sum: number, item: PropertyInfo) => sum + item.monthlyRent, 0);
    hilog.info(0, TAG, 'refresh: renting=' + this.rentingProperties.length + ' candidate=' + this.candidateProperties.length);
  }

  async deleteProperty(id: string): Promise<void> {
    await this.repository.deleteProperty(id);
    this.refreshFromRepository();
  }

  async promoteCandidate(id: string): Promise<void> {
    hilog.info(0, TAG, 'promoteCandidate: id=' + id);
    await this.repository.promoteCandidate(id);
    this.refreshFromRepository();
  }

  async demoteRenting(id: string): Promise<void> {
    hilog.info(0, TAG, 'demoteRenting: id=' + id);
    await this.repository.demoteRenting(id);
    this.refreshFromRepository();
  }

  async batchDeleteCandidates(ids: string[]): Promise<void> {
    await this.repository.batchDelete(ids);
    this.refreshFromRepository();
  }
}
