// BugangVisualizer.ets
// 步罡图形化展示组件 - 可视化七步罡路线

import { common } from '@kit.AbilityKit';
import { buffer, JSON as ArkJSON } from '@kit.ArkTS';

// 接口定义
interface StepInfo {
  step: number;
  action: string;
  footwork: string;
  direction: string;
  description: string;
  positionX: number;
  positionY: number;
}

interface QibugangInfo {
  name: string;
  totalSteps: number;
  purpose: string;
  steps: StepInfo[];
}

interface StarInfo {
  name: string;
  alias: string;
  position: number;
  x: number;
  y: number;
  meaning: string;
}

interface BeidouGangInfo {
  name: string;
  description: string;
  stars: StarInfo[];
  pathType: string;
  symbolMeaning: string;
}

interface PalacePosition {
  palace: number;
  name: string;
  x: number;
  y: number;
  direction: string;
}

interface RouteInfo {
  id: string;
  name: string;
  description: string;
  sequence: number[];
  usage: string;
}

interface JiugongGangInfo {
  name: string;
  description: string;
  palaceOrder: number[];
  palaceNames: string[];
  palacePositions: PalacePosition[];
  routes: RouteInfo[];
}

interface PracticeGuideInfo {
  preparation: string[];
  execution: string[];
  completion: string[];
}

interface VisualizationConfig {
  gridSize: number;
  cellSize: number;
  pathColor: string;
  stepColor: string;
  currentStepColor: string;
  animationDuration: number;
  showStepNumbers: boolean;
  showDirections: boolean;
}

interface BugangRules {
  title: string;
  description: string;
  qibugang: QibugangInfo;
  beidouGang: BeidouGangInfo;
  jiugongGang: JiugongGangInfo;
  practiceGuide: PracticeGuideInfo;
  visualizationConfig: VisualizationConfig;
}

@Component
export struct BugangVisualizer {
  @State rules: BugangRules | null = null;
  @State isLoading: boolean = false;
  @State selectedMode: number = 0; // 0: 七步罡, 1: 北斗罡, 2: 九宫罡
  @State currentStep: number = 0;
  @State isAnimating: boolean = false;
  @State showGuide: boolean = false;
  @State selectedRoute: string = 'yangshun'; // 阳顺/阴逆
  private context: common.Context | null = null;
  private animationTimer: number = -1;

  private readonly MODES: string[] = ['七步罡', '北斗七星罡', '九宫步罡'];
  private readonly CELL_SIZE: number = 70;
  private readonly GRID_GAP: number = 4;

  aboutToAppear(): void {
    this.context = getContext(this) as common.Context;
    this.loadRules();
  }

  aboutToDisappear(): void {
    this.stopAnimation();
  }

  private async loadRules(): Promise<void> {
    if (!this.context) {
      return;
    }
    this.isLoading = true;
    try {
      const value = await this.context.resourceManager.getRawFileContent('rules/bugang_rules.json');
      const str = buffer.from(value.buffer).toString();
      this.rules = ArkJSON.parse(str) as BugangRules;
    } catch (err) {
      console.error('Failed to load bugang rules:', err);
    }
    this.isLoading = false;
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('步罡踏斗')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text('📖')
          .fontSize(18)
          .onClick(() => {
            this.showGuide = !this.showGuide;
          })
      }
      .width('100%')
      .padding({ bottom: 8 })

      // 副标题
      if (this.rules) {
        Text(this.rules.description)
          .fontSize(12)
          .fontColor('#666666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 12 })
      }

      // 练习指南
      if (this.showGuide) {
        this.buildPracticeGuide()
      }

      // 模式切换
      this.buildModeTabs()

      // 可视化区域
      if (this.isLoading) {
        this.buildLoadingState()
      } else if (this.rules) {
        this.buildVisualization()
      }

      // 控制按钮
      if (this.rules) {
        this.buildControls()
      }

      // 步骤详情
      if (this.rules && this.selectedMode === 0) {
        this.buildStepDetail()
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  buildPracticeGuide() {
    Column() {
      if (this.rules && this.rules.practiceGuide) {
        // 准备
        Text('准备事项')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1890FF')
          .alignSelf(ItemAlign.Start)

        ForEach(this.rules.practiceGuide.preparation, (item: string, index: number) => {
          Row() {
            Text(`${index + 1}.`)
              .fontSize(12)
              .fontColor('#1890FF')
              .width(20)
            Text(item)
              .fontSize(12)
              .fontColor('#333333')
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ top: 4 })
        })

        Divider().margin({ top: 12, bottom: 12 })

        // 执行
        Text('执行要点')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#52C41A')
          .alignSelf(ItemAlign.Start)

        ForEach(this.rules.practiceGuide.execution, (item: string, index: number) => {
          Row() {
            Text(`${index + 1}.`)
              .fontSize(12)
              .fontColor('#52C41A')
              .width(20)
            Text(item)
              .fontSize(12)
              .fontColor('#333333')
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ top: 4 })
        })

        Divider().margin({ top: 12, bottom: 12 })

        // 收功
        Text('收功')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#722ED1')
          .alignSelf(ItemAlign.Start)

        ForEach(this.rules.practiceGuide.completion, (item: string, index: number) => {
          Row() {
            Text(`${index + 1}.`)
              .fontSize(12)
              .fontColor('#722ED1')
              .width(20)
            Text(item)
              .fontSize(12)
              .fontColor('#333333')
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ top: 4 })
        })
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F0F5FF')
    .borderRadius(8)
    .margin({ bottom: 12 })
    .border({ width: 1, color: '#ADC6FF' })
  }

  @Builder
  buildModeTabs() {
    Row() {
      ForEach(this.MODES, (mode: string, index: number) => {
        Text(mode)
          .fontSize(13)
          .fontColor(this.selectedMode === index ? '#FFFFFF' : '#666666')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.selectedMode === index ? '#722ED1' : '#F5F5F5')
          .borderRadius(16)
          .margin({ right: 8 })
          .onClick(() => {
            this.selectedMode = index;
            this.currentStep = 0;
            this.stopAnimation();
          })
      })
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  @Builder
  buildLoadingState() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
      Text('加载中...')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildVisualization() {
    Column() {
      if (this.selectedMode === 0) {
        this.buildQibugangVisualization()
      } else if (this.selectedMode === 1) {
        this.buildBeidouVisualization()
      } else {
        this.buildJiugongVisualization()
      }
    }
    .width('100%')
    .height(280)
    .backgroundColor('#FAFAFA')
    .borderRadius(8)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildQibugangVisualization() {
    if (this.rules && this.rules.qibugang) {
      Column() {
        // 可视化画布
        Stack() {
          // 绘制路径连线
          ForEach(this.rules.qibugang.steps, (step: StepInfo, index: number) => {
            if (index < this.rules!.qibugang.steps.length - 1) {
              this.buildPathLine(step, this.rules!.qibugang.steps[index + 1], index < this.currentStep)
            }
          })

          // 绘制步骤点
          ForEach(this.rules.qibugang.steps, (step: StepInfo, index: number) => {
            this.buildStepPoint(step, index)
          })
        }
        .width(300)
        .height(200)

        // 当前步骤提示
        if (this.currentStep > 0 && this.currentStep <= this.rules.qibugang.steps.length) {
          Text(`第${this.currentStep}步: ${this.rules.qibugang.steps[this.currentStep - 1].action}`)
            .fontSize(14)
            .fontColor('#722ED1')
            .fontWeight(FontWeight.Medium)
            .margin({ top: 12 })
        }
      }
    }
  }

  @Builder
  buildPathLine(from: StepInfo, to: StepInfo, isActive: boolean) {
    Line()
      .width(Math.abs(to.positionX - from.positionX) * 50 + 10)
      .height(Math.abs(to.positionY - from.positionY) * 50 + 10)
      .startPoint([from.positionX * 50 + 20, from.positionY * 40 + 20])
      .endPoint([to.positionX * 50 + 20, to.positionY * 40 + 20])
      .stroke(isActive ? '#722ED1' : '#CCCCCC')
      .strokeWidth(2)
      .strokeDashArray(isActive ? [] : [5, 5])
  }

  @Builder
  buildStepPoint(step: StepInfo, index: number) {
    Column() {
      Text(`${step.step}`)
        .fontSize(12)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
    }
    .width(30)
    .height(30)
    .backgroundColor(this.getStepColor(index))
    .borderRadius(15)
    .justifyContent(FlexAlign.Center)
    .position({
      x: step.positionX * 50 + 20,
      y: step.positionY * 40 + 20
    })
    .shadow({ radius: 4, color: '#00000033' })
  }

  @Builder
  buildBeidouVisualization() {
    if (this.rules && this.rules.beidouGang) {
      Column() {
        Text(this.rules.beidouGang.symbolMeaning)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ bottom: 12 })

        Stack() {
          // 绘制星星连线
          ForEach(this.rules.beidouGang.stars, (star: StarInfo, index: number) => {
            if (index < this.rules!.beidouGang.stars.length - 1) {
              this.buildStarLine(star, this.rules!.beidouGang.stars[index + 1], index < this.currentStep)
            }
          })

          // 绘制星星点
          ForEach(this.rules.beidouGang.stars, (star: StarInfo, index: number) => {
            this.buildStarPoint(star, index)
          })
        }
        .width(300)
        .height(180)
      }
    }
  }

  @Builder
  buildStarLine(from: StarInfo, to: StarInfo, isActive: boolean) {
    // 简化的线条表示
    Line()
      .startPoint([from.x * 40 + 10, from.y * 35 + 10])
      .endPoint([to.x * 40 + 10, to.y * 35 + 10])
      .stroke(isActive ? '#FFD700' : '#CCCCCC')
      .strokeWidth(2)
  }

  @Builder
  buildStarPoint(star: StarInfo, index: number) {
    Column() {
      Text('★')
        .fontSize(index === this.currentStep ? 24 : 18)
        .fontColor(this.getStarColor(index))
      Text(star.name)
        .fontSize(10)
        .fontColor('#333333')
    }
    .position({
      x: star.x * 40,
      y: star.y * 35
    })
  }

  @Builder
  buildJiugongVisualization() {
    if (this.rules && this.rules.jiugongGang) {
      Column() {
        // 路线选择
        Row() {
          ForEach(this.rules.jiugongGang.routes, (route: RouteInfo) => {
            Text(route.name)
              .fontSize(12)
              .fontColor(this.selectedRoute === route.id ? '#FFFFFF' : '#666666')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor(this.selectedRoute === route.id ? '#722ED1' : '#F0F0F0')
              .borderRadius(12)
              .margin({ right: 8 })
              .onClick(() => {
                this.selectedRoute = route.id;
                this.currentStep = 0;
                this.stopAnimation();
              })
          })
        }
        .margin({ bottom: 12 })

        // 九宫格
        Grid() {
          ForEach(this.getJiugongOrder(), (palaceIndex: number) => {
            GridItem() {
              this.buildJiugongCell(palaceIndex)
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr 1fr')
        .width(this.CELL_SIZE * 3 + this.GRID_GAP * 2)
        .height(this.CELL_SIZE * 3 + this.GRID_GAP * 2)
        .columnsGap(this.GRID_GAP)
        .rowsGap(this.GRID_GAP)
      }
    }
  }

  @Builder
  buildJiugongCell(palaceIndex: number) {
    Column() {
      Text(this.getPalaceName(palaceIndex))
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isJiugongCurrentStep(palaceIndex) ? '#FFFFFF' : (this.isJiugongPassed(palaceIndex) ? '#722ED1' : '#333333'))

      Text(this.getPalaceDirection(palaceIndex))
        .fontSize(11)
        .fontColor(this.isJiugongCurrentStep(palaceIndex) ? '#FFFFFF' : '#666666')
        .margin({ top: 4 })

      if (this.getStepInRoute(palaceIndex) >= 0) {
        Text(`${this.getStepInRoute(palaceIndex) + 1}`)
          .fontSize(10)
          .fontColor(this.isJiugongCurrentStep(palaceIndex) ? '#FFD700' : (this.isJiugongPassed(palaceIndex) ? '#722ED1' : '#999999'))
          .margin({ top: 4 })
      }
    }
    .width(this.CELL_SIZE)
    .height(this.CELL_SIZE)
    .backgroundColor(this.isJiugongCurrentStep(palaceIndex) ? '#722ED1' : (this.isJiugongPassed(palaceIndex) ? '#F0E6FF' : '#FFFFFF'))
    .borderRadius(8)
    .justifyContent(FlexAlign.Center)
    .border({ width: 1, color: this.isJiugongPassed(palaceIndex) ? '#722ED1' : '#E8E8E8' })
  }

  @Builder
  buildControls() {
    Row() {
      // 上一步
      Button('上一步')
        .fontSize(13)
        .fontColor('#666666')
        .backgroundColor('#F5F5F5')
        .height(36)
        .layoutWeight(1)
        .enabled(this.currentStep > 0)
        .onClick(() => {
          this.stopAnimation();
          if (this.currentStep > 0) {
            this.currentStep--;
          }
        })

      // 播放/暂停
      Button(this.isAnimating ? '暂停' : '播放')
        .fontSize(13)
        .fontColor('#FFFFFF')
        .backgroundColor('#722ED1')
        .height(36)
        .layoutWeight(1)
        .margin({ left: 8, right: 8 })
        .onClick(() => {
          if (this.isAnimating) {
            this.stopAnimation();
          } else {
            this.startAnimation();
          }
        })

      // 下一步
      Button('下一步')
        .fontSize(13)
        .fontColor('#666666')
        .backgroundColor('#F5F5F5')
        .height(36)
        .layoutWeight(1)
        .enabled(this.currentStep < this.getMaxSteps())
        .onClick(() => {
          this.stopAnimation();
          if (this.currentStep < this.getMaxSteps()) {
            this.currentStep++;
          }
        })
    }
    .width('100%')
    .margin({ top: 12 })

    // 重置按钮
    Button('重置')
      .fontSize(13)
      .fontColor('#FF4D4F')
      .backgroundColor('#FFF1F0')
      .width('100%')
      .height(36)
      .margin({ top: 8 })
      .onClick(() => {
        this.stopAnimation();
        this.currentStep = 0;
      })
  }

  @Builder
  buildStepDetail() {
    if (this.rules && this.rules.qibugang && this.currentStep > 0 && this.currentStep <= this.rules.qibugang.steps.length) {
      Column() {
        Row() {
          Text(`第${this.getCurrentStepInfo().step}步`)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#722ED1')

          Text(this.getCurrentStepInfo().action)
            .fontSize(14)
            .fontColor('#333333')
            .margin({ left: 8 })
        }
        .width('100%')

        Row() {
          Text('步法：')
            .fontSize(12)
            .fontColor('#666666')
          Text(this.getCurrentStepInfo().footwork)
            .fontSize(12)
            .fontColor('#333333')
        }
        .width('100%')
        .margin({ top: 8 })

        Row() {
          Text('方向：')
            .fontSize(12)
            .fontColor('#666666')
          Text(this.getCurrentStepInfo().direction)
            .fontSize(12)
            .fontColor('#333333')
        }
        .width('100%')
        .margin({ top: 4 })

        Text(this.getCurrentStepInfo().description)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 8 })
          .fontStyle(FontStyle.Italic)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F9F0FF')
      .borderRadius(8)
      .margin({ top: 12 })
    }
  }

  // 辅助方法：获取宫位名称
  private getPalaceName(palaceIndex: number): string {
    if (!this.rules || !this.rules.jiugongGang) {
      return '';
    }
    const palace = this.rules.jiugongGang.palacePositions.find((p: PalacePosition) => p.palace === palaceIndex);
    return palace ? palace.name : '';
  }

  // 辅助方法：获取宫位方向
  private getPalaceDirection(palaceIndex: number): string {
    if (!this.rules || !this.rules.jiugongGang) {
      return '';
    }
    const palace = this.rules.jiugongGang.palacePositions.find((p: PalacePosition) => p.palace === palaceIndex);
    return palace ? palace.direction : '';
  }

  // 辅助方法：获取步骤在路线中的位置
  private getStepInRoute(palaceIndex: number): number {
    if (!this.rules || !this.rules.jiugongGang) {
      return -1;
    }
    const currentRoute = this.rules.jiugongGang.routes.find((r: RouteInfo) => r.id === this.selectedRoute);
    return currentRoute ? currentRoute.sequence.indexOf(palaceIndex) : -1;
  }

  // 辅助方法：判断是否为当前步骤
  private isJiugongCurrentStep(palaceIndex: number): boolean {
    const stepInRoute = this.getStepInRoute(palaceIndex);
    return stepInRoute === this.currentStep - 1;
  }

  // 辅助方法：判断是否已经走过
  private isJiugongPassed(palaceIndex: number): boolean {
    const stepInRoute = this.getStepInRoute(palaceIndex);
    return stepInRoute >= 0 && stepInRoute < this.currentStep - 1;
  }

  // 辅助方法：获取当前步骤信息
  private getCurrentStepInfo(): StepInfo {
    if (this.rules && this.rules.qibugang && this.currentStep > 0 && this.currentStep <= this.rules.qibugang.steps.length) {
      return this.rules.qibugang.steps[this.currentStep - 1];
    }
    return { step: 0, action: '', footwork: '', direction: '', description: '', positionX: 0, positionY: 0 };
  }

  private getStepColor(index: number): string {
    if (index === this.currentStep - 1) {
      return '#FF4D4F'; // 当前步骤
    } else if (index < this.currentStep - 1) {
      return '#722ED1'; // 已完成
    }
    return '#CCCCCC'; // 未到达
  }

  private getStarColor(index: number): string {
    if (index === this.currentStep) {
      return '#FF4D4F';
    } else if (index < this.currentStep) {
      return '#FFD700';
    }
    return '#CCCCCC';
  }

  private getJiugongOrder(): number[] {
    // 标准九宫格显示顺序（从上到下，从左到右）
    // 巽4 离9 坤2
    // 震3 中5 兑7
    // 艮8 坎1 乾6
    return [4, 9, 2, 3, 5, 7, 8, 1, 6];
  }

  private getMaxSteps(): number {
    if (!this.rules) {
      return 0;
    }
    if (this.selectedMode === 0) {
      return this.rules.qibugang.steps.length;
    } else if (this.selectedMode === 1) {
      return this.rules.beidouGang.stars.length;
    } else {
      const currentRoute = this.rules.jiugongGang.routes.find((r: RouteInfo) => r.id === this.selectedRoute);
      return currentRoute ? currentRoute.sequence.length : 0;
    }
  }

  private startAnimation(): void {
    if (this.currentStep >= this.getMaxSteps()) {
      this.currentStep = 0;
    }
    this.isAnimating = true;
    this.animationTimer = setInterval(() => {
      if (this.currentStep < this.getMaxSteps()) {
        this.currentStep++;
      } else {
        this.stopAnimation();
      }
    }, 800);
  }

  private stopAnimation(): void {
    this.isAnimating = false;
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer);
      this.animationTimer = -1;
    }
  }
}
