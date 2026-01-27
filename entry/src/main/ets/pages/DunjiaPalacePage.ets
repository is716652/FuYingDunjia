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
    if (params && params['timestamp']) {
      // 接收时间戳并重建 Date 对象
      const timestamp = params['timestamp'] as number
      this.currentDateTime = new Date(timestamp)
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

  /**
   * 调整时间
   */
  private adjustTime(hours: number) {
    const newDateTime = new Date(this.currentDateTime.getTime() + hours * 60 * 60 * 1000);
    this.currentDateTime = newDateTime;
    this.selectedPalace = null; // 清除选中状态
    this.computePan();
  }

  /**
   * 恢复到当前系统时间
   */
  private resetToCurrentTime() {
    this.currentDateTime = new Date();
    this.selectedPalace = null;
    this.computePan();
  }

  /**
   * 切换时辰（跳转到指定时辰的起始时刻）
   */
  private switchToShichen(shiIndex: number) {
    interface ShichenInfo {
      name: string;
      hour: number;
    }

    const shiMap: ShichenInfo[] = [
      { name: '子时', hour: 23 },
      { name: '丑时', hour: 1 },
      { name: '寅时', hour: 3 },
      { name: '卯时', hour: 5 },
      { name: '辰时', hour: 7 },
      { name: '巳时', hour: 9 },
      { name: '午时', hour: 11 },
      { name: '未时', hour: 13 },
      { name: '申时', hour: 15 },
      { name: '酉时', hour: 17 },
      { name: '戌时', hour: 19 },
      { name: '亥时', hour: 21 }
    ];
    
    if (shiIndex >= 0 && shiIndex < shiMap.length) {
      const targetHour = shiMap[shiIndex].hour;
      const newDateTime = new Date(this.currentDateTime);
      newDateTime.setHours(targetHour, 0, 0, 0); // 设置为时辰起始时刻
      this.currentDateTime = newDateTime;
      this.selectedPalace = null;
      this.computePan();
    }
  }

  build() {
    Column({ space: 0 }) {
      // 顶部导航栏
      NavigationBar({ title: '九宫时空盘' })
  
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
            // 时间调整按钮组
            Column({ space: 12 }) {
              Row({ space: 8 }) {
                Text('⏰ 时间微调')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2C2416')
                  .layoutWeight(1)
                
                Button('恢复当前')
                  .fontSize(12)
                  .backgroundColor('#4A90E2')
                  .fontColor('#FFFFFF')
                  .height(32)
                  .padding({ left: 12, right: 12 })
                  .onClick(() => this.resetToCurrentTime())
              }
              .width('100%')
              
              // 第一行：减少时间
              Row({ space: 8 }) {
                Button('-2时辰')
                  .fontSize(13)
                  .backgroundColor('#F5F1E8')
                  .fontColor('#666666')
                  .layoutWeight(1)
                  .height(38)
                  .onClick(() => this.adjustTime(-4))
                
                Button('-1时辰')
                  .fontSize(13)
                  .backgroundColor('#F5F1E8')
                  .fontColor('#666666')
                  .layoutWeight(1)
                  .height(38)
                  .onClick(() => this.adjustTime(-2))
                
                Button('-1小时')
                  .fontSize(13)
                  .backgroundColor('#F5F1E8')
                  .fontColor('#666666')
                  .layoutWeight(1)
                  .height(38)
                  .onClick(() => this.adjustTime(-1))
              }
              .width('100%')
              
              // 第二行：增加时间
              Row({ space: 8 }) {
                Button('+1小时')
                  .fontSize(13)
                  .backgroundColor('#D4A574')
                  .fontColor('#FFFFFF')
                  .layoutWeight(1)
                  .height(38)
                  .onClick(() => this.adjustTime(1))
                
                Button('+1时辰')
                  .fontSize(13)
                  .backgroundColor('#D4A574')
                  .fontColor('#FFFFFF')
                  .layoutWeight(1)
                  .height(38)
                  .onClick(() => this.adjustTime(2))
                
                Button('+2时辰')
                  .fontSize(13)
                  .backgroundColor('#D4A574')
                  .fontColor('#FFFFFF')
                  .layoutWeight(1)
                  .height(38)
                  .onClick(() => this.adjustTime(4))
              }
              .width('100%')
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .backgroundColor('#ffffff')
            .borderRadius(12)
            .shadow({ radius: 8, color: '#22000000', offsetX: 0, offsetY: 2 })

            // 功能导航按钮
            Row({ space: 8 }) {
              Button('攻守方位')
                .fontSize(13)
                .backgroundColor('#4ECDC4')
                .fontColor('#FFFFFF')
                .layoutWeight(1)
                .height(40)
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/AttackDefensePage',
                    params: {
                      timestamp: this.currentDateTime.getTime()
                    }
                  })
                })
              
              Button('值符值使历史')
                .fontSize(13)
                .backgroundColor('#9B59B6')
                .fontColor('#FFFFFF')
                .layoutWeight(1)
                .height(40)
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/ZhiFuZhiShiHistoryPage',
                    params: {
                      timestamp: this.currentDateTime.getTime()
                    }
                  })
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })

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
