import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { site } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { Colors, Fonts, FontSizes, Dimensions, Radius, Spacing } from '../common/DesignTokens';
import { MapPickerResult, PoiItem } from '../model/PropertyModel';

@Builder
export function MapPickerBuilder() {
  MapPickerPage()
}

const RESIDENTIAL_KEYWORDS: string[] = [
  '住宅', '小区', '公寓', '家园', '花园', '别墅', '商务住宅', '住宅区', '住宅楼', '居民楼', '居民小区'
];

@ComponentV2
export struct MapPickerPage {
  @Local selectedLat: number = 0;
  @Local selectedLng: number = 0;
  @Local district: string = '';
  @Local township: string = '';
  @Local selectedSiteName: string = '';
  @Local hasSelection: boolean = false;
  @Local fallbackTip: string = '';
  @Local poiList: PoiItem[] = [];
  @Local showPoiSheet: boolean = false;
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;
  private pickerMarker?: map.Marker;
  private initialLat: number = 39.904;
  private initialLng: number = 116.407;
  private hasLocated: boolean = false;
  private lastClickTime: number = 0;

  aboutToAppear(): void {
    this.requestCurrentLocation();

    this.mapOptions = {
      position: {
        target: {
          latitude: this.initialLat,
          longitude: this.initialLng
        },
        zoom: 12
      }
    };
    this.callback = async (err: BusinessError | null, mapController: map.MapComponentController) => {
      if (!err) {
        this.mapController = mapController;
        this.mapEventManager = this.mapController.getEventManager();
        this.mapEventManager.on('mapClick', (position: mapCommon.LatLng) => {
          this.onMapClick(position);
        });
        if (this.hasLocated) {
          this.moveToCurrentLocation();
          this.selectLocation(this.initialLat, this.initialLng);
        }
      }
    };
  }

  private requestCurrentLocation(): void {
    try {
      if (!geoLocationManager.isLocationEnabled()) {
        return;
      }
    } catch (_e) {
      return;
    }
    const request: geoLocationManager.SingleLocationRequest = {
      'locatingPriority': geoLocationManager.LocatingPriority.PRIORITY_LOCATING_SPEED,
      'locatingTimeoutMs': 10000
    };
    geoLocationManager.getCurrentLocation(request).then((result: geoLocationManager.Location) => {
      this.initialLat = result.latitude;
      this.initialLng = result.longitude;
      this.hasLocated = true;
      if (this.mapController) {
        this.moveToCurrentLocation();
        this.selectLocation(result.latitude, result.longitude);
      }
    }).catch((_e: BusinessError) => {
    });
  }

  private moveToCurrentLocation(): void {
    if (!this.mapController) {
      return;
    }
    const cameraPosition: mapCommon.CameraPosition = {
      target: {
        latitude: this.initialLat,
        longitude: this.initialLng
      },
      zoom: 14
    };
    const cameraUpdate: map.CameraUpdate = map.newCameraPosition(cameraPosition);
    this.mapController.moveCamera(cameraUpdate);
  }

  private async onMapClick(position: mapCommon.LatLng): Promise<void> {
    const now: number = Date.now();
    if (now - this.lastClickTime < 300) {
      return;
    }
    this.lastClickTime = now;
    this.selectLocation(position.latitude, position.longitude);
  }

  private isResidentialPoi(poiType: string, name: string): boolean {
    const combined: string = (poiType ?? '') + (name ?? '');
    for (const keyword of RESIDENTIAL_KEYWORDS) {
      if (combined.indexOf(keyword) >= 0) {
        return true;
      }
    }
    return false;
  }

  private extractDistrict(ac: site.AddressComponent): string {
    return ac.subLocality1 ?? ac.adminLevel3 ?? '';
  }

  private extractTownship(ac: site.AddressComponent): string {
    return ac.subLocality2 ?? '';
  }

  private onPoiSelected(poi: PoiItem): void {
    this.selectedSiteName = poi.name;
    this.fallbackTip = '';
    this.showPoiSheet = false;
  }

  private async selectLocation(lat: number, lng: number): Promise<void> {
    this.selectedLat = lat;
    this.selectedLng = lng;
    this.hasSelection = true;

    if (this.pickerMarker) {
      this.pickerMarker.remove();
      this.pickerMarker = undefined;
    }

    const markerOptions: mapCommon.MarkerOptions = {
      position: {
        latitude: lat,
        longitude: lng
      },
      clickable: false,
      draggable: true,
      anchorU: 0.5,
      anchorV: 1,
      title: '选中位置'
    };
    try {
      if (this.mapController) {
        const marker: map.Marker = await this.mapController.addMarker(markerOptions);
        this.pickerMarker = marker;
      }
    } catch (_e) {
    }

    const params: site.ReverseGeocodeParams = {
      location: {
        latitude: lat,
        longitude: lng
      },
      language: 'zh',
      radius: 200,
      isExtension: true,
      isNearbyAoi: true
    };
    site.reverseGeocode(params).then((result: site.ReverseGeocodeResult) => {
      this.selectedSiteName = '';
      this.district = '';
      this.township = '';
      this.fallbackTip = '';
      this.showPoiSheet = false;
      this.poiList = [];

      const ac: site.AddressComponent | undefined = result.addressComponent;
      const dist: string = ac ? this.extractDistrict(ac) : '';
      const twp: string = ac ? this.extractTownship(ac) : '';

      const combinedPois: PoiItem[] = [];

      if (result.aois && result.aois.length > 0) {
        for (const aoi of result.aois) {
          const aoiName: string = aoi.name ?? '';
          const aoiType: string = aoi.poiType ?? '';
          if (aoiName.length === 0) {
            continue;
          }
          const isRes: boolean = this.isResidentialPoi(aoiType, aoiName);
          const item: PoiItem = new PoiItem();
          item.name = aoiName;
          item.poiType = aoiType;
          item.address = '';
          item.latitude = aoi.location?.latitude ?? 0;
          item.longitude = aoi.location?.longitude ?? 0;
          item.distance = aoi.distance ?? 0;
          item.isResidential = isRes;
          combinedPois.push(item);
        }
      }

      if (result.pois && result.pois.length > 0) {
        for (const poi of result.pois) {
          const poiName: string = poi.name ?? '';
          const poiType: string = poi.poiType ?? '';
          const poiDistance: number = poi.distance ?? 0;
          if (poiDistance > 250 || poiName.length === 0) {
            continue;
          }
          const isRes: boolean = this.isResidentialPoi(poiType, poiName);
          const item: PoiItem = new PoiItem();
          item.name = poiName;
          item.poiType = poiType;
          item.address = poi.address ?? '';
          item.latitude = poi.location?.latitude ?? 0;
          item.longitude = poi.location?.longitude ?? 0;
          item.distance = poiDistance;
          item.isResidential = isRes;
          combinedPois.push(item);
        }
      }

      combinedPois.sort((a: PoiItem, b: PoiItem) => {
        if (a.isResidential && !b.isResidential) {
          return -1;
        }
        if (!a.isResidential && b.isResidential) {
          return 1;
        }
        return a.distance - b.distance;
      });

      if (combinedPois.length > 0) {
        this.poiList = combinedPois;
        this.showPoiSheet = combinedPois.length > 1;

        const firstPoi: PoiItem = combinedPois[0];
        this.selectedSiteName = firstPoi.name;
        this.district = dist;
        this.township = twp;
        this.fallbackTip = '';
      } else {
        let communityName: string = '';
        if (ac && ac.neighborhoods && ac.neighborhoods.length > 0) {
          communityName = ac.neighborhoods[0] ?? '';
        }

        if (communityName.length > 0) {
          this.selectedSiteName = communityName;
          this.district = dist;
          this.township = twp;
          this.fallbackTip = '未识别小区，取自社区信息，请核对';
        } else {
          this.selectedSiteName = '';
          this.district = dist;
          this.township = twp;
          this.fallbackTip = '';
        }
      }
    }).catch(() => {
      this.selectedSiteName = '';
      this.district = '';
      this.township = '';
      this.fallbackTip = '';
      this.poiList = [];
      this.showPoiSheet = false;
    });
  }

  private confirmSelection(): void {
    if (!this.hasSelection) {
      return;
    }
    const result: MapPickerResult = new MapPickerResult();
    result.district = this.district;
    result.township = this.township;
    result.siteName = this.selectedSiteName;
    result.latitude = this.selectedLat;
    result.longitude = this.selectedLng;
    this.navPathStack.pop(result);
  }

  private buildLocationDisplay(): string {
    const parts: string[] = [];
    if (this.district.length > 0) {
      parts.push(this.district);
    }
    if (this.township.length > 0) {
      parts.push(this.township);
    }
    if (this.selectedSiteName.length > 0) {
      parts.push(this.selectedSiteName);
    }
    return parts.join(' ');
  }

  @Builder
  poiListItem(poi: PoiItem) {
    ListItem() {
      Row({ space: 12 }) {
        Column() {
          if (poi.isResidential) {
            SymbolGlyph($r('sys.symbol.house'))
              .fontSize(20)
              .fontColor([Colors.PRIMARY])
          } else {
            SymbolGlyph($r('sys.symbol.map'))
              .fontSize(20)
              .fontColor([Colors.TEXT_MUTED])
          }
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(poi.isResidential ? Colors.PRIMARY_LIGHT : Colors.CARD_BG)
        .borderRadius(8)

        Column({ space: 4 }) {
          Row({ space: 8 }) {
            Text(poi.name)
              .fontSize(FontSizes.BODY)
              .fontColor(Colors.TEXT_PRIMARY)
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)

            if (poi.isResidential) {
              Text('住宅')
                .fontSize(10)
                .fontColor(Colors.PRIMARY)
                .fontFamily(Fonts.CN)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .backgroundColor(Colors.PRIMARY_LIGHT)
                .borderRadius(4)
            }

            if (poi.distance > 0) {
              Text(poi.distance < 1000 ?
                `${Math.round(poi.distance)}m` :
                `${(poi.distance / 1000).toFixed(1)}km`)
                .fontSize(FontSizes.CAPTION)
                .fontColor(Colors.TEXT_MUTED)
                .fontFamily(Fonts.NUMBER)
            }
          }
          .width('100%')

          if (poi.address.length > 0 && poi.address !== poi.name) {
            Text(poi.address)
              .fontSize(FontSizes.CAPTION)
              .fontColor(Colors.TEXT_SECONDARY)
              .fontFamily(Fonts.CN)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Spacing.CARD_PADDING_SM, right: Spacing.CARD_PADDING_SM, top: 12, bottom: 12 })
      .alignItems(VerticalAlign.Center)
    }
    .onClick(() => {
      this.onPoiSelected(poi);
    })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
          .width('100%')
          .layoutWeight(1)

        if (this.hasSelection) {
          Column() {
            Column() {
              Row() {
                SymbolGlyph($r('sys.symbol.map'))
                  .fontSize(18)
                  .fontColor([Colors.PRIMARY])

                Text(this.buildLocationDisplay() || '正在获取地址...')
                  .fontSize(FontSizes.BODY)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .fontFamily(Fonts.CN)
                  .fontWeight(FontWeight.Medium)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ left: 8 })
                  .layoutWeight(1)

                if (this.poiList.length > 0) {
                  Text(`${this.poiList.length}个结果`)
                    .fontSize(FontSizes.CAPTION)
                    .fontColor(Colors.PRIMARY)
                    .fontFamily(Fonts.CN)
                    .onClick(() => {
                      this.showPoiSheet = true;
                    })
                }
              }
              .width('100%')
              .alignItems(VerticalAlign.Top)

              if (this.fallbackTip.length > 0) {
                Text(this.fallbackTip)
                  .fontSize(FontSizes.CAPTION)
                  .fontColor(Colors.WARNING)
                  .fontFamily(Fonts.CN)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ left: 26, top: 4 })
              }
            }
            .width('100%')
            .padding(Spacing.CARD_PADDING)
            .backgroundColor(Colors.CARD_BG)
            .borderRadius({ topLeft: Radius.CARD, topRight: Radius.CARD })

            Button('确认位置')
              .width('100%')
              .height(Dimensions.BUTTON_HEIGHT)
              .fontSize(FontSizes.SECTION_TITLE)
              .fontColor(Colors.TEXT_WHITE)
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Medium)
              .backgroundColor(Colors.PRIMARY)
              .borderRadius(Radius.BUTTON)
              .margin({ top: Spacing.ITEM_GAP })
              .onClick(() => {
                this.confirmSelection();
              })
          }
          .width('100%')
          .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, bottom: 16 })
          .backgroundColor(Colors.BG_PRIMARY)
        } else {
          Column() {
            Text('点击地图选择位置')
              .fontSize(FontSizes.BODY)
              .fontColor(Colors.TEXT_MUTED)
              .fontFamily(Fonts.CN)
          }
          .width('100%')
          .height(60)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Colors.CARD_BG)
          .borderRadius({ topLeft: Radius.CARD, topRight: Radius.CARD })
        }
      }
      .width('100%')
      .height('100%')
      .bindSheet($$this.showPoiSheet, this.poiSheetBuilder(), {
        height: '50%',
        dragBar: true,
        backgroundColor: Colors.BG_PRIMARY,
        onDisappear: () => {
        }
      })
    }
    .hideTitleBar(false)
    .title('选择位置')
  }

  @Builder
  poiSheetBuilder() {
    Column() {
      Row() {
        Text('选择位置')
          .fontSize(FontSizes.SECTION_TITLE)
          .fontColor(Colors.TEXT_PRIMARY)
          .fontFamily(Fonts.CN)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text(`${this.poiList.length}个结果`)
          .fontSize(FontSizes.CAPTION)
          .fontColor(Colors.TEXT_MUTED)
          .fontFamily(Fonts.CN)
      }
      .width('100%')
      .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: 8, bottom: 8 })

      List({ space: 0 }) {
        ForEach(this.poiList, (poi: PoiItem, index: number) => {
          this.poiListItem(poi)
        }, (item: PoiItem, idx: number) => idx.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .divider({ strokeWidth: 0.5, color: Colors.DIVIDER_DARK, startMargin: 56, endMargin: 16 })
    }
    .width('100%')
    .height('100%')
  }
}
