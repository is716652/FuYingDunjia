import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State countdown: number = 5;
  private timer: number = -1;

  aboutToAppear() {
    this.timer = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        this.navigateToCalendar();
      }
    }, 1000);
  }

  aboutToDisappear() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
  }

  navigateToCalendar() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
    router.pushUrl({
      url: 'pages/Calendar'
    });
  }

  build() {
    Stack() {
      // 背景图片层
      Image($r('app.media.dunjia_background'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      // 内容层
      Column({ space: 0 }) {
        // 上方区域：中央内容
        Column({ space: 20 }) {
          Text('遁甲符应经')
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ffffff')
            .textShadow({ radius: 8, color: '#000000', offsetX: 2, offsetY: 2 })

          Text(`${this.countdown}秒后自动进入`)
            .fontSize(18)
            .fontColor('#ffffff')
            .textShadow({ radius: 4, color: '#000000', offsetX: 1, offsetY: 1 })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)

        // 底部文字链接
        Column() {
          Text('点击进入')
            .fontSize(18)
            .fontColor('#ffffff')
            .decoration({ type: TextDecorationType.Underline, color: '#ffffff' })
            .textShadow({ radius: 4, color: '#000000', offsetX: 1, offsetY: 1 })
            .onClick(() => {
              this.navigateToCalendar();
            })
        }
        .width('100%')
        .padding({ bottom: 50 })
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}