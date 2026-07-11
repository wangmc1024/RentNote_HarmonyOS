import { Colors, Fonts, FontSizes, Dimensions, Radius, Shadows, Spacing } from '../common/DesignTokens';
import { MenuItemRow } from '../components/MenuItemRow';
import { UserProfile } from '../model/PropertyModel';
import { PropertyRepository } from '../repository/PropertyRepository';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct MyContent {
  @Local userName: string = '';
  @Local userSubtitle: string = '';
  @Local avatarUri: string = '';
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @Consumer('refreshFlag') refreshFlag: number = 0;

  private repository: PropertyRepository = PropertyRepository.getInstance();

  @Monitor('refreshFlag')
  onRefreshFlagChange(): void {
    this.loadProfile();
  }

  aboutToAppear(): void {
    this.loadProfile();
  }

  private loadProfile(): void {
    const profile: UserProfile = this.repository.getUserProfile();
    this.userName = profile.name;
    this.userSubtitle = profile.subtitle;
    this.avatarUri = profile.avatarUri;
  }

  private showClearDataDialog(): void {
    AlertDialog.show({
      message: '确认清除所有数据？将删除全部房源、租期和个人资料信息，且无法恢复。',
      primaryButton: {
        value: '确认清除',
        action: () => {
          this.repository.clearAll().then(() => {
            this.refreshFlag++;
            this.loadProfile();
            promptAction.showToast({ message: '数据已清除', duration: 2000 });
          });
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    });
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Text('我的')
            .fontSize(FontSizes.PAGE_TITLE)
            .fontColor(Colors.TEXT_PRIMARY)
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Bold)

          Blank()
        }
        .width('100%')
        .height(Dimensions.HEADER_HEIGHT)
        .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })

        Column() {
          Row() {
            if (this.avatarUri.length > 0) {
              Image(this.avatarUri)
                .width(Dimensions.AVATAR_SIZE)
                .height(Dimensions.AVATAR_SIZE)
                .borderRadius(Radius.AVATAR)
                .objectFit(ImageFit.Cover)
            } else {
              Row() {
                Text(this.userName.length > 0 ? this.userName.charAt(0) : '我')
                  .fontSize(26)
                  .fontColor(Colors.TEXT_WHITE)
                  .fontFamily(Fonts.CN)
                  .fontWeight(FontWeight.Bold)
              }
              .width(Dimensions.AVATAR_SIZE)
              .height(Dimensions.AVATAR_SIZE)
              .backgroundColor(Colors.PRIMARY)
              .borderRadius(Radius.AVATAR)
              .justifyContent(FlexAlign.Center)
            }

            Column() {
              Text(this.userName.length > 0 ? this.userName : '点击编辑资料')
                .fontSize(20)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Bold)

              if (this.userSubtitle.length > 0) {
                Text(this.userSubtitle)
                  .fontSize(FontSizes.BODY_SMALL)
                  .fontColor(Colors.TEXT_SECONDARY)
                  .fontFamily(Fonts.CN)
                  .margin({ top: 4 })
              }
            }
            .layoutWeight(1)
            .margin({ left: Spacing.CONTENT_GAP })

            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontSize(16)
              .fontColor([Colors.TEXT_MUTED])
          }
          .width('100%')
          .padding({ left: 24, right: 24, top: 24, bottom: 24 })
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .backgroundColor(Colors.CARD_BG)
        .borderRadius(Radius.CARD)
        .shadow({
          radius: Shadows.CARD.radius,
          color: Shadows.CARD.color,
          offsetX: Shadows.CARD.offsetX,
          offsetY: Shadows.CARD.offsetY
        })
        .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: 12 })
        .onClick(() => {
          this.navPathStack.pushPathByName('ProfileEdit', null);
        })

        Column() {
          MenuItemRow({
            iconName: 'sys.symbol.bell',
            label: '通知设置',
            onAction: () => {
              this.navPathStack.pushPathByName('Notification', null);
            }
          })
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
          MenuItemRow({
            iconName: 'sys.symbol.arrow_clockwise',
            label: '数据导入',
            onAction: () => {
              this.navPathStack.pushPathByName('DataImport', null);
            }
          })
          Divider().color(Colors.DIVIDER_LIGHT).strokeWidth(0.5).margin({ left: 20, right: 20 })
          MenuItemRow({
            iconName: 'sys.symbol.share',
            label: '导出数据',
            onAction: () => {
              this.navPathStack.pushPathByName('DataExport', null);
            }
          })
          Divider().color(Colors.DIVIDER_LIGHT).strokeWidth(0.5).margin({ left: 20, right: 20 })
          MenuItemRow({
            iconName: 'sys.symbol.trash',
            label: '清除数据',
            onAction: () => {
              this.showClearDataDialog();
            }
          })
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
          MenuItemRow({
            iconName: 'sys.symbol.lock',
            label: '隐私政策',
            onAction: () => {
              this.navPathStack.pushPathByName('Privacy', null);
            }
          })
          Divider().color(Colors.DIVIDER_LIGHT).strokeWidth(0.5).margin({ left: 20, right: 20 })
          MenuItemRow({
            iconName: 'sys.symbol.doc_text',
            label: '用户协议',
            onAction: () => {
              this.navPathStack.pushPathByName('Agreement', null);
            }
          })
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
          MenuItemRow({
            iconName: 'sys.symbol.info',
            label: '关于',
            onAction: () => {
              this.navPathStack.pushPathByName('About', null);
            }
          })
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
        .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: 16 })

        Text('租房台账 v1.0 · 华为鸿蒙元服务')
          .fontSize(FontSizes.CAPTION)
          .fontColor(Colors.TEXT_MUTED)
          .fontFamily(Fonts.CN)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: 28, bottom: 32 })
      }
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(1)
  }
}
