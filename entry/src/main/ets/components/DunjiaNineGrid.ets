import { DunjiaPanResult } from '../utils/DunjiaEngine'

/**
 * 九宫格显示组件
 * 
 * 功能：
 * - 展示九宬格排盘结果
 * - 显示时间信息（阳历、农历、真太阳时）
 * - 显示局数信息
 * - 处理宬位点击事件
 * 
 * 使用方式：
 * ```typescript
 * DunjiaNineGrid({
 *   panResult: this.panResult,
 *   selectedPalace: this.selectedPalace,
 *   onPalaceClick: (index) => { // 处理点击 }
 * })
 * ```
 */
@Component
export struct DunjiaNineGrid {
  @Prop panResult: DunjiaPanResult | null = null
  @Prop selectedPalace: number | null = null
  onPalaceClick?: (index: number) => void

  /**
   * 格式化阳历日期
   */
  private formatSolarDate(): string {
    if (!this.panResult) return ''
    const date = this.panResult.input.dateTime
    return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日`
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
      .backgroundColor(this.selectedPalace === index ? '#FFF8F0' : '#FFFFFF')
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
        if (this.onPalaceClick) {
          this.onPalaceClick(index)
        }
      })
    }
  }

  build() {
    if (this.panResult) {
      Column({ space: 10 }) {
        // 时间与局数信息
        Column({ space: 8 }) {
          // 阳历日期+时辰
          Row({ space: 8 }) {
            Text('阳历：')
              .fontSize(13)
              .fontColor('#888888')
            Text(`${this.formatSolarDate()} ${this.panResult.hourGanZhi || ''}时`)
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
      .padding(16)
    }
  }
}
