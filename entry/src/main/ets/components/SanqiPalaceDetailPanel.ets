import { DunjiaPanResult, PalaceState } from '../utils/DunjiaEngine'

/**
 * 三奇应验宫位详情面板
 * 
 * 功能:
 * - 显示三奇应验详细信息
 * - 显示应验时间周期
 * - 提供择日建议
 */
@Component
export struct SanqiPalaceDetailPanel {
  @Prop panResult: DunjiaPanResult | null = null
  @Prop selectedPalace: number | null = null

  /**
   * 获取选中宫位
   */
  private getSelectedPalaceState(): PalaceState | null {
    if (!this.panResult || this.selectedPalace === null) return null;
    return this.panResult.palaces[this.selectedPalace];
  }

  /**
   * 获取宫位名称
   */
  private getGongName(): string {
    const gongNames = ['坎', '坤', '震', '巽', '中', '乾', '兑', '艮', '离'];
    return this.selectedPalace !== null ? gongNames[this.selectedPalace] : '';
  }

  /**
   * 获取三奇应验简要说明
   */
  private getSanqiInfo(): string {
    const palace = this.getSelectedPalaceState();
    if (!palace || !palace.tianGan) return '';
    
    const tianGan = palace.tianGan;
    if (tianGan === '乙') {
      return '日奇到宫：有利财运，多见衣物钱财之应';
    } else if (tianGan === '丙') {
      return '月奇到宫：有利进财进宝，多见文书契约之应';
    } else if (tianGan === '丁') {
      return '星奇到宫：有利进财得物，多见文书器物之应';
    }
    return '';
  }

  build() {
    Column({ space: 16 }) {
      if (!this.panResult || this.selectedPalace === null) {
        Column() {
          Text('请选择宫位查看详情')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .padding(24)
        .justifyContent(FlexAlign.Center)
      } else {
        Column({ space: 16 }) {
          // 标题
          Row({ space: 8 }) {
            Text(`${this.getGongName()}宫详情`)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')
          }
          .width('100%')

          // 基础信息
          Column({ space: 8 }) {
            Row({ space: 12 }) {
              Text('九星：')
                .fontSize(13)
                .fontColor('#666666')
              Text(this.getSelectedPalaceState()?.starName || '')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#2C2416')
            }

            Row({ space: 12 }) {
              Text('八门：')
                .fontSize(13)
                .fontColor('#666666')
              Text(this.getSelectedPalaceState()?.doorName || '')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#2C2416')
            }

            Row({ space: 12 }) {
              Text('天盘：')
                .fontSize(13)
                .fontColor('#666666')
              Text(this.getSelectedPalaceState()?.tianGan || '')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(['乙', '丙', '丁'].includes(this.getSelectedPalaceState()?.tianGan || '') ? '#FF6B35' : '#2C2416')
            }

            Row({ space: 12 }) {
              Text('地盘：')
                .fontSize(13)
                .fontColor('#666666')
              Text(this.getSelectedPalaceState()?.diGan || '')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#2C2416')
            }
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#F8F8F8')
          .borderRadius(8)

          // 三奇应验信息
          if (['乙', '丙', '丁'].includes(this.getSelectedPalaceState()?.tianGan || '')) {
            Column({ space: 12 }) {
              Row({ space: 6 }) {
                Text('✨')
                  .fontSize(16)
                Text('三奇应验')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2C2416')
              }
              .width('100%')

              Text(this.getSanqiInfo())
                .fontSize(13)
                .fontColor('#666666')
                .lineHeight(20)
                .width('100%')
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FFFBF0')
            .borderRadius(8)
            .border({ width: 1, color: '#FFE4B5' })
          }
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#22000000', offsetX: 0, offsetY: 2 })
  }
}
