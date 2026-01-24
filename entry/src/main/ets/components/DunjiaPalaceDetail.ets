import { DunjiaPanResult, GejuPattern } from '../utils/DunjiaEngine'

/**
 * 宬位详情显示组件
 * 
 * 功能：
 * - 显示宬位详细信息（九星、八门、八神、天盘地盘）
 * - 提供详细解释和分析
 * - 筛选并显示相关格局
 * - 支持滚动查看完整内容
 * 
 * 使用方式：
 * ```typescript
 * DunjiaPalaceDetail({
 *   panResult: this.panResult,
 *   selectedPalace: this.selectedPalace
 * })
 * ```
 */
@Component
export struct DunjiaPalaceDetail {
  @Prop panResult: DunjiaPanResult | null = null
  @Prop selectedPalace: number | null = null

  /**
   * 获取宫位方位
   */
  private getPalacePosition(index: number): string {
    const positions = ['西北', '正北', '东北', '正东', '中央', '正西', '东南', '正南', '西南']
    return positions[index] || ''
  }

  /**
   * 获取九星含义
   */
  private getStarMeaning(starName: string): string {
    const starMeanings: Record<string, string> = {
      '天蓬': '天蓬星属水，主盗贼、阴私之事，利暗谋、伏藏。',
      '天任': '天任星属土，主富贵、财帛，利经商、求财、置产。',
      '天冲': '天冲星属木，主冲动、争斗，利战斗、竞争、进取。',
      '天辅': '天辅星属木，主文书、学问，利读书、考试、文化事业。',
      '天英': '天英星属火，主文明、光彩，利文书、宴会、喜庆之事。',
      '天芯': '天芯星属土，主欺诈、虚伪，不利谋事，易生变故。',
      '天柱': '天柱星属金，主刚健、威武，利军事、法律、执法行动。',
      '天心': '天心星属金，主医药、谋略，利治病、求医、策划。',
      '天禽': '天禽星属土，主中正、调和，利调停、和解、中介。'
    }
    return starMeanings[starName] || '暂无解释'
  }

  /**
   * 获取八门含义
   */
  private getDoorMeaning(doorName: string): string {
    const doorMeanings: Record<string, string> = {
      '休门': '休门属水，主休闲、休养，利休息、求财、婚姻、交易。',
      '死门': '死门属土，主死亡、刑罚，利渔猎、吊丧、埋葬、诉讼。',
      '伤门': '伤门属木，主伤害、损伤，利渔猎、捕捉、索债、讨债。',
      '杜门': '杜门属木，主遮蔽、阻塞，利躲灾、避难、藏身、潜伏。',
      '开门': '开门属金，主开启、开通，利经商、交易、求学、考试。',
      '惊门': '惊门属金，主惊恐、官司，利诉讼、谈判、辩论、求名。',
      '生门': '生门属土，主生机、发财，利经营、贸易、开业、求财。',
      '景门': '景门属火，主文书、文章，利考试、谈判、聚会、演说。'
    }
    return doorMeanings[doorName] || '暂无解释'
  }

  /**
   * 获取八神含义
   */
  private getDeityMeaning(deityName: string): string {
    const deityMeanings: Record<string, string> = {
      '值符': '值符为贵人之首，主贵人提携，利朝见、面圣、求情、办事。',
      '腾蛇': '腾蛇主虚惊、怪异，利驱邪、压惊、镇煞、化解灾厄。',
      '太阴': '太阴主私密、阴私，利密谋、策划、暗中行事、私下交易。',
      '六合': '六合主合作、和合，利婚庆、谈判、签约、合作、交往。',
      '白虎': '白虎主道路、血光，利出行、搬迁、远行、寻访。',
      '玄武': '玄武主偷盗、暗昧，利追逃、捕盗、调查、暗访。',
      '九地': '九地主沉稳、固守，利屯兵、坚守、积蓄力量、稳定根基。',
      '九天': '九天主飞扬、刚健，利举事、出行、征战、扬威、展翅高飞。'
    }
    return deityMeanings[deityName] || '暂无解释'
  }

  /**
   * 获取天盘地盘组合分析
   */
  private getGanCombinationAnalysis(tianGan: string, diGan: string): string {
    if (!tianGan || !diGan) {
      return '天盘地盘干支组合待分析'
    }
    
    // 伏吟分析
    if (tianGan === diGan) {
      return `${tianGan}干伏吟，主静守为宜，不宜轻举妄动，事情进展缓慢，宜按兵不动。`
    }
    
    // 相生相克分析
    const wuxingMap: Record<string, string> = {
      '甲': '木', '乙': '木', '丙': '火', '丁': '火', '戊': '土', '己': '土', '庚': '金', '辛': '金', '壬': '水', '癸': '水'
    }
    
    const tianWuxing = wuxingMap[tianGan] || ''
    const diWuxing = wuxingMap[diGan] || ''
    
    if (tianWuxing && diWuxing) {
      if (tianWuxing === diWuxing) {
        return `${tianGan}临${diGan}同类比和，主和谐稳定，合作顺利。`
      } else if (
        (tianWuxing === '木' && diWuxing === '火') ||
        (tianWuxing === '火' && diWuxing === '土') ||
        (tianWuxing === '土' && diWuxing === '金') ||
        (tianWuxing === '金' && diWuxing === '水') ||
        (tianWuxing === '水' && diWuxing === '木')
      ) {
        return `${tianGan}生${diGan}相生，主助力增益，事情顺利，有利发展。`
      } else {
        return `${tianGan}与${diGan}相克，主阻碍冲突，需谨慎应对，防范风险。`
      }
    }
    
    return `${tianGan}临${diGan}，干支关系待进一步分析。`
  }

  /**
   * 获取与当前选中宫位相关的格局
   */
  private getRelatedGejuPatterns(): GejuPattern[] {
    if (!this.panResult || !this.panResult.gejuPatterns || this.selectedPalace === null) {
      return []
    }
    
    return this.panResult.gejuPatterns.filter((pattern: GejuPattern): boolean => {
      return pattern.palaceIndices !== undefined && pattern.palaceIndices.includes(this.selectedPalace!)
    })
  }

  /**
   * 获取相关格局数量
   */
  private getRelatedGejuCount(): number {
    return this.getRelatedGejuPatterns().length
  }

  build() {
    if (this.selectedPalace !== null && this.panResult && this.selectedPalace < this.panResult.palaces.length) {
      Column({ space: 8 }) {
        // 详情标题
        Text('宫位详解')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C2416')
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 4 })
        
        // 宫位基本信息
        Column({ space: 6 }) {
          Row() {
            Text('宫位：')
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
          
          Row() {
            Text('方位五行：')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#D4A574')
              .width(80)
            Text(`${this.getPalacePosition(this.selectedPalace)} • ${this.panResult.palaces[this.selectedPalace].palaceElement}行`)
              .fontSize(14)
              .fontColor('#666666')
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
        }
        
        Divider().color('#e0e0e0').strokeWidth(1).margin({ top: 4, bottom: 4 })
        
        // 九星信息
        if (this.panResult.palaces[this.selectedPalace].starName) {
          Column({ space: 4 }) {
            Row() {
              Text('九星：')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#D4A574')
                .width(80)
              Text(`${this.panResult.palaces[this.selectedPalace].starName}`)
                .fontSize(14)
                .fontColor('#D4691A')
                .layoutWeight(1)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
            
            Text(`${this.getStarMeaning(this.panResult.palaces[this.selectedPalace].starName || '')}`)
              .fontSize(13)
              .fontColor('#666666')
              .width('100%')
              .margin({ left: 80 })
              .textAlign(TextAlign.Start)
          }
        }
        
        Divider().color('#e0e0e0').strokeWidth(1).margin({ top: 4, bottom: 4 })
        
        // 八门信息
        if (this.panResult.palaces[this.selectedPalace].doorName) {
          Column({ space: 4 }) {
            Row() {
              Text('八门：')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#D4A574')
                .width(80)
              Text(`${this.panResult.palaces[this.selectedPalace].doorName}`)
                .fontSize(14)
                .fontColor('#2A7A8C')
                .layoutWeight(1)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
            
            Text(`${this.getDoorMeaning(this.panResult.palaces[this.selectedPalace].doorName || '')}`)
              .fontSize(13)
              .fontColor('#666666')
              .width('100%')
              .margin({ left: 80 })
              .textAlign(TextAlign.Start)
          }
        }
        
        Divider().color('#e0e0e0').strokeWidth(1).margin({ top: 4, bottom: 4 })
        
        // 天盘地盘信息
        if (this.panResult.palaces[this.selectedPalace].tianGan || this.panResult.palaces[this.selectedPalace].diGan) {
          Column({ space: 4 }) {
            Row() {
              Text('天盘地盘：')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#D4A574')
                .width(80)
              Row() {
                if (this.panResult.palaces[this.selectedPalace].tianGan) {
                  Text(`天:${this.panResult.palaces[this.selectedPalace].tianGan}`)
                    .fontSize(14)
                    .fontColor('#D4691A')
                }
                if (this.panResult.palaces[this.selectedPalace].diGan) {
                  Text(` 地:${this.panResult.palaces[this.selectedPalace].diGan}`)
                    .fontSize(14)
                    .fontColor('#2A7A8C')
                }
              }
              .layoutWeight(1)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
            
            Text(`${this.getGanCombinationAnalysis(this.panResult.palaces[this.selectedPalace].tianGan || '', this.panResult.palaces[this.selectedPalace].diGan || '')}`)
              .fontSize(13)
              .fontColor('#666666')
              .width('100%')
              .margin({ left: 80 })
              .textAlign(TextAlign.Start)
          }
        }
        
        Divider().color('#e0e0e0').strokeWidth(1).margin({ top: 4, bottom: 4 })
        
        // 八神信息
        if (this.panResult.palaces[this.selectedPalace].deityName) {
          Column({ space: 4 }) {
            Row() {
              Text('八神：')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#D4A574')
                .width(80)
              Text(`${this.panResult.palaces[this.selectedPalace].deityName}`)
                .fontSize(14)
                .fontColor('#8B6914')
                .layoutWeight(1)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
            
            Text(`${this.getDeityMeaning(this.panResult.palaces[this.selectedPalace].deityName || '')}`)
              .fontSize(13)
              .fontColor('#666666')
              .width('100%')
              .margin({ left: 80 })
              .textAlign(TextAlign.Start)
          }
        }
        
        Divider().color('#e0e0e0').strokeWidth(1).margin({ top: 4, bottom: 4 })
        
        // 特殊标识
        Column({ space: 4 }) {
          Row() {
            Text('特殊标识：')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#D4A574')
              .width(80)
            Column({ space: 4 }) {
              if (this.panResult.zhiFuPalace === this.selectedPalace) {
                Text('• 值符宫：为时干落宫，代表事物的主要矛盾或核心人物')
                  .fontSize(12)
                  .fontColor('#D4A574')
              }
              if (this.panResult.zhiShiPalace === this.selectedPalace) {
                Text('• 值使宫：为时支落宫，代表事物的发展趋势或行动方向')
                  .fontSize(12)
                  .fontColor('#4A6A8B')
              }
              if (this.panResult.palaces[this.selectedPalace].tianGan === '乙') {
                Text('• 日奇落宫：主光明、吉利、贵人扶持')
                  .fontSize(12)
                  .fontColor('#666666')
              } else if (this.panResult.palaces[this.selectedPalace].tianGan === '丙') {
                Text('• 月奇落宫：主光明、吉利、贵人扶持')
                  .fontSize(12)
                  .fontColor('#666666')
              } else if (this.panResult.palaces[this.selectedPalace].tianGan === '丁') {
                Text('• 星奇落宫：主光明、吉利、贵人扶持')
                  .fontSize(12)
                  .fontColor('#666666')
              }
              if (['戊', '己', '庚', '辛', '壬', '癸'].includes(this.panResult.palaces[this.selectedPalace].tianGan || '')) {
                Text('• 六仪落宫：主常规事务、按部就班')
                  .fontSize(12)
                  .fontColor('#666666')
              }
            }
            .layoutWeight(1)
          }
          .width('100%')
        }
        
        // 相关格局
        if (this.getRelatedGejuCount() > 0) {
          Divider().color('#e0e0e0').strokeWidth(1).margin({ top: 8, bottom: 8 })
          
          Column({ space: 8 }) {
            Row() {
              Text('相关格局：')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#D4A574')
                .width(80)
              Text(`识别到 ${this.getRelatedGejuCount()} 个格局`)
                .fontSize(12)
                .fontColor('#999999')
                .layoutWeight(1)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
            
            ForEach(this.getRelatedGejuPatterns(), (pattern: GejuPattern) => {
              Column({ space: 4 }) {
                Row() {
                  Text(pattern.name)
                    .fontSize(13)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#2C2416')
                    .layoutWeight(1)
                  
                  if (pattern.level === 'major') {
                    Text('主要')
                      .fontSize(9)
                      .fontColor('#ffffff')
                      .padding({ left: 5, right: 5, top: 1, bottom: 1 })
                      .backgroundColor('#D4A574')
                      .borderRadius(6)
                  } else if (pattern.level === 'special') {
                    Text('特殊')
                      .fontSize(9)
                      .fontColor('#ffffff')
                      .padding({ left: 5, right: 5, top: 1, bottom: 1 })
                      .backgroundColor('#8B6914')
                      .borderRadius(6)
                  } else {
                    Text('次要')
                      .fontSize(9)
                      .fontColor('#ffffff')
                      .padding({ left: 5, right: 5, top: 1, bottom: 1 })
                      .backgroundColor('#999999')
                      .borderRadius(6)
                  }
                }
                .width('100%')
                
                Text(pattern.description)
                  .fontSize(12)
                  .fontColor('#666666')
                  .lineHeight(18)
                  .width('100%')
              }
              .width('100%')
              .padding({ left: 8, right: 8, top: 6, bottom: 6 })
              .backgroundColor('#f9f9f9')
              .borderRadius(6)
              .margin({ top: 4 })
            })
          }
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#ffffff')
      .border({ width: 1, color: '#e0e0e0' })
      .borderRadius(8)
      .margin({ left: 16, right: 16, bottom: 16 })
    }
  }
}
