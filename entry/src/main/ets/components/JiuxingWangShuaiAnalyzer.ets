// JiuxingWangShuaiAnalyzer.ets
// 九星休旺智能分析组件 - 根据月令自动计算九星的旺相休囚死状态

import { RulesManager, WangshuaiAnalysisResult } from '../utils/RulesManager';

@Component
export struct JiuxingWangShuaiAnalyzer {
  @Prop monthZhi: string = ''; // 当前月份地支
  @State analysisResults: WangshuaiAnalysisResult[] = [];
  @State isLoading: boolean = false;
  @State selectedStar: WangshuaiAnalysisResult | null = null;
  @State showDetail: boolean = false;

  // 状态图标映射
  private readonly STATE_ICONS: Map<string, string> = new Map([
    ['wang', '🔥'],
    ['xiang', '⭐'],
    ['xiu', '💤'],
    ['qiu', '🔒'],
    ['si', '💀']
  ]);

  aboutToAppear(): void {
    if (this.monthZhi) {
      this.loadAnalysis();
    }
  }

  private async loadAnalysis(): Promise<void> {
    this.isLoading = true;
    const manager = RulesManager.getInstance();
    const results = await manager.analyzeAllStarsWangshuai(this.monthZhi);
    this.analysisResults = results;
    this.isLoading = false;
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('九星休旺分析')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        if (this.monthZhi) {
          Text(`${this.monthZhi}月`)
            .fontSize(14)
            .fontColor('#666666')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#F5F5F5')
            .borderRadius(4)
        }
      }
      .width('100%')
      .padding({ bottom: 12 })

      // 状态图例说明
      this.buildLegend()

      // 分析结果网格
      if (this.isLoading) {
        this.buildLoadingState()
      } else if (this.analysisResults.length === 0) {
        this.buildEmptyState()
      } else {
        this.buildResultGrid()
      }

      // 详情弹窗
      if (this.showDetail && this.selectedStar) {
        this.buildDetailOverlay()
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  buildLegend() {
    Row() {
      this.buildLegendItem('旺', '#FF4444', '🔥')
      this.buildLegendItem('相', '#FF8800', '⭐')
      this.buildLegendItem('休', '#4488FF', '💤')
      this.buildLegendItem('囚', '#888888', '🔒')
      this.buildLegendItem('死', '#444444', '💀')
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ top: 8, bottom: 16 })
  }

  @Builder
  buildLegendItem(name: string, color: string, icon: string) {
    Row() {
      Text(icon)
        .fontSize(12)
      Text(name)
        .fontSize(12)
        .fontColor(color)
        .margin({ left: 4 })
    }
  }

  @Builder
  buildLoadingState() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
      Text('正在分析...')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildEmptyState() {
    Column() {
      Text('暂无分析数据')
        .fontSize(14)
        .fontColor('#999999')
      Text('请确认已选择月份')
        .fontSize(12)
        .fontColor('#CCCCCC')
        .margin({ top: 4 })
    }
    .width('100%')
    .height(100)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildResultGrid() {
    Grid() {
      ForEach(this.analysisResults, (result: WangshuaiAnalysisResult) => {
        GridItem() {
          this.buildStarCard(result)
        }
      })
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsGap(12)
    .columnsGap(12)
    .width('100%')
  }

  @Builder
  buildStarCard(result: WangshuaiAnalysisResult) {
    Column() {
      // 状态图标
      Text(this.getStateIcon(result.currentState))
        .fontSize(24)

      // 星名
      Text(result.starName)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .margin({ top: 4 })

      // 五行
      Text(result.starElement)
        .fontSize(11)
        .fontColor('#888888')
        .margin({ top: 2 })

      // 状态标签
      Text(result.stateName)
        .fontSize(13)
        .fontColor('#FFFFFF')
        .backgroundColor(result.stateColor)
        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
        .borderRadius(4)
        .margin({ top: 6 })

      // 力量等级条
      this.buildFortuneBar(result.fortuneLevel)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FAFAFA')
    .borderRadius(8)
    .border({ width: 1, color: '#EEEEEE' })
    .onClick(() => {
      this.selectedStar = result;
      this.showDetail = true;
    })
  }

  @Builder
  buildFortuneBar(level: number) {
    Row() {
      ForEach([1, 2, 3, 4, 5], (i: number) => {
        Column()
          .width(12)
          .height(4)
          .backgroundColor(i <= level ? this.getLevelColor(level) : '#E0E0E0')
          .borderRadius(2)
          .margin({ right: i < 5 ? 2 : 0 })
      })
    }
    .margin({ top: 8 })
  }

  @Builder
  buildDetailOverlay() {
    Stack() {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000066')
        .onClick(() => {
          this.showDetail = false;
        })

      // 详情卡片
      Column() {
        // 关闭按钮
        Row() {
          Blank()
          Text('✕')
            .fontSize(20)
            .fontColor('#999999')
            .onClick(() => {
              this.showDetail = false;
            })
        }
        .width('100%')

        if (this.selectedStar) {
          // 星名和状态
          Text(this.selectedStar.starName)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Row() {
            Text(this.selectedStar.starElement + '星')
              .fontSize(14)
              .fontColor('#666666')
            Text(' · ')
              .fontColor('#CCCCCC')
            Text(this.selectedStar.stateName)
              .fontSize(14)
              .fontColor(this.selectedStar.stateColor)
              .fontWeight(FontWeight.Medium)
          }
          .margin({ top: 8 })

          // 分隔线
          Divider()
            .strokeWidth(1)
            .color('#EEEEEE')
            .margin({ top: 16, bottom: 16 })

          // 当前月令
          Row() {
            Text('当前月令')
              .fontSize(14)
              .fontColor('#666666')
            Blank()
            Text(`${this.selectedStar.currentMonthZhi}月 (${this.selectedStar.seasonDesc})`)
              .fontSize(14)
              .fontColor('#333333')
          }
          .width('100%')

          // 原因说明
          Column() {
            Text('状态解析')
              .fontSize(14)
              .fontColor('#666666')
              .alignSelf(ItemAlign.Start)
            Text(this.selectedStar.reason)
              .fontSize(14)
              .fontColor('#333333')
              .margin({ top: 8 })
              .lineHeight(22)
          }
          .width('100%')
          .margin({ top: 16 })
          .padding(12)
          .backgroundColor('#F8F8F8')
          .borderRadius(8)

          // 力量等级
          Row() {
            Text('力量等级')
              .fontSize(14)
              .fontColor('#666666')
            Blank()
            this.buildFortuneBarLarge(this.selectedStar.fortuneLevel)
          }
          .width('100%')
          .margin({ top: 16 })
        }
      }
      .width('85%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }

  @Builder
  buildFortuneBarLarge(level: number) {
    Row() {
      ForEach([1, 2, 3, 4, 5], (i: number) => {
        Column()
          .width(20)
          .height(8)
          .backgroundColor(i <= level ? this.getLevelColor(level) : '#E0E0E0')
          .borderRadius(4)
          .margin({ right: i < 5 ? 4 : 0 })
      })
    }
  }

  private getStateIcon(state: string): string {
    const icon = this.STATE_ICONS.get(state);
    return icon ? icon : '❓';
  }

  private getLevelColor(level: number): string {
    if (level >= 5) {
      return '#FF4444';
    }
    if (level === 4) {
      return '#FF8800';
    }
    if (level === 3) {
      return '#4488FF';
    }
    if (level === 2) {
      return '#888888';
    }
    return '#444444';
  }
}
