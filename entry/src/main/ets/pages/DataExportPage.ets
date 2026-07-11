import { Colors, Fonts, FontSizes, Radius, Shadows, Spacing } from '../common/DesignTokens';
import { HeaderBar } from '../components/HeaderBar';
import { PropertyRepository } from '../repository/PropertyRepository';
import { picker, fileIo } from '@kit.CoreFileKit';
import { buffer } from '@kit.ArkTS';

@Builder
export function DataExportBuilder() {
  DataExportPage()
}

@ComponentV2
export struct DataExportPage {
  @Local exportStatus: string = '';
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  private repository: PropertyRepository = PropertyRepository.getInstance();

  private async exportAsJson(): Promise<void> {
    try {
      const jsonStr: string = this.repository.exportToJson();
      const documentSaveOptions: picker.DocumentSaveOptions = new picker.DocumentSaveOptions();
      documentSaveOptions.newFileNames = ['RentNote_Export.json'];
      documentSaveOptions.fileSuffixChoices = ['JSON|.json'];
      const context: Context = this.getUIContext().getHostContext() as Context;
      const documentViewPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker(context);
      const uris: string[] = await documentViewPicker.save(documentSaveOptions);
      if (uris.length === 0) {
        return;
      }
      const uri: string = uris[0];
      const file: fileIo.File = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE);
      const bytes: Uint8Array = new Uint8Array(buffer.from(jsonStr, 'utf-8').buffer);
      fileIo.writeSync(file.fd, bytes.buffer);
      fileIo.closeSync(file);
      this.exportStatus = '导出成功';
      this.getUIContext().getPromptAction().showToast({ message: '导出成功', duration: 2000 });
    } catch (_e) {
      this.exportStatus = '导出失败';
      try {
        this.getUIContext().getPromptAction().showToast({ message: '导出失败', duration: 2000 });
      } catch (_ee) {
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        HeaderBar({
          title: '导出数据',
          showBack: true,
          onBack: () => {
            this.navPathStack.pop();
          }
        })

        Scroll() {
          Column() {
            Column() {
              Row() {
                Column() {
                  SymbolGlyph($r('sys.symbol.doc_text'))
                    .fontSize(28)
                    .fontColor([Colors.PRIMARY])

                  Text('导出为 JSON')
                    .fontSize(FontSizes.BODY)
                    .fontColor(Colors.TEXT_PRIMARY)
                    .fontFamily(Fonts.CN)
                    .fontWeight(FontWeight.Medium)
                    .margin({ top: 8 })

                  Text('导出全部房源数据为 JSON 文件')
                    .fontSize(FontSizes.CAPTION)
                    .fontColor(Colors.TEXT_MUTED)
                    .fontFamily(Fonts.CN)
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Center)
              }
              .width('100%')
              .padding({ top: 24, bottom: 24 })
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.exportAsJson();
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

            if (this.exportStatus.length > 0) {
              Column() {
                Text(this.exportStatus)
                  .fontSize(FontSizes.BODY)
                  .fontColor(Colors.TEXT_SECONDARY)
                  .fontFamily(Fonts.CN)
              }
              .width('100%')
              .padding(Spacing.CARD_PADDING)
              .backgroundColor(Colors.PRIMARY_LIGHT)
              .borderRadius(Radius.CARD_SM)
              .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: Spacing.ITEM_GAP })
            }

            Column() {
              Text('导出说明')
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)

              Text('1. JSON 格式保留完整数据结构，适合备份和跨设备迁移\n2. 导出的 JSON 文件可通过"数据导入"功能恢复\n3. 导出包含所有在租、备选房源数据\n4. 请妥善保管导出文件，避免数据泄露')
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
