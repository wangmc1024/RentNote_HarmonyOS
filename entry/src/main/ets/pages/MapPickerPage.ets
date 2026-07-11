import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { site } from '@kit.MapKit';
import { Colors, Fonts, FontSizes, Dimensions, Radius, Spacing } from '../common/DesignTokens';
import { MapPickerResult } from '../model/PropertyModel';

class ParsedSiteItem {
  formattedAddress: string = '';
  siteName: string = '';
}

class ReverseGeoParsed {
  sites: ParsedSiteItem[] = [];
}

@Builder
export function MapPickerBuilder() {
  MapPickerPage()
}

@ComponentV2
export struct MapPickerPage {
  @Local selectedLat: number = 39.904;
  @Local selectedLng: number = 116.407;
  @Local selectedAddress: string = '';
  @Local selectedSiteName: string = '';
  @Local hasSelection: boolean = false;
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;
  private pickerMarker?: map.Marker;

  aboutToAppear(): void {
    this.mapOptions = {
      position: {
        target: {
          latitude: this.selectedLat,
          longitude: this.selectedLng
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
      }
    };
  }

  private async onMapClick(position: mapCommon.LatLng): Promise<void> {
    this.selectedLat = position.latitude;
    this.selectedLng = position.longitude;
    this.hasSelection = true;

    if (this.pickerMarker) {
      this.pickerMarker.remove();
      this.pickerMarker = undefined;
    }

    const markerOptions: mapCommon.MarkerOptions = {
      position: {
        latitude: position.latitude,
        longitude: position.longitude
      },
      clickable: false,
      draggable: true,
      anchorU: 0.5,
      anchorV: 1,
      title: '选中位置'
    };
    try {
      const marker: map.Marker = await this.mapController!.addMarker(markerOptions);
      this.pickerMarker = marker;
    } catch (_e) {
    }

    const params: site.ReverseGeocodeParams = {
      location: {
        latitude: position.latitude,
        longitude: position.longitude
      },
      language: 'cn',
      radius: 200
    };
    site.reverseGeocode(params).then((result: site.ReverseGeocodeResult) => {
      this.selectedAddress = `${position.latitude.toFixed(4)}, ${position.longitude.toFixed(4)}`;
      this.selectedSiteName = '';
      const json: string = JSON.stringify(result);
      const parsed: ReverseGeoParsed = JSON.parse(json) as ReverseGeoParsed;
      if (parsed.sites && parsed.sites.length > 0) {
        const addr: string = parsed.sites[0].formattedAddress ?? parsed.sites[0].siteName ?? '';
        if (addr.length > 0) {
          this.selectedAddress = addr;
        }
        this.selectedSiteName = parsed.sites[0].siteName ?? '';
      }
    }).catch(() => {
      this.selectedAddress = `${position.latitude.toFixed(4)}, ${position.longitude.toFixed(4)}`;
    });
  }

  private confirmSelection(): void {
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
