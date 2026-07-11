import { Colors, Fonts, FontSizes, Radius, Shadows, Spacing } from '../common/DesignTokens';
import { HeaderBar } from '../components/HeaderBar';
import { PropertyRepository } from '../repository/PropertyRepository';

@Builder
export function ReminderBuilder() {
  ReminderPage()
}

@ComponentV2
export struct ReminderPage {
  @Local reminderDays: number = 30;
  @Local reminderEnabled: boolean = true;
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    const repo: PropertyRepository = PropertyRepository.getInstance();
    this.reminderEnabled = repo.getReminderEnabled();
    this.reminderDays = repo.getReminderDays();
  }

  private async saveSettings(): Promise<void> {
    const repo: PropertyRepository = PropertyRepository.getInstance();
    await repo.saveReminderEnabled(this.reminderEnabled);
    await repo.saveReminderDays(this.reminderDays);
  }

  build() {
    NavDestination() {
      Column() {
        HeaderBar({
          title: '租约到期提醒',
          showBack: true,
          onBack: () => {
            this.saveSettings();
            this.navPathStack.pop();
          }
        })

        Scroll() {
          Column() {
            Column() {
              Row() {
                Text('启用提醒')
                  .fontSize(FontSizes.BODY_LARGE)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .fontFamily(Fonts.CN)
                  .fontWeight(FontWeight.Medium)
                  .margin({ left: Spacing.CARD_PADDING })

                Blank()

                Toggle({ type: ToggleType.Switch, isOn: this.reminderEnabled })
                  .onChange((value: boolean) => {
                    this.reminderEnabled = value;
                    this.saveSettings();
                  })
                  .margin({ right: Spacing.CARD_PADDING })
              }
              .width('100%')
              .height(52)
            }
            .width('100%')
            .backgroundColor(Colors.CARD_BG)
            .borderRadius(Radius.CARD)
            .shadow({
              radius: Shadows.LIST_ITEM.radius,
              color: Shadows.LIST_ITEM.color,
              offsetX: Shadows.LIST_ITEM.offsetX,
              offsetY: Shadows.LIST_ITEM.offsetY
            })
            .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: 12 })

            Column() {
              Text('提前提醒天数')
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)
                .margin({ left: Spacing.CARD_PADDING, top: Spacing.CARD_PADDING })

              Row() {
                ForEach([7, 15, 30, 60], (days: number) => {
                  Column() {
                    Text(days.toString())
                      .fontSize(FontSizes.PAGE_TITLE)
                      .fontColor(this.reminderDays === days ? Colors.PRIMARY : Colors.TEXT_PRIMARY)
                      .fontFamily(Fonts.NUMBER)
                      .fontWeight(FontWeight.Bold)

                    Text('天')
                      .fontSize(FontSizes.CAPTION)
                      .fontColor(this.reminderDays === days ? Colors.PRIMARY : Colors.TEXT_MUTED)
                      .fontFamily(Fonts.CN)
                      .margin({ top: 2 })
                  }
                  .layoutWeight(1)
                  .height(64)
                  .backgroundColor(this.reminderDays === days ? Colors.PRIMARY_LIGHT : Colors.DIVIDER_LIGHT)
                  .borderRadius(Radius.CARD_SM)
                  .justifyContent(FlexAlign.Center)
                  .onClick(() => {
                    this.reminderDays = days;
                    this.saveSettings();
                  })
                }, (item: number) => item.toString())
              }
              .width('100%')
              .padding({ left: Spacing.CARD_PADDING, right: Spacing.CARD_PADDING, top: 12, bottom: Spacing.CARD_PADDING })
            }
            .width('100%')
            .backgroundColor(Colors.CARD_BG)
            .borderRadius(Radius.CARD)
            .shadow({
              radius: Shadows.LIST_ITEM.radius,
              color: Shadows.LIST_ITEM.color,
              offsetX: Shadows.LIST_ITEM.offsetX,
              offsetY: Shadows.LIST_ITEM.offsetY
            })
            .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: Spacing.ITEM_GAP })

            Column() {
              Text('提醒说明')
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)

              Text('开启后，系统将在租约到期前根据设定天数发送提醒通知。您也可以在通知设置中自定义提醒方式。')
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(Colors.TEXT_SECONDARY)
                .fontFamily(Fonts.CN)
                .lineHeight(22)
                .margin({ top: 12 })
                .alignSelf(ItemAlign.Start)
            }
            .width('100%')
            .backgroundColor(Colors.CARD_BG)
            .borderRadius(Radius.CARD)
            .padding(Spacing.CARD_PADDING)
            .shadow({
              radius: Shadows.LIST_ITEM.radius,
              color: Shadows.LIST_ITEM.color,
              offsetX: Shadows.LIST_ITEM.offsetX,
              offsetY: Shadows.LIST_ITEM.offsetY
            })
            .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: Spacing.ITEM_GAP })
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Colors.BG_PRIMARY)
    }
    .hideTitleBar(true)
  }
}
