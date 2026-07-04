const storageLocal: LocalStorage = new LocalStorage();
storageLocal.setOrCreate('totalRent', '暂无');
storageLocal.setOrCreate('rentLabel', '本月租金');
storageLocal.setOrCreate('nextExpiry', '暂无到期');
storageLocal.setOrCreate('expiryColor', '#9CA3AF');

@Entry(storageLocal)
@Component
struct RentWidgetCard {
  @LocalStorageProp('totalRent') totalRent: string = '暂无';
  @LocalStorageProp('rentLabel') rentLabel: string = '本月租金';
  @LocalStorageProp('nextExpiry') nextExpiry: string = '暂无到期';
  @LocalStorageProp('expiryColor') expiryColor: string = '#9CA3AF';

  build() {
    Row() {
      Column() {
        Text('+')
          .fontSize(32)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Lighter)

        Text('快捷添加')
          .fontSize(12)
          .fontColor('#FFFFFF')
          .margin({ top: 4 })
      }
      .width(80)
      .height(120)
      .backgroundColor('#5046E5')
      .borderRadius(24)
      .justifyContent(FlexAlign.Center)
      .margin({ left: 16 })
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
        Text(this.totalRent)
          .fontSize(32)
          .fontColor('#0F1419')
          .fontWeight(FontWeight.Bold)

        Text(this.rentLabel)
          .fontSize(13)
          .fontColor('#6B7280')
          .margin({ top: 4 })

        Text(this.nextExpiry)
          .fontSize(12)
          .fontColor(this.expiryColor)
          .margin({ top: 6 })
      }
      .layoutWeight(1)
      .height(120)
      .margin({ left: 16 })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
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
    .padding({ right: 16 })
  }
}
