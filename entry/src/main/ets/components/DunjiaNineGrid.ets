import { DunjiaPanResult } from '../utils/DunjiaEngine'
import { GejuPattern } from '../utils/DunjiaEngine'

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
   * 获取宫位相关格局
   */
  private getPalacePatterns(palaceIndex: number): string[] {
    if (!this.panResult || !this.panResult.gejuPatterns) return [];
    return this.panResult.gejuPatterns
      .filter(pattern => pattern.palaceIndices.includes(palaceIndex))
      .map(pattern => pattern.name);
  }

  /**
   * 获取格局颜色
   */
  private getPatternColor(patternName: string): string {
    if (patternName.includes('天遁') || patternName.includes('三奇得使')) {
      return '#FF6B35'; // 特殊格局，橙色
    } else if (patternName.includes('地遁') || patternName.includes('人遁')) {
      return '#D4A574'; // 主要格局，金色
    }
    return '#4A90E2'; // 次要格局，蓝色
  }

  /**
   * 渲染单个宫位卡片
   */
  @Builder
  buildPalaceCard(index: number) {
    if (this.panResult && this.panResult.palaces.length > index) {
      Stack({ alignContent: Alignment.TopEnd }) {
        Column({ space: 3 }) {
          // 宫名
          Text(this.panResult.palaces[index].palaceName)
            .fontSize(11)
            .fontColor('#888888')
            .textAlign(TextAlign.Start)
            .width('100%')
          
          // 九星（主要显示）
          Text(this.panResult.palaces[index].starName || '')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2C2416')
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ top: 2 })
          
          // 八门
          Text(this.panResult.palaces[index].doorName || '')
            .fontSize(12)
            .fontColor('#555555')
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ top: 1 })
          
          // 分割线
          Divider()
            .color('#f0f0f0')
            .strokeWidth(0.5)
            .margin({ top: 3, bottom: 3 })
          
          // 天盘地盘干支
          Row({ space: 5 }) {
            Text('天')
              .fontSize(9)
              .fontColor('#999999')
            Text(this.panResult.palaces[index].tianGan || '')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('#D4691A')
            Text('地')
              .fontSize(9)
              .fontColor('#999999')
            Text(this.panResult.palaces[index].diGan || '')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('#2A7A8C')
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 1 })
          
          // 八神
          Text(this.panResult.palaces[index].deityName || '')
            .fontSize(10)
            .fontColor('#8B6914')
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ top: 2 })
          
          // 格局徽章
          if (this.getPalacePatterns(index).length > 0) {
            Row({ space: 2 }) {
              ForEach(this.getPalacePatterns(index).slice(0, 2), (patternName: string) => {
                Text(patternName)
                  .fontSize(9)
                  .fontColor('#FFFFFF')
                  .backgroundColor(this.getPatternColor(patternName))
                  .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                  .borderRadius(4)
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ top: 3 })
          }
        }
        .width('100%')

        // 值符/值使角标
        if (this.panResult.zhiFuPalace === index) {
          Text('符')
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .backgroundColor('#D4A574')
            .padding({ left: 5, right: 5, top: 2, bottom: 2 })
            .borderRadius({ topRight: 8, bottomLeft: 8 })
        } else if (this.panResult.zhiShiPalace === index) {
          Text('使')
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .backgroundColor('#4A6A8B')
            .padding({ left: 5, right: 5, top: 2, bottom: 2 })
            .borderRadius({ topRight: 8, bottomLeft: 8 })
        }
      }
      .width('32%')
      .height(145)
      .padding({ left: 8, right: 8, top: 8, bottom: 8 })
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

        // 格局总览
        if (this.panResult.gejuPatterns && this.panResult.gejuPatterns.length > 0) {
          Column({ space: 8 }) {
            Row({ space: 8 }) {
              Text('🎯')
                .fontSize(16)
              Text('识别格局')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2C2416')
              Text(`${this.panResult.gejuPatterns.length}个`)
                .fontSize(12)
                .fontColor('#999999')
            }
            .width('100%')

            // 格局列表
            Column({ space: 6 }) {
              ForEach(this.panResult.gejuPatterns, (pattern: GejuPattern) => {
                Row({ space: 8 }) {
                  Text(pattern.name)
                    .fontSize(13)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.getPatternColor(pattern.name))
                  Text(pattern.description)
                    .fontSize(12)
                    .fontColor('#666666')
                    .layoutWeight(1)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .width('100%')
                .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                .backgroundColor('#F8F8F8')
                .borderRadius(6)
              })
            }
            .width('100%')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor('#ffffff')
          .borderRadius(12)
          .shadow({ radius: 8, color: '#22000000', offsetX: 0, offsetY: 2 })
        }

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
