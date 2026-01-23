// DunjiaPalacePage.ets
// 九宫时空盘页面 - 展示完整的奇门遁甲九宫盘面

import router from '@ohos.router';
import { DunjiaEngine, DunjiaPanResult, DunjiaInput, PalaceState } from '../utils/DunjiaEngine';

// 北京经度
const BEIJING_LONGITUDE = 116.4074;

@Entry
@Component
struct DunjiaPalacePage {
  @State panResult: DunjiaPanResult | null = null;
  @State currentDateTime: Date = new Date();
  @State loading: boolean = true;

  aboutToAppear() {
    this.initPanFromParams();
  }

  private initPanFromParams() {
    // 从路由参数中获取日期（如果有），否则使用当前时间
    let dt: Date = new Date();
    try {
      const params: Record<string, Object> | undefined = router.getParams() as Record<string, Object> | undefined;
      if (params && params.date) {
        const dateStr = params.date as string;
        dt = new Date(dateStr);
      }
    } catch (e) {
      // 路由参数异常时忽略，使用当前时间
    }
    this.currentDateTime = dt;

    const engine = DunjiaEngine.getInstance();
    const input = engine.createDefaultInput(this.currentDateTime, BEIJING_LONGITUDE);
    
    // 异步计算盘面
    engine.computePan(input)
      .then((result: DunjiaPanResult) => {
        this.panResult = result;
        this.loading = false;
      })
      .catch((err: Object) => {
        console.error('[DunjiaPalacePage] computePan error', JSON.stringify(err));
        this.loading = false;
      });
  }

  /**
   * 渲染单个宫位卡片
   */
  @Builder
  buildPalaceCard(index: number) {
    if (this.panResult && this.panResult.palaces.length > index) {
      Column({ space: 2 }) {
        // 宫名
        Text(this.panResult.palaces[index].palaceName)
          .fontSize(10)
          .fontColor('#888888')
          .textAlign(TextAlign.Start)
          .width('100%')
        
        // 九星（主要显示）
        Text(this.panResult.palaces[index].starName || '')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C2416')
          .textAlign(TextAlign.Center)
          .width('100%')
        
        // 八门
        Text(this.panResult.palaces[index].doorName || '')
          .fontSize(10)
          .fontColor('#555555')
          .textAlign(TextAlign.Center)
          .width('100%')
        
        // 分割线
        Divider()
          .color('#f0f0f0')
          .strokeWidth(0.5)
          .margin({ top: 2, bottom: 2 })
        
        // 天盘地盘干支
        Row({ space: 4 }) {
          Text('天')
            .fontSize(8)
            .fontColor('#999999')
          Text(this.panResult.palaces[index].tianGan || '')
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor('#D4691A')
          Text('地')
            .fontSize(8)
            .fontColor('#999999')
          Text(this.panResult.palaces[index].diGan || '')
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2A7A8C')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        
        // 八神
        Text(this.panResult.palaces[index].deityName || '')
          .fontSize(9)
          .fontColor('#8B6914')
          .textAlign(TextAlign.Center)
          .width('100%')
      }
      .width('32%')
      .padding({ left: 6, right: 6, top: 6, bottom: 6 })
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      .border({
        width: (this.panResult.zhiFuPalace === index || this.panResult.zhiShiPalace === index) ? 2 : 1,
        color: (this.panResult.zhiFuPalace === index) ? '#D4A574' : (this.panResult.zhiShiPalace === index ? '#4A6A8B' : '#E0E0E0')
      })
      .shadow({
        radius: (this.panResult.zhiFuPalace === index || this.panResult.zhiShiPalace === index) ? 10 : 4,
        color: (this.panResult.zhiFuPalace === index) ? '#33D4A574' : '#22000000',
        offsetX: 0,
        offsetY: 1
      })
    }
  }

  build() {
    Column({ space: 0 }) {
      // 顶部导航栏
      Row() {
        Text('← 返回')
          .fontSize(16)
          .fontColor('#666666')
          .onClick(() => {
            router.back();
          })
        Text('九宫时空盘')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text(' ')
          .fontSize(16)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#ffffff')

      Divider().color('#eeeeee')

      if (this.loading) {
        Column() {
          Text('排盘计算中...')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            // 盘面信息卡片
            if (this.panResult) {
              Column({ space: 10 }) {
                // 时间与局数信息
                Column({ space: 6 }) {
                  Row({ space: 10 }) {
                    Text('当前时间：')
                      .fontSize(12)
                      .fontColor('#888888')
                    Text(`${this.currentDateTime.getFullYear()}-${this.currentDateTime.getMonth() + 1}-${this.currentDateTime.getDate()}`)
                      .fontSize(12)
                      .fontColor('#555555')
                  }
                  
                  Row({ space: 10 }) {
                    Text('局数：')
                      .fontSize(12)
                      .fontColor('#888888')
                    Text(this.panResult.juLabel)
                      .fontSize(13)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#D4A574')
                  }
                  
                  if (this.panResult.summary && this.panResult.summary.overview) {
                    Text(this.panResult.summary.overview)
                      .fontSize(12)
                      .fontColor('#666666')
                      .lineHeight(18)
                  }
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)

                // 九宫格
                Column({ space: 4 }) {
                  // 第一行：0,1,2
                  Row({ space: 4 }) {
                    this.buildPalaceCard(0)
                    this.buildPalaceCard(1)
                    this.buildPalaceCard(2)
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)

                  // 第二行：3,4,5
                  Row({ space: 4 }) {
                    this.buildPalaceCard(3)
                    this.buildPalaceCard(4)
                    this.buildPalaceCard(5)
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)

                  // 第三行：6,7,8
                  Row({ space: 4 }) {
                    this.buildPalaceCard(6)
                    this.buildPalaceCard(7)
                    this.buildPalaceCard(8)
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                }
                .width('100%')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16, bottom: 16 })
              .backgroundColor('#ffffff')
              .borderRadius(12)
              .shadow({ radius: 8, color: '#22000000', offsetX: 0, offsetY: 2 })
            }
          }
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F1E8')
  }
}
