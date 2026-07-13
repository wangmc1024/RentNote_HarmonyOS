import { Colors, Fonts, FontSizes, Radius, Spacing } from '../common/DesignTokens';
import { HeaderBar } from '../components/HeaderBar';

@Builder
export function AgreementBuilder() {
  AgreementPage()
}

@ComponentV2
export struct AgreementPage {
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        HeaderBar({
          title: '用户协议',
          showBack: true,
          onBack: () => {
            this.navPathStack.pop();
          }
        })

        Scroll() {
          Column() {
            Column() {
              Text('用户服务协议')
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

              Text('一、服务内容')
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)

              Text('小寓台账是一款华为鸿蒙元服务应用，为用户提供租房信息管理、租金统计、到期提醒等功能。本服务仅供个人非商业用途使用。')
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(Colors.TEXT_SECONDARY)
                .fontFamily(Fonts.CN)
                .lineHeight(22)
                .margin({ top: 8 })
                .alignSelf(ItemAlign.Start)

              Text('二、用户责任')
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)
                .margin({ top: 16 })

              Text('1. 用户应确保输入的房源信息真实准确\n2. 用户应妥善保管自己的设备，防止数据泄露\n3. 用户不得利用本服务从事任何违法活动\n4. 用户应对自己的数据定期备份')
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(Colors.TEXT_SECONDARY)
                .fontFamily(Fonts.CN)
                .lineHeight(22)
                .margin({ top: 8 })
                .alignSelf(ItemAlign.Start)

              Text('三、免责声明')
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)
                .margin({ top: 16 })

              Text('本应用仅提供信息管理工具，不对用户输入的房源信息真实性负责。因设备故障、系统更新等原因导致的数据丢失，开发者不承担赔偿责任。建议用户定期导出数据备份。')
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(Colors.TEXT_SECONDARY)
                .fontFamily(Fonts.CN)
                .lineHeight(22)
                .margin({ top: 8 })
                .alignSelf(ItemAlign.Start)

              Text('四、协议变更')
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)
                .margin({ top: 16 })

              Text('开发者有权根据需要修改本协议条款，修改后的协议将在应用更新后生效。继续使用本服务即视为同意修改后的协议。')
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
