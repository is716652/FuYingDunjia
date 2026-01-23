// DunjiaPalacePage.ets
// 九宫时空盘页面 - 展示完整的奇门遁甲九宫盘面

import router from '@ohos.router';
import { DunjiaEngine, DunjiaPanResult, DunjiaInput, PalaceState, GejuPattern } from '../utils/DunjiaEngine';

// 北京经度
const BEIJING_LONGITUDE = 116.4074;

@Entry
@Component
struct DunjiaPalacePage {
  @State panResult: DunjiaPanResult | null = null;
  @State currentDateTime: Date = new Date();
  @State loading: boolean = true;
  @State selectedPalace: number | null = null;  // 选中的宫位

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
   * 显示宫位详细信息
   */
  private showPalaceDetail(index: number) {
    if (this.panResult && this.panResult.palaces.length > index) {
      this.selectedPalace = index;
    }
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
      .onClick(() => {
        this.showPalaceDetail(index);
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
        // 主要内容区域（九宫盘在顶部，宫位详情在底部）
        Column() {
          // 九宫格区域（固定在顶部）
          if (this.panResult) {
            Column({ space: 10 }) {
              // 时间与局数信息
              Column({ space: 8 }) {
                // 阳历日期+时辰
                Row({ space: 8 }) {
                  Text('阳历：')
                    .fontSize(13)
                    .fontColor('#888888')
                  Text(`${this.currentDateTime.getFullYear()}年${this.currentDateTime.getMonth() + 1}月${this.currentDateTime.getDate()}日 ${this.panResult.hourGanZhi || ''}时`)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#2C2416')
                }
                
                // 农历日期+时辰
                if (this.panResult.dayInfo) {
                  Row({ space: 8 }) {
                    Text('农历：')
                      .fontSize(13)
                      .fontColor('#888888')
                    Text(`${this.panResult.dayInfo.lunar_year}年${this.panResult.dayInfo.lunar_month}月${this.panResult.dayInfo.lunar_day}日 ${this.panResult.hourGanZhi || ''}时`)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#2C2416')
                  }
                }
                
                // 真太阳时偏移
                if (this.panResult.solarTimeOffset !== undefined) {
                  Row({ space: 8 }) {
                    Text('真太阳时：')
                      .fontSize(13)
                      .fontColor('#888888')
                    Text(`${this.panResult.solarTimeOffset >= 0 ? '+' : ''}${this.panResult.solarTimeOffset}分钟`)
                      .fontSize(13)
                      .fontColor('#666666')
                    Text(`(当地经度${this.panResult.input.longitude.toFixed(2)}°)`)
                      .fontSize(11)
                      .fontColor('#999999')
                  }
                }
                
                Divider().color('#e0e0e0').strokeWidth(1).margin({ top: 4, bottom: 4 })
                
                // 局数
                Row({ space: 8 }) {
                  Text('局数：')
                    .fontSize(13)
                    .fontColor('#888888')
                  Text(this.panResult.juLabel)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#D4A574')
                }
                
                if (this.panResult.summary && this.panResult.summary.overview) {
                  Text(this.panResult.summary.overview)
                    .fontSize(13)
                    .fontColor('#666666')
                    .lineHeight(20)
                }
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 16, right: 16, top: 16, bottom: 16 })
              .backgroundColor('#ffffff')
              .borderRadius(12)
              .shadow({ radius: 8, color: '#22000000', offsetX: 0, offsetY: 2 })

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
            .layoutWeight(1)  // 占据可用空间
            .alignSelf(ItemAlign.Start)  // 顶部对齐
          }
          
          // 格局显示区域（在九宫盘下方，宫位详情上方）
          if (this.panResult && this.panResult.gejuPatterns && this.panResult.gejuPatterns.length > 0) {
            Column({ space: 12 }) {
              // 格局标题
              Text('识别格局')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2C2416')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding({ top: 12, bottom: 12 })
              
              // 格局列表
              ForEach(this.panResult.gejuPatterns ?? [], (pattern: GejuPattern) => {
                Column() {
                  Column({ space: 6 }) {
                    Row() {
                      Text(pattern.name)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#2C2416')
                        .layoutWeight(1)
                      
                      // 根据格局级别显示不同颜色标签
                      if (pattern.level === 'major') {
                        Text('主要')
                          .fontSize(10)
                          .fontColor('#ffffff')
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          .backgroundColor('#D4A574')
                          .borderRadius(8)
                      } else if (pattern.level === 'special') {
                        Text('特殊')
                          .fontSize(10)
                          .fontColor('#ffffff')
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          .backgroundColor('#8B6914')
                          .borderRadius(8)
                      } else {
                        Text('次要')
                          .fontSize(10)
                          .fontColor('#ffffff')
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          .backgroundColor('#999999')
                          .borderRadius(8)
                      }
                    }
                    
                    Text(pattern.description)
                      .fontSize(12)
                      .fontColor('#666666')
                      .lineHeight(16)
                    
                    // 涉及宫位
                    if (pattern.palaceIndices && pattern.palaceIndices.length > 0) {
                      Text(`涉及宫位: ${pattern.palaceIndices?.map(i => this.panResult?.palaces[i]?.palaceName ?? '').join(', ') ?? ''}`)
                        .fontSize(11)
                        .fontColor('#888888')
                    }
                  }
                  .padding({ left: 12, right: 12, top: 12, bottom: 12 })
                  .width('100%')
                  .backgroundColor('#ffffff')
                  .borderRadius(8)
                  .shadow({ radius: 4, color: '#22000000', offsetX: 0, offsetY: 2 })
                }
                .width('100%')
                .margin({ bottom: 8 })
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 0, bottom: 16 })
            .backgroundColor('#f9f9f9')
          }
          
          // 宫位详情区域（固定在底部）
          if (this.selectedPalace !== null && this.panResult && this.selectedPalace < this.panResult.palaces.length) {
            Scroll() {
              Column({ space: 12 }) {
                // 详情标题
                Text('宫位详解')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2C2416')
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .padding({ bottom: 12 })
                
                // 宫位基本信息 - 采用表格形式
                Column({ space: 8 }) {
                  // 宫位名称
                  Row() {
                    Text('宫位名称：')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#D4A574')
                      .width(80)
                    Text(`${this.panResult.palaces[this.selectedPalace].palaceName} (${this.panResult.palaces[this.selectedPalace].palaceElement}宫)`)
                      .fontSize(14)
                      .fontColor('#2C2416')
                      .layoutWeight(1)
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center)
                  
                  // 九星信息
                  if (this.panResult.palaces[this.selectedPalace].starName) {
                    Row() {
                      Text('九星：')
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#D4A574')
                        .width(80)
                      Text(`${this.panResult.palaces[this.selectedPalace].starName}`)
                        .fontSize(14)
                        .fontColor('#666666')
                        .layoutWeight(1)
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Center)
                  }
                  
                  // 八门信息
                  if (this.panResult.palaces[this.selectedPalace].doorName) {
                    Row() {
                      Text('八门：')
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#D4A574')
                        .width(80)
                      Text(`${this.panResult.palaces[this.selectedPalace].doorName}`)
                        .fontSize(14)
                        .fontColor('#666666')
                        .layoutWeight(1)
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Center)
                  }
                  
                  // 天盘信息
                  if (this.panResult.palaces[this.selectedPalace].tianGan) {
                    Row() {
                      Text('天盘：')
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#D4A574')
                        .width(80)
                      Text(`${this.panResult.palaces[this.selectedPalace].tianGan}`)
                        .fontSize(14)
                        .fontColor('#D4691A')
                        .layoutWeight(1)
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Center)
                  }
                  
                  // 地盘信息
                  if (this.panResult.palaces[this.selectedPalace].diGan) {
                    Row() {
                      Text('地盘：')
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#D4A574')
                        .width(80)
                      Text(`${this.panResult.palaces[this.selectedPalace].diGan}`)
                        .fontSize(14)
                        .fontColor('#2A7A8C')
                        .layoutWeight(1)
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Center)
                  }
                  
                  // 八神信息
                  if (this.panResult.palaces[this.selectedPalace].deityName) {
                    Row() {
                      Text('八神：')
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#D4A574')
                        .width(80)
                      Text(`${this.panResult.palaces[this.selectedPalace].deityName}`)
                        .fontSize(14)
                        .fontColor('#666666')
                        .layoutWeight(1)
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Center)
                  }
                  
                  // 特殊标识
                  if (this.panResult.zhiFuPalace === this.selectedPalace || this.panResult.zhiShiPalace === this.selectedPalace) {
                    Row() {
                      Text('特殊标识：')
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#D4A574')
                        .width(80)
                      Column({ space: 4 }) {
                        if (this.panResult.zhiFuPalace === this.selectedPalace) {
                          Text('• 值符宫')
                            .fontSize(12)
                            .fontColor('#D4A574')
                        }
                        if (this.panResult.zhiShiPalace === this.selectedPalace) {
                          Text('• 值使宫')
                            .fontSize(12)
                            .fontColor('#4A6A8B')
                        }
                      }
                      .layoutWeight(1)
                    }
                    .width('100%')
                  }
                }
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16, bottom: 16 })
            }
            .width('100%')
            .height(300)  // 固定高度
            .backgroundColor('#ffffff')
            .border({ width: 1, color: '#e0e0e0' })
          }
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
