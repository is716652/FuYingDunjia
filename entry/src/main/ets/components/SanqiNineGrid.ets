import { DunjiaPanResult } from '../utils/DunjiaEngine'

/**
 * 三奇择日九宫组件
 * 
 * 与研习九宫的区别:
 * - 侧重三奇(乙丙丁)标识
 * - 不显示八神
 * - 不显示格局徽章
 * - 突出应验方位标识
 * 
 * 布局说明：
 * 请确认是否需要3×3标准矩阵布局（9个宫位平铺），还是洛书布局（一宫八宫在最下方）
 */

@Component
export struct SanqiNineGrid {
  @Prop panResult: DunjiaPanResult
  @Prop selectedPalace: number | null = null
  onPalaceClick?: (index: number) => void

  /**
   * 构建单个宫位卡片(择日版)
   */
  @Builder
  buildSanqiPalaceCard(index: number) {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column({ space: 2 }) {
        // 宫名
        Text(this.panResult.palaces[index].palaceName)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C2416')
          
        // 九星
        Text(this.panResult.palaces[index].starName || '')
          .fontSize(12)
          .fontColor('#666666')
          
        // 八门
        Text(this.panResult.palaces[index].doorName || '')
          .fontSize(12)
          .fontColor(this.getDoorColor(this.panResult.palaces[index].doorName || ''))
          .fontWeight(FontWeight.Medium)
          
        // 天盘地盘(突出三奇)
        Row({ space: 4 }) {
          Text(this.panResult.palaces[index].tianGan || '')
            .fontSize(13)
            .fontColor(['乙', '丙', '丁'].includes(this.panResult.palaces[index].tianGan || '') ? '#FF6B35' : '#2C2416')
            .fontWeight(['乙', '丙', '丁'].includes(this.panResult.palaces[index].tianGan || '') ? FontWeight.Bold : FontWeight.Normal)
          Text(this.panResult.palaces[index].diGan || '')
            .fontSize(11)
            .fontColor('#999999')
        }
          
        // 三奇应验标识
        if (['乙', '丙', '丁'].includes(this.panResult.palaces[index].tianGan || '')) {
          Text(this.getSanqiLabel(this.panResult.palaces[index].tianGan!))
            .fontSize(10)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF6B35')
            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
            .borderRadius(3)
        }
      }
      .padding(8)
      .width('100%')
        
      // 值符值使角标
      if (this.panResult.zhiFuPalace === index) {
        Text('符')
          .fontSize(10)
          .fontColor('#FFFFFF')
          .backgroundColor('#D4A574')
          .padding({ left: 4, right: 4, top: 1, bottom: 1 })
          .borderRadius(3)
      } else if (this.panResult.zhiShiPalace === index) {
        Text('使')
          .fontSize(10)
          .fontColor('#FFFFFF')
          .backgroundColor('#4A6A8B')
          .padding({ left: 4, right: 4, top: 1, bottom: 1 })
          .borderRadius(3)
      }
    }
    .width('32%')
    .height(115)
    .backgroundColor(this.selectedPalace === index ? '#FFF8F0' : (['乙', '丙', '丁'].includes(this.panResult.palaces[index].tianGan || '') ? '#FFFBF0' : '#FFFFFF'))
    .borderRadius(8)
    .border({
      width: this.panResult.zhiFuPalace === index || this.panResult.zhiShiPalace === index || ['乙', '丙', '丁'].includes(this.panResult.palaces[index].tianGan || '') ? 2 : 1,
      color: this.panResult.zhiFuPalace === index ? '#D4A574' : (this.panResult.zhiShiPalace === index ? '#4A6A8B' : (['乙', '丙', '丁'].includes(this.panResult.palaces[index].tianGan || '') ? '#FF6B35' : '#E0E0E0'))
    })
    .shadow({
      radius: this.panResult.zhiFuPalace === index || this.panResult.zhiShiPalace === index || ['乙', '丙', '丁'].includes(this.panResult.palaces[index].tianGan || '') ? 8 : 4,
      color: this.panResult.zhiFuPalace === index ? '#33D4A574' : (['乙', '丙', '丁'].includes(this.panResult.palaces[index].tianGan || '') ? '#33FF6B35' : '#22000000'),
      offsetX: 0,
      offsetY: 1
    })
    .onClick(() => {
      if (this.onPalaceClick) {
        this.onPalaceClick(index)
      }
    })
  }

  /**
   * 获取三奇标签
   */
  private getSanqiLabel(tianGan: string): string {
    const labels: Record<string, string> = {
      '乙': '日奇',
      '丙': '月奇',
      '丁': '星奇'
    }
    return labels[tianGan] || ''
  }

  /**
   * 获取八门颜色
   */
  private getDoorColor(doorName: string): string {
    const jiMen = ['开门', '休门', '生门']
    const xiongMen = ['伤门', '杜门', '死门', '惊门']
    
    if (jiMen.includes(doorName)) {
      return '#4CAF50'
    } else if (xiongMen.includes(doorName)) {
      return '#F44336'
    } else {
      return '#FF9800'
    }
  }

  build() {
    Column({ space: 4 }) {
      // 第一行：0,1,2
      Row({ space: 4 }) {
        this.buildSanqiPalaceCard(0)
        this.buildSanqiPalaceCard(1)
        this.buildSanqiPalaceCard(2)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // 第二行：3,4,5
      Row({ space: 4 }) {
        this.buildSanqiPalaceCard(3)
        this.buildSanqiPalaceCard(4)
        this.buildSanqiPalaceCard(5)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // 第三行：6,7,8
      Row({ space: 4 }) {
        this.buildSanqiPalaceCard(6)
        this.buildSanqiPalaceCard(7)
        this.buildSanqiPalaceCard(8)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(8)
  }
}
