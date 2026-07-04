import { Colors, Fonts, FontSizes, Radius, Spacing } from '../common/DesignTokens';
import { HeaderBar } from '../components/HeaderBar';

@Builder
export function PrivacyBuilder() {
  PrivacyPage()
}

@ComponentV2
export struct PrivacyPage {
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        HeaderBar({
          title: '隐私政策',
          showBack: true,
          onBack: () => {
            this.navPathStack.pop();
          }
        })

        Scroll() {
          Column() {
            Column() {
              Text('隐私政策')
                .fontSize(FontSizes.PAGE_TITLE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Bold)
                .alignSelf(ItemAlign.Start)

              Text('更新日期：2026年1月1日')
                .fontSize(FontSizes.CAPTION)
                .fontColor(Colors.TEXT_MUTED)
                .fontFamily(Fonts.CN)
                .margin({ top: 8 })
                .alignSelf(ItemAlign.Start)

              Divider().color(Colors.DIVIDER_LIGHT).strokeWidth(0.5).margin({ top: 16, bottom: 16 })

              Text('一、信息收集')
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)

              Text('本应用仅收集您主动输入的房源信息（小区名称、地址、租金、租期等），所有数据均存储在本地设备中，不会上传至任何服务器。')
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(Colors.TEXT_SECONDARY)
                .fontFamily(Fonts.CN)
                .lineHeight(22)
                .margin({ top: 8 })
                .alignSelf(ItemAlign.Start)

              Text('二、信息使用')
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)
                .margin({ top: 16 })

              Text('您的房源数据仅用于本应用的租房台账管理功能，包括租金统计、到期提醒等。我们不会将您的数据用于任何其他目的。')
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(Colors.TEXT_SECONDARY)
                .fontFamily(Fonts.CN)
                .lineHeight(22)
                .margin({ top: 8 })
                .alignSelf(ItemAlign.Start)

              Text('三、数据安全')
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)
                .margin({ top: 16 })

              Text('所有数据采用本地加密存储，不会通过网络传输。您可随时通过数据导出功能备份或通过清除数据功能删除所有信息。')
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(Colors.TEXT_SECONDARY)
                .fontFamily(Fonts.CN)
                .lineHeight(22)
                .margin({ top: 8 })
                .alignSelf(ItemAlign.Start)

              Text('四、权限说明')
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)
                .margin({ top: 16 })

              Text('本应用可能申请以下权限：\n· 通知权限：用于发送租约到期提醒\n· 存储权限：用于数据导入/导出功能\n所有权限均可由用户自主管理。')
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(Colors.TEXT_SECONDARY)
                .fontFamily(Fonts.CN)
                .lineHeight(22)
                .margin({ top: 8 })
                .alignSelf(ItemAlign.Start)
            }
            .width('100%')
            .backgroundColor(Colors.CARD_BG)
            .borderRadius(Radius.CARD)
            .padding(Spacing.CARD_PADDING)
            .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: 12 })
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
