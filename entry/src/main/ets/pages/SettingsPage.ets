/**
 * 设置页 - NavDestination 页面
 * 使用 @ComponentV2 装饰器
 * 统一使用 HeaderBar 组件
 * Emoji 替换为 SymbolGlyph
 * 通过 @Consumer 获取 navPathStack 用于返回操作
 * 使用 MenuItemRow 组件替代自定义 SettingItem
 */
import { Colors, Fonts, FontSizes, Dimensions, Radius, Shadows, Spacing } from '../common/DesignTokens';
import { HeaderBar } from '../components/HeaderBar';
import { MenuItemRow } from '../components/MenuItemRow';

@Builder
export function SettingsBuilder() {
  SettingsPage()
}

@ComponentV2
export struct SettingsPage {
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        HeaderBar({
          title: '设置',
          showBack: true,
          onBack: () => {
            this.navPathStack.pop();
          }
        })

        Scroll() {
          Column() {
            // ===== 提醒设置 =====
            Column() {
              MenuItemRow({
                iconName: 'sys.symbol.bell',
                label: '租约到期提醒',
                onAction: () => {
                  this.navPathStack.pushPathByName('Reminder', null);
                }
              })
              Divider().color(Colors.DIVIDER).strokeWidth(0.5).margin({ left: 20, right: 20 })
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
            .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: 12 })

            // ===== 数据管理 =====
            Column() {
              MenuItemRow({
                iconName: 'sys.symbol.doc_text',
                label: '数据管理',
                onAction: () => {
                  this.navPathStack.pushPathByName('DataManage', null);
                }
              })
              Divider().color(Colors.DIVIDER).strokeWidth(0.5).margin({ left: 20, right: 20 })

              // 清除缓存 - 带右侧数值
              Row() {
                Text('清除缓存')
                  .fontSize(FontSizes.BODY_LARGE)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .fontFamily(Fonts.CN)
                  .fontWeight(FontWeight.Medium)
                  .margin({ left: Spacing.CARD_PADDING })

                Blank()

                Text('0.0 MB')
                  .fontSize(FontSizes.BODY_SMALL)
                  .fontColor(Colors.TEXT_MUTED)
                  .fontFamily(Fonts.CN)
                  .margin({ right: Spacing.ITEM_GAP })

                SymbolGlyph($r('sys.symbol.chevron_left'))
                  .fontSize(20)
                  .fontColor([Colors.TEXT_MUTED])
                  .rotate({ angle: 180 })
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

            // ===== 隐私/协议 =====
            Column() {
              MenuItemRow({
                iconName: 'sys.symbol.lock',
                label: '隐私政策',
                onAction: () => {
                  this.navPathStack.pushPathByName('Privacy', null);
                }
              })
              Divider().color(Colors.DIVIDER).strokeWidth(0.5).margin({ left: 20, right: 20 })
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

            // 页脚
            Text('租房台账 v1.0 · 华为鸿蒙元服务')
              .fontSize(FontSizes.CAPTION)
              .fontColor(Colors.TEXT_MUTED)
              .fontFamily(Fonts.CN)
              .textAlign(TextAlign.Center)
              .width('100%')
              .margin({ top: 32, bottom: 32 })
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
