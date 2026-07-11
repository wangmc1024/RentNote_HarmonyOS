import { Colors, Fonts, FontSizes, Dimensions, Radius, Spacing } from '../common/DesignTokens';
import { HeaderBar } from '../components/HeaderBar';
import { UserProfile } from '../model/PropertyModel';
import { PropertyRepository } from '../repository/PropertyRepository';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';

@Builder
export function ProfileEditBuilder() {
  ProfileEditPage()
}

@ComponentV2
export struct ProfileEditPage {
  @Local userName: string = '';
  @Local userSubtitle: string = '';
  @Local avatarUri: string = '';
  @Consumer('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @Consumer('refreshFlag') refreshFlag: number = 0;

  private repository: PropertyRepository = PropertyRepository.getInstance();

  aboutToAppear(): void {
    const profile: UserProfile = this.repository.getUserProfile();
    this.userName = profile.name;
    this.userSubtitle = profile.subtitle;
    this.avatarUri = profile.avatarUri;
  }

  private saveProfile(): void {
    const profile: UserProfile = new UserProfile();
    profile.name = this.userName;
    profile.subtitle = this.userSubtitle;
    profile.avatarUri = this.avatarUri;
    this.repository.saveUserProfile(profile).then(() => {
      this.refreshFlag++;
      this.navPathStack.pop();
    });
  }

  private async pickAvatar(): Promise<void> {
    const options: photoAccessHelper.PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    options.maxSelectNumber = 1;
    const photoPicker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
    try {
      const result: photoAccessHelper.PhotoSelectResult = await photoPicker.select(options);
      if (result.photoUris && result.photoUris.length > 0) {
        const context: Context = this.getUIContext().getHostContext() as Context;
        const dir: string = context.filesDir + '/profile_images';
        if (!fs.accessSync(dir)) {
          fs.mkdirSync(dir);
        }
        const fileName: string = 'avatar_' + Date.now().toString() + '.jpg';
        const destPath: string = dir + '/' + fileName;
        let srcFile: fs.File | null = null;
        let destFile: fs.File | null = null;
        try {
          srcFile = fs.openSync(result.photoUris[0], fs.OpenMode.READ_ONLY);
          destFile = fs.openSync(destPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
          fs.copyFileSync(srcFile.fd, destFile.fd);
          this.avatarUri = fileUri.getUriFromPath(destPath);
        } catch (_e) {
        } finally {
          if (srcFile) {
            try { fs.closeSync(srcFile); } catch (_e) {}
          }
          if (destFile) {
            try { fs.closeSync(destFile); } catch (_e) {}
          }
        }
      }
    } catch (_e) {
    }
  }

  build() {
    NavDestination() {
      Column() {
        HeaderBar({
          title: '编辑资料',
          showBack: true,
          onBack: () => {
            this.navPathStack.pop();
          }
        })

        Scroll() {
          Column({ space: 24 }) {
            Column() {
              if (this.avatarUri.length > 0) {
                Image(this.avatarUri)
                  .width(Dimensions.AVATAR_SIZE * 1.5)
                  .height(Dimensions.AVATAR_SIZE * 1.5)
                  .borderRadius(Radius.AVATAR * 1.5)
                  .objectFit(ImageFit.Cover)
              } else {
                Row() {
                  Text(this.userName.length > 0 ? this.userName.charAt(0) : '我')
                    .fontSize(32)
                    .fontColor(Colors.TEXT_WHITE)
                    .fontFamily(Fonts.CN)
                    .fontWeight(FontWeight.Bold)
                }
                .width(Dimensions.AVATAR_SIZE * 1.5)
                .height(Dimensions.AVATAR_SIZE * 1.5)
                .backgroundColor(Colors.PRIMARY)
                .borderRadius(Radius.AVATAR * 1.5)
                .justifyContent(FlexAlign.Center)
              }

              Text('更换头像')
                .fontSize(FontSizes.CAPTION)
                .fontColor(Colors.PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .margin({ top: 8 })
            }
            .alignItems(HorizontalAlign.Center)
            .margin({ top: 16 })
            .onClick(() => {
              this.pickAvatar();
            })

            Column({ space: 8 }) {
              Text('昵称')
                .fontSize(FontSizes.BODY)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)

              TextInput({ placeholder: '请输入昵称', text: this.userName })
                .width('100%')
                .height(48)
                .backgroundColor(Colors.CARD_BG)
                .borderRadius(Radius.CARD_SM)
                .padding({ left: Spacing.CARD_PADDING_SM })
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .placeholderColor(Colors.TEXT_MUTED)
                .onChange((v: string) => { this.userName = v })
            }

            Column({ space: 8 }) {
              Text('签名')
                .fontSize(FontSizes.BODY)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)

              TextInput({ placeholder: '请输入个性签名', text: this.userSubtitle })
                .width('100%')
                .height(48)
                .backgroundColor(Colors.CARD_BG)
                .borderRadius(Radius.CARD_SM)
                .padding({ left: Spacing.CARD_PADDING_SM })
                .fontSize(FontSizes.BODY_LARGE)
                .fontColor(Colors.TEXT_PRIMARY)
                .fontFamily(Fonts.CN)
                .placeholderColor(Colors.TEXT_MUTED)
                .onChange((v: string) => { this.userSubtitle = v })
            }

            Button('保存')
              .width('100%')
              .height(52)
              .fontSize(FontSizes.SECTION_TITLE)
              .fontColor(Colors.TEXT_WHITE)
              .fontFamily(Fonts.CN)
              .fontWeight(FontWeight.Medium)
              .backgroundColor(Colors.PRIMARY)
              .borderRadius(Radius.BUTTON)
              .onClick(() => {
                this.saveProfile();
              })
          }
          .padding({ left: Spacing.PAGE_HORIZONTAL, right: Spacing.PAGE_HORIZONTAL, top: 8, bottom: 40 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Colors.BG_PRIMARY)
    }
    .hideTitleBar(true)
  }
}
