import { DunjiaPanResult } from '../utils/DunjiaEngine'
import { GejuPattern } from '../utils/DunjiaEngine'
import { PalaceInfoCard, PalaceCardConfig } from './PalaceInfoCard'

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
      PalaceInfoCard({
        config: {
          palace: this.panResult.palaces[index],
          index: index,
          isSelected: this.selectedPalace === index,
          isZhiFu: this.panResult.zhiFuPalace === index,
          isZhiShi: this.panResult.zhiShiPalace === index,
          patterns: this.getPalacePatterns(index)
        },
        onCardClick: () => {
          if (this.onPalaceClick) {
            this.onPalaceClick(index)
          }
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
