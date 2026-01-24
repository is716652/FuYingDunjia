import router from '@ohos.router'
import { DunjiaEngine, DunjiaPanResult, DunjiaInput, DunjiaSceneType } from '../utils/DunjiaEngine'
import { DunjiaNineGrid } from '../components/DunjiaNineGrid'
import { DunjiaPalaceDetail } from '../components/DunjiaPalaceDetail'
import { NavigationBar } from '../components/NavigationBar'

/**
 * 奇门遁甲九宫盘页面
 * 职责：页面状态管理、组件组合
 */
@Entry
@Component
struct DunjiaPalacePage {
  @State panResult: DunjiaPanResult | null = null
  @State selectedPalace: number | null = null
  @State loading: boolean = true
  @State currentDateTime: Date = new Date()
  
  private engine: DunjiaEngine = DunjiaEngine.getInstance()

  aboutToAppear() {
    // 从路由参数获取时间信息
    const params = router.getParams() as Record<string, Object>
    if (params && params['dateTime']) {
      this.currentDateTime = params['dateTime'] as Date
    }
    
    // 执行排盘计算
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
        longitude: 116.4074,  // 北京经度，实际应从配置或定位获取
        sceneType: DunjiaSceneType.GENERAL_STUDY  // 普通研习
      }
      
      // 调用排盘引擎（异步）
      this.panResult = await this.engine.computePan(input)
      
      this.loading = false
    } catch (err) {
      console.error('排盘计算失败', err)
      this.loading = false
    }
  }

  /**
   * 宫位点击回调
   */
  private onPalaceClick = (index: number) => {
    if (this.selectedPalace === index) {
      this.selectedPalace = null  // 再次点击取消选中
    } else {
      this.selectedPalace = index
    }
  }

  build() {
    Column({ space: 0 }) {
      // 顶部导航栏
      NavigationBar({ title: '九宬时空盘' })
  
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
        // 主内容区域：使用Scroll包裹，九宫盘和宫位详情垂直排列
        Scroll() {
          Column({ space: 16 }) {
            // 九宫格组件
            DunjiaNineGrid({
              panResult: this.panResult,
              selectedPalace: this.selectedPalace,
              onPalaceClick: this.onPalaceClick
            })

            // 宫位详情组件
            DunjiaPalaceDetail({
              panResult: this.panResult,
              selectedPalace: this.selectedPalace
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)  // 水平左对齐
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .align(Alignment.TopStart)  // Scroll内容从顶部开始
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F1E8')
  }
}
