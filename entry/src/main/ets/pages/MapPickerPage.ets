import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { site } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { Colors, Fonts, FontSizes, Dimensions, Radius, Spacing } from '../common/DesignTokens';
import { MapPickerResult } from '../model/PropertyModel';

@Builder
export function MapPickerBuilder() {
  MapPickerPage()
}

@ComponentV2
export struct MapPickerPage {
  @Local selectedLat: number = 0;
  @Local selectedLng: number = 0;
  @Local selectedAddress: string = '';
  @Local selectedSiteName: string = '';
  @Local hasSelection: boolean = false;
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;
  private pickerMarker?: map.Marker;
  private initialLat: number = 39.904;
  private initialLng: number = 116.407;
  private hasLocated: boolean = false;

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
    this.selectLocation(position.latitude, position.longitude);
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
      language: 'cn',
      radius: 200
    };
    site.reverseGeocode(params).then((result: site.ReverseGeocodeResult) => {
      this.selectedAddress = '';
      this.selectedSiteName = '';
      let communityName: string = '';
      if (result.pois && result.pois.length > 0) {
        for (const poi of result.pois) {
          if (poi.poiType && (poi.poiType.indexOf('住宅') >= 0 || poi.poiType.indexOf('小区') >= 0)) {
            communityName = poi.name ?? '';
            break;
          }
        }
        if (communityName.length === 0 && result.pois[0].name) {
          communityName = result.pois[0].name ?? '';
        }
      }
      if (communityName.length === 0 && result.addressComponent
        && result.addressComponent.neighborhoods
        && result.addressComponent.neighborhoods.length > 0) {
        communityName = result.addressComponent.neighborhoods[0] ?? '';
      }
      this.selectedSiteName = communityName;
      if (result.addressComponent) {
        const ac: site.AddressComponent = result.addressComponent;
        const parts: string[] = [];
        const district: string = ac.subLocality1 ?? ac.adminLevel3 ?? '';
        if (district.length > 0) {
          parts.push(district);
        }
        if (ac.subLocality2 && ac.subLocality2.length > 0) {
          parts.push(ac.subLocality2);
        }
        if (communityName.length > 0) {
          parts.push(communityName);
        } else if (result.pois && result.pois.length > 0 && result.pois[0].address) {
          parts.push(result.pois[0].address ?? '');
        }
        if (parts.length > 0) {
          this.selectedAddress = parts.join('');
        }
      }
      if (this.selectedAddress.length === 0 && result.addressDescription
        && result.addressDescription.length > 0) {
        this.selectedAddress = result.addressDescription;
      }
    }).catch(() => {
      this.selectedAddress = '';
      this.selectedSiteName = '';
    });
  }

  private confirmSelection(): void {
    if (!this.hasSelection) {
      return;
    }
    const result: MapPickerResult = new MapPickerResult();
    result.latitude = this.selectedLat;
    result.longitude = this.selectedLng;
    result.address = this.selectedAddress;
    result.siteName = this.selectedSiteName;
    this.navPathStack.pop(result);
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

                Text(this.selectedAddress || '正在获取地址...')
                  .fontSize(FontSizes.BODY)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .fontFamily(Fonts.CN)
                  .fontWeight(FontWeight.Medium)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ left: 8 })
                  .layoutWeight(1)
              }
              .width('100%')
              .alignItems(VerticalAlign.Top)
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
    }
    .hideTitleBar(false)
    .title('选择位置')
  }
}
