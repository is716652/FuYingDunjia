import { DunjiaPanResult, PalaceState, GejuPattern } from '../utils/DunjiaEngine'

/**
 * 宫位详情面板组件（优化版）
 * 
 * 功能：
 * - 显示选中宫位的完整信息
 * - 格局解析说明
 * - 值符值使详细信息
 * - 宫位生克关系
 */

@Component
export struct PalaceDetailPanel {
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
   * 获取相关格局
   */
  private getRelatedPatterns(): GejuPattern[] {
    if (!this.panResult || this.selectedPalace === null || !this.panResult.gejuPatterns) return [];
    return this.panResult.gejuPatterns.filter(pattern => 
      pattern.palaceIndices.includes(this.selectedPalace!)
    );
  }

  /**
   * 获取五行生克关系
   */
  private getWuxingRelation(): string {
    const palace = this.getSelectedPalaceState();
    if (!palace) return '';
    
    interface WuxingRelationInfo {
      sheng: string;
      ke: string;
      beike: string;
      beisheng: string;
    }

    const wuxingShengke: Record<string, WuxingRelationInfo> = {
      '水': { sheng: '木', ke: '火', beike: '土', beisheng: '金' },
      '火': { sheng: '土', ke: '金', beike: '水', beisheng: '木' },
      '木': { sheng: '火', ke: '土', beike: '金', beisheng: '水' },
      '金': { sheng: '水', ke: '木', beike: '火', beisheng: '土' },
      '土': { sheng: '金', ke: '水', beike: '木', beisheng: '火' }
    };
    
    const element = palace.palaceElement;
    const relation = wuxingShengke[element];
    if (!relation) return '';
    
    return `生${relation.sheng} 克${relation.ke} 被${relation.beike}克 ${relation.beisheng}生我`;
  }

  /**
   * 获取值符值使说明
   */
  private getZhiFuZhiShiInfo(): string {
    if (!this.panResult || this.selectedPalace === null) return '';
    
    if (this.panResult.zhiFuPalace === this.selectedPalace) {
      return '此宫为值符所在，为主导力量，代表天时之利';
    } else if (this.panResult.zhiShiPalace === this.selectedPalace) {
      return '此宫为值使所在，为行动之门，代表时机把握';
    }
    return '';
  }

  build() {
    if (this.selectedPalace !== null && this.getSelectedPalaceState()) {
      Column({ space: 16 }) {
        // 标题栏
        Text('宫位详情')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C2416')
          .width('100%')

        Column({ space: 16 }) {
          // 基本信息
          Column({ space: 12 }) {
            Text('⚙️ 基本信息')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')
              .width('100%')

            Column({ space: 8 }) {
              this.buildInfoRow('宫位', this.getSelectedPalaceState()!.palaceName)
              this.buildInfoRow('五行', this.getSelectedPalaceState()!.palaceElement)
              this.buildInfoRow('九星', this.getSelectedPalaceState()!.starName || '')
              this.buildInfoRow('八门', this.getSelectedPalaceState()!.doorName || '')
              this.buildInfoRow('天盘', this.getSelectedPalaceState()!.tianGan || '')
              this.buildInfoRow('地盘', this.getSelectedPalaceState()!.diGan || '')
              this.buildInfoRow('八神', this.getSelectedPalaceState()!.deityName || '')
            }
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#F8F8F8')
          .borderRadius(8)

          // 五行生克关系
          if (this.getWuxingRelation()) {
            Column({ space: 12 }) {
              Text('☯️ 五行生克')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2C2416')
                .width('100%')

              Text(this.getWuxingRelation())
                .fontSize(13)
                .fontColor('#666666')
                .lineHeight(20)
                .width('100%')
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F8F8F8')
            .borderRadius(8)
          }

          // 值符值使信息
          if (this.getZhiFuZhiShiInfo()) {
            Column({ space: 12 }) {
              Text('⭐ 特殊标识')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2C2416')
                .width('100%')

              Text(this.getZhiFuZhiShiInfo())
                .fontSize(13)
                .fontColor('#D4A574')
                .lineHeight(20)
                .width('100%')
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FFF8F0')
            .borderRadius(8)
          }

          // 相关格局
          if (this.getRelatedPatterns().length > 0) {
            Column({ space: 12 }) {
              Text('🎯 相关格局')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2C2416')
                .width('100%')

              Column({ space: 8 }) {
                ForEach(this.getRelatedPatterns(), (pattern: GejuPattern) => {
                  Column({ space: 6 }) {
                    Text(pattern.name)
                      .fontSize(13)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#FF6B35')
                      .width('100%')
                    
                    Text(pattern.description)
                      .fontSize(12)
                      .fontColor('#666666')
                      .lineHeight(18)
                      .width('100%')
                  }
                  .width('100%')
                  .padding(10)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(6)
                  .border({ width: 1, color: '#FFE0D6' })
                })
              }
              .width('100%')
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F8F8F8')
            .borderRadius(8)
          }
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .shadow({ radius: 8, color: '#22000000', offsetX: 0, offsetY: 2 })
    }
  }

  @Builder
  buildInfoRow(label: string, value: string) {
    Row({ space: 12 }) {
      Text(label)
        .fontSize(13)
        .fontColor('#888888')
        .width(60)
        .textAlign(TextAlign.Start)
      
      Text(value)
        .fontSize(13)
        .fontColor('#2C2416')
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
    }
    .width('100%')
  }
}
