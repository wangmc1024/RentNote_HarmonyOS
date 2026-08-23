import { Colors, Fonts, FontSizes, Radius, Shadows, Spacing } from '../common/DesignTokens';
import { HeaderBar } from '../components/HeaderBar';
import { PropertyRepository } from '../repository/PropertyRepository';
import { ImportResult } from '../model/PropertyModel';
import { picker, fileIo } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';

@Builder
export function DataImportBuilder() {
  DataImportPage()
}

@ComponentV2
export struct DataImportPage {
  @Local importStatus: string = '';
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @Consumer('refreshFlag') refreshFlag: number = 0;

  private repository: PropertyRepository = PropertyRepository.getInstance();

  private async importFromJson(): Promise<void> {
    try {
      const documentSelectOptions: picker.DocumentSelectOptions = new picker.DocumentSelectOptions();
      documentSelectOptions.maxSelectNumber = 1;
      documentSelectOptions.fileSuffixFilters = ['JSON|.json'];
      const context: Context = this.getUIContext().getHostContext() as Context;
      const documentViewPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker(context);
      const uris: string[] = await documentViewPicker.select(documentSelectOptions);
      if (uris.length === 0) {
        return;
      }
      const uri: string = uris[0];
      const file: fileIo.File = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
      const stat: fileIo.Stat = fileIo.statSync(file.fd);
      const buffer: ArrayBuffer = new ArrayBuffer(stat.size);
      fileIo.readSync(file.fd, buffer);
      fileIo.closeSync(file);
      const decoder: util.TextDecoder = util.TextDecoder.create('utf-8');
      const jsonStr: string = decoder.decodeToString(new Uint8Array(buffer));
      const importResult: ImportResult = await this.repository.importFromJson(jsonStr);
      if (importResult.imported > 0 || importResult.updated > 0) {
        const parts: string[] = [];
        if (importResult.imported > 0) {
          parts.push(`新增 ${importResult.imported} 条`);
        }
        if (importResult.updated > 0) {
          parts.push(`更新 ${importResult.updated} 条`);
        }
        const msg: string = `成功导入：${parts.join('，')}`;
        this.importStatus = msg;
        this.refreshFlag++;
        this.getUIContext().getPromptAction().showToast({ message: msg, duration: 2000 });
      } else {
        this.importStatus = '未导入任何数据，文件可能为空或所有房源已存在';
        this.getUIContext().getPromptAction().showToast({ message: '没有可导入的新房源', duration: 2000 });
      }
    } catch (_e) {
      this.importStatus = '导入失败，请检查文件格式';
      try {
        this.getUIContext().getPromptAction().showToast({ message: '导入失败', duration: 2000 });
      } catch (_ee) {
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        HeaderBar({
          title: '数据导入',
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

                  Text('从 JSON 文件导入')
                    .fontSize(FontSizes.BODY)
                    .fontColor(Colors.TEXT_PRIMARY)
                    .fontFamily(Fonts.CN)
                    .fontWeight(FontWeight.Medium)
                    .margin({ top: 8 })

                  Text('选择 .json 文件导入房源数据')
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
                this.importFromJson();
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

            if (this.importStatus.length > 0) {
              Column() {
                Text(this.importStatus)
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
              Text('导入说明')
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)

              Text('1. 选择要导入的 JSON 文件\n2. 文件需包含房源名称、地址、月租金等必填字段\n3. 支持含照片数据的 JSON 格式导入，兼容旧版不含照片的 JSON\n4. 导入数据将与现有数据合并，重复项自动更新\n5. 导入完成后可在首页查看新增和更新的房源')
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
