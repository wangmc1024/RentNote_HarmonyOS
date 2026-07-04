import { StatisticsOverview, MonthlyRentItem, PropertyInfo, LeaseTimelineItem } from '../model/PropertyModel';
import { PropertyRepository } from '../repository/PropertyRepository';

@ObservedV2
export class StatisticsViewModel {
  @Trace overview: StatisticsOverview = new StatisticsOverview();
  @Trace monthlyData: MonthlyRentItem[] = [];
  @Trace expiringProperties: PropertyInfo[] = [];
  @Trace leaseTimeline: LeaseTimelineItem[] = [];
  @Trace timelineRangeStartLabel: string = '';
  @Trace timelineRangeEndLabel: string = '';
  @Trace timelineBaseYear: number = 2024;
  @Trace timelineBaseMonth: number = 1;

  private repository: PropertyRepository = PropertyRepository.getInstance();

  private computeTimelineRange(): void {
    if (this.leaseTimeline.length === 0) {
      this.timelineBaseYear = 2024;
      this.timelineBaseMonth = 1;
      this.timelineRangeStartLabel = '2024.01';
      this.timelineRangeEndLabel = '2025.12';
      return;
    }
    let minYear: number = 9999;
    let minMonth: number = 13;
    let maxYear: number = 0;
    let maxMonth: number = 0;
    for (const item of this.leaseTimeline) {
      if (item.startYear < minYear || (item.startYear === minYear && item.startMonth < minMonth)) {
        minYear = item.startYear;
        minMonth = item.startMonth;
      }
      if (item.endYear > maxYear || (item.endYear === maxYear && item.endMonth > maxMonth)) {
        maxYear = item.endYear;
        maxMonth = item.endMonth;
      }
    }
    this.timelineBaseYear = minYear;
    this.timelineBaseMonth = minMonth;
    this.timelineRangeStartLabel = minYear + '.' + (minMonth < 10 ? '0' + minMonth : minMonth.toString());
    this.timelineRangeEndLabel = maxYear + '.' + (maxMonth < 10 ? '0' + maxMonth : maxMonth.toString());
  }

  async loadData(): Promise<void> {
    await this.repository.reloadData();
    this.overview = this.repository.getStatisticsOverview();
    this.monthlyData = this.repository.getMonthlyRentItems();
    this.expiringProperties = this.repository.getExpiringProperties(30);
    this.leaseTimeline = this.repository.getLeaseTimelineItems();
    this.computeTimelineRange();
  }

  getDaysUntilExpiry(endDate: string): number {
    const parts: string[] = endDate.split('.');
    if (parts.length !== 3) {
      return 0;
    }
    const year: number = parseInt(parts[0], 10);
    const month: number = parseInt(parts[1], 10) - 1;
    const day: number = parseInt(parts[2], 10);
    const expiry: Date = new Date(year, month, day);
    const today: Date = new Date();
    today.setHours(0, 0, 0, 0);
    const diff: number = expiry.getTime() - today.getTime();
    return Math.ceil(diff / (1000 * 60 * 60 * 24));
  }
}
