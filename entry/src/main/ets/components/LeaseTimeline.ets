import { Colors, Fonts, FontSizes, Spacing } from '../common/DesignTokens';
import { LeaseTimelineItem } from '../model/PropertyModel';

@ComponentV2
export struct LeaseTimeline {
  @Param data: LeaseTimelineItem[] = [];
  @Param rangeStartLabel: string = '';
  @Param rangeEndLabel: string = '';
  @Param baseYear: number = 2024;
  @Param baseMonth: number = 1;

  private formatMonth(year: number, month: number): string {
    return year + '.' + (month < 10 ? '0' + month : month.toString());
  }

  private getElapsedPercent(item: LeaseTimelineItem): number {
    const totalMonths: number = (item.endYear - item.startYear) * 12 + (item.endMonth - item.startMonth) + 1;
    if (totalMonths <= 0) {
      return 0;
    }
    const now: Date = new Date();
    const currentMonth: number = now.getFullYear() * 12 + now.getMonth() + 1;
    const startMonth: number = item.startYear * 12 + item.startMonth;
    const elapsed: number = currentMonth - startMonth;
    const pct: number = Math.floor((elapsed / totalMonths) * 100);
    return Math.max(0, Math.min(pct, 100));
  }

  build() {
    Column() {
      if (this.data.length === 0) {
        Column() {
          SymbolGlyph($r('sys.symbol.calendar'))
            .fontSize(32)
            .fontColor([Colors.TEXT_MUTED])

          Text('暂无在租房源')
            .fontSize(FontSizes.BODY_SMALL)
            .fontColor(Colors.TEXT_MUTED)
            .fontFamily(Fonts.CN)
            .margin({ top: 8 })
        }
        .width('100%')
        .height(120)
        .justifyContent(FlexAlign.Center)
      } else {
        Row() {
          Text(this.rangeStartLabel)
            .fontSize(10)
            .fontColor(Colors.TEXT_MUTED)
            .fontFamily(Fonts.NUMBER)

          Blank()

          Text(this.rangeEndLabel)
            .fontSize(10)
            .fontColor(Colors.TEXT_MUTED)
            .fontFamily(Fonts.NUMBER)
        }
        .width('100%')
        .margin({ bottom: 12 })

        ForEach(this.data, (item: LeaseTimelineItem) => {
          Column() {
            Row() {
              Text(item.name)
                .fontSize(FontSizes.CAPTION)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)

              Text('¥' + item.monthlyRent.toLocaleString() + '/月')
                .fontSize(FontSizes.CAPTION)
                .fontColor(item.isExpiring ? Colors.WARNING : Colors.PRIMARY)
                .fontFamily(Fonts.NUMBER)
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')

            Progress({
              value: this.getElapsedPercent(item),
              total: 100,
              type: ProgressType.Linear
            })
              .width('100%')
              .height(8)
              .color(item.isExpiring ? Colors.WARNING : Colors.PRIMARY)
              .backgroundColor(item.isExpiring ? Colors.WARNING_LIGHT : Colors.PRIMARY_LIGHT)
              .style({ strokeWidth: 8 })
              .margin({ top: 6 })

            Row() {
              Text(this.formatMonth(item.startYear, item.startMonth))
                .fontSize(10)
                .fontColor(Colors.TEXT_MUTED)
                .fontFamily(Fonts.NUMBER)

              Blank()

              if (item.isExpiring) {
                Text('即将到期')
                  .fontSize(10)
                  .fontColor(Colors.WARNING)
                  .fontFamily(Fonts.CN)
                  .fontWeight(FontWeight.Medium)
              }

              Text(this.formatMonth(item.endYear, item.endMonth))
                .fontSize(10)
                .fontColor(item.isExpiring ? Colors.WARNING : Colors.TEXT_MUTED)
                .fontFamily(Fonts.NUMBER)
                .margin({ left: item.isExpiring ? 8 : 0 })
            }
            .width('100%')
            .margin({ top: 4 })
          }
          .width('100%')
          .margin({ bottom: 16 })
        }, (item: LeaseTimelineItem) => item.propertyId)
      }
    }
    .width('100%')
    .padding({ left: Spacing.CARD_PADDING, right: Spacing.CARD_PADDING })
  }
}
