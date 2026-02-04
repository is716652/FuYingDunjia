import router from '@ohos.router'
import { DunjiaEngine, DunjiaPanResult, DunjiaInput, DunjiaSceneType } from '../utils/DunjiaEngine'
import { DunjiaNineGrid } from '../components/DunjiaNineGrid'
import { DunjiaPalaceDetail } from '../components/DunjiaPalaceDetail'
import { NavigationBar } from '../components/NavigationBar'

/**
 * 用神信息接口
 */
interface YongshenElement {
  element: string;
  elementType: string;
  reason: string;
}

interface AffairCategory {
  id: string;
  name: string;
  icon?: string;
  description?: string;
  primaryYongshen?: YongshenElement[];
  secondaryYongshen?: YongshenElement[];
  judgmentLogic?: string[];
  directionRule?: string;
  timingHints?: string[];
}

interface YongshenMappingFile {
  title?: string;
  categories?: AffairCategory[];
}

/**
 * 三奇应验规则接口
 */
interface AffairSpecificMeanings {
  find_person?: string;
  find_object?: string;
  travel?: string;
  marriage?: string;
  job_interview?: string;
  wealth?: string;
  exam?: string;
  health?: string;
}

interface SanqiPosition {
  qi: string;
  palace: string;
}

interface SanqiSubRule {
  subId: string;
  palace: string;
  direction: string;
  signs: string[];
  timeWindow: string;
  fortune: string;
  tips: string;
  affairSpecificMeanings?: AffairSpecificMeanings;
}

interface SanqiRule {
  id: string;
  name: string;
  category: string;
  ruleSource: string;
  description: string;
  sub_rules?: SanqiSubRule[];
}

interface SanqiRulesFile {
  volume?: string;
  title?: string;
  rules?: SanqiRule[];
}

/**
 * 奇门遁甲九宫盘页面
 * 职责：页面状态管理、组件组合、用神占断指引
 */
@Entry
@Component
struct DunjiaPalacePage {
  @State panResult: DunjiaPanResult | null = null
  @State selectedPalace: number | null = null
  @State loading: boolean = true
  @State currentDateTime: Date = new Date()
  @State selectedAffair: string | null = null
  @State currentAffairInfo: AffairCategory | null = null
  @State showYongshenPanel: boolean = false
  @State affairCategories: AffairCategory[] = []
  @State sanqiRules: SanqiRule[] = []
  @State currentSanqiMeanings: SanqiSubRule[] = []
  
  private engine: DunjiaEngine = DunjiaEngine.getInstance()

  aboutToAppear() {
    // 从路由参数获取时间信息
    const params = router.getParams() as Record<string, Object>
    if (params && params['timestamp']) {
      // 接收时间戳并重建 Date 对象
      const timestamp = params['timestamp'] as number
      this.currentDateTime = new Date(timestamp)
    }
    
    // 加载用神映射规则
    this.loadYongshenRules()
    
    // 加载三奇应验规则
    this.loadSanqiRules()
    
    // 执行排盘计算
    this.computePan()
  }

  /**
   * 加载用神映射规则
   */
  private loadYongshenRules() {
    try {
      const context = getContext(this);
      if (!context || !context.resourceManager || !context.resourceManager.getRawFileContent) {
        console.error('[DunjiaPalacePage] 无法获取资源管理器');
        return;
      }

      context.resourceManager.getRawFileContent('rules/yongshen_mapping_rules.json')
        .then((data: Uint8Array) => {
          const jsonStr = this.decodeUtf8(data);
          let parsed: YongshenMappingFile | null = null;
          try {
            parsed = JSON.parse(jsonStr) as YongshenMappingFile;
          } catch (e) {
            console.error('[DunjiaPalacePage] 解析用神规则 JSON 失败', JSON.stringify(e));
            return;
          }
          if (parsed && parsed.categories && Array.isArray(parsed.categories)) {
            this.affairCategories = parsed.categories;
          }
        })
        .catch((err: Error) => {
          console.error('[DunjiaPalacePage] 读取用神规则 JSON 失败', JSON.stringify(err));
        });
    } catch (e) {
      console.error('[DunjiaPalacePage] loadYongshenRules 异常', JSON.stringify(e));
    }
  }

  /**
   * 加载三奇应验规则
   */
  private loadSanqiRules() {
    try {
      const context = getContext(this);
      if (!context || !context.resourceManager || !context.resourceManager.getRawFileContent) {
        console.error('[DunjiaPalacePage] 无法获取资源管理器');
        return;
      }

      context.resourceManager.getRawFileContent('rules/sanqi_yingyan_rules.json')
        .then((data: Uint8Array) => {
          const jsonStr = this.decodeUtf8(data);
          let parsed: SanqiRulesFile | null = null;
          try {
            parsed = JSON.parse(jsonStr) as SanqiRulesFile;
          } catch (e) {
            console.error('[DunjiaPalacePage] 解析三奇规则 JSON 失败', JSON.stringify(e));
            return;
          }
          if (parsed && parsed.rules && Array.isArray(parsed.rules)) {
            this.sanqiRules = parsed.rules;
          }
        })
        .catch((err: Error) => {
          console.error('[DunjiaPalacePage] 读取三奇规则 JSON 失败', JSON.stringify(err));
        });
    } catch (e) {
      console.error('[DunjiaPalacePage] loadSanqiRules 异常', JSON.stringify(e));
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
   * 排盘计算
   */
  private async computePan() {
    try {
      this.loading = true
        
      const input: DunjiaInput = {
        dateTime: this.currentDateTime,
        longitude: 116.4074,  // 北京经度，实际应从配置或定位获取
        sceneType: DunjiaSceneType.GENERAL_STUDY  // 普通研习
      }
        
      // 调用排盘引擎（异步）
      this.panResult = await this.engine.computePan(input)
        
      this.loading = false
    } catch (err) {
      console.error('排盘计算失败', err)
      this.loading = false
    }
  }
    
  /**
   * 检查是否触发六仪击刑
   */
  private hasLiuyiJixingPattern(): boolean {
    if (!this.panResult || !this.panResult.gejuPatterns) return false;
    for (let i = 0; i < this.panResult.gejuPatterns.length; i++) {
      const p = this.panResult.gejuPatterns[i];
      if (p && p.id === 'liuyi_jixing') {
        return true;
      }
    }
    return false;
  }
    
  /**
   * 检查是否触发天网四张
   */
  private hasTianwangSizhangPattern(): boolean {
    if (!this.panResult || !this.panResult.gejuPatterns) return false;
    for (let i = 0; i < this.panResult.gejuPatterns.length; i++) {
      const p = this.panResult.gejuPatterns[i];
      if (p && p.id === 'tianwang_sizhang') {
        return true;
      }
    }
    return false;
  }
   
  /**
   * 宫位点击回调
   */
  private onPalaceClick = (index: number) => {
    if (this.selectedPalace === index) {
      this.selectedPalace = null  // 再次点击取消选中
    } else {
      this.selectedPalace = index
    }
  }

  /**
   * 调整时间
   */
  private adjustTime(hours: number) {
    const newDateTime = new Date(this.currentDateTime.getTime() + hours * 60 * 60 * 1000);
    this.currentDateTime = newDateTime;
    this.selectedPalace = null; // 清除选中状态
    this.computePan();
  }

  /**
   * 恢复到当前系统时间
   */
  private resetToCurrentTime() {
    this.currentDateTime = new Date();
    this.selectedPalace = null;
    this.computePan();
  }

  /**
   * 切换时辰（跳转到指定时辰的起始时刻）
   */
  private switchToShichen(shiIndex: number) {
    interface ShichenInfo {
      name: string;
      hour: number;
    }

    const shiMap: ShichenInfo[] = [
      { name: '子时', hour: 23 },
      { name: '丑时', hour: 1 },
      { name: '寅时', hour: 3 },
      { name: '卯时', hour: 5 },
      { name: '辰时', hour: 7 },
      { name: '巳时', hour: 9 },
      { name: '午时', hour: 11 },
      { name: '未时', hour: 13 },
      { name: '申时', hour: 15 },
      { name: '酉时', hour: 17 },
      { name: '戌时', hour: 19 },
      { name: '亥时', hour: 21 }
    ];
    
    if (shiIndex >= 0 && shiIndex < shiMap.length) {
      const targetHour = shiMap[shiIndex].hour;
      const newDateTime = new Date(this.currentDateTime);
      newDateTime.setHours(targetHour, 0, 0, 0); // 设置为时辰起始时刻
      this.currentDateTime = newDateTime;
      this.selectedPalace = null;
      this.computePan();
    }
  }

  /**
   * 选择占断事类
   */
  private selectAffair(affairId: string) {
    this.selectedAffair = affairId;
    const affair = this.affairCategories.find(a => a.id === affairId);
    if (affair) {
      this.currentAffairInfo = affair;
      this.showYongshenPanel = true;
      this.filterSanqiMeanings(affairId);
    }
  }

  /**
   * 筛选三奇象意：根据当前事类和盘面中的三奇位置
   */
  private filterSanqiMeanings(affairId: string) {
    this.currentSanqiMeanings = [];
    
    if (!this.panResult || !this.panResult.palaces) {
      return;
    }
    
    // 获取当前盘面中的三奇位置
    const sanqiPositions: SanqiPosition[] = [];
    
    this.panResult.palaces.forEach(palace => {
      if (palace.tianGan) {
        const gan = palace.tianGan;
        if (gan === '乙' || gan === '丙' || gan === '丁') {
          // 将宫位名转换为规则中的格式（如"一宫坎"转为"坎一"）
          let palaceName = '';
          switch(palace.palaceName) {
            case '一宫坎': palaceName = '坎一'; break;
            case '二宫坤': palaceName = '坤二'; break;
            case '三宫震': palaceName = '震三'; break;
            case '四宫巽': palaceName = '巽四'; break;
            case '五宫中': palaceName = '中五'; break;
            case '六宫乾': palaceName = '乾六'; break;
            case '七宫兑': palaceName = '兑七'; break;
            case '八宫艮': palaceName = '艮八'; break;
            case '九宫离': palaceName = '离九'; break;
          }
          
          if (palaceName) {
            const pos: SanqiPosition = { qi: gan, palace: palaceName };
            sanqiPositions.push(pos);
          }
        }
      }
    });
    
    if (sanqiPositions.length === 0) {
      return;
    }
    
    // 根据三奇位置筛选对应的象意
    this.sanqiRules.forEach(rule => {
      if (!rule.sub_rules) return;
      
      // 确定规则类型：日奇、月奇、星奇
      let qiType = '';
      if (rule.id === 'riqi_yingyan') {
        qiType = '乙'; // 日奇
      } else if (rule.id === 'yueqi_yingyan') {
        qiType = '丙'; // 月奇
      } else if (rule.id === 'dingqi_yingyan') {
        qiType = '丁'; // 星奇
      }
      
      // 检查该类奇是否在当前盘面中
      const qiPosition = sanqiPositions.find(p => p.qi === qiType);
      if (!qiPosition) return;
      
      const subRule = rule.sub_rules.find(sr => sr.palace === qiPosition.palace);
      if (subRule && subRule.affairSpecificMeanings) {
        const meaning = this.getMeaningByAffairId(subRule.affairSpecificMeanings, affairId);
        if (meaning) {
          this.currentSanqiMeanings.push(subRule);
        }
      }
    });
  }

  /**
   * 根据subId获取三奇名称
   */
  private getSanqiName(subId: string): string {
    if (subId.startsWith('riqi_')) {
      return '🌞 日奇（乙）';
    } else if (subId.startsWith('yueqi_')) {
      return '🌙 月奇（丙）';
    } else if (subId.startsWith('dingqi_')) {
      return '⭐ 星奇（丁）';
    }
    return '三奇';
  }

  /**
   * 根据事类ID获取象意文本
   */
  private getMeaningByAffairId(meanings: AffairSpecificMeanings, affairId: string): string | undefined {
    switch(affairId) {
      case 'find_person': return meanings.find_person;
      case 'find_object': return meanings.find_object;
      case 'travel': return meanings.travel;
      case 'marriage': return meanings.marriage;
      case 'job_interview': return meanings.job_interview;
      case 'wealth': return meanings.wealth;
      case 'exam': return meanings.exam;
      case 'health': return meanings.health;
      default: return undefined;
    }
  }

  /**
   * 检查是否有象意
   */
  private hasMeaning(sanqi: SanqiSubRule): boolean {
    if (!sanqi.affairSpecificMeanings || !this.selectedAffair) {
      return false;
    }
    const meaning = this.getMeaningByAffairId(sanqi.affairSpecificMeanings, this.selectedAffair);
    return meaning !== undefined && meaning.length > 0;
  }

  /**
   * 构建三奇象意内容
   */
  @Builder
  buildSanqiMeaning(sanqi: SanqiSubRule) {
    if (sanqi.affairSpecificMeanings && this.selectedAffair) {
      Text(this.getMeaningByAffairId(sanqi.affairSpecificMeanings, this.selectedAffair) || '')
        .fontSize(12)
        .fontColor('#333333')
        .lineHeight(20)
        .width('100%')
        .padding(10)
        .backgroundColor('#FFF8E1')
        .borderRadius(6)
        .visibility(this.hasMeaning(sanqi) ? Visibility.Visible : Visibility.None)
    }
  }

  /**
   * 构建三奇提示
   */
  @Builder
  buildSanqiTips(sanqi: SanqiSubRule) {
    if (sanqi.tips && !this.hasMeaning(sanqi)) {
      Row({ space: 6 }) {
        Text('💡')
          .fontSize(12)
        Text(sanqi.tips)
          .fontSize(11)
          .fontColor('#666666')
          .lineHeight(18)
          .layoutWeight(1)
      }
      .width('100%')
    }
  }

  /**
   * 构建事类选择器
   */
  @Builder
  buildAffairSelector() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('🎯 选择占断事类')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C2416')
          .layoutWeight(1)
        
        if (this.showYongshenPanel) {
          Button('收起')
            .fontSize(12)
            .backgroundColor('#F5F1E8')
            .fontColor('#666666')
            .height(28)
            .onClick(() => {
              this.showYongshenPanel = false;
            })
        }
      }
      .width('100%')
      
      // 常用事类快捷按钮
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(this.affairCategories.slice(0, 8), (affair: AffairCategory) => {
          Button() {
            Row({ space: 4 }) {
              if (affair.icon) {
                Text(affair.icon)
                  .fontSize(14)
              }
              Text(affair.name)
                .fontSize(13)
                .fontColor(this.selectedAffair === affair.id ? '#FFFFFF' : '#2C2416')
            }
          }
          .backgroundColor(this.selectedAffair === affair.id ? '#FFD700' : '#FFFFFF')
          .borderRadius(8)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .margin({ right: 8, bottom: 8 })
          .onClick(() => {
            this.selectAffair(affair.id);
          })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#ffffff')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#22000000', offsetX: 0, offsetY: 2 })
  }

  /**
   * 构建用神指引面板
   */
  @Builder
  buildYongshenGuidance() {
    if (this.currentAffairInfo && this.showYongshenPanel) {
      Column({ space: 16 }) {
        // 事类说明
        Row({ space: 8 }) {
          Text(this.currentAffairInfo.icon || '🔮')
            .fontSize(20)
          Column({ space: 4 }) {
            Text(this.currentAffairInfo.name)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')
            if (this.currentAffairInfo.description) {
              Text(this.currentAffairInfo.description)
                .fontSize(12)
                .fontColor('#666666')
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        
        // 主用神
        if (this.currentAffairInfo.primaryYongshen && this.currentAffairInfo.primaryYongshen.length > 0) {
          Column({ space: 8 }) {
            Text('📍 主用神（重点观察）')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')
            
            ForEach(this.currentAffairInfo.primaryYongshen, (yong: YongshenElement) => {
              Row({ space: 10 }) {
                Text(yong.element)
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF6B35')
                  .width(80)
                Text(yong.reason)
                  .fontSize(12)
                  .fontColor('#666666')
                  .lineHeight(18)
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(10)
              .backgroundColor('#FFF8F0')
              .borderRadius(6)
            })
          }
          .width('100%')
        }
        
        // 次用神
        if (this.currentAffairInfo.secondaryYongshen && this.currentAffairInfo.secondaryYongshen.length > 0) {
          Column({ space: 8 }) {
            Text('🔍 次用神（辅助参考）')
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor('#666666')
            
            ForEach(this.currentAffairInfo.secondaryYongshen, (yong: YongshenElement) => {
              Row({ space: 10 }) {
                Text(yong.element)
                  .fontSize(12)
                  .fontColor('#3F51B5')
                  .width(80)
                Text(yong.reason)
                  .fontSize(11)
                  .fontColor('#999999')
                  .lineHeight(16)
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(8)
              .backgroundColor('#F5F5F5')
              .borderRadius(6)
            })
          }
          .width('100%')
        }
        
        // 判断逻辑
        if (this.currentAffairInfo.judgmentLogic && this.currentAffairInfo.judgmentLogic.length > 0) {
          Column({ space: 8 }) {
            Text('⚖️ 判断逻辑')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')
            
            ForEach(this.currentAffairInfo.judgmentLogic, (logic: string) => {
              Row({ space: 6 }) {
                Text('•')
                  .fontSize(12)
                  .fontColor('#FF9800')
                Text(logic)
                  .fontSize(12)
                  .fontColor('#666666')
                  .lineHeight(20)
                  .layoutWeight(1)
              }
              .width('100%')
            })
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FFFBF0')
          .borderRadius(8)
        }
        
        // 方位提示
        if (this.currentAffairInfo.directionRule) {
          Row({ space: 8 }) {
            Text('🧭')
              .fontSize(16)
            Text(this.currentAffairInfo.directionRule)
              .fontSize(12)
              .fontColor('#4A90E2')
              .lineHeight(18)
              .layoutWeight(1)
          }
          .width('100%')
          .padding(10)
          .backgroundColor('#E3F2FD')
          .borderRadius(6)
        }
        
        // 三奇象意（根据事类动态展示）
        if (this.currentSanqiMeanings.length > 0) {
          Column({ space: 12 }) {
            Text('✨ 三奇象意指引')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')
            
            ForEach(this.currentSanqiMeanings, (sanqi: SanqiSubRule) => {
              Column({ space: 8 }) {
                // 标题行：三奇名称 + 宫位方位
                Row({ space: 8 }) {
                  // 确定三奇类型
                  Text(this.getSanqiName(sanqi.subId))
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FF6B35')
                  
                  Text(`${sanqi.palace}（${sanqi.direction}）`)
                    .fontSize(12)
                    .fontColor('#666666')
                  
                  Blank()
                  
                  Text(sanqi.fortune)
                    .fontSize(12)
                    .fontColor(sanqi.fortune === '大吉' ? '#4CAF50' : sanqi.fortune === '吉' ? '#8BC34A' : '#FFC107')
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .backgroundColor(sanqi.fortune === '大吉' ? '#E8F5E9' : sanqi.fortune === '吉' ? '#F1F8E9' : '#FFF9C4')
                    .borderRadius(4)
                }
                .width('100%')
                
                // 应验征兆
                if (sanqi.signs && sanqi.signs.length > 0) {
                  Row({ space: 6 }) {
                    Text('征兆：')
                      .fontSize(11)
                      .fontColor('#999999')
                    Text(sanqi.signs.join('、'))
                      .fontSize(11)
                      .fontColor('#666666')
                      .layoutWeight(1)
                  }
                  .width('100%')
                }
                
                // 时间窗口
                Row({ space: 6 }) {
                  Text('⏱️')
                    .fontSize(12)
                  Text(`时间窗口：${sanqi.timeWindow}`)
                    .fontSize(11)
                    .fontColor('#4A90E2')
                }
                .width('100%')
                
                // 具体事类象意（从affairSpecificMeanings中提取）
                this.buildSanqiMeaning(sanqi)
                
                // 总体提示（如果没有具体事类象意则显示tips）
                this.buildSanqiTips(sanqi)
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#FFFBF0')
              .borderRadius(8)
              .border({ width: 1, color: '#FFE082' })
            })
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#ffffff')
      .borderRadius(12)
      .shadow({ radius: 8, color: '#22000000', offsetX: 0, offsetY: 2 })
    }
  }

  build() {
    Column({ space: 0 }) {
      // 顶部导航栏
      NavigationBar({ title: '九宫时空盘' })
  
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
        // 主内容区域：使用Scroll包裹，九宫盘和宫位详情垂直排列
        Scroll() {
          Column({ space: 16 }) {
            // 占断事类选择器
            this.buildAffairSelector()
            
            // 用神指引面板
            this.buildYongshenGuidance()
            
            // 时间调整按钮组
            Column({ space: 12 }) {
              Row({ space: 8 }) {
                Text('⏰ 时间微调')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2C2416')
                  .layoutWeight(1)
                
                Button('恢复当前')
                  .fontSize(12)
                  .backgroundColor('#4A90E2')
                  .fontColor('#FFFFFF')
                  .height(32)
                  .padding({ left: 12, right: 12 })
                  .onClick(() => this.resetToCurrentTime())
              }
              .width('100%')
              
              // 第一行：减少时间
              Row({ space: 8 }) {
                Button('-2时辰')
                  .fontSize(13)
                  .backgroundColor('#F5F1E8')
                  .fontColor('#666666')
                  .layoutWeight(1)
                  .height(38)
                  .onClick(() => this.adjustTime(-4))
                
                Button('-1时辰')
                  .fontSize(13)
                  .backgroundColor('#F5F1E8')
                  .fontColor('#666666')
                  .layoutWeight(1)
                  .height(38)
                  .onClick(() => this.adjustTime(-2))
                
                Button('-1小时')
                  .fontSize(13)
                  .backgroundColor('#F5F1E8')
                  .fontColor('#666666')
                  .layoutWeight(1)
                  .height(38)
                  .onClick(() => this.adjustTime(-1))
              }
              .width('100%')
              
              // 第二行：增加时间
              Row({ space: 8 }) {
                Button('+1小时')
                  .fontSize(13)
                  .backgroundColor('#D4A574')
                  .fontColor('#FFFFFF')
                  .layoutWeight(1)
                  .height(38)
                  .onClick(() => this.adjustTime(1))
                
                Button('+1时辰')
                  .fontSize(13)
                  .backgroundColor('#D4A574')
                  .fontColor('#FFFFFF')
                  .layoutWeight(1)
                  .height(38)
                  .onClick(() => this.adjustTime(2))
                
                Button('+2时辰')
                  .fontSize(13)
                  .backgroundColor('#D4A574')
                  .fontColor('#FFFFFF')
                  .layoutWeight(1)
                  .height(38)
                  .onClick(() => this.adjustTime(4))
              }
              .width('100%')
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .backgroundColor('#ffffff')
            .borderRadius(12)
            .shadow({ radius: 8, color: '#22000000', offsetX: 0, offsetY: 2 })

            // 功能导航按钮
            Row({ space: 8 }) {
              Button('攻守方位')
                .fontSize(13)
                .backgroundColor('#4ECDC4')
                .fontColor('#FFFFFF')
                .layoutWeight(1)
                .height(40)
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/AttackDefensePage',
                    params: {
                      timestamp: this.currentDateTime.getTime()
                    }
                  })
                })
                          
              Button('值符值使历史')
                .fontSize(13)
                .backgroundColor('#9B59B6')
                .fontColor('#FFFFFF')
                .layoutWeight(1)
                .height(40)
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/ZhiFuZhiShiHistoryPage',
                    params: {
                      timestamp: this.currentDateTime.getTime()
                    }
                  })
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
                        
            // 强凶时段提示（六仪击刑 / 天网四张）
            if (this.hasLiuyiJixingPattern() || this.hasTianwangSizhangPattern()) {
              Column({ space: 6 }) {
                if (this.hasLiuyiJixingPattern()) {
                  Row({ space: 6 }) {
                    Text('⚠️ 六仪击刑')
                      .fontSize(13)
                      .fontColor('#F44336')
                      .fontWeight(FontWeight.Bold)
                    Text('当前为六仪击刑时段，凡举大事多凶，不宜发动关键性行动。')
                      .fontSize(12)
                      .fontColor('#F44336')
                      .lineHeight(18)
                      .layoutWeight(1)
                  }
                  .width('100%')
                }
                if (this.hasTianwangSizhangPattern()) {
                  Row({ space: 6 }) {
                    Text('⚠️ 天网四张')
                      .fontSize(13)
                      .fontColor('#F44336')
                      .fontWeight(FontWeight.Bold)
                    Text('当前为“天网四张”强凶时段，万物尽伤，不宜举造百事。')
                      .fontSize(12)
                      .fontColor('#F44336')
                      .lineHeight(18)
                      .layoutWeight(1)
                  }
                  .width('100%')
                }
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor('#FFEBEE')
              .borderRadius(8)
              .border({ width: 1, color: '#FFCDD2' })
            }
             
            // 九宫格组件
            DunjiaNineGrid({
              panResult: this.panResult,
              selectedPalace: this.selectedPalace,
              onPalaceClick: this.onPalaceClick
            })

            // 宫位详情组件
            DunjiaPalaceDetail({
              panResult: this.panResult,
              selectedPalace: this.selectedPalace
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)  // 水平左对齐
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .align(Alignment.TopStart)  // Scroll内容从顶部开始
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F1E8')
  }
}
