import { DunjiaPanResult, PalaceState, GejuPattern } from '../utils/DunjiaEngine'

/**
 * 九星断语信息
 */
interface StarInterpretation {
  summary: string;
  favorable: string;
  unfavorable: string;
}

/**
 * 八门吉凶信息
 */
interface DoorInterpretation {
  type: string;
  summary: string;
  favorable: string;
  unfavorable: string;
}

/**
 * 宫位详情面板组件（古籍知识版）
 * 
 * 功能：
 * - 基于《遁甲符应经》的九星八门知识解读
 * - 格局深度分析与古籍依据
 * - 天地盘组合吉凶判断
 * - 应用建议与时机参考
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
      return '此宫为值符所在,为主导力量,代表天时之利';
    } else if (this.panResult.zhiShiPalace === this.selectedPalace) {
      return '此宫为值使所在,为行动之门,代表时机把握';
    }
    return '';
  }
  
  /**
   * 获取九星断语
   */
  private getStarInterpretation(): StarInterpretation | null {
    const palace = this.getSelectedPalaceState();
    if (!palace || !palace.starName) return null;
      
    const starInfo: Record<string, StarInterpretation> = {
      '天蓬': {
        summary: '智慧冒险,但主盗贼破财。春夏出兵利左将,秋冬大凶。',
        favorable: '安抚边境、修筑城池、春夏季节军事行动',
        unfavorable: '秋冬用事、嫁娶、搬家、入官、经商、争斗'
      },
      '天芮': {
        summary: '病星学生星。秋冬吉,春夏凶。利求医拜师,忌用兵嫁娶。',
        favorable: '求医问药、拜师学艺、结交朋友',
        unfavorable: '用兵、嫁娶、诉讼、搬家、盖房、春秋用事大凶'
      },
      '天冲': {
        summary: '雷神行动星。冲动出击,快速行动。春夏大吉,秋冬凶。',
        favorable: '出兵报仇、春夏季节作战(左将胜)',
        unfavorable: '秋冬用事、嫁娶、搬家、入官、祭祀、经商'
      },
      '天辅': {
        summary: '文曲贵人星(上吉)。教育文化贵人扶持。春夏大吉。',
        favorable: '读书学习、设立学校、带兵、嫁娶(多子多福)、搬家、经商、入官、盖房(春夏尤吉)',
        unfavorable: '无明显禁忌,秋冬力量减弱'
      },
      '天禽': {
        summary: '帝王调和星(上吉)。中正稳定,百事皆宜,四季皆吉。',
        favorable: '祭祀求福、带兵(四时皆吉)、封官授爵、搬家、入官、经商、嫁娶',
        unfavorable: '几乎无禁忌'
      },
      '天心': {
        summary: '医星领导星(上吉)。医疗科技领导力。秋冬大吉,春夏凶。',
        favorable: '治病合药、带兵、嫁娶、入官、盖房、祭祀、经商(秋冬吉)',
        unfavorable: '春夏用事不利、小人行事反招祸'
      },
      '天柱': {
        summary: '破坏隐士星(小凶)。口舌变革。利守不利攻,宜静不宜动。',
        favorable: '屯兵自守、隐居避世、嫁娶、修造、祭祀(有限可用)',
        unfavorable: '带兵出征、搬家、入官、经商'
      },
      '天任': {
        summary: '诚信建筑星(次吉)。稳重积累。四季月大吉,利守成不利变动。',
        favorable: '拜访贵人、通财利、带兵(四时皆吉)、嫁娶(利子孙)、入官',
        unfavorable: '搬家、盖房'
      },
      '天英': {
        summary: '名声急躁星(小凶)。虚名火灾。夏小凶,冬大凶。利虚名不利实利。',
        favorable: '出行远行、饮宴作乐、嫁娶(利名声)',
        unfavorable: '出兵、搬家、入官、盖房、诉讼、经商'
      }
    };
      
    return starInfo[palace.starName] || null;
  }
  
  /**
   * 获取八门吉凶
   */
  private getDoorInterpretation(): DoorInterpretation | null {
    const palace = this.getSelectedPalaceState();
    if (!palace || !palace.doorName) return null;
      
    const doorInfo: Record<string, DoorInterpretation> = {
      '开门': {
        type: '吉门',
        summary: '三大吉门之首。主开通顺达,百事可为。',
        favorable: '远行、签约、升职、开业、求职、见贵人',
        unfavorable: '几乎无禁忌'
      },
      '休门': {
        type: '吉门',
        summary: '三大吉门之一。主休养生息,谈判协商。',
        favorable: '休息疗养、谈判协商、学习进修、养生修炼',
        unfavorable: '不宜紧急行动'
      },
      '生门': {
        type: '吉门',
        summary: '三大吉门之一。主生财置业,创业求财。',
        favorable: '求财、置业、见贵人、创业、投资、贸易',
        unfavorable: '不宜破坏性行动'
      },
      '伤门': {
        type: '凶门',
        summary: '五大凶门。主伤害冲突,但利竞争讨债。',
        favorable: '捕猎、竞争、手术、讨债、索赔',
        unfavorable: '出行、嫁娶、签约、合作'
      },
      '杜门': {
        type: '凶门',
        summary: '五大凶门。主闭塞隐藏,利保密防范。',
        favorable: '隐蔽行动、保密工作、防小人、藏匿',
        unfavorable: '公开活动、宣传推广、社交娱乐'
      },
      '景门': {
        type: '中平',
        summary: '半吉半凶。主文书名声,利考试面试。',
        favorable: '上书、面试、宣传、考试、文化活动',
        unfavorable: '丧葬、阴暗之事'
      },
      '死门': {
        type: '凶门',
        summary: '五大凶门。主终结死亡,仅利丧葬。',
        favorable: '丧葬、诛罚、结束旧事',
        unfavorable: '一切新开始、创业、嫁娶、搬家'
      },
      '惊门': {
        type: '凶门',
        summary: '五大凶门。主惊恐官司,利诉讼抓捕。',
        favorable: '诉讼、抓捕、演讲、惊醒',
        unfavorable: '安静之事、疗养、签约'
      }
    };
      
    return doorInfo[palace.doorName] || null;
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
              Text('☘️ 五行生克')
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
          
          // 九星断语
          if (this.getStarInterpretation()) {
            Column({ space: 12 }) {
              Row({ space: 6 }) {
                Text('⭐ 九星断语')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2C2416')
                Text(`[【${this.getSelectedPalaceState()!.starName}】]`)
                  .fontSize(12)
                  .fontColor('#D4A574')
              }
              .width('100%')
          
              Column({ space: 10 }) {
                Text(this.getStarInterpretation()!.summary)
                  .fontSize(13)
                  .fontColor('#666666')
                  .lineHeight(20)
                  .width('100%')
                          
                Column({ space: 6 }) {
                  Row({ space: 6 }) {
                    Text('✅ 宜：')
                      .fontSize(12)
                      .fontColor('#4CAF50')
                      .fontWeight(FontWeight.Bold)
                    Text(this.getStarInterpretation()!.favorable)
                      .fontSize(12)
                      .fontColor('#4CAF50')
                      .lineHeight(18)
                      .layoutWeight(1)
                  }
                  .width('100%')
                            
                  Row({ space: 6 }) {
                    Text('❌ 忌：')
                      .fontSize(12)
                      .fontColor('#F44336')
                      .fontWeight(FontWeight.Bold)
                    Text(this.getStarInterpretation()!.unfavorable)
                      .fontSize(12)
                      .fontColor('#F44336')
                      .lineHeight(18)
                      .layoutWeight(1)
                  }
                  .width('100%')
                }
                .width('100%')
              }
              .width('100%')
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FFFBF0')
            .borderRadius(8)
            .border({ width: 1, color: '#FFE4B5' })
          }
          
          // 八门吉凶
          if (this.getDoorInterpretation()) {
            Column({ space: 12 }) {
              Row({ space: 6 }) {
                Text('🚦 八门吉凶')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2C2416')
                Text(`[【${this.getSelectedPalaceState()!.doorName}】]`)
                  .fontSize(12)
                  .fontColor(this.getDoorInterpretation()!.type === '吉门' ? '#4CAF50' : 
                           (this.getDoorInterpretation()!.type === '凶门' ? '#F44336' : '#FF9800'))
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
          
              Column({ space: 10 }) {
                Text(this.getDoorInterpretation()!.summary)
                  .fontSize(13)
                  .fontColor('#666666')
                  .lineHeight(20)
                  .width('100%')
                          
                Column({ space: 6 }) {
                  Row({ space: 6 }) {
                    Text('✅ 宜：')
                      .fontSize(12)
                      .fontColor('#4CAF50')
                      .fontWeight(FontWeight.Bold)
                    Text(this.getDoorInterpretation()!.favorable)
                      .fontSize(12)
                      .fontColor('#4CAF50')
                      .lineHeight(18)
                      .layoutWeight(1)
                  }
                  .width('100%')
                            
                  Row({ space: 6 }) {
                    Text('❌ 忌：')
                      .fontSize(12)
                      .fontColor('#F44336')
                      .fontWeight(FontWeight.Bold)
                    Text(this.getDoorInterpretation()!.unfavorable)
                      .fontSize(12)
                      .fontColor('#F44336')
                      .lineHeight(18)
                      .layoutWeight(1)
                  }
                  .width('100%')
                }
                .width('100%')
              }
              .width('100%')
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F0F8FF')
            .borderRadius(8)
            .border({ width: 1, color: '#B0D4FF' })
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
