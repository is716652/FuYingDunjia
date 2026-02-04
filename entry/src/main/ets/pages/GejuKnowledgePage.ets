import { NavigationBar } from '../components/NavigationBar'

/**
 * 格局知识库类别
 */
interface GejuCategory {
  id: string;
  title: string;
  description: string;
  patterns: GejuKnowledgeItem[];
}

/**
 * 格局知识条目
 */
interface GejuKnowledgeItem {
  id: string;
  name: string;
  type: 'major_auspicious' | 'minor_auspicious' | 'major_inauspicious' | 'minor_inauspicious' | 'neutral';
  description: string;
  conditions: string[];
  effect: string;
  source: string;
}

interface GejuJsonEffects {
  good?: string[];
  bad?: string[];
}

interface GejuJsonConditions {
  core?: string;
  door?: string;
  ganCombination?: string[];
  deity?: string;
  notes?: string;
}

interface GejuJsonSubRule {
  subId?: string;
  name?: string;
  palace?: string;
  direction?: string;
  description?: string;
  effects?: GejuJsonEffects;
}

interface GejuJsonRule {
  id?: string;
  name?: string;
  category?: string;
  ruleSource?: string;
  description?: string;
  conditions?: GejuJsonConditions;
  effects?: GejuJsonEffects;
  sub_rules?: GejuJsonSubRule[];
}

interface GejuJsonFile {
  rules?: GejuJsonRule[];
}

/**
 * 格局识别与判断页面
 * 
 * 功能：
 * - 分类展示所有格局知识
 * - 大吉格局、强凶格局、对敌战术等分类
 * - 每个格局显示判定条件、效应、来源
 */
@Entry
@Component
struct GejuKnowledgePage {
  @State currentTabIndex: number = 0
  @State showDetailDialog: boolean = false
  @State selectedPattern: GejuKnowledgeItem | null = null
  @State categories: GejuCategory[] = [
    {
      id: 'major_auspicious',
      title: '大吉格局',
      description: '三遁、三奇得使、青龙返首等上佳格局',
      patterns: [
        {
          id: 'sanqi_deshi',
          name: '三奇得使',
          type: 'major_auspicious',
          description: '三奇（乙丙丁）临值使门，为大吉格局',
          conditions: [
            '乙奇临值使门（日奇得使）',
            '丙奇临值使门（月奇得使）',
            '丁奇临值使门（星奇得使）'
          ],
          effect: '主贵人扶助，事半功倍，推进顺利',
          source: '上卷·三奇得使条'
        },
        {
          id: 'tian_dun',
          name: '天遁',
          type: 'major_auspicious',
          description: '丙奇临吉门（生门/开门/休门），得日精之蔽',
          conditions: [
            '丙奇在某宫',
            '该宫门为生门、开门或休门之一'
          ],
          effect: '得天时之利，宜争讼、陈诉、上书、献策等公开推进事项',
          source: '中卷·释天遁条'
        },
        {
          id: 'di_dun',
          name: '地遁',
          type: 'major_auspicious',
          description: '乙奇临开门或杜门，得月精之蔽',
          conditions: [
            '乙奇在某宫',
            '该宫门为开门或杜门'
          ],
          effect: '得地利之便，宜埋葬、修造、建厂、藏兵等稳固性事项',
          source: '中卷·释地遁条'
        },
        {
          id: 'ren_dun',
          name: '人遁',
          type: 'major_auspicious',
          description: '丁奇临杜门，得星精之蔽',
          conditions: [
            '丁奇在某宫',
            '该宫门为杜门'
          ],
          effect: '得人和之助，宜潜藏、匿形、和谈、密谋等隐秘性事项',
          source: '中卷·释人遁条'
        },
        {
          id: 'qinglong_huishou',
          name: '青龙返首',
          type: 'major_auspicious',
          description: '六甲加六丙，龙回首之象',
          conditions: [
            '天盘为甲（含戊己代甲）',
            '地盘为丙'
          ],
          effect: '造举百事皆吉，主声势大振，尤利文书、竞争',
          source: '中卷·青龙返首条'
        },
        {
          id: 'feiniao_diexue',
          name: '飞鸟跌穴',
          type: 'major_auspicious',
          description: '六丙加六甲，鸟归巢之象',
          conditions: [
            '天盘为丙',
            '地盘为甲（含戊己代甲）'
          ],
          effect: '百事皆吉，主计划落地、稳健推进',
          source: '中卷·飞鸟跌穴条'
        }
      ]
    },
    {
      id: 'major_inauspicious',
      title: '强凶格局',
      description: '六仪击刑、天网四张、五不过时等强凶时段',
      patterns: [
        {
          id: 'liuyi_jixing',
          name: '六仪击刑',
          type: 'major_inauspicious',
          description: '甲子、甲戌、甲申、甲辰、甲午、甲寅等日直符加到相应“相刑”地支时，为六仪击刑，凡举大事多凶不可用。',
          conditions: [
            '甲子日直符加卯（子卯相刑）',
            '甲戌日直符加未（丑戌未三刑）',
            '甲申日直符加寅（寅巳申三刑）',
            '甲辰日直符加辰（辰午酉未自刑）',
            '甲午日直符加午（午自刑）',
            '甲寅日直符加巳（工程简化采寅巳刑）'
          ],
          effect: '百事不宜，主反复、阻滞、刑伤',
          source: '中卷·六仪击刑条'
        },
        {
          id: 'tianwang_sizhang',
          name: '天网四张',
          type: 'major_inauspicious',
          description: '“时下得六癸之时”为天网四张，万物尽伤，此时不可举造百事。',
          conditions: [
            '原文：时下得六癸之时',
            '工程实现：以时干为癸近似触发“天网四张”强凶警告'
          ],
          effect: '强凶时段，诸事不宜，主困顿、羁绊',
          source: '中卷·天网四张条'
        },
        {
          id: 'wubu_guoshi',
          name: '五不过时',
          type: 'major_inauspicious',
          description: '时干克日干，损明不可行百事',
          conditions: [
            '时干克日干（如甲日庚时、乙日辛时等）'
          ],
          effect: '强凶禁忌，不可出军、不可行事，主损折',
          source: '下卷·五不过时条'
        },
        {
          id: 'sanqi_rumu',
          name: '三奇入墓',
          type: 'major_inauspicious',
          description: '三奇落入墓地，精华被掩',
          conditions: [
            '乙奇在坤二（土墓，未位在坤）',
            '丙丁奇在乾六（火墓，戌位在乾）'
          ],
          effect: '吉力大减，主谋事不遂、贵人难得',
          source: '中卷·三奇入墓条'
        }
      ]
    },
    {
      id: 'tactical',
      title: '对敌战术',
      description: '太白入荧惑、五不可击等攻守推演规则',
      patterns: [
        {
          id: 'taibai_ru_yinghuo',
          name: '太白入荧惑',
          type: 'minor_auspicious',
          description: '庚加丙，白虎入赤地',
          conditions: [
            '天盘为庚',
            '地盘为丙'
          ],
          effect: '利反击、利突袭，主客快速击溃敌方',
          source: '中卷·太白入荧惑条'
        },
        {
          id: 'yinghuo_ru_taibai',
          name: '荧惑入太白',
          type: 'minor_inauspicious',
          description: '丙加庚，赤炎遇刚金',
          conditions: [
            '天盘为丙',
            '地盘为庚'
          ],
          effect: '敌方退却之象，宜观望、不宜急攻',
          source: '中卷·荧惑入太白条'
        },
        {
          id: 'wubu_keji',
          name: '五不可击',
          type: 'neutral',
          description: '攻守战术中的五个禁攻宫位',
          conditions: [
            '天乙宫（值符所在）',
            '九天宫（对应星宫）',
            '生门三奇宫',
            '九地宫（对应星宫）',
            '直使宫（值使所在）'
          ],
          effect: '此五宫为战术禁区，不可主动攻击，宜守不宜攻',
          source: '下卷·五不可击条'
        }
      ]
    },
    {
      id: 'minor',
      title: '其他格局',
      description: '伏吟、反吟等变动格局',
      patterns: [
        {
          id: 'fu_yin',
          name: '伏吟',
          type: 'neutral',
          description: '天盘地盘相同，静守之象',
          conditions: [
            '某宫天盘天干与地盘天干相同'
          ],
          effect: '主静守为宜，不宜轻举妄动，事多迟滞',
          source: '上卷·伏吟条'
        },
        {
          id: 'fan_yin',
          name: '反吟',
          type: 'neutral',
          description: '对冲格局，变动之象',
          conditions: [
            '甲子与甲午对冲',
            '甲戌与甲辰对冲',
            '甲申与甲寅对冲'
          ],
          effect: '主变动、反复，宜谨慎行事，事多波折',
          source: '上卷·反吟条'
        }
      ]
    }
  ]
  
  aboutToAppear() {
    this.loadGejuJson()
  }
  
  private loadGejuJson() {
    try {
      const context = getContext(this);
      if (!context || !context.resourceManager || !context.resourceManager.getRawFileContent) {
        console.error('[GejuKnowledgePage] 无法获取资源管理器');
        return;
      }
  
      context.resourceManager.getRawFileContent('rules/geju_jixiong_rules.json')
        .then((data: Uint8Array) => {
          const jsonStr = this.decodeUtf8(data);
          let parsed: GejuJsonFile | null = null;
          try {
            parsed = JSON.parse(jsonStr) as GejuJsonFile;
          } catch (e) {
            console.error('[GejuKnowledgePage] 解析格局 JSON 失败', JSON.stringify(e));
            return;
          }
  
          if (!parsed || !parsed.rules || !Array.isArray(parsed.rules)) {
            return;
          }
  
          let newCategories: GejuCategory[] = [];
          for (let i = 0; i < this.categories.length; i++) {
            const category = this.categories[i];
            const copiedPatterns: GejuKnowledgeItem[] = [];
            for (let j = 0; j < category.patterns.length; j++) {
              const p = category.patterns[j];
              copiedPatterns.push({
                id: p.id,
                name: p.name,
                type: p.type,
                description: p.description,
                conditions: p.conditions.slice(),
                effect: p.effect,
                source: p.source
              });
            }
            newCategories.push({
              id: category.id,
              title: category.title,
              description: category.description,
              patterns: copiedPatterns
            });
          }
  
          for (let i = 0; i < parsed.rules.length; i++) {
            const rule = parsed.rules[i];
            if (!rule || !rule.id) {
              continue;
            }
            if (rule.sub_rules && Array.isArray(rule.sub_rules) && rule.sub_rules.length > 0) {
              for (let j = 0; j < rule.sub_rules.length; j++) {
                const subRule = rule.sub_rules[j];
                newCategories = this.addOrUpdatePatternFromJson(rule, subRule, newCategories);
              }
            } else {
              newCategories = this.addOrUpdatePatternFromJson(rule, null, newCategories);
            }
          }
  
          this.categories = newCategories;
        })
        .catch((err: Error) => {
          console.error('[GejuKnowledgePage] 读取格局 JSON 失败', JSON.stringify(err));
        });
    } catch (e) {
      console.error('[GejuKnowledgePage] loadGejuJson 异常', JSON.stringify(e));
    }
  }
  
  private addOrUpdatePatternFromJson(rule: GejuJsonRule, subRule: GejuJsonSubRule | null, categories: GejuCategory[]): GejuCategory[] {
    const targetCategoryId: string = this.mapGejuCategoryId(rule.category);
    if (!targetCategoryId) {
      return categories;
    }
  
    const itemId: string = (subRule && subRule.subId ? subRule.subId : (rule.id ? rule.id : ''));
    const itemName: string = (subRule && subRule.name ? subRule.name : (rule.name ? rule.name : ''));
  
    const conditions: string[] = [];
    if (rule.description && typeof rule.description === 'string') {
      conditions.push(rule.description);
    }
    if (rule.conditions) {
      const cond = rule.conditions;
      if (cond.core) {
        conditions.push(cond.core);
      }
      if (cond.door) {
        conditions.push('门：' + cond.door);
      }
      if (cond.ganCombination && Array.isArray(cond.ganCombination) && cond.ganCombination.length > 0) {
        conditions.push('干组合：' + cond.ganCombination.join('、'));
      }
      if (cond.deity) {
        conditions.push('神：' + cond.deity);
      }
      if (cond.notes) {
        conditions.push(cond.notes);
      }
    }
    if (subRule) {
      if (subRule.palace) {
        conditions.push('宫位：' + subRule.palace);
      }
      if (subRule.direction) {
        conditions.push('方位：' + subRule.direction);
      }
      if (subRule.description && typeof subRule.description === 'string') {
        conditions.push(subRule.description);
      }
    }
  
    const effectsList: string[] = [];
    if (rule.effects) {
      if (rule.effects.good && Array.isArray(rule.effects.good) && rule.effects.good.length > 0) {
        effectsList.push('吉：' + rule.effects.good.join('、'));
      }
      if (rule.effects.bad && Array.isArray(rule.effects.bad) && rule.effects.bad.length > 0) {
        effectsList.push('凶：' + rule.effects.bad.join('、'));
      }
    }
    if (subRule && subRule.effects) {
      if (subRule.effects.good && Array.isArray(subRule.effects.good) && subRule.effects.good.length > 0) {
        effectsList.push('吉：' + subRule.effects.good.join('、'));
      }
      if (subRule.effects.bad && Array.isArray(subRule.effects.bad) && subRule.effects.bad.length > 0) {
        effectsList.push('凶：' + subRule.effects.bad.join('、'));
      }
    }
    const effectText: string = effectsList.join('；');
  
    const item: GejuKnowledgeItem = {
      id: itemId,
      name: itemName,
      type: this.mapGejuType(rule.category),
      description: rule.description && typeof rule.description === 'string' ? rule.description : '',
      conditions: conditions,
      effect: effectText,
      source: rule.ruleSource || ''
    };
  
    for (let i = 0; i < categories.length; i++) {
      const category = categories[i];
      if (category.id === targetCategoryId) {
        const updatedPatterns: GejuKnowledgeItem[] = [];
        let found: boolean = false;
        for (let j = 0; j < category.patterns.length; j++) {
          const existing = category.patterns[j];
          if (existing.id === item.id) {
            updatedPatterns.push(item);
            found = true;
          } else {
            updatedPatterns.push(existing);
          }
        }
        if (!found) {
          updatedPatterns.push(item);
        }
        categories[i] = {
          id: category.id,
          title: category.title,
          description: category.description,
          patterns: updatedPatterns
        };
        break;
      }
    }
  
    return categories;
  }
  
  private mapGejuCategoryId(category: string | undefined): string {
    if (category === '吉格') {
      return 'major_auspicious';
    }
    if (category === '凶格') {
      return 'major_inauspicious';
    }
    if (category === '特殊凶象') {
      return 'minor';
    }
    return '';
  }
  
  private mapGejuType(category: string | undefined): 'major_auspicious' | 'minor_auspicious' | 'major_inauspicious' | 'minor_inauspicious' | 'neutral' {
    if (category === '吉格') {
      return 'major_auspicious';
    }
    if (category === '凶格') {
      return 'major_inauspicious';
    }
    if (category === '特殊凶象') {
      return 'minor_inauspicious';
    }
    return 'neutral';
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
  
  /**
   * 获取格局类型标签
   */
  private getTypeLabel(type: string): string {
    const typeMap: Record<string, string> = {
      'major_auspicious': '大吉',
      'minor_auspicious': '偏吉',
      'major_inauspicious': '大凶',
      'minor_inauspicious': '偏凶',
      'neutral': '中性'
    }
    return typeMap[type] || '未知'
  }

  /**
   * 获取格局类型颜色
   */
  private getTypeColor(type: string): string {
    const colorMap: Record<string, string> = {
      'major_auspicious': '#4CAF50',
      'minor_auspicious': '#8BC34A',
      'major_inauspicious': '#F44336',
      'minor_inauspicious': '#FF9800',
      'neutral': '#9E9E9E'
    }
    return colorMap[type] || '#999999'
  }

  /**
   * 渲染格局卡片
   */
  @Builder
  buildPatternCard(pattern: GejuKnowledgeItem) {
    Column({ space: 8 }) {
      // 标题行
      Row({ space: 8 }) {
        Text(pattern.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C2416')
          .layoutWeight(1)
        
        Text(this.getTypeLabel(pattern.type))
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor(this.getTypeColor(pattern.type))
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(4)
      }
      .width('100%')

      // 描述
      Text(pattern.description)
        .fontSize(13)
        .fontColor('#666666')
        .lineHeight(20)
        .width('100%')

      // 判定条件
      Column({ space: 4 }) {
        Text('判定条件：')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#888888')
        
        ForEach(pattern.conditions, (condition: string) => {
          Row({ space: 6 }) {
            Text('•')
              .fontSize(12)
              .fontColor('#999999')
            Text(condition)
              .fontSize(12)
              .fontColor('#666666')
              .layoutWeight(1)
          }
          .width('100%')
        })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 效应
      Row({ space: 6 }) {
        Text('效应：')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#888888')
        Text(pattern.effect)
          .fontSize(12)
          .fontColor('#2C2416')
          .layoutWeight(1)
      }
      .width('100%')

      // 来源
      Text(`📖 ${pattern.source}`)
        .fontSize(11)
        .fontColor('#999999')
        .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .shadow({ radius: 4, color: '#22000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      this.selectedPattern = pattern
      this.showDetailDialog = true
    })
  }

  /**
   * 格局详情弹窗
   */
  @Builder
  buildDetailDialog() {
    if (this.showDetailDialog && this.selectedPattern) {
      Column({ space: 0 }) {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#80000000')
          .onClick(() => {
            this.showDetailDialog = false
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .position({ x: 0, y: 0 })
      .zIndex(1000)

      // 弹窗内容
      Column({ space: 16 }) {
        // 标题区
        Row({ space: 12 }) {
          Text(this.selectedPattern.name)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2C2416')
            .layoutWeight(1)
          
          Text('×')
            .fontSize(28)
            .fontColor('#666666')
            .onClick(() => {
              this.showDetailDialog = false
            })
        }
        .width('100%')

        Divider().color('#EEEEEE')

        // 滚动区域
        Scroll() {
          Column({ space: 16 }) {
            // 类型标签
            Row() {
              Text(this.getTypeLabel(this.selectedPattern.type))
                .fontSize(13)
                .fontColor('#FFFFFF')
                .backgroundColor(this.getTypeColor(this.selectedPattern.type))
                .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                .borderRadius(6)
            }
            .width('100%')

            // 描述
            Column({ space: 8 }) {
              Text('格局描述')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2C2416')
              Text(this.selectedPattern.description)
                .fontSize(14)
                .fontColor('#4A3B20')
                .lineHeight(22)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(12)
            .backgroundColor('#FFF8F0')
            .borderRadius(8)

            // 判定条件
            Column({ space: 8 }) {
              Text('判定条件')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2C2416')
              
              ForEach(this.selectedPattern.conditions, (condition: string, index: number) => {
                Row({ space: 8 }) {
                  Text(`${index + 1}.`)
                    .fontSize(13)
                    .fontColor('#888888')
                    .width(24)
                  Text(condition)
                    .fontSize(13)
                    .fontColor('#4A3B20')
                    .lineHeight(20)
                    .layoutWeight(1)
                }
                .width('100%')
              })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(12)
            .backgroundColor('#F7F5ED')
            .borderRadius(8)

            // 效应说明
            Column({ space: 8 }) {
              Text('效应说明')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2C2416')
              Text(this.selectedPattern.effect)
                .fontSize(14)
                .fontColor('#4A3B20')
                .lineHeight(22)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(12)
            .backgroundColor('#FFF8F0')
            .borderRadius(8)

            // 来源出处
            Column({ space: 8 }) {
              Text('来源出处')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2C2416')
              Text(`📖 ${this.selectedPattern.source}`)
                .fontSize(13)
                .fontColor('#666666')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(12)
            .backgroundColor('#F7F5ED')
            .borderRadius(8)
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
      .width('85%')
      .height('75%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .shadow({ radius: 16, color: '#44000000', offsetX: 0, offsetY: 4 })
      .position({ x: '7.5%', y: '12.5%' })
      .zIndex(1001)
    }
  }

  build() {
    Column({ space: 0 }) {
      // 顶部导航栏
      NavigationBar({ title: '格局识别与判断' })

      // 标签页
      Tabs({ index: this.currentTabIndex }) {
        ForEach(this.categories, (category: GejuCategory) => {
          TabContent() {
            Scroll() {
              Column({ space: 12 }) {
                // 类别说明
                Text(category.description)
                  .fontSize(13)
                  .fontColor('#666666')
                  .lineHeight(20)
                  .width('100%')
                  .padding(12)
                  .backgroundColor('#FFF8F0')
                  .borderRadius(8)

                // 格局列表
                ForEach(category.patterns, (pattern: GejuKnowledgeItem) => {
                  this.buildPatternCard(pattern)
                })
              }
              .width('100%')
              .padding(16)
            }
            .width('100%')
            .height('100%')
            .scrollBar(BarState.Auto)
          }
          .tabBar(category.title)
        })
      }
      .width('100%')
      .layoutWeight(1)
      .barMode(BarMode.Scrollable)
      .onChange((index: number) => {
        this.currentTabIndex = index
      })

      // 格局详情弹窗
      this.buildDetailDialog()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F1E8')
  }
}
