// BiliuwuCalculator.ets
// 闭六戊计算器 - 根据日期自动计算六戊方位

import { CalendarManager, CalendarDayInfo } from '../utils/CalendarManager'
import util from '@ohos.util';

// 六戊映射接口
interface LiuwuMapping {
  xunName: string;
  xunHead: string;
  xunRange: string[];
  liuwu: string;
  liuwuZhi: string;
  direction: string;
  element: string;
  palaceIndex: number;
}

// 操作步骤接口
interface OperationStep {
  step: number;
  title: string;
  description: string;
}

// 咒语接口
interface SpellInfo {
  name: string;
  content: string;
}

// 相关咒语接口
interface RelatedSpells {
  anYingZhou: SpellInfo;
  yuBuZhou: SpellInfo;
}

// 应用场景接口
interface ApplicationScenario {
  scenario: string;
  description: string;
  priority: string;
}

// 六戊表接口
interface LiuwuTable {
  mappings: LiuwuMapping[];
}

// 闭六戊规则接口
interface BiliuwuRules {
  liuwuTable: LiuwuTable;
  operationSteps: OperationStep[];
  relatedSpells: RelatedSpells;
  applicationScenarios: ApplicationScenario[];
}

// 计算结果接口
interface CalculationResult {
  dayGanZhi: string;
  xunName: string;
  liuwu: string;
  direction: string;
  palaceIndex: number;
}

@Component
export struct BiliuwuCalculator {
  @State selectedYear: number = new Date().getFullYear();
  @State selectedMonth: number = new Date().getMonth() + 1;
  @State selectedDay: number = new Date().getDate();
  @State calculationResult: CalculationResult | null = null;
  @State rulesData: BiliuwuRules | null = null;
  @State isLoading: boolean = true;
  @State showSpellPanel: boolean = false;

  private calendarManager: CalendarManager = CalendarManager.getInstance();
  private tianGan: string[] = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
  private diZhi: string[] = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

  aboutToAppear(): void {
    this.calendarManager.init(getContext(this));
    this.loadRulesData();
  }

  private async loadRulesData(): Promise<void> {
    try {
      const context = getContext(this);
      const resourceMgr = context.resourceManager;
      const rawFile = await resourceMgr.getRawFileContent('rules/biliuwu_rules.json');
      const jsonStr = new util.TextDecoder('utf-8').decodeToString(rawFile);
      this.rulesData = JSON.parse(jsonStr) as BiliuwuRules;
      this.isLoading = false;
      this.calculateLiuwu();
    } catch (e) {
      console.error('加载闭六戊规则失败:', e);
      this.isLoading = false;
    }
  }

  private async calculateLiuwu(): Promise<void> {
    if (!this.rulesData) return;

    const dayInfo = await this.calendarManager.getDayInfo(
      this.selectedYear,
      this.selectedMonth,
      this.selectedDay
    );

    if (!dayInfo || !dayInfo.day_gan || !dayInfo.day_zhi) {
      this.calculationResult = null;
      return;
    }

    const dayGanZhi = dayInfo.day_gan + dayInfo.day_zhi;
    const mapping = this.findXunMapping(dayGanZhi);

    if (mapping) {
      this.calculationResult = {
        dayGanZhi: dayGanZhi,
        xunName: mapping.xunName,
        liuwu: mapping.liuwu,
        direction: mapping.direction,
        palaceIndex: mapping.palaceIndex
      };
    }
  }

  private findXunMapping(dayGanZhi: string): LiuwuMapping | null {
    if (!this.rulesData) return null;

    for (const mapping of this.rulesData.liuwuTable.mappings) {
      if (mapping.xunRange.includes(dayGanZhi)) {
        return mapping;
      }
    }
    return null;
  }

  private getPalaceName(index: number): string {
    const names = ['一宫坎', '二宫坤', '三宫震', '四宫巽', '五宫中', '六宫乾', '七宫兑', '八宫艮', '九宫离'];
    return names[index] || '';
  }

  private getDirectionEmoji(direction: string): string {
    const emojiMap: Record<string, string> = {
      '正北': '⬆️',
      '东北': '↗️',
      '正东': '➡️',
      '东南': '↘️',
      '正南': '⬇️',
      '西南': '↙️',
      '正西': '⬅️',
      '西北': '↖️'
    };
    return emojiMap[direction] || '📍';
  }

  build() {
    Column({ space: 12 }) {
      // 标题
      Row() {
        Text('🏕️')
          .fontSize(20)
        Text('闭六戊计算器')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C2416')
          .margin({ left: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      // 日期选择器
      this.buildDateSelector()

      // 计算结果
      if (this.calculationResult) {
        this.buildResultPanel()
      }

      // 操作步骤
      if (this.rulesData && this.calculationResult) {
        this.buildStepsPanel()
      }

      // 相关咒语面板
      if (this.showSpellPanel && this.rulesData) {
        this.buildSpellPanel()
      }

      // 应用场景
      if (this.rulesData) {
        this.buildScenariosPanel()
      }
    }
    .width('100%')
    .padding(16)
  }

  @Builder
  private buildDateSelector() {
    Column({ space: 8 }) {
      Text('选择日期')
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)

      Row({ space: 8 }) {
        // 年份选择
        Column() {
          Text('年')
            .fontSize(12)
            .fontColor('#999999')
          TextInput({ text: this.selectedYear.toString() })
            .type(InputType.Number)
            .width(80)
            .height(36)
            .fontSize(14)
            .textAlign(TextAlign.Center)
            .onChange((value: string) => {
              const year = parseInt(value);
              if (year >= 1900 && year <= 2100) {
                this.selectedYear = year;
                this.calculateLiuwu();
              }
            })
        }

        // 月份选择
        Column() {
          Text('月')
            .fontSize(12)
            .fontColor('#999999')
          TextInput({ text: this.selectedMonth.toString() })
            .type(InputType.Number)
            .width(60)
            .height(36)
            .fontSize(14)
            .textAlign(TextAlign.Center)
            .onChange((value: string) => {
              const month = parseInt(value);
              if (month >= 1 && month <= 12) {
                this.selectedMonth = month;
                this.calculateLiuwu();
              }
            })
        }

        // 日期选择
        Column() {
          Text('日')
            .fontSize(12)
            .fontColor('#999999')
          TextInput({ text: this.selectedDay.toString() })
            .type(InputType.Number)
            .width(60)
            .height(36)
            .fontSize(14)
            .textAlign(TextAlign.Center)
            .onChange((value: string) => {
              const day = parseInt(value);
              if (day >= 1 && day <= 31) {
                this.selectedDay = day;
                this.calculateLiuwu();
              }
            })
        }

        // 今日按钮
        Button('今日')
          .fontSize(12)
          .height(36)
          .backgroundColor('#722ED1')
          .onClick(() => {
            const today = new Date();
            this.selectedYear = today.getFullYear();
            this.selectedMonth = today.getMonth() + 1;
            this.selectedDay = today.getDate();
            this.calculateLiuwu();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FAFAFA')
    .borderRadius(8)
  }

  @Builder
  private buildResultPanel() {
    if (this.calculationResult) {
      Column({ space: 12 }) {
        Text('计算结果')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#722ED1')
          .alignSelf(ItemAlign.Start)

        // 日干支和旬
        Row({ space: 16 }) {
          Column() {
            Text('日干支')
              .fontSize(12)
              .fontColor('#999999')
            Text(this.calculationResult.dayGanZhi)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')
          }

          Column() {
            Text('所属旬')
              .fontSize(12)
              .fontColor('#999999')
            Text(this.calculationResult.xunName)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)

        Divider().color('#EEEEEE')

        // 六戊方位（核心结果）
        Column({ space: 8 }) {
          Text('六戊方位')
            .fontSize(12)
            .fontColor('#999999')

          Row({ space: 12 }) {
            Text(this.getDirectionEmoji(this.calculationResult.direction))
              .fontSize(32)

            Column({ space: 4 }) {
              Text(this.calculationResult.liuwu)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#D4380D')

              Text(this.calculationResult.direction + ' · ' + this.getPalaceName(this.calculationResult.palaceIndex))
                .fontSize(14)
                .fontColor('#666666')
            }
            .alignItems(HorizontalAlign.Start)
          }

          Text('安营结界时，应以此方位为核心设置防护')
            .fontSize(12)
            .fontColor('#52C41A')
            .padding({ top: 8 })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFF7E6')
        .borderRadius(8)

        // 查看咒语按钮
        Button(this.showSpellPanel ? '收起咒语' : '查看相关咒语')
          .fontSize(13)
          .width('100%')
          .height(36)
          .backgroundColor(this.showSpellPanel ? '#EEEEEE' : '#722ED1')
          .fontColor(this.showSpellPanel ? '#666666' : '#FFFFFF')
          .onClick(() => {
            this.showSpellPanel = !this.showSpellPanel;
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
    }
  }

  @Builder
  private buildStepsPanel() {
    if (this.rulesData) {
      Column({ space: 8 }) {
        Text('操作步骤')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)

        ForEach(this.rulesData.operationSteps, (step: OperationStep) => {
          Row({ space: 12 }) {
            Text(step.step.toString())
              .fontSize(12)
              .fontColor('#FFFFFF')
              .width(24)
              .height(24)
              .textAlign(TextAlign.Center)
              .backgroundColor('#722ED1')
              .borderRadius(12)

            Column({ space: 2 }) {
              Text(step.title)
                .fontSize(13)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              Text(step.description)
                .fontSize(12)
                .fontColor('#666666')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(8)
        })
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F9F0FF')
      .borderRadius(8)
    }
  }

  @Builder
  private buildSpellPanel() {
    if (this.rulesData) {
      Column({ space: 12 }) {
        Text('相关咒语')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFE082')
          .alignSelf(ItemAlign.Start)

        // 安营咒
        Column({ space: 6 }) {
          Text(this.rulesData.relatedSpells.anYingZhou.name)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFE082')

          Text(this.rulesData.relatedSpells.anYingZhou.content)
            .fontSize(12)
            .fontColor('#FFF8E1')
            .lineHeight(20)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#5D4037')
        .borderRadius(6)

        // 禹步咒
        Column({ space: 6 }) {
          Text(this.rulesData.relatedSpells.yuBuZhou.name)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFE082')

          Text(this.rulesData.relatedSpells.yuBuZhou.content)
            .fontSize(12)
            .fontColor('#FFF8E1')
            .lineHeight(20)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#5D4037')
        .borderRadius(6)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#3E2723')
      .borderRadius(8)
    }
  }

  @Builder
  private buildScenariosPanel() {
    if (this.rulesData) {
      Column({ space: 8 }) {
        Text('应用场景')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)

        Row({ space: 8 }) {
          ForEach(this.rulesData.applicationScenarios, (item: ApplicationScenario) => {
            Column({ space: 4 }) {
              Text(item.scenario)
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(item.priority === '高' ? '#D4380D' : '#333333')

              Text(item.priority === '高' ? '⭐ 高优先' : '中优先')
                .fontSize(10)
                .fontColor(item.priority === '高' ? '#FA8C16' : '#999999')
            }
            .padding(8)
            .backgroundColor(item.priority === '高' ? '#FFF7E6' : '#FAFAFA')
            .borderRadius(6)
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      .border({ width: 1, color: '#EEEEEE' })
    }
  }
}
