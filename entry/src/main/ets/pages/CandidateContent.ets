import { Colors, Fonts, FontSizes, Dimensions, Radius, Shadows, Spacing, getTagTextColor, getTagBgColor } from '../common/DesignTokens';
import { PropertyInfo, PropertyIdParam } from '../model/PropertyModel';
import { HomeViewModel } from '../viewmodel/HomeViewModel';
import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { MapLocationHelper, createMapOptions } from '../common/MapLocationHelper';

@ComponentV2
export struct CandidateContent {
  @Local viewModel: HomeViewModel = new HomeViewModel();
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @Consumer('refreshFlag') refreshFlag: number = 0;
  @Local isMapExpanded: boolean = false;
  @Local selectedMarkerPropertyId: string = '';
  @Local selectedMarkerPropertyName: string = '';
  @Local selectedMarkerDistrict: string = '';
  @Local selectedMarkerImage: string = '';

  private mapOptions?: mapCommon.MapOptions;
  private mapCallback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private addedMarkers: map.Marker[] = [];
  private markerPropertyIds: string[] = [];
  private locationHelper: MapLocationHelper = new MapLocationHelper();

  @Monitor('refreshFlag')
  onRefreshFlagChange(): void {
    this.updateMarkers();
  }

  aboutToAppear(): void {
    const context = getContext(this) as common.UIAbilityContext;
    this.locationHelper.requestLocationPermission(context);

    this.viewModel.loadData().then(() => {
      this.updateMarkers();
    });
    this.mapOptions = createMapOptions(39.904, 116.407, 10);
    this.mapCallback = async (err: BusinessError | null, mapController: map.MapComponentController) => {
      if (!err) {
        this.mapController = mapController;
        this.locationHelper.setMapController(mapController);
        this.updateMarkers();
        // 定位成功后自动移动到用户位置
        const state = this.locationHelper.getState();
        if (state.hasCachedLocation) {
          this.locationHelper.animateToCachedLocation();
        }
        mapController.on('markerClick', (marker: map.Marker) => {
          const markerIndex: number = this.addedMarkers.indexOf(marker);
          if (markerIndex >= 0 && markerIndex < this.markerPropertyIds.length) {
            const propId: string = this.markerPropertyIds[markerIndex];
            const prop: PropertyInfo | null = this.getPropertyById(propId);
            if (prop) {
              this.selectedMarkerPropertyId = prop.id;
              this.selectedMarkerPropertyName = prop.name;
              this.selectedMarkerDistrict = prop.district;
              this.selectedMarkerImage = prop.getFirstImage();
            }
          }
          return false;
        });
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
    this.markerPropertyIds = [];

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
        try {
          const marker: map.Marker = await this.mapController.addMarker(markerOptions);
          this.addedMarkers.push(marker);
          this.markerPropertyIds.push(p.id);
        } catch (_e) {
        }
      }
    }
  }

  private hasGeoProperties(): boolean {
    return this.viewModel.candidateProperties.some((p: PropertyInfo) => p.latitude !== 0 && p.longitude !== 0);
  }

  private getPropertyById(id: string): PropertyInfo | null {
    const all: PropertyInfo[] = [...this.viewModel.candidateProperties, ...this.viewModel.rentingProperties];
    for (const p of all) {
      if (p.id === id) {
        return p;
      }
    }
    return null;
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Row() {
          Text('备选房源')
            .fontSize(FontSizes.PAGE_TITLE)
            .fontColor(Colors.TEXT_PRIMARY)
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Bold)
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

            Stack() {
              MapComponent({ mapOptions: this.mapOptions, mapCallback: this.mapCallback, customInfoWindow: this.customInfoWindowBuilder })
                .width('100%')
                .height('100%')
            }
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
                    MapComponent({ mapOptions: this.mapOptions, mapCallback: this.mapCallback, customInfoWindow: this.customInfoWindowBuilder })
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

                  Text('暂无备选房源')
                    .fontSize(FontSizes.BODY_LARGE)
                    .fontColor(Colors.TEXT_SECONDARY)
                    .fontFamily(Fonts.CN)
                    .fontWeight(FontWeight.Medium)
                    .margin({ top: 12 })

                  Column({ space: 6 }) {
                    Row() {
                      Row() {
                        Text('1')
                          .fontSize(10)
                          .fontColor(Colors.PRIMARY)
                          .fontFamily(Fonts.NUMBER)
                          .fontWeight(FontWeight.Bold)
                      }
                      .width(18)
                      .height(18)
                      .backgroundColor(Colors.PRIMARY_LIGHT)
                      .borderRadius(9)
                      .justifyContent(FlexAlign.Center)

                      Text('点击右下角 + 添加看房候选')
                        .fontSize(FontSizes.BODY_SMALL)
                        .fontColor(Colors.TEXT_SECONDARY)
                        .fontFamily(Fonts.CN)
                        .margin({ left: 8 })
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Center)

                    Row() {
                      Row() {
                        Text('2')
                          .fontSize(10)
                          .fontColor(Colors.PRIMARY)
                          .fontFamily(Fonts.NUMBER)
                          .fontWeight(FontWeight.Bold)
                      }
                      .width(18)
                      .height(18)
                      .backgroundColor(Colors.PRIMARY_LIGHT)
                      .borderRadius(9)
                      .justifyContent(FlexAlign.Center)

                      Text('左滑备选卡片可「选定」或「删除」')
                        .fontSize(FontSizes.BODY_SMALL)
                        .fontColor(Colors.TEXT_SECONDARY)
                        .fontFamily(Fonts.CN)
                        .margin({ left: 8 })
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Center)

                    Row() {
                      Row() {
                        Text('3')
                          .fontSize(10)
                          .fontColor(Colors.PRIMARY)
                          .fontFamily(Fonts.NUMBER)
                          .fontWeight(FontWeight.Bold)
                      }
                      .width(18)
                      .height(18)
                      .backgroundColor(Colors.PRIMARY_LIGHT)
                      .borderRadius(9)
                      .justifyContent(FlexAlign.Center)

                      Text('选定后房源将出现在首页')
                        .fontSize(FontSizes.BODY_SMALL)
                        .fontColor(Colors.TEXT_SECONDARY)
                        .fontFamily(Fonts.CN)
                        .margin({ left: 8 })
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')
                  .padding({ left: 40, right: 40 })
                  .margin({ top: 8 })
                }
                .width('100%')
                .height(220)
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
                        onCardClick: () => {
                          const detailParam: PropertyIdParam = new PropertyIdParam();
                          detailParam.propertyId = property.id;
                          this.navPathStack.pushPathByName('PropertyDetail', detailParam);
                        }
                      })
                    }
                    .swipeAction({ end: {
                      builder: () => {
                        this.candidateSwipeAction(property.id)
                      }
                    } })
                  }, (item: PropertyInfo) => item.id + '_' + this.viewModel.dataVersion.toString())
                }
                .width('100%')
                .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL })
                .margin({ top: Spacing.ITEM_GAP })
                .listDirection(Axis.Vertical)
                .scrollBar(BarState.Off)
                .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })

                if (this.viewModel.candidateProperties.length > 0) {
                  Row() {
                    SymbolGlyph($r('sys.symbol.lightbulb'))
                      .fontSize(14)
                      .fontColor([Colors.PRIMARY])

                    Text('左滑备选卡片可「选定」为在租房源，支持多套同时选定')
                      .fontSize(FontSizes.CAPTION)
                      .fontColor(Colors.PRIMARY)
                      .fontFamily(Fonts.CN)
                      .margin({ left: 6 })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Center)
                  .padding({ top: 8, bottom: 8 })
                  .backgroundColor(Colors.PRIMARY_LIGHT)
                  .borderRadius(Radius.TAG)
                  .margin({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: Spacing.ITEM_GAP })
                }
              }

              Column().height(96)
            }
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .layoutWeight(1)
        }
      }
      .layoutWeight(1)

      if (!this.isMapExpanded) {
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

      if (this.selectedMarkerPropertyId.length > 0) {
        this.MarkerInfoOverlay()
      }
    }
    .layoutWeight(1)
  }

  @Builder
  MarkerInfoOverlay() {
    Column() {
      Row() {
        if (this.selectedMarkerImage.length > 0) {
          Image(this.selectedMarkerImage)
            .width(48)
            .height(48)
            .objectFit(ImageFit.Cover)
            .borderRadius(Radius.CARD_SM)
            .margin({ right: 12 })
        }
        Column() {
          Text(this.selectedMarkerPropertyName)
            .fontSize(FontSizes.BODY)
            .fontColor(Colors.TEXT_PRIMARY)
            .fontFamily(Fonts.CN)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          if (this.selectedMarkerDistrict.length > 0) {
            Text(this.selectedMarkerDistrict)
              .fontSize(FontSizes.CAPTION)
              .fontColor(Colors.TEXT_MUTED)
              .fontFamily(Fonts.CN)
              .margin({ top: 2 })
          }
        }
        .layoutWeight(1)
        Row() {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(16)
            .fontColor([Colors.TEXT_MUTED])
        }
        .width(28)
        .height(28)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.clearMarkerSelection();
        })
      }
      .width('100%')
      .padding({ left: 16, right: 12, top: 12, bottom: 12 })
      .backgroundColor(Colors.CARD_BG)
      .borderRadius(Radius.CARD)
      .shadow({
        radius: Shadows.CARD.radius,
        color: 'rgba(0,0,0,0.12)',
        offsetX: 0,
        offsetY: 2
      })
      .onClick(() => {
        if (this.selectedMarkerPropertyId.length > 0) {
          const detailParam: PropertyIdParam = new PropertyIdParam();
          detailParam.propertyId = this.selectedMarkerPropertyId;
          this.navPathStack.pushPathByName('PropertyDetail', detailParam);
          this.clearMarkerSelection();
        }
      })
    }
    .width('100%')
    .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, bottom: 16 })
  }

  private clearMarkerSelection(): void {
    this.selectedMarkerPropertyId = '';
    this.selectedMarkerPropertyName = '';
    this.selectedMarkerDistrict = '';
    this.selectedMarkerImage = '';
  }

  private getMarkerPropertyImage(marker: map.Marker): string {
    const markerIndex: number = this.addedMarkers.indexOf(marker);
    if (markerIndex >= 0 && markerIndex < this.markerPropertyIds.length) {
      const prop: PropertyInfo | null = this.getPropertyById(this.markerPropertyIds[markerIndex]);
      if (prop) {
        return prop.getFirstImage();
      }
    }
    return '';
  }

  @Builder
  customInfoWindowBuilder($$: map.MarkerDelegate) {
    if ($$.marker) {
      Column() {
        Row() {
          if (this.getMarkerPropertyImage($$.marker).length > 0) {
            Image(this.getMarkerPropertyImage($$.marker))
              .width(36)
              .height(36)
              .objectFit(ImageFit.Cover)
              .borderRadius(Radius.CARD_SM)
              .margin({ right: 8 })
          }
          Column() {
            Text($$.marker.getTitle())
              .fontSize(FontSizes.CAPTION)
              .fontColor(Colors.TEXT_PRIMARY)
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            if ($$.marker.getSnippet().length > 0) {
              Text($$.marker.getSnippet())
                .fontSize(10)
                .fontColor(Colors.TEXT_MUTED)
                .fontFamily(Fonts.CN)
                .margin({ top: 2 })
            }
          }
          .layoutWeight(1)
        }
      }
      .padding({ left: 8, right: 8, top: 6, bottom: 6 })
      .backgroundColor(Colors.CARD_BG)
      .borderRadius(Radius.CARD_SM)
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.15)', offsetX: 0, offsetY: 2 })
    }
  }

  @Builder
  candidateSwipeAction(propertyId: string) {
    Row() {
      Button('选定')
        .fontSize(FontSizes.BODY)
        .fontColor(Colors.TEXT_WHITE)
        .fontFamily(Fonts.CN)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(Colors.SUCCESS)
        .borderRadius(0)
        .height('100%')
        .width(72)
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
  @Param onCardClick: () => void = () => {};

  build() {
    Row() {
      Column() {
        Row() {
          if (this.property.getFirstImage().length > 0) {
            Image(this.property.getFirstImage())
              .width(48)
              .height(48)
              .objectFit(ImageFit.Cover)
              .borderRadius(24)
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

        Row() {
          if (this.property.tags.length > 0) {
            Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center }) {
              ForEach(this.property.tags, (tag: string) => {
                Text(tag)
                  .fontSize(FontSizes.CAPTION)
                  .fontColor(getTagTextColor(tag))
                  .fontFamily(Fonts.CN)
                  .fontWeight(FontWeight.Medium)
                  .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                  .backgroundColor(getTagBgColor(tag))
                  .borderRadius(Radius.TAG)
                  .margin({ right: 6, top: 4, bottom: 4 })
              }, (item: string) => item)
            }
            .layoutWeight(1)
          } else {
            Blank()
              .layoutWeight(1)
          }

          if (this.property.monthlyRent > 0) {
            Column() {
              Row() {
                Text('¥' + this.property.monthlyRent.toLocaleString())
                  .fontSize(FontSizes.BODY_LARGE)
                  .fontColor(Colors.PRIMARY)
                  .fontFamily(Fonts.NUMBER)
                  .fontWeight(FontWeight.Bold)

                Text('/月')
                  .fontSize(FontSizes.CAPTION)
                  .fontColor(Colors.TEXT_MUTED)
                  .fontFamily(Fonts.CN)
                  .margin({ left: 2 })
              }

              if (this.property.deposit > 0) {
                Text('押金 ¥' + this.property.deposit.toLocaleString())
                  .fontSize(FontSizes.CAPTION)
                  .fontColor(Colors.TEXT_SECONDARY)
                  .fontFamily(Fonts.NUMBER)
                  .margin({ top: 2 })
              }
            }
            .alignItems(HorizontalAlign.End)
            .margin({ left: 8 })
          }
        }
        .width('100%')
        .margin({ top: 10 })
        .alignItems(VerticalAlign.Center)

        if (this.property.notes.length > 0) {
          Text(this.property.notes)
            .fontSize(FontSizes.CAPTION)
            .fontColor(Colors.TEXT_MUTED)
            .fontFamily(Fonts.CN)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 8 })
            .alignSelf(ItemAlign.Start)
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
  }
}
