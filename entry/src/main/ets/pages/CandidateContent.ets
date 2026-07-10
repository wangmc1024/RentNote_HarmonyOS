import { Colors, Fonts, FontSizes, Dimensions, Radius, Shadows, Spacing, getTagTextColor, getTagBgColor } from '../common/DesignTokens';
import { PropertyInfo, PropertyIdParam } from '../model/PropertyModel';
import { HomeViewModel } from '../viewmodel/HomeViewModel';
import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';

@ComponentV2
export struct CandidateContent {
  @Local viewModel: HomeViewModel = new HomeViewModel();
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @Consumer('refreshFlag') refreshFlag: number = 0;
  @Local isEditMode: boolean = false;
  @Local selectedIds: Set<string> = new Set();
  @Local isMapExpanded: boolean = false;

  private mapOptions?: mapCommon.MapOptions;
  private mapCallback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private addedMarkers: map.Marker[] = [];

  @Monitor('refreshFlag')
  onRefreshFlagChange(): void {
    this.viewModel.loadData();
  }

  aboutToAppear(): void {
    this.viewModel.loadData();
    this.mapOptions = {
      position: {
        target: {
          latitude: 39.904,
          longitude: 116.407
        },
        zoom: 10
      }
    };
    this.mapCallback = async (err: BusinessError | null, mapController: map.MapComponentController) => {
      if (!err) {
        this.mapController = mapController;
        this.updateMarkers();
      }
    };
  }

  private async updateMarkers(): Promise<void> {
    if (!this.mapController) {
      return;
    }
    for (const marker of this.addedMarkers) {
      marker.remove();
    }
    this.addedMarkers = [];

    const properties: PropertyInfo[] = this.viewModel.candidateProperties;
    for (const p of properties) {
      if (p.latitude !== 0 && p.longitude !== 0) {
        const markerOptions: mapCommon.MarkerOptions = {
          position: {
            latitude: p.latitude,
            longitude: p.longitude
          },
          clickable: true,
          anchorU: 0.5,
          anchorV: 1,
          title: p.name,
          snippet: p.district.length > 0 ? p.district : undefined
        };
        const marker: map.Marker = await this.mapController.addMarker(markerOptions);
        this.addedMarkers.push(marker);
      }
    }
    for (const marker of this.addedMarkers) {
      marker.setInfoWindowVisible(true);
    }
  }

  private enterEditMode(id: string): void {
    this.isEditMode = true;
    this.selectedIds = new Set();
    this.selectedIds.add(id);
    this.selectedIds = new Set(this.selectedIds);
  }

  private toggleSelect(id: string): void {
    if (this.selectedIds.has(id)) {
      this.selectedIds.delete(id);
    } else {
      this.selectedIds.add(id);
    }
    this.selectedIds = new Set(this.selectedIds);
  }

  private selectAll(): void {
    this.selectedIds = new Set();
    for (const p of this.viewModel.candidateProperties) {
      this.selectedIds.add(p.id);
    }
    this.selectedIds = new Set(this.selectedIds);
  }

  private deselectAll(): void {
    this.selectedIds = new Set();
  }

  private exitEditMode(): void {
    this.isEditMode = false;
    this.selectedIds = new Set();
  }

  private async deleteSelected(): Promise<void> {
    if (this.selectedIds.size === 0) {
      return;
    }
    const ids: string[] = Array.from(this.selectedIds);
    await this.viewModel.batchDeleteCandidates(ids);
    this.refreshFlag++;
    this.exitEditMode();
  }

  private isAllSelected(): boolean {
    return this.viewModel.candidateProperties.length > 0 &&
      this.viewModel.candidateProperties.every((p: PropertyInfo) => this.selectedIds.has(p.id));
  }

  private hasSingleSelection(): boolean {
    return this.selectedIds.size === 1;
  }

  private getSelectedId(): string {
    const arr: string[] = Array.from(this.selectedIds);
    return arr.length > 0 ? arr[0] : '';
  }

  private hasGeoProperties(): boolean {
    return this.viewModel.candidateProperties.some((p: PropertyInfo) => p.latitude !== 0 && p.longitude !== 0);
  }

  private hasRentingProperty(): boolean {
    return this.viewModel.rentingProperties.length > 0;
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Row() {
          if (this.isEditMode) {
            Text('取消')
              .fontSize(FontSizes.BODY)
              .fontColor(Colors.PRIMARY)
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Medium)
              .onClick(() => {
                this.exitEditMode();
              })
          } else {
            Text('备选房源')
              .fontSize(FontSizes.PAGE_TITLE)
              .fontColor(Colors.TEXT_PRIMARY)
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Bold)
          }

          Blank()

          if (this.isEditMode) {
            if (this.hasSingleSelection() && !this.hasRentingProperty()) {
              Button('选定')
                .fontSize(FontSizes.BODY)
                .fontColor(Colors.TEXT_WHITE)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .backgroundColor(Colors.SUCCESS)
                .borderRadius(Radius.BUTTON)
                .height(32)
                .margin({ right: 12 })
                .onClick(() => {
                  this.viewModel.promoteCandidate(this.getSelectedId()).then(() => {
                    this.refreshFlag++;
                    this.exitEditMode();
                  });
                })
            } else if (this.hasSingleSelection() && this.hasRentingProperty()) {
              Text('已有选定')
                .fontSize(FontSizes.BODY)
                .fontColor(Colors.TEXT_MUTED)
                .fontFamily(Fonts.CN)
                .margin({ right: 12 })
            }

            if (this.viewModel.candidateProperties.length > 0) {
              Text(this.isAllSelected() ? '取消全选' : '全选')
                .fontSize(FontSizes.BODY)
                .fontColor(Colors.PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .onClick(() => {
                  if (this.isAllSelected()) {
                    this.deselectAll();
                  } else {
                    this.selectAll();
                  }
                })
            }
          }
        }
        .width('100%')
        .height(Dimensions.HEADER_HEIGHT)
        .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })

        if (this.isMapExpanded) {
          Column() {
            Row() {
              Row() {
                SymbolGlyph($r('sys.symbol.arrow_down_right_and_arrow_up_left'))
                  .fontSize(18)
                  .fontColor([Colors.TEXT_WHITE])

                Text('缩小')
                  .fontSize(FontSizes.CAPTION)
                  .fontColor(Colors.TEXT_WHITE)
                  .fontFamily(Fonts.CN)
                  .margin({ left: 4 })
              }
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor('rgba(0,0,0,0.5)')
              .borderRadius(Radius.BUTTON)
              .margin({ left: Spacing.PAGE_HORIZONTAL, top: 8 })
              .onClick(() => {
                this.isMapExpanded = false;
              })

              Blank()
            }
            .width('100%')

            MapComponent({ mapOptions: this.mapOptions, mapCallback: this.mapCallback })
              .width('100%')
              .layoutWeight(1)
          }
          .width('100%')
          .layoutWeight(1)
        } else {
          Scroll() {
            Column() {
              Column() {
                if (this.hasGeoProperties()) {
                  Stack() {
                    MapComponent({ mapOptions: this.mapOptions, mapCallback: this.mapCallback })
                      .width('100%')
                      .height(Dimensions.MAP_CARD_HEIGHT)
                      .borderRadius(Radius.CARD)
                      .clip(true)

                    Row() {
                      SymbolGlyph($r('sys.symbol.arrow_up_left_and_arrow_down_right'))
                        .fontSize(18)
                        .fontColor([Colors.TEXT_WHITE])

                      Text('放大查看')
                        .fontSize(FontSizes.CAPTION)
                        .fontColor(Colors.TEXT_WHITE)
                        .fontFamily(Fonts.CN)
                        .margin({ left: 4 })
                    }
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .backgroundColor('rgba(0,0,0,0.5)')
                    .borderRadius(Radius.BUTTON)
                    .position({ x: 12, y: 12 })
                    .onClick(() => {
                      this.isMapExpanded = true;
                    })
                  }
                  .width('100%')
                  .height(Dimensions.MAP_CARD_HEIGHT)
                  .borderRadius(Radius.CARD)
                  .clip(true)
                } else {
                  Row() {
                    SymbolGlyph($r('sys.symbol.map'))
                      .fontSize(32)
                      .fontColor([Colors.TEXT_MUTED])

                    Text('暂无位置信息')
                      .fontSize(FontSizes.BODY)
                      .fontColor(Colors.TEXT_MUTED)
                      .fontFamily(Fonts.CN)
                      .margin({ left: 12 })
                  }
                  .width('100%')
                  .height(Dimensions.MAP_CARD_HEIGHT)
                  .backgroundColor(Colors.BG_PRIMARY)
                  .borderRadius(Radius.CARD)
                  .justifyContent(FlexAlign.Center)
                }
              }
              .width('100%')
              .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })

              if (this.viewModel.candidateProperties.length === 0) {
                Column() {
                  SymbolGlyph($r('sys.symbol.magnifyingglass'))
                    .fontSize(36)
                    .fontColor([Colors.TEXT_MUTED])

                  Text('暂无备选，点击 + 添加看房候选')
                    .fontSize(FontSizes.BODY_SMALL)
                    .fontColor(Colors.TEXT_MUTED)
                    .fontFamily(Fonts.CN)
                    .margin({ top: 12 })
                }
                .width('100%')
                .height(120)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Colors.CARD_BG)
                .borderRadius(Radius.CARD)
                .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: Spacing.ITEM_GAP })
              } else {
                List({ space: 12 }) {
                  ForEach(this.viewModel.candidateProperties, (property: PropertyInfo) => {
                    ListItem() {
                      CandidateCard({
                        property: property,
                        isEditMode: this.isEditMode,
                        isSelected: this.selectedIds.has(property.id),
                        onCardClick: () => {
                          if (this.isEditMode) {
                            this.toggleSelect(property.id);
                          } else {
                            const detailParam: PropertyIdParam = { propertyId: property.id, mode: '' };
                            this.navPathStack.pushPathByName('PropertyDetail', detailParam);
                          }
                        },
                        onLongPress: () => {
                          if (!this.isEditMode) {
                            this.enterEditMode(property.id);
                          }
                        },
                        onSelect: () => { this.toggleSelect(property.id) }
                      })
                    }
                    .swipeAction({ end: {
                      builder: () => {
                        this.candidateSwipeAction(property.id)
                      }
                    } })
                  }, (item: PropertyInfo) => item.id)
                }
                .width('100%')
                .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })
                .margin({ top: Spacing.ITEM_GAP })
                .listDirection(Axis.Vertical)
                .scrollBar(BarState.Off)
                .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
              }

              Column().height(96)
            }
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .layoutWeight(1)
        }

        if (this.isEditMode) {
          Row() {
            Text(`已选 ${this.selectedIds.size} 项`)
              .fontSize(FontSizes.BODY)
              .fontColor(Colors.TEXT_SECONDARY)
              .fontFamily(Fonts.CN)

            Blank()

            Button('删除所选')
              .fontSize(FontSizes.BODY)
              .fontColor(Colors.TEXT_WHITE)
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Medium)
              .backgroundColor(this.selectedIds.size > 0 ? Colors.DANGER : Colors.DIVIDER_DARK)
              .borderRadius(Radius.BUTTON)
              .height(36)
              .enabled(this.selectedIds.size > 0)
              .onClick(() => {
                this.deleteSelected();
              })
          }
          .width('100%')
          .height(60)
          .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })
          .backgroundColor(Colors.CARD_BG)
          .shadow({
            radius: Shadows.TAB_BAR.radius,
            color: 'rgba(0,0,0,0.08)',
            offsetX: 0,
            offsetY: -2
          })
        }
      }
      .layoutWeight(1)

      if (!this.isEditMode && !this.isMapExpanded) {
        Button() {
          SymbolGlyph($r('sys.symbol.plus'))
            .fontSize(24)
            .fontColor([Colors.TEXT_WHITE])
        }
        .width(Dimensions.FAB_SIZE)
        .height(Dimensions.FAB_SIZE)
        .backgroundColor(Colors.PRIMARY)
        .borderRadius(28)
        .shadow({
          radius: Shadows.TAB_BAR.radius,
          color: 'rgba(80,70,229,0.4)',
          offsetX: 0,
          offsetY: 4
        })
        .margin({ right: Spacing.PAGE_HORIZONTAL, bottom: 20 })
        .onClick(() => {
          const addParam: PropertyIdParam = new PropertyIdParam();
          addParam.mode = 'candidate';
          this.navPathStack.pushPathByName('AddProperty', addParam);
        })
      }
    }
    .layoutWeight(1)
  }

  @Builder
  candidateSwipeAction(propertyId: string) {
    Row() {
      Button('选定')
        .fontSize(FontSizes.BODY)
        .fontColor(Colors.TEXT_WHITE)
        .fontFamily(Fonts.CN)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.hasRentingProperty() ? Colors.DIVIDER_DARK : Colors.SUCCESS)
        .borderRadius(0)
        .height('100%')
        .width(72)
        .enabled(!this.hasRentingProperty())
        .onClick(() => {
          this.viewModel.promoteCandidate(propertyId).then(() => {
            this.refreshFlag++;
          });
        })

      Button('删除')
        .fontSize(FontSizes.BODY)
        .fontColor(Colors.TEXT_WHITE)
        .fontFamily(Fonts.CN)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(Colors.DANGER)
        .borderRadius(0)
        .height('100%')
        .width(72)
        .onClick(() => {
          this.viewModel.deleteProperty(propertyId).then(() => {
            this.refreshFlag++;
          });
        })
    }
  }
}

@ComponentV2
struct CandidateCard {
  @Param property: PropertyInfo = new PropertyInfo();
  @Param isEditMode: boolean = false;
  @Param isSelected: boolean = false;
  @Param onCardClick: () => void = () => {};
  @Param onLongPress: () => void = () => {};
  @Param onSelect: () => void = () => {};

  build() {
    Row() {
      if (this.isEditMode) {
        Checkbox()
          .select(this.isSelected)
          .shape(CheckBoxShape.CIRCLE)
          .width(24)
          .height(24)
          .margin({ right: 12 })
          .onChange((checked: boolean) => {
            this.onSelect();
          })
      }

      Column() {
        Row() {
           if (this.property.getFirstImage().length > 0) {
             Image(this.property.getFirstImage())
               .width(48)
               .height(48)
               .objectFit(ImageFit.Cover)
               .borderRadius(Radius.ICON_BG)
           } else {
             Row() {
               SymbolGlyph($r('sys.symbol.house'))
                 .fontSize(22)
                 .fontColor([Colors.WARNING])
             }
             .width(48)
             .height(48)
             .backgroundColor(Colors.WARNING_LIGHT)
             .borderRadius(Radius.ICON_BG)
             .justifyContent(FlexAlign.Center)
           }

          Column() {
            Text(this.property.name)
              .fontSize(FontSizes.BODY_LARGE)
              .fontColor(Colors.TEXT_PRIMARY)
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            if (this.property.address.length > 0) {
              Text(this.property.address)
                .fontSize(FontSizes.BODY_SMALL)
                .fontColor(Colors.TEXT_SECONDARY)
                .fontFamily(Fonts.CN)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ top: 4 })
            }
          }
          .layoutWeight(1)
          .margin({ left: 12 })

          Text('备选')
            .fontSize(FontSizes.CAPTION)
            .fontColor(Colors.TEXT_MUTED)
            .fontFamily(Fonts.CN)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        if (this.property.tags.length > 0) {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.property.tags, (tag: string) => {
              Text(tag)
                .fontSize(FontSizes.CAPTION)
                .fontColor(getTagTextColor(tag))
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                .backgroundColor(getTagBgColor(tag))
                .borderRadius(Radius.TAG)
                .margin({ right: 6, top: 4 })
            }, (item: string) => item)
          }
          .width('100%')
          .margin({ top: 10 })
        }
      }
      .layoutWeight(1)
      .backgroundColor(Colors.CARD_BG)
      .borderRadius(Radius.CARD)
      .padding(Spacing.CARD_PADDING)
      .shadow({
        radius: Shadows.CARD.radius,
        color: Shadows.CARD.color,
        offsetX: Shadows.CARD.offsetX,
        offsetY: Shadows.CARD.offsetY
      })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.onCardClick();
    })
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction(() => {
          this.onLongPress();
        })
    )
  }
}
