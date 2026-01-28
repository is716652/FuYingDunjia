import { NavigationBar } from '../components/NavigationBar'

/**
 * 九星知识条目
 */
interface StarKnowledge {
  name: string;
  alias: string;
  element: string;
  season: string;
  tendency: 'auspicious' | 'inauspicious' | 'neutral';
  characteristics: string;
  suitable: string[];
  avoid: string[];
  wangxiang: string;
}

/**
 * 八门知识条目
 */
interface DoorKnowledge {
  name: string;
  element: string;
  tendency: 'auspicious' | 'inauspicious' | 'neutral';
  characteristics: string;
  suitable: string[];
  avoid: string[];
  menpo: string;
}

interface JiuxingJsonRule {
  id?: string;
  name?: string;
  category?: string;
  description?: string;
  meaning?: string;
  suitable?: string[];
  taboo?: string[];
  tips?: string;
}

interface JiuxingJsonFile {
  rules?: JiuxingJsonRule[];
}

/**
 * 九星八门知识解读页面
 * 
 * 功能：
 * - 九星知识库：九星属性、旺相休囚、宜忌事项
 * - 八门知识库：八门吉凶、适用场景、门迫判断
 */
@Entry
@Component
struct JiuxingBamenKnowledgePage {
  @State currentTabIndex: number = 0
  @State starJsonSummary: Record<string, string> = {}
  
  // 九星知识库
  private stars: StarKnowledge[] = [
    {
      name: '天蓬',
      alias: '贪狼星',
      element: '水',
      season: '冬季旺相',
      tendency: 'inauspicious',
      characteristics: '司盗贼、奸谋、阴谋暗害之事。天蓬为水贼之星，性喜流动隐匿。',
      suitable: ['暗中谋划', '隐蔽行动', '捕盗缉凶', '水利工程'],
      avoid: ['公开推进', '婚嫁喜庆', '求名求官', '合伙经营'],
      wangxiang: '冬旺、春相、夏休、四季囚、秋死'
    },
    {
      name: '天任',
      alias: '左辅星',
      element: '土',
      season: '四季旺相',
      tendency: 'auspicious',
      characteristics: '司田土、仓库、诚信厚重之事。天任为土德之星，性喜稳固务实。',
      suitable: ['置业建造', '婚嫁结盟', '求财交易', '埋葬修坟', '屯粮储物'],
      avoid: ['远行舟车', '急速求名', '轻举妄动'],
      wangxiang: '四季旺、秋相、冬休、春囚、夏死'
    },
    {
      name: '天冲',
      alias: '廉贞星',
      element: '木',
      season: '春季旺相',
      tendency: 'inauspicious',
      characteristics: '司冲击、争斗、不安之事。天冲为雷霆之星，性喜动荡突破。',
      suitable: ['破旧立新', '竞争争讼', '讨债催逼', '破土动工'],
      avoid: ['婚嫁和合', '求财交易', '安居静养', '谋求长远'],
      wangxiang: '春旺、夏相、四季休、秋囚、冬死'
    },
    {
      name: '天辅',
      alias: '文曲星',
      element: '木',
      season: '春季旺相',
      tendency: 'auspicious',
      characteristics: '司文书、科举、教化之事。天辅为文昌之星，性喜文教谋略。',
      suitable: ['求学考试', '文书契约', '谋划策略', '拜师求教', '上书献策'],
      avoid: ['武力征伐', '粗暴行事', '不义之举'],
      wangxiang: '春旺、夏相、四季休、秋囚、冬死'
    },
    {
      name: '天英',
      alias: '禄存星',
      element: '火',
      season: '夏季旺相',
      tendency: 'inauspicious',
      characteristics: '司文明、血光、火烛之事。天英为烈火之星，性喜光明激烈。',
      suitable: ['文书公开', '照明祭祀', '显扬名声', '开张营业'],
      avoid: ['远行求财', '婚嫁结盟', '动土修造', '求医问药'],
      wangxiang: '夏旺、四季相、秋休、冬囚、春死'
    },
    {
      name: '天芮',
      alias: '巨门星',
      element: '土',
      season: '四季旺相',
      tendency: 'inauspicious',
      characteristics: '司疾病、死丧、腐烂之事。天芮为病符之星，性喜阴暗潮湿。',
      suitable: ['求医治病', '丧葬之事', '除旧清理', '修补破损'],
      avoid: ['婚嫁喜庆', '求财交易', '远行出师', '建造新宅'],
      wangxiang: '四季旺、秋相、冬休、春囚、夏死'
    },
    {
      name: '天柱',
      alias: '破军星',
      element: '金',
      season: '秋季旺相',
      tendency: 'inauspicious',
      characteristics: '司刚硬、破坏、阻滞之事。天柱为刚金之星，性喜坚硬破败。',
      suitable: ['破敌攻坚', '拆除旧物', '刚强决断', '斩断羁绊'],
      avoid: ['婚嫁和合', '求财交易', '建造新宅', '文书考试'],
      wangxiang: '秋旺、冬相、春休、夏囚、四季死'
    },
    {
      name: '天心',
      alias: '武曲星',
      element: '金',
      season: '秋季旺相',
      tendency: 'auspicious',
      characteristics: '司医药、将帅、决断之事。天心为贵人医星，性喜果决救护。',
      suitable: ['求医治病', '将帅出征', '决断大事', '求贵人助', '公正裁决'],
      avoid: ['阴谋诡计', '奸邪不义', '拖延犹豫'],
      wangxiang: '秋旺、冬相、春休、夏囚、四季死'
    },
    {
      name: '天禽',
      alias: '右弼星',
      element: '土',
      season: '四季旺相',
      tendency: 'auspicious',
      characteristics: '司中正、和合、稳重之事。天禽为中宫之星，性喜平和包容。',
      suitable: ['婚嫁结盟', '和解纠纷', '求财交易', '屯积储备', '中介调停'],
      avoid: ['急速突进', '冒险投机', '背信弃义'],
      wangxiang: '四季旺、秋相、冬休、春囚、夏死'
    }
  ]

  // 八门知识库
  private doors: DoorKnowledge[] = [
    {
      name: '休门',
      element: '水',
      tendency: 'auspicious',
      characteristics: '休养生息之门，主静养、休整、积蓄。为上吉之门。',
      suitable: ['休养调理', '婚嫁喜庆', '求财交易', '埋葬修坟', '建宅安居', '上表求官'],
      avoid: ['远行征战', '急速求成', '冒险投机'],
      menpo: '门迫：休门落坎宫（水入水）为门迫，主休养过度、懒散拖延'
    },
    {
      name: '生门',
      element: '土',
      tendency: 'auspicious',
      characteristics: '生长发展之门，主生机、创造、发展。为上吉之门。',
      suitable: ['求财交易', '开业立业', '婚嫁结盟', '建造种植', '生育求子', '请求升迁'],
      avoid: ['丧葬之事', '讨债催逼', '破坏拆除'],
      menpo: '门迫：生门落艮宫或坤宫（土入土）为门迫，主生机受阻、发展迟缓'
    },
    {
      name: '伤门',
      element: '木',
      tendency: 'inauspicious',
      characteristics: '损伤破坏之门，主伤害、争斗、破败。为中凶之门。',
      suitable: ['讨债催逼', '捕盗缉凶', '竞争争讼', '破除旧物', '体育竞技'],
      avoid: ['婚嫁喜庆', '求财交易', '远行出师', '上表求官', '建造新宅'],
      menpo: '门迫：伤门落震宫或巽宫（木入木）为门迫，主伤害加重、诉讼缠身'
    },
    {
      name: '杜门',
      element: '木',
      tendency: 'neutral',
      characteristics: '闭塞隐藏之门，主隐蔽、阻塞、关闭。为中平之门。',
      suitable: ['隐蔽藏匿', '守密防泄', '闭关修炼', '防守坚守', '避难躲祸'],
      avoid: ['公开推进', '远行求财', '婚嫁喜庆', '开业立业'],
      menpo: '门迫：杜门落震宫或巽宫（木入木）为门迫，主闭塞加重、难以突破'
    },
    {
      name: '景门',
      element: '火',
      tendency: 'neutral',
      characteristics: '光明显露之门，主文书、显扬、光明。为中平之门。',
      suitable: ['文书考试', '显扬名声', '公开宣传', '照明祭祀', '开张营业'],
      avoid: ['隐蔽行事', '逃亡避难', '求医治病', '埋葬修坟'],
      menpo: '门迫：景门落离宫（火入火）为门迫，主光芒过盛、锋芒毕露'
    },
    {
      name: '死门',
      element: '土',
      tendency: 'inauspicious',
      characteristics: '终结死亡之门，主死亡、终止、衰败。为大凶之门。',
      suitable: ['丧葬之事', '吊唁送终', '终止合同', '除旧破败', '狩猎捕鱼'],
      avoid: ['婚嫁喜庆', '求财交易', '远行出师', '开业立业', '建造新宅'],
      menpo: '门迫：死门落艮宫或坤宫（土入土）为门迫，主死气沉沉、衰败加剧'
    },
    {
      name: '惊门',
      element: '金',
      tendency: 'inauspicious',
      characteristics: '惊恐不安之门，主惊扰、争斗、口舌。为中凶之门。',
      suitable: ['竞争争讼', '讨债催逼', '鸣冤申诉', '捕盗缉凶', '惊吓驱邪'],
      avoid: ['婚嫁喜庆', '求财交易', '远行出师', '安居静养'],
      menpo: '门迫：惊门落乾宫或兑宫（金入金）为门迫，主惊恐加剧、口舌不断'
    },
    {
      name: '开门',
      element: '金',
      tendency: 'auspicious',
      characteristics: '开拓进取之门，主开创、开放、通达。为上吉之门。',
      suitable: ['开业立业', '远行出师', '求财交易', '竞争争讼', '婚嫁结盟', '上表求官'],
      avoid: ['丧葬之事', '闭关隐居', '保守防守'],
      menpo: '门迫：开门落乾宫或兑宫（金入金）为门迫，主开拓过度、锋芒太露'
    }
  ]
    
  aboutToAppear() {
    this.loadJiuxingJson()
  }
  
  private loadJiuxingJson() {
    try {
      const context = getContext(this);
      if (!context || !context.resourceManager || !context.resourceManager.getRawFileContent) {
        console.error('[JiuxingBamenKnowledgePage] 无法获取资源管理器');
        return;
      }
  
      context.resourceManager.getRawFileContent('rules/jiuxing_duanyu_rules.json')
        .then((data: Uint8Array) => {
          const jsonStr = this.decodeUtf8(data);
          let parsed: JiuxingJsonFile | null = null;
          try {
            parsed = JSON.parse(jsonStr) as JiuxingJsonFile;
          } catch (e) {
            console.error('[JiuxingBamenKnowledgePage] 解析九星 JSON 失败', JSON.stringify(e));
            return;
          }
      
          if (!parsed || !parsed.rules || !Array.isArray(parsed.rules)) {
            return;
          }
      
          const summaryMap: Record<string, string> = {};
          for (let i = 0; i < parsed.rules.length; i++) {
            const rule = parsed.rules[i];
            if (!rule || rule.category !== '九星断语') {
              continue;
            }
            const ruleName: string = typeof rule.name === 'string' ? rule.name : '';
            const starName: string = this.extractStarNameFromRuleName(ruleName);
            if (!starName) {
              continue;
            }
  
            const parts: string[] = [];
            if (rule.description && typeof rule.description === 'string') {
              parts.push(rule.description);
            }
            if (rule.meaning && typeof rule.meaning === 'string') {
              parts.push('象意：' + rule.meaning);
            }
            if (rule.suitable && Array.isArray(rule.suitable) && rule.suitable.length > 0) {
              parts.push('宜：' + rule.suitable.join('、'));
            }
            if (rule.taboo && Array.isArray(rule.taboo) && rule.taboo.length > 0) {
              parts.push('忌：' + rule.taboo.join('、'));
            }
            if (rule.tips && typeof rule.tips === 'string') {
              parts.push('提示：' + rule.tips);
            }
  
            if (parts.length > 0) {
              summaryMap[starName] = parts.join('\n');
            }
          }
  
          this.starJsonSummary = summaryMap;
        })
        .catch((err: Error) => {
          console.error('[JiuxingBamenKnowledgePage] 读取九星 JSON 失败', JSON.stringify(err));
        });
    } catch (e) {
      console.error('[JiuxingBamenKnowledgePage] loadJiuxingJson 异常', JSON.stringify(e));
    }
  }
  
  private decodeUtf8(bytes: Uint8Array): string {
    let out = '';
    let i = 0;
    while (i < bytes.length) {
      const c = bytes[i++];
      if (c < 0x80) {
        out += String.fromCharCode(c);
      } else if ((c & 0xe0) === 0xc0 && i < bytes.length) {
        const c2 = bytes[i++];
        const code = ((c & 0x1f) << 6) | (c2 & 0x3f);
        out += String.fromCharCode(code);
      } else if ((c & 0xf0) === 0xe0 && i + 1 < bytes.length) {
        const c2 = bytes[i++];
        const c3 = bytes[i++];
        const code = ((c & 0x0f) << 12) | ((c2 & 0x3f) << 6) | (c3 & 0x3f);
        out += String.fromCharCode(code);
      } else if ((c & 0xf8) === 0xf0 && i + 2 < bytes.length) {
        const c2 = bytes[i++];
        const c3 = bytes[i++];
        const c4 = bytes[i++];
        let codePoint = ((c & 0x07) << 18) | ((c2 & 0x3f) << 12) | ((c3 & 0x3f) << 6) | (c4 & 0x3f);
        codePoint -= 0x10000;
        const high = 0xd800 + (codePoint >> 10);
        const low = 0xdc00 + (codePoint & 0x3ff);
        out += String.fromCharCode(high, low);
      } else {
        out += '?';
      }
    }
    return out;
  }
  
  private extractStarNameFromRuleName(ruleName: string): string {
    if (!ruleName) {
      return '';
    }
    if (ruleName.endsWith('星断语')) {
      const length: number = ruleName.length - 3;
      if (length > 0) {
        return ruleName.substring(0, length);
      }
    }
    if (ruleName.endsWith('星')) {
      const length2: number = ruleName.length - 1;
      if (length2 > 0) {
        return ruleName.substring(0, length2);
      }
    }
    return ruleName;
  }
  
  /**
   * 获取倾向标签
   */
  private getTendencyLabel(tendency: string): string {
    const map: Record<string, string> = {
      'auspicious': '吉',
      'inauspicious': '凶',
      'neutral': '平'
    }
    return map[tendency] || '未知'
  }

  /**
   * 获取倾向颜色
   */
  private getTendencyColor(tendency: string): string {
    const map: Record<string, string> = {
      'auspicious': '#4CAF50',
      'inauspicious': '#F44336',
      'neutral': '#FF9800'
    }
    return map[tendency] || '#999999'
  }

  /**
   * 渲染九星卡片
   */
  @Builder
  buildStarCard(star: StarKnowledge) {
    Column({ space: 8 }) {
      // 标题行
      Row({ space: 8 }) {
        Text(star.name)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C2416')
        
        Text(star.alias)
          .fontSize(13)
          .fontColor('#888888')
        
        Blank()
        
        Text(this.getTendencyLabel(star.tendency))
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor(this.getTendencyColor(star.tendency))
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(4)
      }
      .width('100%')

      // 属性信息
      Row({ space: 12 }) {
        Text(`五行：${star.element}`)
          .fontSize(12)
          .fontColor('#666666')
        Text(`旺季：${star.season}`)
          .fontSize(12)
          .fontColor('#666666')
      }
      .width('100%')

      Divider().color('#E0E0E0').strokeWidth(1)

      // 特性
      Text(star.characteristics)
        .fontSize(13)
        .fontColor('#2C2416')
        .lineHeight(20)
        .width('100%')

      // 中卷九星断语（来自 JSON）
      if (this.starJsonSummary[star.name]) {
        Text(this.starJsonSummary[star.name])
          .fontSize(12)
          .fontColor('#4A3B20')
          .lineHeight(18)
          .width('100%')
          .padding({ top: 4 })
          .backgroundColor('#FFFDF5')
          .borderRadius(4)
      }

      // 宜
      Column({ space: 4 }) {
        Text('✓ 适宜：')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#4CAF50')
        
        Text(star.suitable.join('、'))
          .fontSize(12)
          .fontColor('#666666')
          .lineHeight(18)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 忌
      Column({ space: 4 }) {
        Text('✗ 不宜：')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#F44336')
        
        Text(star.avoid.join('、'))
          .fontSize(12)
          .fontColor('#666666')
          .lineHeight(18)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 旺相休囚死
      Text(`📅 ${star.wangxiang}`)
        .fontSize(11)
        .fontColor('#999999')
        .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .shadow({ radius: 4, color: '#22000000', offsetX: 0, offsetY: 2 })
  }

  /**
   * 渲染八门卡片
   */
  @Builder
  buildDoorCard(door: DoorKnowledge) {
    Column({ space: 8 }) {
      // 标题行
      Row({ space: 8 }) {
        Text(door.name)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C2416')
        
        Text(`五行：${door.element}`)
          .fontSize(13)
          .fontColor('#888888')
        
        Blank()
        
        Text(this.getTendencyLabel(door.tendency))
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor(this.getTendencyColor(door.tendency))
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(4)
      }
      .width('100%')

      Divider().color('#E0E0E0').strokeWidth(1)

      // 特性
      Text(door.characteristics)
        .fontSize(13)
        .fontColor('#2C2416')
        .lineHeight(20)
        .width('100%')

      // 宜
      Column({ space: 4 }) {
        Text('✓ 适宜：')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#4CAF50')
        
        Text(door.suitable.join('、'))
          .fontSize(12)
          .fontColor('#666666')
          .lineHeight(18)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 忌
      Column({ space: 4 }) {
        Text('✗ 不宜：')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#F44336')
        
        Text(door.avoid.join('、'))
          .fontSize(12)
          .fontColor('#666666')
          .lineHeight(18)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 门迫说明
      Text(`⚠️ ${door.menpo}`)
        .fontSize(11)
        .fontColor('#FF9800')
        .lineHeight(16)
        .width('100%')
        .padding(8)
        .backgroundColor('#FFF8F0')
        .borderRadius(6)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .shadow({ radius: 4, color: '#22000000', offsetX: 0, offsetY: 2 })
  }

  build() {
    Column({ space: 0 }) {
      // 顶部导航栏
      NavigationBar({ title: '九星八门知识解读' })

      // 标签页
      Tabs({ index: this.currentTabIndex }) {
        // 九星解读标签页
        TabContent() {
          Scroll() {
            Column({ space: 12 }) {
              // 说明卡片
              Text('九星源自北斗七星加左辅右弼，配合洛书九宫，司掌天时、人事、吉凶。以下按九星顺序排列（天蓬、天任、天冲、天辅、天英、天芮、天柱、天心、天禽）。')
                .fontSize(13)
                .fontColor('#666666')
                .lineHeight(20)
                .width('100%')
                .padding(12)
                .backgroundColor('#FFF8F0')
                .borderRadius(8)

              // 原典九星圆式（缩略预览）
              Column({ space: 6 }) {
                Text('原典九星圆式（缩略预览）')
                  .fontSize(12)
                  .fontColor('#888888')
                  .width('100%')

                Image($r('app.media.jiuxingyuantu'))
                  .width('100%')
                  .height(140)
                  .objectFit(ImageFit.Contain)
                  .borderRadius(8)
              }
              .width('100%')
              .padding({ top: 4, bottom: 4 })

              // 九星列表
              ForEach(this.stars, (star: StarKnowledge) => {
                this.buildStarCard(star)
              })
            }
            .width('100%')
            .padding(16)
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Auto)
        }
        .tabBar('九星解读')

        // 八门解读标签页
        TabContent() {
          Scroll() {
            Column({ space: 12 }) {
              // 说明卡片
              Text('八门源自八卦方位，司掌地利、行事、开阖。分为三吉门（开休生）、三平门（杜景惊）、二凶门（伤死）。以下按八卦顺序排列。')
                .fontSize(13)
                .fontColor('#666666')
                .lineHeight(20)
                .width('100%')
                .padding(12)
                .backgroundColor('#FFF8F0')
                .borderRadius(8)

              // 八门列表
              ForEach(this.doors, (door: DoorKnowledge) => {
                this.buildDoorCard(door)
              })
            }
            .width('100%')
            .padding(16)
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Auto)
        }
        .tabBar('八门吉凶')
      }
      .width('100%')
      .layoutWeight(1)
      .onChange((index: number) => {
        this.currentTabIndex = index
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F1E8')
  }
}
