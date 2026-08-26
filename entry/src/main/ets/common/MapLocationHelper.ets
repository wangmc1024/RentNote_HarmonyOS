import { mapCommon, map } from '@kit.MapKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { abilityAccessCtrl, Permissions, PermissionRequestResult, common } from '@kit.AbilityKit';

const TAG: string = '[MapLocation]';

export class LocationState {
  cachedLat: number = 0;
  cachedLng: number = 0;
  hasCachedLocation: boolean = false;
  mapReady: boolean = false;
}

export class MapLocationHelper {
  private state: LocationState = new LocationState();
  private mapController?: map.MapComponentController;
  private onLocationReady?: (lat: number, lng: number) => void;

  constructor(onLocationReady?: (lat: number, lng: number) => void) {
    this.onLocationReady = onLocationReady;
  }

  getState(): LocationState {
    return this.state;
  }

  setMapController(controller: map.MapComponentController, bottomPadding: number = 0): void {
    this.mapController = controller;
    this.state.mapReady = true;
    this.enableMyLocation();
    // 启用自带定位控件（显示在缩放按钮上方）和缩放控件
    try {
      this.mapController.setMyLocationControlsEnabled(true);
      this.mapController.setZoomControlsEnabled(true);
    } catch (_e) {
      console.warn(`${TAG} setControlsEnabled failed`);
    }
    // 底部 padding 将缩放+定位控件整体上移，避免与底部面板重叠
    if (bottomPadding > 0) {
      try {
        const padding: mapCommon.Padding = { left: 0, top: 0, right: 0, bottom: bottomPadding };
        this.mapController.setPadding(padding);
      } catch (_e) {
        console.warn(`${TAG} setPadding failed`);
      }
    }
    if (this.state.hasCachedLocation) {
      this.animateToCachedLocation();
    }
    if (this.onLocationReady && this.state.hasCachedLocation) {
      this.onLocationReady(this.state.cachedLat, this.state.cachedLng);
    }
  }

  private enableMyLocation(): void {
    if (!this.mapController) {
      return;
    }
    try {
      this.mapController.setMyLocationEnabled(true);
    } catch (_e) {
      console.warn(`${TAG} setMyLocationEnabled failed`);
    }
  }

  async requestLocationPermission(context: common.UIAbilityContext): Promise<void> {
    const permissions: Array<Permissions> = [
      'ohos.permission.APPROXIMATELY_LOCATION',
      'ohos.permission.LOCATION'
    ];
    const atManager = abilityAccessCtrl.createAtManager();
    try {
      const result: PermissionRequestResult =
        await atManager.requestPermissionsFromUser(context, permissions);
      const granted: boolean = result.authResults.length > 0 && result.authResults[0] === 0;
      if (granted) {
        this.fetchCurrentLocation();
      } else {
        console.warn(`${TAG} Location permission denied`);
      }
    } catch (e) {
      console.error(`${TAG} Permission request failed: ${(e as BusinessError).code}`);
    }
  }

  fetchCurrentLocation(): void {
    try {
      if (!geoLocationManager.isLocationEnabled()) {
        console.warn(`${TAG} System location disabled`);
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
      this.state.cachedLat = result.latitude;
      this.state.cachedLng = result.longitude;
      this.state.hasCachedLocation = true;
      if (this.state.mapReady && this.mapController) {
        this.animateToCachedLocation();
      }
      if (this.onLocationReady) {
        this.onLocationReady(result.latitude, result.longitude);
      }
    }).catch((_e: BusinessError) => {
      console.warn(`${TAG} getCurrentLocation failed`);
    });
  }

  animateToCachedLocation(): void {
    if (!this.mapController || !this.state.hasCachedLocation) {
      return;
    }
    const cameraPosition: mapCommon.CameraPosition = {
      target: {
        latitude: this.state.cachedLat,
        longitude: this.state.cachedLng
      },
      zoom: 14
    };
    const cameraUpdate: map.CameraUpdate = map.newCameraPosition(cameraPosition);
    try {
      this.mapController.animateCamera(cameraUpdate, 500);
    } catch (_e) {
      try {
        this.mapController.moveCamera(cameraUpdate);
      } catch (_e2) {
        console.warn(`${TAG} moveCamera fallback failed`);
      }
    }
  }

  onLocateMeClick(): void {
    if (this.state.hasCachedLocation && this.mapController) {
      this.animateToCachedLocation();
    }
    this.fetchCurrentLocation();
  }

  animateToPosition(lat: number, lng: number, zoom: number): void {
    if (!this.mapController) {
      return;
    }
    const cameraPosition: mapCommon.CameraPosition = {
      target: {
        latitude: lat,
        longitude: lng
      },
      zoom: zoom
    };
    const cameraUpdate: map.CameraUpdate = map.newCameraPosition(cameraPosition);
    try {
      this.mapController.animateCamera(cameraUpdate, 500);
    } catch (_e) {
      try {
        this.mapController.moveCamera(cameraUpdate);
      } catch (_e2) {
        console.warn(`${TAG} moveCamera fallback failed`);
      }
    }
  }
}

export function createMapOptions(lat: number, lng: number, zoom: number): mapCommon.MapOptions {
  return {
    position: {
      target: {
        latitude: lat,
        longitude: lng
      },
      zoom: zoom
    },
    compassEnabled: true
  } as mapCommon.MapOptions;
}
