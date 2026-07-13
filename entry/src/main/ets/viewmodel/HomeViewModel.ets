import { PropertyInfo } from '../model/PropertyModel';
import { PropertyRepository } from '../repository/PropertyRepository';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'HomeViewModel';

@ObservedV2
export class HomeViewModel {
  @Trace rentingProperties: PropertyInfo[] = [];
  @Trace candidateProperties: PropertyInfo[] = [];

  private repository: PropertyRepository = PropertyRepository.getInstance();

  async loadData(): Promise<void> {
    await this.repository.reloadData();
    this.refreshFromRepository();
  }

  refreshFromRepository(): void {
    this.rentingProperties = [...this.repository.getRentingProperties()];
    this.candidateProperties = [...this.repository.getCandidates()];
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
}
