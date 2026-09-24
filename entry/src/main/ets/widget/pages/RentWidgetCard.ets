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

  private openApp(): void {
    postCardAction(this, {
      action: 'router',
      abilityName: 'EntryAbility',
      params: {}
    });
  }

  private addProperty(): void {
    postCardAction(this, {
      action: 'router',
      abilityName: 'EntryAbility',
      params: {
        action: 'addProperty'
      }
    });
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column()
        .width(170)
        .height(170)
        .borderRadius(85)
        .backgroundColor('#2FF5C39B')
        .margin({ top: -65, right: -60 })

      Column()
        .width(110)
        .height(110)
        .borderRadius(55)
        .backgroundColor('#24E07840')
        .margin({ top: 75, right: -30 })

      Column()
        .width(130)
        .height(130)
        .borderRadius(65)
        .backgroundColor('#26FFFFFF')
        .position({ x: -40, y: '68%' })

      Column() {
        Row() {
          Row() {
            Column()
              .width(6)
              .height(6)
              .borderRadius(3)
              .backgroundColor('#E07840')
            Text('小寓台账')
              .fontSize(10)
              .fontColor('#A18067')
              .margin({ left: 5 })
          }
          .alignItems(VerticalAlign.Center)

          Blank()

          Row() {
            Text('+')
              .fontSize(13)
              .fontColor('#FFFFFF')
            Text('添加')
              .fontSize(10)
              .fontColor('#FFFFFF')
              .margin({ left: 3 })
          }
          .alignItems(VerticalAlign.Center)
          .padding({ left: 11, right: 11, top: 4, bottom: 4 })
          .backgroundColor('#E07840')
          .borderRadius(11)
          .onClick(() => {
            this.addProperty();
          })
        }
        .width('100%')

        Column() {
          Row() {
            Column() {
              if (this.totalRent.startsWith('¥')) {
                Row() {
                  Text('¥')
                    .fontSize(13)
                    .fontColor('#8C6F5E')
                    .margin({ bottom: 5 })
                  Text(this.totalRent.substring(1))
                    .fontSize(30)
                    .fontColor('#38231A')
                    .fontWeight(FontWeight.Bold)
                }
                .alignItems(VerticalAlign.Bottom)
              } else {
                Text(this.totalRent)
                  .fontSize(24)
                  .fontColor('#38231A')
                  .fontWeight(FontWeight.Bold)
              }
              Text(this.rentLabel)
                .fontSize(10)
                .fontColor('#9A7B63')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Row()
              .width(0.6)
              .height(36)
              .backgroundColor('#1F38231A')

            Column() {
              if (this.propertyName.length > 0) {
                Text(this.propertyName)
                  .fontSize(10)
                  .fontColor('#9A7B63')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .constraintSize({ maxWidth: 110 })
              }
              if (this.hasExpiry === 'true') {
                if (this.expiryLabel === '今天到期') {
                  Row() {
                    Text('今天')
                      .fontSize(20)
                      .fontColor(this.expiryColor)
                      .fontWeight(FontWeight.Bold)
                    Text('到期')
                      .fontSize(10)
                      .fontColor(this.expiryColor)
                      .margin({ left: 2, bottom: 2 })
                  }
                  .alignItems(VerticalAlign.Bottom)
                } else if (this.expiryLabel === '已过期') {
                  Row() {
                    Text(this.countdownDays)
                      .fontSize(20)
                      .fontColor(this.expiryColor)
                      .fontWeight(FontWeight.Bold)
                    Text('天前到期')
                      .fontSize(10)
                      .fontColor(this.expiryColor)
                      .margin({ left: 2, bottom: 2 })
                  }
                  .alignItems(VerticalAlign.Bottom)
                } else {
                  Row() {
                    Text(this.countdownDays)
                      .fontSize(20)
                      .fontColor(this.expiryColor)
                      .fontWeight(FontWeight.Bold)
                    Text('天后到期')
                      .fontSize(10)
                      .fontColor(this.expiryColor)
                      .margin({ left: 2, bottom: 2 })
                  }
                  .alignItems(VerticalAlign.Bottom)
                }
              } else {
                Text('暂无到期')
                  .fontSize(12)
                  .fontColor('#9A7B63')
              }
            }
            .margin({ left: 12 })
            .alignItems(HorizontalAlign.End)
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
        }
        .layoutWeight(1)
        .width('100%')
        .margin({ top: 10 })
        .padding({ left: 14, right: 14, top: 12, bottom: 12 })
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#59FFFFFF')
        .borderRadius(18)
        .border({ width: 1, color: '#73FFFFFF' })
        .backdropBlur(18)
        .onClick(() => {
          if (this.totalRent === '暂无') {
            this.addProperty();
          } else {
            this.openApp();
          }
        })
      }
      .width('100%')
      .height('100%')
      .padding({ left: 12, right: 12, top: 11, bottom: 12 })
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 135,
      colors: [['#FDF6EF', 0], ['#F8EADB', 0.55], ['#F3DFCD', 1]]
    })
    .borderRadius(20)
    .clip(true)
  }
}
