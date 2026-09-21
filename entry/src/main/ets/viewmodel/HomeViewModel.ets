import { PropertyInfo } from '../model/PropertyModel';
import { PropertyRepository } from '../repository/PropertyRepository';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'HomeViewModel';

@ObservedV2
export class HomeViewModel {
  private repository: PropertyRepository = PropertyRepository.getInstance();

  /** 在租/即将到期房源（响应式派生，数据变更时自动刷新 UI） */
  @Computed
  get rentingProperties(): PropertyInfo[] {
    return this.repository.getRentingProperties();
  }

  /** 备选房源（响应式派生，数据变更时自动刷新 UI） */
  @Computed
  get candidateProperties(): PropertyInfo[] {
    return this.repository.getCandidates();
  }

  /** 数据版本号，用于 ForEach 生成新键以强制刷新列表项 */
  @Computed
  get dataVersion(): number {
    return this.repository.dataVersion;
  }

  async loadData(): Promise<void> {
    await this.repository.reloadData();
  }

  async deleteProperty(id: string): Promise<void> {
    await this.repository.deleteProperty(id);
    hilog.info(0, TAG, 'deleteProperty: id=' + id);
  }

  async promoteCandidate(id: string): Promise<void> {
    hilog.info(0, TAG, 'promoteCandidate: id=' + id);
    await this.repository.promoteCandidate(id);
  }

  async demoteRenting(id: string): Promise<void> {
    hilog.info(0, TAG, 'demoteRenting: id=' + id);
    await this.repository.demoteRenting(id);
  }
}
