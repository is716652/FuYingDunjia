// ShiershenLookup.ets
// 十二神吉凶速查组件 - 快速查询十二神的吉凶信息

import { RulesManager, ShiershenGod, ShiershenQueryResult } from '../utils/RulesManager';

@Component
export struct ShiershenLookup {
  @State godsList: ShiershenGod[] = [];
  @State selectedGod: ShiershenQueryResult | null = null;
  @State isLoading: boolean = false;
  @State filterMode: string = 'all'; // 'all', 'ji', 'xiong'
  @State showMnemonic: boolean = false;

  // 十二神口诀
  private readonly MNEMONIC_RIGHT: string = '五符最利天曹平，地府忧慎人马惊，风伯雷公鼓角位，雨师凿将奏天英，风云失路唐符庆，国印丹书紫诏荣';
  private readonly MNEMONIC_LEFT: string = '天关封把地轴忌，天贼须防后向兵';

  aboutToAppear(): void {
    this.loadGodsList();
  }

  private async loadGodsList(): Promise<void> {
    this.isLoading = true;
    const manager = RulesManager.getInstance();
    const allGods = await manager.getAllShiershenList();
    this.godsList = allGods;
    this.isLoading = false;
  }

  private async onSelectGod(godName: string): Promise<void> {
    const manager = RulesManager.getInstance();
    const result = await manager.queryShiershenJixiong(godName);
    this.selectedGod = result;
  }

  private getFilteredGods(): ShiershenGod[] {
    if (this.filterMode === 'all') {
      return this.godsList;
    }
    const filtered: ShiershenGod[] = [];
    for (let i = 0; i < this.godsList.length; i++) {
      const god = this.godsList[i];
      if (this.filterMode === 'ji' && god.fortuneLevel >= 4) {
        filtered.push(god);
      } else if (this.filterMode === 'xiong' && god.fortuneLevel <= 2) {
        filtered.push(god);
      }
    }
    return filtered;
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('十二神吉凶速查')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text('📜')
          .fontSize(18)
          .fontColor('#999999')
          .onClick(() => {
            this.showMnemonic = !this.showMnemonic;
          })
      }
      .width('100%')
      .padding({ bottom: 12 })

      // 口诀展示
      if (this.showMnemonic) {
        this.buildMnemonicSection()
      }

      // 筛选器
      this.buildFilterTabs()

      // 神列表
      if (this.isLoading) {
        this.buildLoadingState()
      } else {
        this.buildGodsGrid()
      }

      // 选中的神详情
      if (this.selectedGod) {
        this.buildGodDetail()
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  buildMnemonicSection() {
    Column() {
      Text('十二神吉凶口诀')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)

      Column() {
        Text('【右列·吉神为主】')
          .fontSize(12)
          .fontColor('#52C41A')
          .alignSelf(ItemAlign.Start)
        Text(this.MNEMONIC_RIGHT)
          .fontSize(13)
          .fontColor('#333333')
          .lineHeight(22)
          .margin({ top: 4 })
      }
      .width('100%')
      .margin({ top: 8 })

      Column() {
        Text('【左列·凶神警示】')
          .fontSize(12)
          .fontColor('#FF4D4F')
          .alignSelf(ItemAlign.Start)
        Text(this.MNEMONIC_LEFT)
          .fontSize(13)
          .fontColor('#333333')
          .lineHeight(22)
          .margin({ top: 4 })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFBE6')
    .borderRadius(8)
    .margin({ bottom: 12 })
    .border({ width: 1, color: '#FFE58F' })
  }

  @Builder
  buildFilterTabs() {
    Row() {
      this.buildFilterTab('全部', 'all')
      this.buildFilterTab('吉神', 'ji')
      this.buildFilterTab('凶神', 'xiong')
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .margin({ bottom: 12 })
  }

  @Builder
  buildFilterTab(label: string, mode: string) {
    Text(label)
      .fontSize(14)
      .fontColor(this.filterMode === mode ? '#FFFFFF' : '#666666')
      .padding({ left: 16, right: 16, top: 6, bottom: 6 })
      .backgroundColor(this.filterMode === mode ? '#1890FF' : '#F5F5F5')
      .borderRadius(16)
      .margin({ right: 8 })
      .onClick(() => {
        this.filterMode = mode;
        this.selectedGod = null;
      })
  }

  @Builder
  buildLoadingState() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
      Text('正在加载...')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .height(120)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildGodsGrid() {
    Grid() {
      ForEach(this.getFilteredGods(), (god: ShiershenGod) => {
        GridItem() {
          this.buildGodCard(god)
        }
      })
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsGap(10)
    .columnsGap(10)
    .width('100%')
  }

  @Builder
  buildGodCard(god: ShiershenGod) {
    Column() {
      // 吉凶标识
      Text(this.getFortuneIcon(god.fortuneLevel))
        .fontSize(20)

      // 神名
      Text(god.name)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .margin({ top: 4 })

      // 吉凶标签
      Text(god.fortune)
        .fontSize(11)
        .fontColor('#FFFFFF')
        .backgroundColor(this.getFortuneColor(god.fortuneLevel))
        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        .borderRadius(4)
        .margin({ top: 4 })
    }
    .width('100%')
    .padding(10)
    .backgroundColor(this.selectedGod && this.selectedGod.god.id === god.id ? '#E6F7FF' : '#FAFAFA')
    .borderRadius(8)
    .border({
      width: 1,
      color: this.selectedGod && this.selectedGod.god.id === god.id ? '#1890FF' : '#EEEEEE'
    })
    .onClick(() => {
      this.onSelectGod(god.name);
    })
  }

  @Builder
  buildGodDetail() {
    if (this.selectedGod) {
      Column() {
        // 分隔线
        Divider()
          .strokeWidth(1)
          .color('#EEEEEE')
          .margin({ top: 16, bottom: 16 })

        // 神名和基本信息
        Row() {
          Column() {
            Text(this.selectedGod.god.name)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            Text(this.selectedGod.god.category)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Column() {
            Text(this.selectedGod.god.fortune)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.selectedGod.colorTag)
            Text(this.selectedGod.actionAdvice)
              .fontSize(11)
              .fontColor('#666666')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.End)
        }
        .width('100%')

        // 原文出处
        Text(`"${this.selectedGod.god.originalText}"`)
          .fontSize(14)
          .fontColor('#8B4513')
          .fontStyle(FontStyle.Italic)
          .margin({ top: 12 })
          .padding(8)
          .backgroundColor('#FFF8DC')
          .borderRadius(4)
          .width('100%')

        // 含义解释
        Column() {
          Text('象意解析')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#666666')
            .alignSelf(ItemAlign.Start)
          Text(this.selectedGod.god.meaning)
            .fontSize(14)
            .fontColor('#333333')
            .lineHeight(22)
            .margin({ top: 6 })
        }
        .width('100%')
        .margin({ top: 12 })

        // 符号象征
        Row() {
          Text('符号象征')
            .fontSize(13)
            .fontColor('#666666')
            .width(80)
          Text(this.selectedGod.god.symbol)
            .fontSize(13)
            .fontColor('#333333')
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 12 })

        // 宜忌事项
        Row() {
          // 宜
          if (this.selectedGod.god.suitable.length > 0) {
            Column() {
              Text('宜')
                .fontSize(13)
                .fontColor('#52C41A')
                .fontWeight(FontWeight.Medium)
              ForEach(this.selectedGod.god.suitable, (item: string) => {
                Text(`· ${item}`)
                  .fontSize(12)
                  .fontColor('#333333')
                  .margin({ top: 4 })
              })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }

          // 忌
          if (this.selectedGod.god.taboo.length > 0) {
            Column() {
              Text('忌')
                .fontSize(13)
                .fontColor('#FF4D4F')
                .fontWeight(FontWeight.Medium)
              ForEach(this.selectedGod.god.taboo, (item: string) => {
                Text(`· ${item}`)
                  .fontSize(12)
                  .fontColor('#333333')
                  .margin({ top: 4 })
              })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
        }
        .width('100%')
        .margin({ top: 12 })
        .padding(12)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)

        // 具体应用场景
        this.buildApplicationScenarios()

        // 警告信息（如有）
        if (this.selectedGod.god.warning) {
          Row() {
            Text('⚠️')
              .fontSize(14)
            Text(this.selectedGod.god.warning)
              .fontSize(13)
              .fontColor('#FA8C16')
              .margin({ left: 8 })
          }
          .width('100%')
          .margin({ top: 12 })
          .padding(10)
          .backgroundColor('#FFF7E6')
          .borderRadius(8)
        }
      }
      .width('100%')
    }
  }

  @Builder
  buildApplicationScenarios() {
    if (this.selectedGod) {
      Column() {
        Text('应用场景')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)

        Grid() {
          GridItem() {
            this.buildScenarioCard('出行', this.selectedGod.god.application.travel, '🚗')
          }
          GridItem() {
            this.buildScenarioCard('事业', this.selectedGod.god.application.career, '💼')
          }
          GridItem() {
            this.buildScenarioCard('财运', this.selectedGod.god.application.wealth, '💰')
          }
          GridItem() {
            this.buildScenarioCard('婚恋', this.selectedGod.god.application.marriage, '💕')
          }
        }
        .columnsTemplate('1fr 1fr')
        .rowsGap(8)
        .columnsGap(8)
        .margin({ top: 8 })
      }
      .width('100%')
      .margin({ top: 12 })
    }
  }

  @Builder
  buildScenarioCard(title: string, desc: string, icon: string) {
    Column() {
      Row() {
        Text(icon)
          .fontSize(14)
        Text(title)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ left: 4 })
      }

      Text(desc)
        .fontSize(11)
        .fontColor('#666666')
        .margin({ top: 4 })
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding(8)
    .backgroundColor('#F5F5F5')
    .borderRadius(6)
    .alignItems(HorizontalAlign.Start)
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
}
