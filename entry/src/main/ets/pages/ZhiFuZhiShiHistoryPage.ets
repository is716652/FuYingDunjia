import { NavigationBar } from '../components/NavigationBar'
import router from '@ohos.router'
import { DunjiaEngine, DunjiaPanResult, DunjiaInput, DunjiaSceneType } from '../utils/DunjiaEngine'

/**
 * 值符值使历史追踪页
 * 功能：12时辰值符值使值使门动态演化追踪
 */
@Entry
@Component
struct ZhiFuZhiShiHistoryPage {
  @State historyData: ZhiData[] = []
  @State loading: boolean = true
  @State currentDate: Date = new Date()
  
  private engine: DunjiaEngine = DunjiaEngine.getInstance()

  aboutToAppear() {
    // 从路由参数获取日期信息
    const params = router.getParams() as Record<string, Object>
    if (params && params['timestamp']) {
      const timestamp = params['timestamp'] as number
      this.currentDate = new Date(timestamp)
    }
    
    this.computeHistory()
  }

  /**
   * 计算12时辰历史数据
   */
  private async computeHistory() {
    try {
      this.loading = true
      this.historyData = []
      
      const baseDate = new Date(this.currentDate)
      baseDate.setHours(0, 0, 0, 0)
      
      // 12时辰：子丑寅卯辰巳午未申酉戌亥
      const shiChens = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥']
      
      for (let i = 0; i < 12; i++) {
        const hourStart = (i * 2 + 23) % 24
        const targetDate = new Date(baseDate)
        
        if (hourStart === 23) {
          targetDate.setDate(targetDate.getDate() - 1)
        }
        targetDate.setHours(hourStart, 0, 0, 0)
        
        const input: DunjiaInput = {
          dateTime: targetDate,
          longitude: 116.4074,
          sceneType: DunjiaSceneType.GENERAL_STUDY
        }
        
        const panResult = await this.engine.computePan(input)
        
        this.historyData.push({
          shichen: shiChens[i],
          timeRange: this.getTimeRange(i),
          zhiFuName: panResult.palaces[panResult.zhiFuPalace].starName || '',
          zhiFuPalace: panResult.palaces[panResult.zhiFuPalace].palaceName,
          zhiShiName: panResult.palaces[panResult.zhiShiPalace].doorName || '',
          zhiShiPalace: panResult.palaces[panResult.zhiShiPalace].palaceName,
          juLabel: panResult.juLabel
        })
      }
      
      this.loading = false
    } catch (err) {
      console.error('值符值使历史计算失败', err)
      this.loading = false
    }
  }

  /**
   * 获取时辰时间范围
   */
  private getTimeRange(index: number): string {
    const hourStart = (index * 2 + 23) % 24
    const hourEnd = (hourStart + 2) % 24
    return `${this.formatHour(hourStart)}-${this.formatHour(hourEnd)}`
  }

  /**
   * 格式化小时
   */
  private formatHour(hour: number): string {
    return hour.toString().padStart(2, '0') + ':00'
  }

  /**
   * 渲染历史列表
   */
  @Builder
  buildHistoryList() {
    Column({ space: 0 }) {
      ForEach(this.historyData, (item: ZhiData, index: number) => {
        this.buildHistoryItem(item, index)
      })
    }
    .width('100%')
  }

  /**
   * 渲染单条历史记录
   */
  @Builder
  buildHistoryItem(item: ZhiData, index: number) {
    Column({ space: 8 }) {
      // 时辰标题
      Row({ space: 12 }) {
        Text(item.shichen + '时')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C2416')
        
        Text(item.timeRange)
          .fontSize(13)
          .fontColor('#666666')
        
        Text(item.juLabel)
          .fontSize(13)
          .fontColor('#666666')
      }
      .width('100%')
      
      // 值符值使信息
      Row({ space: 16 }) {
        Column({ space: 4 }) {
          Text('值符')
            .fontSize(12)
            .fontColor('#999999')
          Text(item.zhiFuName)
            .fontSize(14)
            .fontColor('#2C2416')
            .fontWeight(FontWeight.Medium)
          Text(item.zhiFuPalace)
            .fontSize(12)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        Column({ space: 4 }) {
          Text('值使')
            .fontSize(12)
            .fontColor('#999999')
          Text(item.zhiShiName)
            .fontSize(14)
            .fontColor('#2C2416')
            .fontWeight(FontWeight.Medium)
          Text(item.zhiShiPalace)
            .fontSize(12)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      
      // 分隔线
      if (index < this.historyData.length - 1) {
        Divider()
          .color('#E0E0E0')
          .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(index % 2 === 0 ? '#FFFFFF' : '#F9F9F9')
  }

  build() {
    Column({ space: 0 }) {
      NavigationBar({ title: '值符值使历史追踪' })

      if (this.loading) {
        Column() {
          Text('计算中...')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Column({ space: 12 }) {
          // 日期信息
          Text(`${this.currentDate.toLocaleDateString('zh-CN')}`)
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding({ top: 12, bottom: 8 })
          
          // 说明文字
          Text('12时辰值符值使动态演化')
            .fontSize(13)
            .fontColor('#999999')
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding({ bottom: 8 })
          
          // 历史列表
          Scroll() {
            this.buildHistoryList()
          }
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
          .edgeEffect(EdgeEffect.Spring)
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F1E8')
  }
}

/**
 * 值符值使数据结构
 */
interface ZhiData {
  shichen: string
  timeRange: string
  zhiFuName: string
  zhiFuPalace: string
  zhiShiName: string
  zhiShiPalace: string
  juLabel: string
}
