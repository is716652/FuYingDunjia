import { PalaceState } from '../utils/DunjiaEngine'

/**
 * 宫位信息卡片组件（优化版）
 * 
 * 功能：
 * - 显示完整宫位信息（九星、八门、天地盘、八神、地支）
 * - 支持值符值使标识
 * - 支持格局徽章显示
 * - 响应点击事件
 */

export interface PalaceCardConfig {
  palace: PalaceState;
  index: number;
  isSelected: boolean;
  isZhiFu: boolean;
  isZhiShi: boolean;
  patterns: string[];
}

@Component
export struct PalaceInfoCard {
  @Prop config: PalaceCardConfig
  onCardClick?: () => void

  /**
   * 获取格局颜色
   */
  private getPatternColor(patternName: string): string {
    if (patternName.includes('天遁') || patternName.includes('三奇得使')) {
      return '#FF6B35';
    } else if (patternName.includes('地遁') || patternName.includes('人遁')) {
      return '#D4A574';
    }
    return '#4A90E2';
  }

  /**
   * 获取地支（根据宫位索引）
   */
  private getDiZhi(): string {
    const dizhiMap = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    // 简化映射：一宫坎(子)、二宫坤(未)、三宫震(卯)、四宫巽(辰)、五宫中(-)、六宫乾(戌)、七宫兑(酉)、八宫艮(丑)、九宫离(午)
    const palaceDizhiMap = [11, 7, 2, 3, -1, 10, 9, 1, 6]; // 对应索引0-8
    const zhiIndex = palaceDizhiMap[this.config.index];
    return zhiIndex >= 0 ? dizhiMap[zhiIndex] : '';
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column({ space: 3 }) {
        // 宫名 + 地支
        Row({ space: 4 }) {
          Text(this.config.palace.palaceName)
            .fontSize(11)
            .fontColor('#888888')
          
          if (this.getDiZhi()) {
            Text(`[${this.getDiZhi()}]`)
              .fontSize(10)
              .fontColor('#999999')
          }
        }
        .width('100%')
        
        // 九星（主要显示）
        Text(this.config.palace.starName || '')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C2416')
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: 2 })
        
        // 八门
        Text(this.config.palace.doorName || '')
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
          Text(this.config.palace.tianGan || '')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#D4691A')
          Text('地')
            .fontSize(9)
            .fontColor('#999999')
          Text(this.config.palace.diGan || '')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2A7A8C')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 1 })
        
        // 八神
        Text(this.config.palace.deityName || '')
          .fontSize(10)
          .fontColor('#8B6914')
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: 2 })
        
        // 格局徽章
        if (this.config.patterns.length > 0) {
          Row({ space: 2 }) {
            ForEach(this.config.patterns.slice(0, 2), (patternName: string) => {
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
      if (this.config.isZhiFu) {
        Text('符')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor('#D4A574')
          .padding({ left: 5, right: 5, top: 2, bottom: 2 })
          .borderRadius({ topRight: 8, bottomLeft: 8 })
      } else if (this.config.isZhiShi) {
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
    .height(165)
    .padding({ left: 8, right: 8, top: 8, bottom: 8 })
    .backgroundColor(this.config.isSelected ? '#FFF8F0' : '#FFFFFF')
    .borderRadius(8)
    .border({
      width: (this.config.isZhiFu || this.config.isZhiShi) ? 2 : 1,
      color: this.config.isZhiFu ? '#D4A574' : (this.config.isZhiShi ? '#4A6A8B' : '#E0E0E0')
    })
    .shadow({
      radius: (this.config.isZhiFu || this.config.isZhiShi) ? 10 : 4,
      color: this.config.isZhiFu ? '#33D4A574' : '#22000000',
      offsetX: 0,
      offsetY: 1
    })
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick()
      }
    })
  }
}
