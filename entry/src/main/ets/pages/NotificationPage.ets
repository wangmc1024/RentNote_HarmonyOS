import { Colors, Fonts, FontSizes, Radius, Shadows, Spacing } from '../common/DesignTokens';
import { HeaderBar } from '../components/HeaderBar';
import { PropertyRepository } from '../repository/PropertyRepository';
import { ReminderService } from '../service/ReminderService';

@Builder
export function NotificationBuilder() {
  NotificationPage()
}

@ComponentV2
export struct NotificationPage {
  @Local pushEnabled: boolean = true;
  @Local soundEnabled: boolean = true;
  @Local vibrateEnabled: boolean = false;
  @Local reminderEnabled: boolean = true;
  @Local reminderDays: number = 30;
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    const repo: PropertyRepository = PropertyRepository.getInstance();
    this.pushEnabled = repo.getPushEnabled();
    this.soundEnabled = repo.getSoundEnabled();
    this.vibrateEnabled = repo.getVibrateEnabled();
    this.reminderEnabled = repo.getReminderEnabled();
    this.reminderDays = repo.getReminderDays();
  }

  private async saveSettings(): Promise<void> {
    const repo: PropertyRepository = PropertyRepository.getInstance();
    await repo.savePushEnabled(this.pushEnabled);
    await repo.saveSoundEnabled(this.soundEnabled);
    await repo.saveVibrateEnabled(this.vibrateEnabled);
    await repo.saveReminderEnabled(this.reminderEnabled);
    await repo.saveReminderDays(this.reminderDays);
    ReminderService.getInstance().markPending();
  }

  build() {
    NavDestination() {
      Column() {
        HeaderBar({
          title: '通知设置',
          showBack: true,
          onBack: () => {
            this.saveSettings();
            this.navPathStack.pop();
          }
        })

        Scroll() {
          Column() {
            Column() {
              Text('租约到期提醒')
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(Colors.TEXT_MUTED)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .margin({ left: Spacing.CARD_PADDING, top: 12, bottom: 4 })
                .alignSelf(ItemAlign.Start)

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

              Divider().color(Colors.DIVIDER_LIGHT).strokeWidth(0.5).margin({ left: 20, right: 20 })

              Column() {
                Text('提前提醒天数')
                  .fontSize(FontSizes.BODY)
                  .fontColor(this.reminderEnabled ? Colors.TEXT_PRIMARY : Colors.TEXT_MUTED)
                  .fontFamily(Fonts.CN)
                  .fontWeight(FontWeight.Medium)
                  .alignSelf(ItemAlign.Start)
                  .margin({ left: Spacing.CARD_PADDING, top: 12 })

                Row() {
                  ForEach([7, 15, 30, 60], (days: number) => {
                    Column() {
                      Text(days.toString())
                        .fontSize(FontSizes.PAGE_TITLE)
                        .fontColor(this.reminderDays === days ? Colors.PRIMARY : (this.reminderEnabled ? Colors.TEXT_PRIMARY : Colors.TEXT_MUTED))
                        .fontFamily(Fonts.NUMBER)
                        .fontWeight(FontWeight.Bold)

                      Text('天')
                        .fontSize(FontSizes.CAPTION)
                        .fontColor(this.reminderDays === days ? Colors.PRIMARY : Colors.TEXT_MUTED)
                        .fontFamily(Fonts.CN)
                        .margin({ top: 2 })
                    }
                    .layoutWeight(1)
                    .height(52)
                    .backgroundColor(this.reminderDays === days ? Colors.PRIMARY_LIGHT : Colors.DIVIDER_LIGHT)
                    .borderRadius(Radius.CARD_SM)
                    .justifyContent(FlexAlign.Center)
                    .onClick(() => {
                      if (this.reminderEnabled) {
                        this.reminderDays = days;
                        this.saveSettings();
                      }
                    })
                  }, (item: number) => item.toString())
                }
                .width('100%')
                .padding({ left: Spacing.CARD_PADDING, right: Spacing.CARD_PADDING, top: 8, bottom: Spacing.CARD_PADDING })
              }
              .width('100%')
              .enabled(this.reminderEnabled)
              .opacity(this.reminderEnabled ? 1 : 0.4)
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
              Text('通知方式')
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(Colors.TEXT_MUTED)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .margin({ left: Spacing.CARD_PADDING, top: 12, bottom: 4 })
                .alignSelf(ItemAlign.Start)

              Row() {
                Text('推送通知')
                  .fontSize(FontSizes.BODY_LARGE)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .fontFamily(Fonts.CN)
                  .fontWeight(FontWeight.Medium)
                  .margin({ left: Spacing.CARD_PADDING })

                Blank()

                Toggle({ type: ToggleType.Switch, isOn: this.pushEnabled })
                  .onChange((value: boolean) => {
                    this.pushEnabled = value;
                    this.saveSettings();
                  })
                  .margin({ right: Spacing.CARD_PADDING })
              }
              .width('100%')
              .height(52)

              Divider().color(Colors.DIVIDER_LIGHT).strokeWidth(0.5).margin({ left: 20, right: 20 })

              Row() {
                Text('通知声音')
                  .fontSize(FontSizes.BODY_LARGE)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .fontFamily(Fonts.CN)
                  .fontWeight(FontWeight.Medium)
                  .margin({ left: Spacing.CARD_PADDING })

                Blank()

                Toggle({ type: ToggleType.Switch, isOn: this.soundEnabled })
                  .onChange((value: boolean) => {
                    this.soundEnabled = value;
                    this.saveSettings();
                  })
                  .margin({ right: Spacing.CARD_PADDING })
              }
              .width('100%')
              .height(52)

              Divider().color(Colors.DIVIDER_LIGHT).strokeWidth(0.5).margin({ left: 20, right: 20 })

              Row() {
                Text('振动提醒')
                  .fontSize(FontSizes.BODY_LARGE)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .fontFamily(Fonts.CN)
                  .fontWeight(FontWeight.Medium)
                  .margin({ left: Spacing.CARD_PADDING })

                Blank()

                Toggle({ type: ToggleType.Switch, isOn: this.vibrateEnabled })
                  .onChange((value: boolean) => {
                    this.vibrateEnabled = value;
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
            .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: Spacing.ITEM_GAP })

            Column() {
              Text('说明')
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)

              Text('开启租约到期提醒后，系统将在到期前根据设定天数发送通知。推送通知用于接收租约到期、账单提醒等重要通知；通知声音和振动可自定义提醒方式。')
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
          .padding({ bottom: 32 })
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
