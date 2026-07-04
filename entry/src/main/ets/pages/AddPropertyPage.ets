/**
 * 新增/编辑房源页 - NavDestination 页面
 * 使用 @ComponentV2 装饰器
 * 通过 onReady 获取可选的 propertyId 参数区分新增/编辑模式
 * 保存后调用 navPathStack.pop({ result: { saved: true } })
 * 统一使用 HeaderBar 组件
 */
import { Colors, Fonts, FontSizes, Dimensions, Radius, Shadows, Spacing } from '../common/DesignTokens';
import { promptAction } from '@kit.ArkUI';
import { HeaderBar } from '../components/HeaderBar';
import { TagCategory } from '../model/TagModel';
import { PropertyInfo, PropertyIdParam, SaveResult, DeleteResult } from '../model/PropertyModel';
import { AddPropertyViewModel } from '../viewmodel/AddPropertyViewModel';

@Builder
export function AddPropertyBuilder() {
  AddPropertyPage()
}

@ComponentV2
export struct AddPropertyPage {
  @Local viewModel: AddPropertyViewModel = new AddPropertyViewModel();
  @Local communityName: string = '';
  @Local address: string = '';
  @Local monthlyRent: string = '';
  @Local deposit: string = '';
  @Local startDate: string = '';
  @Local endDate: string = '';
  @Local notes: string = '';
  @Local renewalStatus: string = '';
  @Local tagCategories: TagCategory[] = [
    new TagCategory('付款方式', Colors.TAG_PAYMENT_BG, Colors.TAG_PAYMENT_TEXT,
      ['押一付三', '半年付'], []),
    new TagCategory('租赁类型', Colors.TAG_LEASE_BG, Colors.TAG_LEASE_TEXT,
      ['整租', '合租'], []),
    new TagCategory('房屋条件', Colors.TAG_CONDITION_BG, Colors.TAG_CONDITION_TEXT,
      ['精装修', '民水民电', '包物业', '有电梯', '朝南', '学区房', '南北通透', '新小区'], []),
    new TagCategory('其他', Colors.TAG_SURROUND_BG, Colors.TAG_SURROUND_TEXT,
      ['近地铁', '可短租', '房东好说话', '科技园区'], [])
  ];
  @Local validationError: string = '';
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @Consumer('refreshFlag') refreshFlag: number = 0;

  aboutToAppear(): void {
    this.viewModel.setAddMode();
    this.viewModel.isCandidateMode = true;
  }

  /** 加载编辑房源数据预填充 */
  private loadPropertyData(): void {
    const property: PropertyInfo | undefined = this.viewModel.loadProperty();
    if (property) {
      this.communityName = property.name;
      this.address = property.address;
      this.monthlyRent = property.monthlyRent.toString();
      this.deposit = property.deposit.toString();
      this.startDate = property.startDate;
      this.endDate = property.endDate;
      this.notes = property.notes;
      this.renewalStatus = property.renewalStatus;
    }
  }

  /** 收集选中的标签 */
  private getSelectedTags(): string[] {
    const selected: string[] = [];
    for (const category of this.tagCategories) {
      for (let i: number = 0; i < category.tags.length; i++) {
        if (category.selected[i]) {
          selected.push(category.tags[i]);
        }
      }
    }
    return selected;
  }

  /** 保存房源 */
  private saveProperty(): void {
    const property: PropertyInfo = new PropertyInfo();
    property.name = this.communityName;
    property.address = this.address;
    property.district = this.address.length > 0 ? this.address.substring(0, 3) : '';
    property.tags = this.getSelectedTags();
    property.monthlyRent = parseFloat(this.monthlyRent) || 0;
    property.deposit = parseFloat(this.deposit) || 0;
    property.startDate = this.startDate;
    property.endDate = this.endDate;
    property.status = 'renting';
    property.billsPaid = 0;
    property.imageUrl = '';
    property.notes = this.notes;
    property.renewalStatus = this.renewalStatus;

    this.viewModel.saveProperty(property).then((success: boolean) => {
      if (success) {
        promptAction.showToast({
          message: '保存成功',
          duration: 2000
        });
        const saveResult: SaveResult = new SaveResult();
        saveResult.saved = true;
        this.refreshFlag++;
        this.navPathStack.pop(saveResult);
      } else {
        this.validationError = this.viewModel.validationError;
      }
    });
  }

  build() {
    NavDestination() {
      Column() {
        HeaderBar({
          title: this.viewModel.isEditMode
            ? (this.viewModel.isCandidateMode ? '编辑备选' : '编辑房源')
            : (this.viewModel.isCandidateMode ? '新增备选' : '新增房源'),
          showBack: true,
          onBack: () => {
            this.navPathStack.pop();
          }
        })

        // 可滚动表单
        Scroll() {
          Column({ space: 24 }) {
            // ===== 房源信息 =====
            Text('房源信息')
              .fontSize(FontSizes.PAGE_TITLE)
              .fontColor(Colors.TEXT_PRIMARY)
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)

            // 小区名
            this.SectionField('小区名', '请输入小区名称', 48, this.communityName, (v: string) => { this.communityName = v })

            // 详细地址
            Column({ space: 8 }) {
              Text('详细地址')
                .fontSize(FontSizes.BODY)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)

              Row({ space: 8 }) {
                SymbolGlyph($r('sys.symbol.building'))
                  .fontSize(16)
                  .fontColor([Colors.TEXT_MUTED])

                TextInput({ placeholder: '请输入详细地址', text: this.address })
                  .layoutWeight(1)
                  .height(48)
                  .backgroundColor(Colors.CARD_BG)
                  .borderRadius(Radius.CARD_SM)
                  .padding({ left: Spacing.CARD_PADDING_SM })
                  .fontSize(FontSizes.BODY_LARGE)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .fontFamily(Fonts.CN)
                  .placeholderColor(Colors.TEXT_MUTED)
                  .onChange((v: string) => { this.address = v })
              }
              .width('100%')
              .height(48)
              .backgroundColor(Colors.CARD_BG)
              .borderRadius(Radius.CARD_SM)
              .padding({ left: Spacing.CARD_PADDING_SM, right: Spacing.CARD_PADDING_SM })
              .alignItems(VerticalAlign.Center)
            }

            // ===== 费用与租期 =====
            Text('费用与租期')
              .fontSize(FontSizes.PAGE_TITLE)
              .fontColor(Colors.TEXT_PRIMARY)
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)

            this.SectionField('月租金', '¥ 0.00', 48, this.monthlyRent, (v: string) => { this.monthlyRent = v })
            this.SectionField('押金', '¥ 0.00', 48, this.deposit, (v: string) => { this.deposit = v })

            Row({ space: 12 }) {
              this.DateField('入住时间', '2024.07.01', this.startDate, (v: string) => { this.startDate = v })
              this.DateField('到期时间', '2025.07.01', this.endDate, (v: string) => { this.endDate = v })
            }
            .width('100%')

            if (!this.viewModel.isCandidateMode) {
              Column({ space: 8 }) {
                Text('续租意向')
                  .fontSize(FontSizes.BODY)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .fontFamily(Fonts.CN)
                  .fontWeight(FontWeight.Medium)
                  .alignSelf(ItemAlign.Start)

                Row({ space: 12 }) {
                  Text('续租')
                    .fontSize(FontSizes.BODY)
                    .fontColor(this.renewalStatus === 'renew' ? Colors.TEXT_WHITE : Colors.TEXT_SECONDARY)
                    .fontFamily(Fonts.CN)
                    .fontWeight(FontWeight.Medium)
                    .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                    .backgroundColor(this.renewalStatus === 'renew' ? Colors.SUCCESS : Colors.CARD_BG)
                    .borderRadius(Radius.TAG)
                    .border({
                      width: this.renewalStatus === 'renew' ? 0 : 1,
                      color: Colors.DIVIDER_DARK,
                      style: BorderStyle.Solid
                    })
                    .onClick(() => { this.renewalStatus = 'renew' })

                  Text('不租')
                    .fontSize(FontSizes.BODY)
                    .fontColor(this.renewalStatus === 'no_renew' ? Colors.TEXT_WHITE : Colors.TEXT_SECONDARY)
                    .fontFamily(Fonts.CN)
                    .fontWeight(FontWeight.Medium)
                    .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                    .backgroundColor(this.renewalStatus === 'no_renew' ? Colors.DANGER : Colors.CARD_BG)
                    .borderRadius(Radius.TAG)
                    .border({
                      width: this.renewalStatus === 'no_renew' ? 0 : 1,
                      color: Colors.DIVIDER_DARK,
                      style: BorderStyle.Solid
                    })
                    .onClick(() => { this.renewalStatus = 'no_renew' })

                  Text('待定')
                    .fontSize(FontSizes.BODY)
                    .fontColor(this.renewalStatus === 'undecided' ? Colors.TEXT_WHITE : Colors.TEXT_SECONDARY)
                    .fontFamily(Fonts.CN)
                    .fontWeight(FontWeight.Medium)
                    .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                    .backgroundColor(this.renewalStatus === 'undecided' ? Colors.WARNING : Colors.CARD_BG)
                    .borderRadius(Radius.TAG)
                    .border({
                      width: this.renewalStatus === 'undecided' ? 0 : 1,
                      color: Colors.DIVIDER_DARK,
                      style: BorderStyle.Solid
                    })
                    .onClick(() => { this.renewalStatus = 'undecided' })
                }
                .width('100%')
              }
            }

            // ===== 标签筛选 =====
            Text('标签')
              .fontSize(FontSizes.PAGE_TITLE)
              .fontColor(Colors.TEXT_PRIMARY)
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)

            // 标签筛选卡片
            Column({ space: 14 }) {
              ForEach(this.tagCategories, (category: TagCategory, catIdx: number) => {
                Column({ space: 6 }) {
                  Text(category.name)
                    .fontSize(FontSizes.CAPTION)
                    .fontColor(Colors.TAG_LABEL)
                    .fontFamily(Fonts.CN)
                    .fontWeight(FontWeight.Medium)
                    .alignSelf(ItemAlign.Start)

                  Flex({ wrap: FlexWrap.Wrap }) {
                    ForEach(category.tags, (tag: string, tagIdx: number) => {
                      Text(tag)
                        .fontSize(FontSizes.CAPTION)
                        .fontColor(category.selected[tagIdx] ? category.tagText : Colors.TEXT_MUTED)
                        .fontFamily(Fonts.CN)
                        .fontWeight(FontWeight.Medium)
                        .padding({ left: 12, right: 12, top: 5, bottom: 5 })
                        .backgroundColor(category.selected[tagIdx] ? category.tagBg : Colors.CARD_BG)
                        .borderRadius(Radius.TAG)
                        .border({
                          width: category.selected[tagIdx] ? 0 : 1,
                          color: '#E7E7EA',
                          style: BorderStyle.Solid
                        })
                        .onClick(() => {
                          const updated: boolean[] = [...category.selected];
                          updated[tagIdx] = !updated[tagIdx];
                          this.tagCategories[catIdx].selected = updated;
                          // 触发状态更新
                          this.tagCategories = [...this.tagCategories];
                        })
                    }, (item: string) => item)
                  }
                  .width('100%')
                }
                .width('100%')
              }, (item: TagCategory, idx: number) => idx.toString())
            }
            .width('100%')
            .backgroundColor(Colors.CARD_BG)
            .borderRadius(Radius.CARD)
            .padding({
              left: Spacing.CARD_PADDING_SM,
              right: Spacing.CARD_PADDING_SM,
              top: 16,
              bottom: 16
            })

            // ===== 备注 =====
            Text('备注')
              .fontSize(FontSizes.PAGE_TITLE)
              .fontColor(Colors.TEXT_PRIMARY)
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)

            Column({ space: 8 }) {
              TextArea({ placeholder: '添加备注信息，如押一付三、包物业...', text: this.notes })
                .width('100%')
                .height(80)
                .backgroundColor(Colors.CARD_BG)
                .borderRadius(Radius.CARD_SM)
                .padding({
                  left: Spacing.CARD_PADDING_SM,
                  right: Spacing.CARD_PADDING_SM,
                  top: 12,
                  bottom: 12
                })
                .fontSize(FontSizes.BODY)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .placeholderColor(Colors.TEXT_MUTED)
                .onChange((value: string) => { this.notes = value; })

              Text('备注将以标签形式展示在房源卡片上')
                .fontSize(FontSizes.CAPTION)
                .fontColor(Colors.TEXT_MUTED)
                .fontFamily(Fonts.CN)
                .alignSelf(ItemAlign.Start)
                .margin({ left: 4 })
            }

            // 验证错误提示
            if (this.validationError) {
              Text(this.validationError)
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(Colors.DANGER)
                .fontFamily(Fonts.CN)
                .alignSelf(ItemAlign.Start)
            }

            // 保存/删除按钮
            if (this.viewModel.isEditMode) {
              Row({ space: 12 }) {
                Button('保存')
                  .layoutWeight(1)
                  .height(52)
                  .fontSize(FontSizes.SECTION_TITLE)
                  .fontColor(Colors.TEXT_WHITE)
                  .fontFamily(Fonts.CN)
                  .fontWeight(FontWeight.Medium)
                  .backgroundColor(Colors.PRIMARY)
                  .borderRadius(Radius.BUTTON)
                  .onClick(() => {
                    this.saveProperty();
                  })

                Button('删除')
                  .layoutWeight(1)
                  .height(52)
                  .fontSize(FontSizes.SECTION_TITLE)
                  .fontColor(Colors.DANGER)
                  .fontFamily(Fonts.CN)
                  .fontWeight(FontWeight.Medium)
                  .backgroundColor(Colors.DANGER_LIGHT)
                  .borderRadius(Radius.BUTTON)
                  .border({ width: 1, color: Colors.DANGER_BORDER })
                  .onClick(() => {
                    this.showDeleteDialog();
                  })
              }
              .width('100%')
            } else {
              Button(this.viewModel.isCandidateMode ? '添加备选' : '保存')
                .width('100%')
                .height(52)
                .fontSize(FontSizes.SECTION_TITLE)
                .fontColor(Colors.TEXT_WHITE)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .backgroundColor(Colors.PRIMARY)
                .borderRadius(Radius.BUTTON)
                .onClick(() => {
                  this.saveProperty();
                })
            }
          }
          .alignItems(HorizontalAlign.Center)
          .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: 8, bottom: 40 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Colors.BG_PRIMARY)
    }
    .onReady((context: NavDestinationContext) => {
      const param: PropertyIdParam | undefined = context.pathInfo.param as PropertyIdParam | undefined;
      if (param && param.propertyId) {
        this.viewModel.setEditMode(param.propertyId);
        const property: PropertyInfo | undefined = this.viewModel.loadProperty();
        if (property && property.status === 'candidate') {
          this.viewModel.isCandidateMode = true;
        } else {
          this.viewModel.isCandidateMode = false;
        }
        this.loadPropertyData();
      } else if (param && param.mode === 'candidate') {
        this.viewModel.isCandidateMode = true;
      } else {
        this.viewModel.isCandidateMode = false;
      }
    })
    .hideTitleBar(true)
  }

  // 通用表单字段构建器
  @Builder
  SectionField(label: string, placeholder: string, inputHeight: number, value: string, onChange: (v: string) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(FontSizes.BODY)
        .fontColor(Colors.TEXT_PRIMARY)
        .fontFamily(Fonts.CN)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)

      TextInput({ placeholder: placeholder, text: value })
        .width('100%')
        .height(inputHeight)
        .backgroundColor(Colors.CARD_BG)
        .borderRadius(Radius.CARD_SM)
        .padding({ left: Spacing.CARD_PADDING_SM, right: Spacing.CARD_PADDING_SM })
        .fontSize(FontSizes.BODY_LARGE)
        .fontColor(Colors.TEXT_PRIMARY)
        .fontFamily(Fonts.CN)
        .placeholderColor(Colors.TEXT_MUTED)
        .onChange((v: string) => onChange(v))
    }
  }

  // 日期字段构建器
  @Builder
  DateField(label: string, placeholder: string, value: string, onChange: (v: string) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(FontSizes.BODY)
        .fontColor(Colors.TEXT_PRIMARY)
        .fontFamily(Fonts.CN)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)

      TextInput({ placeholder: placeholder, text: value })
        .width('100%')
        .height(48)
        .backgroundColor(Colors.CARD_BG)
        .borderRadius(Radius.CARD_SM)
        .padding({ left: Spacing.CARD_PADDING_SM, right: Spacing.CARD_PADDING_SM })
        .fontSize(FontSizes.BODY_LARGE)
        .fontColor(Colors.TEXT_MUTED)
        .fontFamily(Fonts.NUMBER)
        .placeholderColor(Colors.TEXT_MUTED)
        .onChange((v: string) => onChange(v))
    }
    .layoutWeight(1)
  }

  private showDeleteDialog(): void {
    AlertDialog.show({
      message: '确认删除此房源？删除后无法恢复。',
      primaryButton: {
        value: '确认删除',
        action: () => {
          if (this.viewModel.editPropertyId) {
            this.viewModel.deleteProperty(this.viewModel.editPropertyId).then(() => {
              const delResult: DeleteResult = new DeleteResult();
              delResult.deleted = true;
              delResult.propertyId = this.viewModel.editPropertyId;
              this.refreshFlag++;
              this.navPathStack.pop(delResult);
            });
          }
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    });
  }
}
