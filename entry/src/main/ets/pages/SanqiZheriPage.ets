import { DunjiaPanResult, DunjiaEngine, DunjiaInput, DunjiaSceneType } from '../utils/DunjiaEngine'
import router from '@ohos.router'
import { SanqiNineGrid } from '../components/SanqiNineGrid'
import { SanqiPalaceDetailPanel } from '../components/SanqiPalaceDetailPanel'

/**
 * 干支类型信息
 */
interface GanzhiTypeInfo {
  type: string;
  level: number;
  color: string;
}

/**
 * 时辰类型信息
 */
interface ShichenTypeInfo {
  type: string;
  desc: string;
  color: string;
}

interface ZeriRiType {
  type?: string;
  alias?: string;
  level?: string;
  relation?: string;
  examples?: string[];
  suitable?: string[];
  taboo?: string[];
  mnemonic?: string;
}

interface WuyangTimeBlock {
  scope?: string;
  stems?: string[];
  attribute?: string;
  strategy?: string;
  suitable?: string[];
  taboo?: string[];
  special?: string;
}

interface RulesJsonRule {
  id?: string;
  name?: string;
  summary?: string;
  types?: ZeriRiType[];
  yangTime?: WuyangTimeBlock;
  yinTime?: WuyangTimeBlock;
}

interface RulesJsonFile {
  rules?: RulesJsonRule[];
}

/**
 * 三奇应验择日页面
 * 
 * 功能:
 * - 专为择日设计的排盘页面
 * - 宫位卡片显示三奇应验信息
 * - 顶部显示干支择日信息
 * - 定制化宫位详情面板
 */

@Entry
@Component
struct SanqiZheriPage {
  @State panResult: DunjiaPanResult | null = null
  @State selectedPalace: number | null = null
  @State loading: boolean = true
  @State currentDateTime: Date = new Date()
  @State sanqiJsonSummary: string = ''
  @State zeriJsonSummary: string = ''
  @State shenshaJsonSummary: string = ''
  private riTypeMapFromJson: Record<string, GanzhiTypeInfo> = {}
  private yangTimeInfoFromJson: WuyangTimeBlock | null = null
  private yinTimeInfoFromJson: WuyangTimeBlock | null = null
  private scroller: Scroller = new Scroller()
  private engine: DunjiaEngine = DunjiaEngine.getInstance()

  aboutToAppear() {
    // 从路由参数获取时间信息
    const params = router.getParams() as Record<string, Object>;
    if (params && params['dateTime']) {
      this.currentDateTime = params['dateTime'] as Date;
    }
    
    // 执行排盘计算
    this.computePan();
    // 加载中卷/下卷 JSON 规则摘要
    this.loadZeriAndSanqiJson();
  }

  /**
   * 排盘计算
   */
  private async computePan() {
    try {
      this.loading = true;
      
      const input: DunjiaInput = {
        dateTime: this.currentDateTime,
        longitude: 116.4074,  // 北京经度
        sceneType: DunjiaSceneType.GENERAL_STUDY
      };
      
      this.panResult = await this.engine.computePan(input);
      
      this.loading = false;
    } catch (err) {
      console.error('排盘计算失败', err);
      this.loading = false;
    }
  }

  private loadZeriAndSanqiJson() {
    try {
      const context = getContext(this);
      if (!context || !context.resourceManager || !context.resourceManager.getRawFileContent) {
        console.error('[SanqiZheriPage] 无法获取资源管理器');
        return;
      }

      context.resourceManager.getRawFileContent('rules/sanqi_yingyan_rules.json')
        .then((data: Uint8Array) => {
          const jsonStr = this.decodeUtf8(data);
          let parsed: RulesJsonFile | null = null;
          try {
            parsed = JSON.parse(jsonStr) as RulesJsonFile;
          } catch (e) {
            console.error('[SanqiZheriPage] 解析三奇应验 JSON 失败', JSON.stringify(e));
            return;
          }
          if (parsed && parsed.rules && Array.isArray(parsed.rules)) {
            const names: string[] = [];
            for (let i = 0; i < parsed.rules.length; i++) {
              const rule = parsed.rules[i];
              if (rule && typeof rule.name === 'string') {
                names.push(rule.name);
              }
            }
            if (names.length > 0) {
              this.sanqiJsonSummary = '三奇应验 JSON 包含：' + names.join('、') + ' 等规则。';
            }
          }
        })
        .catch((err: Error) => {
          console.error('[SanqiZheriPage] 读取三奇应验 JSON 失败', JSON.stringify(err));
        });

      context.resourceManager.getRawFileContent('rules/zeri_yingyong_rules.json')
        .then((data: Uint8Array) => {
          const jsonStr = this.decodeUtf8(data);
          let parsed: RulesJsonFile | null = null;
          try {
            parsed = JSON.parse(jsonStr) as RulesJsonFile;
          } catch (e) {
            console.error('[SanqiZheriPage] 解析择日应用 JSON 失败', JSON.stringify(e));
            return;
          }
          if (parsed && parsed.rules && Array.isArray(parsed.rules)) {
            let summary: string = '';
            const riTypeMap: Record<string, GanzhiTypeInfo> = {};
            for (let i = 0; i < parsed.rules.length; i++) {
              const rule: RulesJsonRule | undefined = parsed.rules[i];
              if (!rule || !rule.id) {
                continue;
              }
              if (rule.id === 'wulei_ri_ji_xiong') {
                if (rule.summary && typeof rule.summary === 'string') {
                  summary = rule.summary;
                }
                if (rule.types && Array.isArray(rule.types)) {
                  for (let j = 0; j < rule.types.length; j++) {
                    const typeInfo: ZeriRiType | undefined = rule.types[j];
                    if (!typeInfo || !typeInfo.type || !typeInfo.examples || !Array.isArray(typeInfo.examples)) {
                      continue;
                    }
                    const typeName: string = typeInfo.type;
                    let level: number = 3;
                    let color: string = '#4CAF50';
                    if (typeName === '宝日') {
                      level = 5;
                      color = '#FFD700';
                    } else if (typeName === '伐日') {
                      level = 0;
                      color = '#F44336';
                    } else if (typeName === '制日') {
                      level = 3;
                      color = '#FF9800';
                    } else if (typeName === '义日' || typeName === '和日') {
                      level = 4;
                      color = '#4CAF50';
                    }
                    for (let k = 0; k < typeInfo.examples.length; k++) {
                      const exampleGanzhi: string = typeInfo.examples[k];
                      if (typeof exampleGanzhi === 'string' && exampleGanzhi !== '') {
                        riTypeMap[exampleGanzhi] = {
                          type: typeName,
                          level: level,
                          color: color
                        };
                      }
                    }
                  }
                }
              }
              if (rule.id === 'wuyang_wuyin_shi') {
                const yangInfo: WuyangTimeBlock | undefined = rule.yangTime;
                const yinInfo: WuyangTimeBlock | undefined = rule.yinTime;
                if (yangInfo) {
                  this.yangTimeInfoFromJson = yangInfo;
                }
                if (yinInfo) {
                  this.yinTimeInfoFromJson = yinInfo;
                }
              }
            }
            if (summary !== '') {
              this.zeriJsonSummary = summary;
            }
            if (Object.keys(riTypeMap).length > 0) {
              this.riTypeMapFromJson = riTypeMap;
            }
          }
        })
        .catch((err: Error) => {
          console.error('[SanqiZheriPage] 读取择日应用 JSON 失败', JSON.stringify(err));
        });

      context.resourceManager.getRawFileContent('rules/shensha_rules.json')
        .then((data: Uint8Array) => {
          const jsonStr = this.decodeUtf8(data);
          let parsed: RulesJsonFile | null = null;
          try {
            parsed = JSON.parse(jsonStr) as RulesJsonFile;
          } catch (e) {
            console.error('[SanqiZheriPage] 解析神煞 JSON 失败', JSON.stringify(e));
            return;
          }
          if (parsed && parsed.rules && Array.isArray(parsed.rules)) {
            const names: string[] = [];
            for (let i = 0; i < parsed.rules.length; i++) {
              const rule = parsed.rules[i];
              if (rule && typeof rule.name === 'string') {
                names.push(rule.name);
              }
            }
            if (names.length > 0) {
              this.shenshaJsonSummary = '神煞 JSON 包含：' + names.join('、') + ' 等规则。';
            }
          }
        })
        .catch((err: Error) => {
          console.error('[SanqiZheriPage] 读取神煞 JSON 失败', JSON.stringify(err));
        });
    } catch (e) {
      console.error('[SanqiZheriPage] loadZeriAndSanqiJson 异常', JSON.stringify(e));
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

  /**
   * 获取日干支类型(宝日/义日/制日/和日/伐日)
   */
  private getRiGanzhiType(): GanzhiTypeInfo {
    if (!this.panResult || !this.panResult.dayInfo) return { type: '未知', level: 0, color: '#999999' };

    const riGanzhi = `${this.panResult.dayInfo.day_gan}${this.panResult.dayInfo.day_zhi}`;
    if (this.riTypeMapFromJson && this.riTypeMapFromJson[riGanzhi]) {
      return this.riTypeMapFromJson[riGanzhi];
    }
    return { type: '和日', level: 3, color: '#4CAF50' };
  }
    
  /**
   * 获取时辰属性(五阳时/五阴时)
   */
  private getShichenType(): ShichenTypeInfo {
    if (!this.panResult || !this.panResult.hourGanZhi) return { type: '未知', desc: '', color: '#999999' };

    const shiGan: string = this.panResult.hourGanZhi.charAt(0);
    let isYang: boolean | null = null;

    if (this.yangTimeInfoFromJson && this.yangTimeInfoFromJson.stems && Array.isArray(this.yangTimeInfoFromJson.stems)) {
      if (this.yangTimeInfoFromJson.stems.indexOf(shiGan) >= 0) {
        isYang = true;
      }
    }
    if (isYang === null && this.yinTimeInfoFromJson && this.yinTimeInfoFromJson.stems && Array.isArray(this.yinTimeInfoFromJson.stems)) {
      if (this.yinTimeInfoFromJson.stems.indexOf(shiGan) >= 0) {
        isYang = false;
      }
    }

    // 如果 JSON 没有覆盖到当前时干, 退回到原来的干类判断
    if (isYang === null) {
      const yangGanFallback: string[] = ['甲', '乙', '丙', '丁', '戊'];
      isYang = yangGanFallback.includes(shiGan);
    }

    if (isYang) {
      let descParts: string[] = [];
      if (this.yangTimeInfoFromJson) {
        if (this.yangTimeInfoFromJson.attribute && typeof this.yangTimeInfoFromJson.attribute === 'string') {
          descParts.push(this.yangTimeInfoFromJson.attribute);
        }
        if (this.yangTimeInfoFromJson.strategy && typeof this.yangTimeInfoFromJson.strategy === 'string') {
          descParts.push(this.yangTimeInfoFromJson.strategy);
        }
      }
      const desc: string = descParts.length > 0 ? descParts.join('，') : '利客先发,高旗鸣鼓';
      return {
        type: '五阳时',
        desc: desc,
        color: '#FF9800'
      };
    } else {
      let descParts2: string[] = [];
      if (this.yinTimeInfoFromJson) {
        if (this.yinTimeInfoFromJson.attribute && typeof this.yinTimeInfoFromJson.attribute === 'string') {
          descParts2.push(this.yinTimeInfoFromJson.attribute);
        }
        if (this.yinTimeInfoFromJson.strategy && typeof this.yinTimeInfoFromJson.strategy === 'string') {
          descParts2.push(this.yinTimeInfoFromJson.strategy);
        }
      }
      const desc2: string = descParts2.length > 0 ? descParts2.join('，') : '利主后动,低旗衔枕';
      return {
        type: '五阴时',
        desc: desc2,
        color: '#3F51B5'
      };
    }
  }
    
  /**
   * 检查五不过时格局
   */
  private checkWuBuGuoShi(): boolean {
    if (!this.panResult || !this.panResult.dayInfo || !this.panResult.hourGanZhi) return false;
      
    const dayGan = this.panResult.dayInfo.day_gan;
    const hourGan = this.panResult.hourGanZhi.charAt(0);
      
    // 五不过时:时干克日干
    const keMap: Record<string, string> = {
      '甲': '庚',  // 甲日庚时(庚克甲)
      '乙': '辛',  // 乙日辛时(辛克乙)
      '丙': '壬',  // 丙日壬时(壬克丙)
      '丁': '癸',  // 丁日癸时(癸克丁)
      '戊': '甲',  // 戊日甲时(甲克戊)
      '己': '乙',  // 己日乙时(乙克己)
      '庚': '丙',  // 庚日丙时(丙克庚)
      '辛': '丁',  // 辛日丁时(丁克辛)
      '壬': '戊',  // 壬日戊时(戊克壬)
      '癸': '己'   // 癸日己时(己克癸)
    };
      
    return keMap[dayGan] === hourGan;
  }
    
  /**
   * 检查五不可击宫位(天乙/九天/生门/九地/直使)
   */
  private getWuBuKeJiPalaces(): number[] {
    if (!this.panResult) return [];
      
    const forbiddenPalaces: number[] = [];
      
    // 1. 天乙宫(值符宫)
    forbiddenPalaces.push(this.panResult.zhiFuPalace);
      
    // 2. 直使宫
    forbiddenPalaces.push(this.panResult.zhiShiPalace);
      
    // 3. 九天宫
    const jiuTianPalace = this.panResult.palaces.findIndex(p => p.deityName === '九天');
    if (jiuTianPalace !== -1) forbiddenPalaces.push(jiuTianPalace);
      
    // 4. 九地宫
    const jiuDiPalace = this.panResult.palaces.findIndex(p => p.deityName === '九地');
    if (jiuDiPalace !== -1) forbiddenPalaces.push(jiuDiPalace);
      
    // 5. 生门宫
    const shengMenPalace = this.panResult.palaces.findIndex(p => p.doorName === '生门');
    if (shengMenPalace !== -1) forbiddenPalaces.push(shengMenPalace);
      
    // 去重
    const uniquePalaces: number[] = [];
    for (const palace of forbiddenPalaces) {
      if (!uniquePalaces.includes(palace)) {
        uniquePalaces.push(palace);
      }
    }
    return uniquePalaces;
  }
  
  /**
   * 获取择日建议
   */
  private getZheriSuggestion(): string {
    const riType = this.getRiGanzhiType();
    const shiType = this.getShichenType();
    const wuBuGuoShi = this.checkWuBuGuoShi();
      
    // 五不过时强凶警告
    if (wuBuGuoShi) {
      return `今日今时犯五不过时格局！时干克日干,纵有吉门亦凶,百事不宜。`;
    }
      
    if (riType.level === 5) {
      return `今日${riType.type},百事皆宜。${shiType.desc}。`;
    } else if (riType.level === 0) {
      return `今日${riType.type},百事忌用!尤其不可出军。`;
    } else {
      return `今日${riType.type},可办一般事务。${shiType.desc}。`;
    }
  }

  build() {
    Column() {
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
        // 顶部择日信息栏
        Column({ space: 12 }) {
        // 标题
        Text('三奇应验择日')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C2416')
        
        // 日期选择按钮
        Button() {
          Row({ space: 8 }) {
            Text('📅')
              .fontSize(16)
            if (this.panResult && this.panResult.dayInfo) {
              Text(`${this.panResult.dayInfo.year}年${this.panResult.dayInfo.month}月${this.panResult.dayInfo.day}日`)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
            } else {
              Text('选择日期')
                .fontSize(14)
            }
          }
        }
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .onClick(() => {
          DatePickerDialog.show({
            start: new Date('1900-1-1'),
            end: new Date('2100-12-31'),
            selected: this.currentDateTime,
            onAccept: (value: DatePickerResult) => {
              this.currentDateTime = new Date(value.year!, value.month! + 1, value.day!);
              this.computePan();
            }
          })
        })
        
        // 日干支信息
        Row({ space: 16 }) {
          Row({ space: 8 }) {
            Text('日干支:')
              .fontSize(13)
              .fontColor('#666666')
            if (this.panResult && this.panResult.dayInfo) {
              Text(`${this.panResult.dayInfo.day_gan}${this.panResult.dayInfo.day_zhi}`)
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getRiGanzhiType().color)
            }
            Text(`(${this.getRiGanzhiType().type})`)
              .fontSize(12)
              .fontColor(this.getRiGanzhiType().color)
              .padding({ left: 2, right: 6, top: 2, bottom: 2 })
              .backgroundColor(this.getRiGanzhiType().color + '22')
              .borderRadius(4)
          }
          
          Row({ space: 8 }) {
            Text('时辰:')
              .fontSize(13)
              .fontColor('#666666')
            if (this.panResult && this.panResult.hourGanZhi) {
              Text(`${this.panResult.hourGanZhi}时`)
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getShichenType().color)
            }
            Text(`(${this.getShichenType().type})`)
              .fontSize(12)
              .fontColor(this.getShichenType().color)
              .padding({ left: 2, right: 6, top: 2, bottom: 2 })
              .backgroundColor(this.getShichenType().color + '22')
              .borderRadius(4)
          }
        }
        .width('100%')
        
        // 择日建议
        Column({ space: 8 }) {
          Text(this.getZheriSuggestion())
            .fontSize(13)
            .fontColor(this.checkWuBuGuoShi() ? '#F44336' : '#2C2416')
            .lineHeight(20)
            .width('100%')
            .padding(12)
            .backgroundColor(this.checkWuBuGuoShi() ? '#FFEBEE' : '#FFF8F0')
            .borderRadius(8)
            .border({ width: 1, color: this.checkWuBuGuoShi() ? '#FFCDD2' : '#FFE4B5' })
                   
          // 五不可击宫位提示
          if (this.getWuBuKeJiPalaces().length > 0) {
            Row({ space: 4 }) {
              Text('⚠️')
                .fontSize(12)
              Text('五不可击宫位:')
                .fontSize(12)
                .fontColor('#666666')
              ForEach(this.getWuBuKeJiPalaces(), (palaceIndex: number) => {
                if (this.panResult && this.panResult.palaces[palaceIndex]) {
                  Text(this.panResult.palaces[palaceIndex].palaceName)
                    .fontSize(11)
                    .fontColor('#FF9800')
                    .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                    .backgroundColor('#FFF3E0')
                    .borderRadius(4)
                }
              })
            }
            .width('100%')
            .padding(10)
            .backgroundColor('#FFFBF5')
            .borderRadius(6)
          }
        
          // 中卷/下卷 JSON 规则概览
          if (this.sanqiJsonSummary !== '' || this.zeriJsonSummary !== '' || this.shenshaJsonSummary !== '') {
            Column({ space: 4 }) {
              if (this.sanqiJsonSummary !== '') {
                Text(this.sanqiJsonSummary)
                  .fontSize(12)
                  .fontColor('#4A3B20')
                  .lineHeight(18)
                  .width('100%')
              }
              if (this.zeriJsonSummary !== '') {
                Text(this.zeriJsonSummary)
                  .fontSize(12)
                  .fontColor('#4A3B20')
                  .lineHeight(18)
                  .width('100%')
              }
              if (this.shenshaJsonSummary !== '') {
                Text(this.shenshaJsonSummary)
                  .fontSize(12)
                  .fontColor('#4A3B20')
                  .lineHeight(18)
                  .width('100%')
              }
            }
            .width('100%')
            .padding(10)
            .backgroundColor('#F7F5ED')
            .borderRadius(6)
          }
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 4, color: '#22000000', offsetX: 0, offsetY: 2 })

      Scroll(this.scroller) {
        Column({ space: 16 }) {
          // 九宫排盘(专用择日组件)
          if (this.panResult) {
            SanqiNineGrid({
              panResult: this.panResult,
              selectedPalace: this.selectedPalace,
              onPalaceClick: (index: number) => {
                this.selectedPalace = index;
              }
            })
          }

          // 三奇应验宫位详情面板
          if (this.selectedPalace !== null) {
            SanqiPalaceDetailPanel({
              panResult: this.panResult,
              selectedPalace: this.selectedPalace
            })
          }
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
