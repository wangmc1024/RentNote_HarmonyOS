const storageLocal: LocalStorage = new LocalStorage();
storageLocal.setOrCreate('totalRent', '暂无');
storageLocal.setOrCreate('rentLabel', '本月租金');
storageLocal.setOrCreate('propertyName', '');
storageLocal.setOrCreate('expiryLabel', '暂无到期');
storageLocal.setOrCreate('expiryColor', '#9CA3AF');
storageLocal.setOrCreate('countdownDays', '');
storageLocal.setOrCreate('hasExpiry', 'false');

@Entry(storageLocal)
@Component
struct RentWidgetCard {
  @LocalStorageProp('totalRent') totalRent: string = '暂无';
  @LocalStorageProp('rentLabel') rentLabel: string = '本月租金';
  @LocalStorageProp('propertyName') propertyName: string = '';
  @LocalStorageProp('expiryLabel') expiryLabel: string = '暂无到期';
  @LocalStorageProp('expiryColor') expiryColor: string = '#9CA3AF';
  @LocalStorageProp('countdownDays') countdownDays: string = '';
  @LocalStorageProp('hasExpiry') hasExpiry: string = 'false';

  build() {
    Row() {
      Column() {
        Text('+')
          .fontSize(28)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Lighter)

        Text('添加')
          .fontSize(10)
          .fontColor('#FFFFFF')
          .margin({ top: 2 })
      }
      .width(64)
      .height('100%')
      .backgroundColor('#5046E5')
      .borderRadius({ topLeft: 16, bottomLeft: 16 })
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        postCardAction(this, {
          action: 'router',
          abilityName: 'EntryAbility',
          params: {
            action: 'addProperty'
          }
        });
      })

      Column() {
        Text(this.propertyName.length > 0 ? this.propertyName : '暂无房源')
          .fontSize(12)
          .fontColor('#6B7280')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(this.totalRent)
          .fontSize(28)
          .fontColor('#0F1419')
          .fontWeight(FontWeight.Bold)
          .margin({ top: 2 })

        Text(this.rentLabel)
          .fontSize(10)
          .fontColor('#9CA3AF')
          .margin({ top: 0 })
      }
      .layoutWeight(1)
      .height('100%')
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        postCardAction(this, {
          action: 'router',
          abilityName: 'EntryAbility',
          params: {}
        });
      })

      Column() {
        if (this.hasExpiry === 'true' && this.countdownDays.length > 0) {
          Text(this.countdownDays)
            .fontSize(24)
            .fontColor(this.expiryColor)
            .fontWeight(FontWeight.Bold)

          Text(this.expiryLabel)
            .fontSize(10)
            .fontColor(this.expiryColor)
            .margin({ top: 0 })
        } else {
          Text(this.hasExpiry === 'true' ? this.expiryLabel : '暂无到期')
            .fontSize(12)
            .fontColor(this.expiryColor)
        }
      }
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ left: 8, right: 12 })
      .onClick(() => {
        postCardAction(this, {
          action: 'router',
          abilityName: 'EntryAbility',
          params: {}
        });
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }
}
