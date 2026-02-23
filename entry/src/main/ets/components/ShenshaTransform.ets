// ShenshaTransform.ets
// 神煞转化查询工具 - 查询凶神对应的吉神转化关系

import util from '@ohos.util';

// 神煞信息接口
interface ShaInfo {
  name: string;
  category: string;
  nature: string;
  description: string;
}

// 转化关系接口
interface Transformation {
  id: string;
  originalSha: ShaInfo;
  transformTo: ShaInfo;
  meaning: string;
  chant: string;
  applicationTip: string;
}

// 来源信息接口
interface OriginInfo {
  originalText: string;
  source: string;
}

// 使用指南接口
interface UsageGuide {
  basicMethod: string[];
  completeChant: string;
  chantTiming: string[];
}

// 神煞转化规则接口
interface ShenshaRules {
  title: string;
  description: string;
  origin: OriginInfo;
  transformations: Transformation[];
  usageGuide: UsageGuide;
}

@Component
export struct ShenshaTransform {
  @State rulesData: ShenshaRules | null = null;
  @State selectedSha: Transformation | null = null;
  @State isLoading: boolean = true;
  @State showCompleteChant: boolean = false;
  @State searchKeyword: string = '';

  aboutToAppear(): void {
    this.loadRulesData();
  }

  private async loadRulesData(): Promise<void> {
    try {
      const context = getContext(this);
      const resourceMgr = context.resourceManager;
      const rawFile = await resourceMgr.getRawFileContent('rules/shensha_transform_rules.json');
      const jsonStr = new util.TextDecoder('utf-8').decodeToString(rawFile);
      this.rulesData = JSON.parse(jsonStr) as ShenshaRules;
      this.isLoading = false;
    } catch (e) {
      console.error('加载神煞转化规则失败:', e);
      this.isLoading = false;
    }
  }

  private getFilteredTransformations(): Transformation[] {
    if (!this.rulesData) return [];
    if (!this.searchKeyword) return this.rulesData.transformations;

    const keyword = this.searchKeyword.toLowerCase();
    return this.rulesData.transformations.filter(t =>
      t.originalSha.name.includes(keyword) ||
      t.transformTo.name.includes(keyword) ||
      t.meaning.includes(keyword)
    );
  }

  private getCategoryColor(category: string): string {
    if (category === '凶煞' || category === '中性偏凶') {
      return '#FF4D4F';
    } else if (category === '吉神') {
      return '#52C41A';
    }
    return '#666666';
  }

  private getCategoryBgColor(category: string): string {
    if (category === '凶煞' || category === '中性偏凶') {
      return '#FFF1F0';
    } else if (category === '吉神') {
      return '#F6FFED';
    }
    return '#FAFAFA';
  }

  build() {
    Column({ space: 12 }) {
      // 标题
      Row() {
        Text('🔄')
          .fontSize(20)
        Text('神煞转化查询')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C2416')
          .margin({ left: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      // 说明
      Text('将凶神煞气转化为吉庆福气，体现奇门遁甲"化煞为权"的高级应用')
        .fontSize(12)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)

      // 搜索框
      this.buildSearchBar()

      // 转化卡片列表
      if (this.rulesData) {
        this.buildTransformList()
      }

      // 选中详情
      if (this.selectedSha) {
        this.buildDetailPanel()
      }

      // 完整咒语按钮
      if (this.rulesData) {
        Button(this.showCompleteChant ? '收起完整咒语' : '查看完整转化咒')
          .fontSize(13)
          .width('100%')
          .height(40)
          .backgroundColor(this.showCompleteChant ? '#EEEEEE' : '#722ED1')
          .fontColor(this.showCompleteChant ? '#666666' : '#FFFFFF')
          .onClick(() => {
            this.showCompleteChant = !this.showCompleteChant;
          })
      }

      // 完整咒语面板
      if (this.showCompleteChant && this.rulesData) {
        this.buildCompleteChantPanel()
      }

      // 使用指南
      if (this.rulesData) {
        this.buildUsageGuide()
      }
    }
    .width('100%')
    .padding(16)
  }

  @Builder
  private buildSearchBar() {
    Row({ space: 8 }) {
      Text('🔍')
        .fontSize(16)
      TextInput({ placeholder: '搜索凶神或吉神名称...', text: this.searchKeyword })
        .layoutWeight(1)
        .height(36)
        .fontSize(14)
        .onChange((value: string) => {
          this.searchKeyword = value;
        })
    }
    .width('100%')
    .padding({ left: 12, right: 12 })
    .backgroundColor('#F5F5F5')
    .borderRadius(18)
  }

  @Builder
  private buildTransformList() {
    if (this.rulesData) {
      Column({ space: 8 }) {
        Text('转化关系（点击查看详情）')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)

        // 使用Grid布局，每行2个
        Grid() {
          ForEach(this.getFilteredTransformations(), (item: Transformation) => {
            GridItem() {
              Column({ space: 6 }) {
                // 凶神
                Row({ space: 4 }) {
                  Text(item.originalSha.name)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.getCategoryColor(item.originalSha.category))

                  Text(item.originalSha.category)
                    .fontSize(10)
                    .fontColor(this.getCategoryColor(item.originalSha.category))
                    .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                    .backgroundColor(this.getCategoryBgColor(item.originalSha.category))
                    .borderRadius(4)
                }

                // 转化箭头
                Text('↓ 转化为 ↓')
                  .fontSize(10)
                  .fontColor('#999999')

                // 吉神
                Row({ space: 4 }) {
                  Text(item.transformTo.name)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.getCategoryColor(item.transformTo.category))

                  Text(item.transformTo.category)
                    .fontSize(10)
                    .fontColor(this.getCategoryColor(item.transformTo.category))
                    .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                    .backgroundColor(this.getCategoryBgColor(item.transformTo.category))
                    .borderRadius(4)
                }

                // 寓意
                Text(item.meaning)
                  .fontSize(11)
                  .fontColor('#666666')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
              .padding(10)
              .backgroundColor(this.selectedSha?.id === item.id ? '#F9F0FF' : '#FFFFFF')
              .borderRadius(8)
              .border({
                width: this.selectedSha?.id === item.id ? 2 : 1,
                color: this.selectedSha?.id === item.id ? '#722ED1' : '#EEEEEE'
              })
              .onClick(() => {
                this.selectedSha = this.selectedSha?.id === item.id ? null : item;
              })
            }
          })
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(8)
        .rowsGap(8)
        .width('100%')
        .height(this.getGridHeight())
      }
      .width('100%')
    }
  }

  private getGridHeight(): number {
    const count = this.getFilteredTransformations().length;
    const rows = Math.ceil(count / 2);
    return rows * 110 + (rows - 1) * 8;
  }

  @Builder
  private buildDetailPanel() {
    if (this.selectedSha) {
      Column({ space: 12 }) {
        // 标题
        Row() {
          Text('📖')
            .fontSize(16)
          Text('转化详情')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#722ED1')
            .margin({ left: 6 })
        }
        .width('100%')

        // 凶神详情
        Column({ space: 6 }) {
          Row({ space: 6 }) {
            Text('凶煞')
              .fontSize(11)
              .fontColor('#FFFFFF')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor('#FF4D4F')
              .borderRadius(4)
            Text(this.selectedSha.originalSha.name)
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#D4380D')
          }

          Text('性质：' + this.selectedSha.originalSha.nature)
            .fontSize(12)
            .fontColor('#666666')

          Text(this.selectedSha.originalSha.description)
            .fontSize(12)
            .fontColor('#333333')
            .lineHeight(18)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#FFF1F0')
        .borderRadius(8)

        // 转化箭头
        Row() {
          Text('⬇️ 念咒转化 ⬇️')
            .fontSize(12)
            .fontColor('#722ED1')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        // 吉神详情
        Column({ space: 6 }) {
          Row({ space: 6 }) {
            Text('吉神')
              .fontSize(11)
              .fontColor('#FFFFFF')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor('#52C41A')
              .borderRadius(4)
            Text(this.selectedSha.transformTo.name)
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#389E0D')
          }

          Text('性质：' + this.selectedSha.transformTo.nature)
            .fontSize(12)
            .fontColor('#666666')

          Text(this.selectedSha.transformTo.description)
            .fontSize(12)
            .fontColor('#333333')
            .lineHeight(18)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#F6FFED')
        .borderRadius(8)

        // 咒语
        Column({ space: 6 }) {
          Text('转化咒语')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFE082')

          Text(this.selectedSha.chant)
            .fontSize(14)
            .fontColor('#FFF8E1')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#3E2723')
        .borderRadius(8)

        // 应用提示
        Row({ space: 6 }) {
          Text('💡')
            .fontSize(14)
          Text(this.selectedSha.applicationTip)
            .fontSize(12)
            .fontColor('#FA8C16')
            .layoutWeight(1)
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#FFF7E6')
        .borderRadius(6)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
    }
  }

  @Builder
  private buildCompleteChantPanel() {
    if (this.rulesData) {
      Column({ space: 8 }) {
        Text('完整神煞转化咒')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFE082')
          .alignSelf(ItemAlign.Start)

        Text(this.rulesData.usageGuide.completeChant)
          .fontSize(13)
          .fontColor('#FFF8E1')
          .lineHeight(22)

        Divider().color('#5D4037')

        Text('诵咒时机')
          .fontSize(12)
          .fontColor('#FFE082')
          .margin({ top: 8 })
          .alignSelf(ItemAlign.Start)

        ForEach(this.rulesData.usageGuide.chantTiming, (timing: string, index: number) => {
          Row({ space: 8 }) {
            Text((index + 1).toString())
              .fontSize(10)
              .fontColor('#3E2723')
              .width(18)
              .height(18)
              .textAlign(TextAlign.Center)
              .backgroundColor('#FFE082')
              .borderRadius(9)
            Text(timing)
              .fontSize(12)
              .fontColor('#FFF8E1')
              .layoutWeight(1)
          }
          .width('100%')
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#3E2723')
      .borderRadius(8)
    }
  }

  @Builder
  private buildUsageGuide() {
    if (this.rulesData) {
      Column({ space: 8 }) {
        Text('使用方法')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)

        ForEach(this.rulesData.usageGuide.basicMethod, (method: string, index: number) => {
          Row({ space: 10 }) {
            Text((index + 1).toString())
              .fontSize(11)
              .fontColor('#FFFFFF')
              .width(20)
              .height(20)
              .textAlign(TextAlign.Center)
              .backgroundColor('#722ED1')
              .borderRadius(10)
            Text(method)
              .fontSize(12)
              .fontColor('#333333')
              .layoutWeight(1)
          }
          .width('100%')
        })
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F9F0FF')
      .borderRadius(8)
    }
  }
}
