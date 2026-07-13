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
    this.rentingProperties = this.repository.getRentingProperties();
    this.candidateProperties = this.repository.getCandidates();
    this.expiringCount = this.repository.getExpiringProperties(30).length;
    this.totalMonthlyExpense = this.rentingProperties
      .reduce((sum: number, item: PropertyInfo) => sum + item.monthlyRent, 0);
    hilog.info(0, TAG, 'loadData: renting=' + this.rentingProperties.length + ' candidate=' + this.candidateProperties.length);
  }

  async deleteProperty(id: string): Promise<void> {
    await this.repository.deleteProperty(id);
    await this.loadData();
  }

  async promoteCandidate(id: string): Promise<void> {
    hilog.info(0, TAG, 'promoteCandidate: id=' + id);
    await this.repository.promoteCandidate(id);
    hilog.info(0, TAG, 'promoteCandidate: done, reloading...');
    await this.loadData();
    hilog.info(0, TAG, 'promoteCandidate: after loadData renting=' + this.rentingProperties.length);
  }

  async demoteRenting(id: string): Promise<void> {
    hilog.info(0, TAG, 'demoteRenting: id=' + id);
    await this.repository.demoteRenting(id);
    await this.loadData();
    hilog.info(0, TAG, 'demoteRenting: after loadData renting=' + this.rentingProperties.length);
  }

  async batchDeleteCandidates(ids: string[]): Promise<void> {
    await this.repository.batchDelete(ids);
    await this.loadData();
  }
}
