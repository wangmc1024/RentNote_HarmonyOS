import { Colors, Fonts, FontSizes, Radius, Shadows, Spacing } from '../common/DesignTokens';
import { HeaderBar } from '../components/HeaderBar';
import { MenuItemRow } from '../components/MenuItemRow';

@Builder
export function NotificationBuilder() {
  NotificationPage()
}

@ComponentV2
export struct NotificationPage {
  @Local pushEnabled: boolean = true;
  @Local soundEnabled: boolean = true;
  @Local vibrateEnabled: boolean = false;
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        HeaderBar({
          title: '通知设置',
          showBack: true,
          onBack: () => {
            this.navPathStack.pop();
          }
        })

        Scroll() {
          Column() {
            Column() {
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
              Text('通知说明')
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)

              Text('推送通知：接收租约到期、账单提醒等重要通知\n通知声音：收到通知时播放提示音\n振动提醒：收到通知时振动设备')
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
