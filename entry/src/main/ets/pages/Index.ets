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
      Image($r('app.media.dunjia_background'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

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
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)

      // 下方文字链接
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
      .position({ x: 0, y: 0 })
      .offset({ y: '85%' })
      .alignItems(HorizontalAlign.Center)
    }
    .height('100%')
    .width('100%')
  }
}