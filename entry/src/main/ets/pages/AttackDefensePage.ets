import { NavigationBar } from '../components/NavigationBar'
import router from '@ohos.router'
import { DunjiaEngine, DunjiaPanResult, DunjiaInput, DunjiaSceneType } from '../utils/DunjiaEngine'

/**
 * 攻守方位总览页
 * 功能：基于当前时空盘标注五不可击宫位、三胜宫、优势区/禁区
 */
@Entry
@Component
struct AttackDefensePage {
  @State panResult: DunjiaPanResult | null = null
  @State loading: boolean = true
  @State currentDateTime: Date = new Date()
  
  private engine: DunjiaEngine = DunjiaEngine.getInstance()

  aboutToAppear() {
    // 从路由参数获取时间信息
    const params = router.getParams() as Record<string, Object>
    if (params && params['timestamp']) {
      const timestamp = params['timestamp'] as number
      this.currentDateTime = new Date(timestamp)
    }
    
    this.computePan()
  }

  /**
   * 排盘计算
   */
  private async computePan() {
    try {
      this.loading = true
      
      const input: DunjiaInput = {
        dateTime: this.currentDateTime,
        longitude: 116.4074,
        sceneType: DunjiaSceneType.GENERAL_STUDY
      }
      
      this.panResult = await this.engine.computePan(input)
      this.loading = false
    } catch (err) {
      console.error('排盘计算失败', err)
      this.loading = false
    }
  }

  /**
   * 判断宫位是否为五不可击
   */
  private isForbiddenPalace(index: number): boolean {
    if (!this.panResult) return false
    
    // 五不可击：天乙(值符)、九天、生门、九地、直使
    const palace = this.panResult.palaces[index]
    const isZhiFu = index === this.panResult.zhiFuPalace
    const isZhiShi = index === this.panResult.zhiShiPalace
    const isShengMen = palace.doorName === '生门'
    const isJiuTian = palace.deityName === '九天'
    const isJiuDi = palace.deityName === '九地'
    
    return isZhiFu || isZhiShi || isShengMen || isJiuTian || isJiuDi
  }

  /**
   * 判断宫位是否为优势区
   */
  private isAdvantagePalace(index: number): boolean {
    if (!this.panResult) return false
    
    const palace = this.panResult.palaces[index]
    // 三吉门：开门、休门、生门
    const isJiMen = ['开门', '休门', '生门'].includes(palace.doorName || '')
    // 配合吉星
    const isJiXing = ['天心', '天任', '天辅'].includes(palace.starName || '')
    
    return isJiMen && isJiXing
  }

  /**
   * 判断宫位是否为观望区
   */
  private isNeutralPalace(index: number): boolean {
    return !this.isForbiddenPalace(index) && !this.isAdvantagePalace(index)
  }

  /**
   * 获取宫位色块颜色
   */
  private getPalaceColor(index: number): string {
    if (this.isForbiddenPalace(index)) {
      return '#FF6B6B' // 禁区红色
    } else if (this.isAdvantagePalace(index)) {
      return '#4ECDC4' // 优势区青色
    } else {
      return '#F7F7F7' // 观望区灰色
    }
  }

  /**
   * 渲染九宫格
   */
  @Builder
  buildNinePalace() {  
    Grid() {
      GridItem() { this.buildPalaceCell(3) }
      GridItem() { this.buildPalaceCell(8) }
      GridItem() { this.buildPalaceCell(1) }
      GridItem() { this.buildPalaceCell(2) }
      GridItem() { this.buildPalaceCell(4) }
      GridItem() { this.buildPalaceCell(6) }
      GridItem() { this.buildPalaceCell(7) }
      GridItem() { this.buildPalaceCell(0) }
      GridItem() { this.buildPalaceCell(5) }
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsTemplate('1fr 1fr 1fr')
    .width('100%')
    .height(360)
    .columnsGap(4)
    .rowsGap(4)
    .padding(8)
  }

  /**
   * 渲染单个宬位
   */
  @Builder
  buildPalaceCell(index: number) {
    Column({ space: 4 }) {
      // 宫位名称
      Text(this.panResult?.palaces[index]?.palaceName || '')
        .fontSize(11)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
        
      // 星门信息
      Text(`${this.panResult?.palaces[index]?.starName || ''} ${this.panResult?.palaces[index]?.doorName || ''}`)
        .fontSize(10)
        .fontColor('#666666')
        
      // 八神
      Text(this.panResult?.palaces[index]?.deityName || '')
        .fontSize(9)
        .fontColor('#999999')
        .visibility(this.panResult?.palaces[index]?.deityName ? Visibility.Visible : Visibility.None)
        
      // 标注信息
      Text(this.isForbiddenPalace(index) ? '禁区' : (this.isAdvantagePalace(index) ? '优势' : ''))
        .fontSize(10)
        .fontColor('#FFFFFF')
        .backgroundColor(this.isForbiddenPalace(index) ? '#FF6B6B' : '#4ECDC4')
        .padding({ left: 4, right: 4, top: 2, bottom: 2 })
        .borderRadius(4)
        .visibility((this.isForbiddenPalace(index) || this.isAdvantagePalace(index)) ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.getPalaceColor(index))
    .borderRadius(8)
    .padding(4)
  }

  /**
   * 渲染战术解读面板
   */
  @Builder
  buildTacticsPanel() {
    Column({ space: 12 }) {
      Text('战术解读')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2C2416')
        .width('100%')
      
      // 禁区说明
      Column({ space: 6 }) {
        Row({ space: 8 }) {
          Text('●')
            .fontSize(14)
            .fontColor('#FF6B6B')
          Text('禁区（五不可击）')
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        
        Text('包含天乙(值符)、九天、生门、九地、直使五个宫位，为守方优势位置，不可强攻。')
          .fontSize(12)
          .fontColor('#666666')
          .lineHeight(18)
          .width('100%')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FFF5F5')
      .borderRadius(8)
      
      // 优势区说明
      Column({ space: 6 }) {
        Row({ space: 8 }) {
          Text('●')
            .fontSize(14)
            .fontColor('#4ECDC4')
          Text('优势区')
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        
        Text('三吉门(开休生)配合吉星(天心天任天辅)，宜主动进取、发起行动。')
          .fontSize(12)
          .fontColor('#666666')
          .lineHeight(18)
          .width('100%')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F0FFFF')
      .borderRadius(8)
      
      // 观望区说明
      Column({ space: 6 }) {
        Row({ space: 8 }) {
          Text('●')
            .fontSize(14)
            .fontColor('#999999')
          Text('观望区')
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        
        Text('既非禁区也非优势区，需根据具体星门组合判断吉凶，谨慎行事。')
          .fontSize(12)
          .fontColor('#666666')
          .lineHeight(18)
          .width('100%')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F7F7F7')
      .borderRadius(8)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  build() {
    Column({ space: 0 }) {
      NavigationBar({ title: '攻守方位总览' })

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
        Scroll() {
          Column({ space: 16 }) {
            // 时间信息
            Text(`${this.currentDateTime.toLocaleString('zh-CN')}`)
              .fontSize(13)
              .fontColor('#666666')
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 8, bottom: 8 })
            
            // 九宫格
            this.buildNinePalace()
            
            // 战术解读
            this.buildTacticsPanel()
          }
          .width('100%')
          .padding(16)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F1E8')
  }
}
