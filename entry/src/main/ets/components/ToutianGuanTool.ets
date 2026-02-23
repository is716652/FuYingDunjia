// ToutianGuanTool.ets
// 透天关法实战工具组件 - 军事应用场景指导

import { common } from '@kit.AbilityKit';
import { buffer, JSON as ArkJSON } from '@kit.ArkTS';

// 接口定义
interface LiujiaInfo {
  name: string;
  xun: string;
  element: string;
  direction: string;
  palace: number;
}

interface SanJiMenDoor {
  name: string;
  element: string;
  basePalace: string;
  fortune: string;
  meaning: string;
  militaryUse: string;
}

interface MilitaryApplication {
  id: string;
  name: string;
  description: string;
  procedure: string;
  effect: string;
}

interface SpecialAdvantage {
  id: string;
  name: string;
  description: string;
}

interface ModernApplication {
  scenario: string;
  description: string;
  method: string;
}

interface ToutianGuanRules {
  title: string;
  description: string;
  liujiaSystem: LiujiaSystemInfo;
  sanJiMen: SanJiMenInfo;
  militaryApplications: MilitaryApplication[];
  specialAdvantages: SpecialAdvantage[];
  modernApplications: ModernApplication[];
  usageGuidelines: UsageGuidelineInfo;
}

interface LiujiaSystemInfo {
  description: string;
  liujia: LiujiaInfo[];
}

interface SanJiMenInfo {
  description: string;
  doors: SanJiMenDoor[];
}

interface UsageGuidelineInfo {
  principles: string[];
  taboos: string[];
}

@Component
export struct ToutianGuanTool {
  @State rules: ToutianGuanRules | null = null;
  @State isLoading: boolean = false;
  @State selectedTab: number = 0; // 0: 六甲, 1: 三吉门, 2: 军事应用, 3: 现代应用
  @State selectedApplication: MilitaryApplication | null = null;
  @State showGuide: boolean = false;
  private context: common.Context | null = null;

  private readonly TABS: string[] = ['六甲体系', '三吉门', '军事应用', '现代应用'];

  aboutToAppear(): void {
    this.context = getContext(this) as common.Context;
    this.loadRules();
  }

  private async loadRules(): Promise<void> {
    if (!this.context) {
      return;
    }
    this.isLoading = true;
    try {
      const value = await this.context.resourceManager.getRawFileContent('rules/toutianguan_rules.json');
      const str = buffer.from(value.buffer).toString();
      this.rules = ArkJSON.parse(str) as ToutianGuanRules;
    } catch (err) {
      console.error('Failed to load toutianguan rules:', err);
    }
    this.isLoading = false;
  }

  build() {
    Column() {
      // 标题
      Row() {
        Text('透天关法')
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

      // 使用指南
      if (this.showGuide) {
        this.buildUsageGuide()
      }

      // Tab切换
      this.buildTabs()

      // 内容区域
      if (this.isLoading) {
        this.buildLoadingState()
      } else if (this.rules) {
        this.buildContent()
      }

      // 应用详情弹窗
      if (this.selectedApplication) {
        this.buildApplicationDetail()
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  buildUsageGuide() {
    Column() {
      Text('使用原则')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1890FF')
        .alignSelf(ItemAlign.Start)

      if (this.rules && this.rules.usageGuidelines) {
        ForEach(this.rules.usageGuidelines.principles, (principle: string, index: number) => {
          Row() {
            Text(`${index + 1}.`)
              .fontSize(12)
              .fontColor('#52C41A')
              .width(20)
            Text(principle)
              .fontSize(12)
              .fontColor('#333333')
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ top: 4 })
        })
      }

      Divider().margin({ top: 12, bottom: 12 })

      Text('禁忌事项')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FF4D4F')
        .alignSelf(ItemAlign.Start)

      if (this.rules && this.rules.usageGuidelines) {
        ForEach(this.rules.usageGuidelines.taboos, (taboo: string, index: number) => {
          Row() {
            Text(`${index + 1}.`)
              .fontSize(12)
              .fontColor('#FF4D4F')
              .width(20)
            Text(taboo)
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
    .backgroundColor('#F6FFED')
    .borderRadius(8)
    .margin({ bottom: 12 })
    .border({ width: 1, color: '#B7EB8F' })
  }

  @Builder
  buildTabs() {
    Row() {
      ForEach(this.TABS, (tab: string, index: number) => {
        Text(tab)
          .fontSize(13)
          .fontColor(this.selectedTab === index ? '#FFFFFF' : '#666666')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.selectedTab === index ? '#1890FF' : '#F5F5F5')
          .borderRadius(16)
          .margin({ right: 8 })
          .onClick(() => {
            this.selectedTab = index;
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
    .height(150)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildContent() {
    if (this.selectedTab === 0) {
      this.buildLiujiaContent()
    } else if (this.selectedTab === 1) {
      this.buildSanJiMenContent()
    } else if (this.selectedTab === 2) {
      this.buildMilitaryContent()
    } else {
      this.buildModernContent()
    }
  }

  @Builder
  buildLiujiaContent() {
    Column() {
      if (this.rules && this.rules.liujiaSystem) {
        Text(this.rules.liujiaSystem.description)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ bottom: 12 })

        Grid() {
          ForEach(this.rules.liujiaSystem.liujia, (liujia: LiujiaInfo) => {
            GridItem() {
              this.buildLiujiaCard(liujia)
            }
          })
        }
        .columnsTemplate('1fr 1fr')
        .rowsGap(10)
        .columnsGap(10)
        .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  buildLiujiaCard(liujia: LiujiaInfo) {
    Column() {
      Text(liujia.name)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')

      Text(liujia.xun)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })

      Row() {
        Text(liujia.element)
          .fontSize(11)
          .fontColor('#FFFFFF')
          .backgroundColor(this.getElementColor(liujia.element))
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(4)

        Text(liujia.direction)
          .fontSize(11)
          .fontColor('#666666')
          .margin({ left: 8 })
      }
      .margin({ top: 6 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FAFAFA')
    .borderRadius(8)
  }

  @Builder
  buildSanJiMenContent() {
    Column() {
      if (this.rules && this.rules.sanJiMen) {
        Text(this.rules.sanJiMen.description)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ bottom: 12 })

        ForEach(this.rules.sanJiMen.doors, (door: SanJiMenDoor) => {
          this.buildDoorCard(door)
        })
      }
    }
    .width('100%')
  }

  @Builder
  buildDoorCard(door: SanJiMenDoor) {
    Column() {
      Row() {
        Text(door.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Text(door.fortune)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor(door.fortune === '大吉' ? '#52C41A' : '#FAAD14')
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(4)
          .margin({ left: 8 })

        Blank()

        Text(door.basePalace)
          .fontSize(12)
          .fontColor('#666666')
      }
      .width('100%')

      Text(door.meaning)
        .fontSize(13)
        .fontColor('#333333')
        .margin({ top: 8 })

      Row() {
        Text('⚔️')
          .fontSize(12)
        Text(door.militaryUse)
          .fontSize(12)
          .fontColor('#8B4513')
          .margin({ left: 4 })
      }
      .margin({ top: 8 })
      .padding(8)
      .backgroundColor('#FFF8DC')
      .borderRadius(4)
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FAFAFA')
    .borderRadius(8)
    .margin({ bottom: 10 })
  }

  @Builder
  buildMilitaryContent() {
    Column() {
      // 特殊优势
      if (this.rules && this.rules.specialAdvantages) {
        Row() {
          ForEach(this.rules.specialAdvantages, (adv: SpecialAdvantage) => {
            Column() {
              Text('✓')
                .fontSize(14)
                .fontColor('#52C41A')
              Text(adv.name)
                .fontSize(11)
                .fontColor('#333333')
                .margin({ top: 2 })
            }
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#F6FFED')
            .borderRadius(4)
            .margin({ right: 8 })
          })
        }
        .width('100%')
        .margin({ bottom: 12 })
      }

      // 军事应用列表
      if (this.rules && this.rules.militaryApplications) {
        ForEach(this.rules.militaryApplications, (app: MilitaryApplication) => {
          this.buildMilitaryAppCard(app)
        })
      }
    }
    .width('100%')
  }

  @Builder
  buildMilitaryAppCard(app: MilitaryApplication) {
    Row() {
      Column() {
        Text(this.getMilitaryIcon(app.id))
          .fontSize(24)
      }
      .width(50)
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(app.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        Text(app.description)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 4 })
          .maxLines(2)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('›')
        .fontSize(20)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FAFAFA')
    .borderRadius(8)
    .margin({ bottom: 8 })
    .onClick(() => {
      this.selectedApplication = app;
    })
  }

  @Builder
  buildModernContent() {
    Column() {
      if (this.rules && this.rules.modernApplications) {
        ForEach(this.rules.modernApplications, (app: ModernApplication, index: number) => {
          Column() {
            Row() {
              Text(this.getModernIcon(app.scenario))
                .fontSize(20)
              Text(app.scenario)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ left: 8 })
            }
            .width('100%')

            Text(app.description)
              .fontSize(13)
              .fontColor('#666666')
              .margin({ top: 8 })

            Row() {
              Text('方法：')
                .fontSize(12)
                .fontColor('#1890FF')
              Text(app.method)
                .fontSize(12)
                .fontColor('#333333')
                .layoutWeight(1)
            }
            .width('100%')
            .margin({ top: 8 })
            .padding(8)
            .backgroundColor('#E6F7FF')
            .borderRadius(4)
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FAFAFA')
          .borderRadius(8)
          .margin({ bottom: 10 })
        })
      }
    }
    .width('100%')
  }

  @Builder
  buildApplicationDetail() {
    Stack() {
      // 遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000066')
        .onClick(() => {
          this.selectedApplication = null;
        })

      // 详情卡片
      Column() {
        Row() {
          Text(this.selectedApplication ? this.selectedApplication.name : '')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          Blank()
          Text('✕')
            .fontSize(20)
            .fontColor('#999999')
            .onClick(() => {
              this.selectedApplication = null;
            })
        }
        .width('100%')

        if (this.selectedApplication) {
          Divider().margin({ top: 12, bottom: 12 })

          Text('应用说明')
            .fontSize(14)
            .fontColor('#666666')
            .alignSelf(ItemAlign.Start)
          Text(this.selectedApplication.description)
            .fontSize(14)
            .fontColor('#333333')
            .margin({ top: 8 })

          Text('操作步骤')
            .fontSize(14)
            .fontColor('#666666')
            .alignSelf(ItemAlign.Start)
            .margin({ top: 16 })
          Text(this.selectedApplication.procedure)
            .fontSize(14)
            .fontColor('#333333')
            .margin({ top: 8 })
            .padding(12)
            .backgroundColor('#FFF7E6')
            .borderRadius(8)
            .width('100%')

          Text('预期效果')
            .fontSize(14)
            .fontColor('#666666')
            .alignSelf(ItemAlign.Start)
            .margin({ top: 16 })
          Row() {
            Text('✨')
              .fontSize(16)
            Text(this.selectedApplication.effect)
              .fontSize(14)
              .fontColor('#52C41A')
              .fontWeight(FontWeight.Medium)
              .margin({ left: 8 })
          }
          .margin({ top: 8 })
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

  private getElementColor(element: string): string {
    const colorMap = new Map<string, string>([
      ['水', '#1890FF'],
      ['火', '#FF4D4F'],
      ['木', '#52C41A'],
      ['金', '#FFD700'],
      ['土', '#8B4513']
    ]);
    const color = colorMap.get(element);
    return color ? color : '#666666';
  }

  private getMilitaryIcon(id: string): string {
    const iconMap = new Map<string, string>([
      ['chujiang', '⚔️'],
      ['shoubing', '🛡️'],
      ['maozhen', '🗡️'],
      ['jiewei', '🏃'],
      ['qingbao', '🔍']
    ]);
    const icon = iconMap.get(id);
    return icon ? icon : '📋';
  }

  private getModernIcon(scenario: string): string {
    if (scenario.includes('决策')) {
      return '🎯';
    }
    if (scenario.includes('危机')) {
      return '⚡';
    }
    if (scenario.includes('出行')) {
      return '🚗';
    }
    if (scenario.includes('商业')) {
      return '💼';
    }
    return '📋';
  }
}
