// SanqiJixiongDetector.ets
// 三奇吉凶检测组件 - 检测三奇相会/分散/入墓状态

import { RulesManager, SanqiDetectionResult, SanqiPalaceInfo, SanqiRumuInfo } from '../utils/RulesManager';

@Component
export struct SanqiJixiongDetector {
  @Prop sanqiPalaces: SanqiPalaceInfo[] = []; // 三奇所在宫位
  @State detectionResult: SanqiDetectionResult | null = null;
  @State isLoading: boolean = false;
  @State showHelp: boolean = false;

  // 宫位名称映射
  private readonly PALACE_NAMES: string[] = ['坎一宫', '坤二宫', '震三宫', '巽四宫', '中五宫', '乾六宫', '兑七宫', '艮八宫', '离九宫'];

  aboutToAppear(): void {
    if (this.sanqiPalaces.length > 0) {
      this.loadDetection();
    }
  }

  private async loadDetection(): Promise<void> {
    this.isLoading = true;
    const manager = RulesManager.getInstance();
    const result = await manager.detectSanqiJixiong(this.sanqiPalaces);
    this.detectionResult = result;
    this.isLoading = false;
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('三奇吉凶检测')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text('❓')
          .fontSize(18)
          .fontColor('#999999')
          .onClick(() => {
            this.showHelp = !this.showHelp;
          })
      }
      .width('100%')
      .padding({ bottom: 12 })

      // 帮助说明
      if (this.showHelp) {
        this.buildHelpSection()
      }

      // 三奇分布图示
      this.buildSanqiDistribution()

      // 检测结果
      if (this.isLoading) {
        this.buildLoadingState()
      } else if (this.detectionResult) {
        this.buildDetectionResult()
      } else {
        this.buildEmptyState()
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  buildHelpSection() {
    Column() {
      Text('三奇吉凶判定规则')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)

      Column() {
        this.buildHelpItem('✅ 三奇相会', '乙丙丁同宫为大吉，事情容易成功')
        this.buildHelpItem('⭐ 双奇相会', '任意两奇同宫为次吉，力量较好')
        this.buildHelpItem('⚠️ 三奇分散', '三奇分散不聚，力量减弱')
        this.buildHelpItem('❌ 三奇入墓', '三奇落入墓库宫位，最为凶险')
      }
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F8F8F8')
    .borderRadius(8)
    .margin({ bottom: 12 })
  }

  @Builder
  buildHelpItem(title: string, desc: string) {
    Row() {
      Text(title)
        .fontSize(13)
        .fontColor('#333333')
        .width(80)
      Text(desc)
        .fontSize(12)
        .fontColor('#666666')
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 4, bottom: 4 })
  }

  @Builder
  buildSanqiDistribution() {
    Column() {
      Text('三奇分布')
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(this.sanqiPalaces, (info: SanqiPalaceInfo) => {
          this.buildSanqiChip(info)
        })
      }
      .width('100%')
    }
    .width('100%')
    .margin({ bottom: 16 })
  }

  @Builder
  buildSanqiChip(info: SanqiPalaceInfo) {
    Row() {
      Text(this.getQiDisplayName(info.qi))
        .fontSize(14)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Medium)

      Text(' → ')
        .fontSize(12)
        .fontColor('#FFFFFF')

      Text(info.palaceName)
        .fontSize(12)
        .fontColor('#FFFFFF')
    }
    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    .backgroundColor(this.getQiColor(info.qi))
    .borderRadius(16)
    .margin({ right: 8, bottom: 8 })
  }

  @Builder
  buildLoadingState() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
      Text('正在检测...')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .height(120)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildEmptyState() {
    Column() {
      Text('暂无检测数据')
        .fontSize(14)
        .fontColor('#999999')
      Text('请确认三奇宫位信息')
        .fontSize(12)
        .fontColor('#CCCCCC')
        .margin({ top: 4 })
    }
    .width('100%')
    .height(80)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildDetectionResult() {
    Column() {
      // 总体判定
      this.buildOverallJudgment()

      // 相会状态
      this.buildHuiStatus()

      // 入墓检测
      if (this.detectionResult && this.detectionResult.hasRumu) {
        this.buildRumuWarning()
      }

      // 建议
      this.buildAdvice()
    }
    .width('100%')
  }

  @Builder
  buildOverallJudgment() {
    if (this.detectionResult) {
      Row() {
        Column() {
          Text(this.getFortuneIcon(this.detectionResult.fortuneLevel))
            .fontSize(32)
          Text(this.detectionResult.overallFortune)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getFortuneColor(this.detectionResult.fortuneLevel))
            .margin({ top: 4 })
        }

        Column() {
          Text(this.detectionResult.huiType)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          Text(this.detectionResult.huiDescription)
            .fontSize(13)
            .fontColor('#666666')
            .margin({ top: 4 })
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 16 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(this.getFortuneBackgroundColor(this.detectionResult.fortuneLevel))
      .borderRadius(12)
    }
  }

  @Builder
  buildHuiStatus() {
    if (this.detectionResult) {
      Column() {
        Row() {
          Text('相会状态')
            .fontSize(14)
            .fontColor('#666666')
          Blank()
          Text(this.detectionResult.isXianghui ? '已相会' : '未相会')
            .fontSize(14)
            .fontColor(this.detectionResult.isXianghui ? '#52C41A' : '#FF4D4F')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')

        // 相会数量指示
        Row() {
          ForEach([1, 2, 3], (i: number) => {
            Column()
              .width(40)
              .height(8)
              .backgroundColor(i <= this.detectionResult!.huiCount ? '#52C41A' : '#E0E0E0')
              .borderRadius(4)
              .margin({ right: i < 3 ? 8 : 0 })
          })
          Text(`${this.detectionResult.huiCount}/3`)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ left: 12 })
        }
        .margin({ top: 8 })
      }
      .width('100%')
      .padding(12)
      .margin({ top: 12 })
      .backgroundColor('#FAFAFA')
      .borderRadius(8)
    }
  }

  @Builder
  buildRumuWarning() {
    if (this.detectionResult) {
      Column() {
        Row() {
          Text('⚠️')
            .fontSize(16)
          Text('入墓警告')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FF4D4F')
            .margin({ left: 8 })
        }
        .width('100%')

        ForEach(this.detectionResult.rumuList, (rumu: SanqiRumuInfo) => {
          Row() {
            Text(`${rumu.qiName}(${rumu.qi})`)
              .fontSize(13)
              .fontColor('#333333')
            Text(' → ')
              .fontColor('#999999')
            Text(rumu.palace)
              .fontSize(13)
              .fontColor('#FF4D4F')
          }
          .width('100%')
          .margin({ top: 8 })

          Text(rumu.reason)
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 2, left: 16 })
        })
      }
      .width('100%')
      .padding(12)
      .margin({ top: 12 })
      .backgroundColor('#FFF2F0')
      .borderRadius(8)
      .border({ width: 1, color: '#FFCCC7' })
    }
  }

  @Builder
  buildAdvice() {
    if (this.detectionResult) {
      Column() {
        Text('行动建议')
          .fontSize(14)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)

        ForEach(this.detectionResult.advice, (advice: string, index: number) => {
          Row() {
            Text(`${index + 1}.`)
              .fontSize(13)
              .fontColor('#999999')
              .width(20)
            Text(advice)
              .fontSize(13)
              .fontColor('#333333')
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ top: 6 })
        })
      }
      .width('100%')
      .padding(12)
      .margin({ top: 12 })
      .backgroundColor('#F6FFED')
      .borderRadius(8)
    }
  }

  private getQiDisplayName(qi: string): string {
    const nameMap = new Map<string, string>([
      ['乙', '日奇·乙'],
      ['丙', '月奇·丙'],
      ['丁', '星奇·丁']
    ]);
    const name = nameMap.get(qi);
    return name ? name : qi;
  }

  private getQiColor(qi: string): string {
    const colorMap = new Map<string, string>([
      ['乙', '#52C41A'],
      ['丙', '#FA8C16'],
      ['丁', '#EB2F96']
    ]);
    const color = colorMap.get(qi);
    return color ? color : '#666666';
  }

  private getFortuneIcon(level: number): string {
    if (level >= 5) {
      return '🎉';
    }
    if (level === 4) {
      return '✨';
    }
    if (level === 3) {
      return '⚖️';
    }
    if (level === 2) {
      return '⚠️';
    }
    return '💀';
  }

  private getFortuneColor(level: number): string {
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

  private getFortuneBackgroundColor(level: number): string {
    if (level >= 5) {
      return '#FFF0F0';
    }
    if (level === 4) {
      return '#FFF7E6';
    }
    if (level === 3) {
      return '#E6F7FF';
    }
    if (level === 2) {
      return '#F5F5F5';
    }
    return '#F5F5F5';
  }
}
