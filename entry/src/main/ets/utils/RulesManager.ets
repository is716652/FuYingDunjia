// RulesManager.ets
// 规则数据管理器 - 负责加载和管理各类规则JSON数据

import { common } from '@kit.AbilityKit';
import { buffer, JSON as ArkJSON } from '@kit.ArkTS';

// ==================== 九星休旺相关接口 ====================
export interface JiuxingStateInfo {
  months: string[];
  monthNames: string[];
  seasonDesc: string;
  reason: string;
}

export interface JiuxingStates {
  wang: JiuxingStateInfo;
  xiang: JiuxingStateInfo;
  si: JiuxingStateInfo;
  qiu: JiuxingStateInfo;
  xiu: JiuxingStateInfo;
}

export interface JiuxingStar {
  id: string;
  name: string;
  palace: string;
  element: string;
  states: JiuxingStates;
}

export interface StateDescription {
  name: string;
  meaning: string;
  fortuneLevel: number;
  color: string;
}

export interface MonthZhiInfo {
  monthNum: number;
  monthName: string;
  season: string;
}

export interface JiuxingWangshuaiRules {
  volume: string;
  title: string;
  description: string;
  stars: JiuxingStar[];
  stateDescriptions: Record<string, StateDescription>;
  monthZhiMapping: Record<string, MonthZhiInfo>;
}

// ==================== 三奇吉凶相关接口 ====================
export interface SanqiBasicInfo {
  id: string;
  name: string;
  alias: string;
  element: string;
  symbolMeaning: string;
}

export interface SanqiCombination {
  combo: string;
  meaning: string;
}

export interface MuKuInfo {
  qi: string;
  muPalace: string;
  muElement: string;
  reason: string;
  severity: number;
}

export interface LiuyiInfo {
  yi: string;
  element: string;
  position: string;
}

export interface KeRelation {
  ke: string;
  example: string;
  meaning: string;
}

export interface XingRelation {
  xing: string;
  meaning: string;
}

export interface SanqiRule {
  id: string;
  name: string;
  category: string;
  condition: string;
  fortune: string;
  fortuneLevel: number;
  description: string;
  application: string[];
  combinations?: SanqiCombination[];
  muKuMapping?: MuKuInfo[];
  liuyiInfo?: LiuyiInfo[];
  keRelations?: KeRelation[];
  xingRelations?: XingRelation[];
}

export interface SanqiJixiongRules {
  volume: string;
  title: string;
  description: string;
  sanqiBasic: Record<string, SanqiBasicInfo>;
  rules: SanqiRule[];
}

// ==================== 十二神吉凶相关接口 ====================
export interface ShiershenApplication {
  general: string;
  travel: string;
  career: string;
  wealth: string;
  marriage: string;
}

export interface ShiershenGod {
  id: string;
  name: string;
  category: string;
  fortuneLevel: number;
  fortune: string;
  originalText: string;
  meaning: string;
  symbol: string;
  suitable: string[];
  taboo: string[];
  application: ShiershenApplication;
  warning?: string;
  note?: string;
  remedy?: string;
}

export interface ShiershenJixiongRules {
  volume: string;
  title: string;
  description: string;
  mnemonic: Record<string, string>;
  gods: ShiershenGod[];
  fortuneLevelDesc: Record<string, string>;
}

// ==================== 九星休旺分析结果接口 ====================
export interface WangshuaiAnalysisResult {
  starName: string;
  starElement: string;
  currentMonthZhi: string;
  currentState: string;
  stateName: string;
  stateColor: string;
  fortuneLevel: number;
  reason: string;
  seasonDesc: string;
}

// ==================== 三奇检测结果接口 ====================
export interface SanqiDetectionResult {
  isXianghui: boolean;
  huiCount: number;
  huiType: string;
  huiDescription: string;
  rumuList: SanqiRumuInfo[];
  hasRumu: boolean;
  overallFortune: string;
  fortuneLevel: number;
  advice: string[];
}

export interface SanqiRumuInfo {
  qi: string;
  qiName: string;
  palace: string;
  reason: string;
}

export interface SanqiPalaceInfo {
  qi: string;
  palace: number;
  palaceName: string;
}

// ==================== 十二神查询结果接口 ====================
export interface ShiershenQueryResult {
  god: ShiershenGod;
  isJi: boolean;
  actionAdvice: string;
  colorTag: string;
}

// ==================== 规则管理器 ====================
export class RulesManager {
  private static instance: RulesManager | null = null;
  private context: common.Context | null = null;

  // 规则数据缓存
  private jiuxingWangshuaiRules: JiuxingWangshuaiRules | null = null;
  private sanqiJixiongRules: SanqiJixiongRules | null = null;
  private shiershenJixiongRules: ShiershenJixiongRules | null = null;

  // 十二地支列表
  private readonly DIZHI_LIST: string[] = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

  // 宫位名称映射
  private readonly PALACE_NAMES: string[] = ['坎一宫', '坤二宫', '震三宫', '巽四宫', '中五宫', '乾六宫', '兑七宫', '艮八宫', '离九宫'];

  private constructor() {}

  public static getInstance(): RulesManager {
    if (!RulesManager.instance) {
      RulesManager.instance = new RulesManager();
    }
    return RulesManager.instance;
  }

  public init(context: common.Context): void {
    this.context = context;
  }

  // ==================== 数据加载方法 ====================

  /**
   * 加载九星休旺规则数据
   */
  public async loadJiuxingWangshuaiRules(): Promise<JiuxingWangshuaiRules | null> {
    if (this.jiuxingWangshuaiRules) {
      return this.jiuxingWangshuaiRules;
    }
    const data = await this.loadJsonFile<JiuxingWangshuaiRules>('rules/jiuxing_wangshuai_rules.json');
    if (data) {
      this.jiuxingWangshuaiRules = data;
    }
    return data;
  }

  /**
   * 加载三奇吉凶规则数据
   */
  public async loadSanqiJixiongRules(): Promise<SanqiJixiongRules | null> {
    if (this.sanqiJixiongRules) {
      return this.sanqiJixiongRules;
    }
    const data = await this.loadJsonFile<SanqiJixiongRules>('rules/sanqi_jixiong_rules.json');
    if (data) {
      this.sanqiJixiongRules = data;
    }
    return data;
  }

  /**
   * 加载十二神吉凶规则数据
   */
  public async loadShiershenJixiongRules(): Promise<ShiershenJixiongRules | null> {
    if (this.shiershenJixiongRules) {
      return this.shiershenJixiongRules;
    }
    const data = await this.loadJsonFile<ShiershenJixiongRules>('rules/shiershen_jixiong_rules.json');
    if (data) {
      this.shiershenJixiongRules = data;
    }
    return data;
  }

  // ==================== 九星休旺分析方法 ====================

  /**
   * 分析单颗九星在指定月份的休旺状态
   * @param starName 九星名称
   * @param monthZhi 月份地支
   */
  public async analyzeStarWangshuai(starName: string, monthZhi: string): Promise<WangshuaiAnalysisResult | null> {
    const rules = await this.loadJiuxingWangshuaiRules();
    if (!rules) {
      return null;
    }

    // 查找对应的星
    let targetStar: JiuxingStar | null = null;
    for (let i = 0; i < rules.stars.length; i++) {
      if (rules.stars[i].name === starName) {
        targetStar = rules.stars[i];
        break;
      }
    }

    if (!targetStar) {
      return null;
    }

    // 确定当前状态
    const stateResult = this.determineState(targetStar.states, monthZhi);
    const stateDesc = rules.stateDescriptions[stateResult.stateKey];

    const result: WangshuaiAnalysisResult = {
      starName: targetStar.name,
      starElement: targetStar.element,
      currentMonthZhi: monthZhi,
      currentState: stateResult.stateKey,
      stateName: stateDesc ? stateDesc.name : stateResult.stateKey,
      stateColor: stateDesc ? stateDesc.color : '#888888',
      fortuneLevel: stateDesc ? stateDesc.fortuneLevel : 3,
      reason: stateResult.reason,
      seasonDesc: stateResult.seasonDesc
    };

    return result;
  }

  /**
   * 分析所有九星在指定月份的休旺状态
   * @param monthZhi 月份地支
   */
  public async analyzeAllStarsWangshuai(monthZhi: string): Promise<WangshuaiAnalysisResult[]> {
    const rules = await this.loadJiuxingWangshuaiRules();
    if (!rules) {
      return [];
    }

    const results: WangshuaiAnalysisResult[] = [];
    for (let i = 0; i < rules.stars.length; i++) {
      const star = rules.stars[i];
      const stateResult = this.determineState(star.states, monthZhi);
      const stateDesc = rules.stateDescriptions[stateResult.stateKey];

      const result: WangshuaiAnalysisResult = {
        starName: star.name,
        starElement: star.element,
        currentMonthZhi: monthZhi,
        currentState: stateResult.stateKey,
        stateName: stateDesc ? stateDesc.name : stateResult.stateKey,
        stateColor: stateDesc ? stateDesc.color : '#888888',
        fortuneLevel: stateDesc ? stateDesc.fortuneLevel : 3,
        reason: stateResult.reason,
        seasonDesc: stateResult.seasonDesc
      };
      results.push(result);
    }

    return results;
  }

  /**
   * 确定星曜在某月的状态
   */
  private determineState(states: JiuxingStates, monthZhi: string): StateResult {
    // 检查各状态
    if (this.monthInList(monthZhi, states.wang.months)) {
      return { stateKey: 'wang', reason: states.wang.reason, seasonDesc: states.wang.seasonDesc };
    }
    if (this.monthInList(monthZhi, states.xiang.months)) {
      return { stateKey: 'xiang', reason: states.xiang.reason, seasonDesc: states.xiang.seasonDesc };
    }
    if (this.monthInList(monthZhi, states.si.months)) {
      return { stateKey: 'si', reason: states.si.reason, seasonDesc: states.si.seasonDesc };
    }
    if (this.monthInList(monthZhi, states.qiu.months)) {
      return { stateKey: 'qiu', reason: states.qiu.reason, seasonDesc: states.qiu.seasonDesc };
    }
    if (this.monthInList(monthZhi, states.xiu.months)) {
      return { stateKey: 'xiu', reason: states.xiu.reason, seasonDesc: states.xiu.seasonDesc };
    }

    return { stateKey: 'xiu', reason: '默认休态', seasonDesc: '' };
  }

  private monthInList(month: string, list: string[]): boolean {
    for (let i = 0; i < list.length; i++) {
      if (list[i] === month) {
        return true;
      }
    }
    return false;
  }

  // ==================== 三奇吉凶检测方法 ====================

  /**
   * 检测三奇相会/分散/入墓状态
   * @param sanqiPalaces 三奇所在宫位信息
   */
  public async detectSanqiJixiong(sanqiPalaces: SanqiPalaceInfo[]): Promise<SanqiDetectionResult> {
    const rules = await this.loadSanqiJixiongRules();

    // 默认结果
    const defaultResult: SanqiDetectionResult = {
      isXianghui: false,
      huiCount: 0,
      huiType: '分散',
      huiDescription: '三奇分散在不同宫位',
      rumuList: [],
      hasRumu: false,
      overallFortune: '凶',
      fortuneLevel: 2,
      advice: ['力量分散难聚', '事情多有反复']
    };

    if (!rules || sanqiPalaces.length === 0) {
      return defaultResult;
    }

    // 统计各宫位的三奇数量
    const palaceCount = new Map<number, string[]>();
    for (let i = 0; i < sanqiPalaces.length; i++) {
      const info = sanqiPalaces[i];
      const existing = palaceCount.get(info.palace);
      if (existing) {
        existing.push(info.qi);
      } else {
        palaceCount.set(info.palace, [info.qi]);
      }
    }

    // 检测相会情况
    let maxHuiCount = 0;
    let huiPalace = -1;
    const entries = Array.from(palaceCount.entries());
    for (let i = 0; i < entries.length; i++) {
      const entry = entries[i];
      if (entry[1].length > maxHuiCount) {
        maxHuiCount = entry[1].length;
        huiPalace = entry[0];
      }
    }

    // 检测入墓情况
    const rumuList: SanqiRumuInfo[] = [];
    for (let i = 0; i < sanqiPalaces.length; i++) {
      const info = sanqiPalaces[i];
      const rumuCheck = this.checkSanqiRumu(info.qi, info.palace);
      if (rumuCheck) {
        rumuList.push(rumuCheck);
      }
    }

    // 构建结果
    const result: SanqiDetectionResult = {
      isXianghui: maxHuiCount >= 2,
      huiCount: maxHuiCount,
      huiType: this.getHuiType(maxHuiCount),
      huiDescription: this.getHuiDescription(maxHuiCount, huiPalace),
      rumuList: rumuList,
      hasRumu: rumuList.length > 0,
      overallFortune: this.calculateOverallFortune(maxHuiCount, rumuList.length),
      fortuneLevel: this.calculateFortuneLevelBySanqi(maxHuiCount, rumuList.length),
      advice: this.generateSanqiAdvice(maxHuiCount, rumuList.length)
    };

    return result;
  }

  private checkSanqiRumu(qi: string, palace: number): SanqiRumuInfo | null {
    // 乙奇入乾六宫为墓
    if (qi === '乙' && palace === 5) {
      return {
        qi: '乙',
        qiName: '日奇',
        palace: '乾六宫',
        reason: '乙木入乾金之墓'
      };
    }
    // 丙奇入乾六宫为墓
    if (qi === '丙' && palace === 5) {
      return {
        qi: '丙',
        qiName: '月奇',
        palace: '乾六宫',
        reason: '丙火入乾金戌墓'
      };
    }
    // 丁奇入艮八宫为墓
    if (qi === '丁' && palace === 7) {
      return {
        qi: '丁',
        qiName: '星奇',
        palace: '艮八宫',
        reason: '丁火入艮土丑墓'
      };
    }
    return null;
  }

  private getHuiType(count: number): string {
    if (count >= 3) {
      return '三奇相会';
    }
    if (count === 2) {
      return '双奇相会';
    }
    return '分散';
  }

  private getHuiDescription(count: number, palace: number): string {
    const palaceName = palace >= 0 && palace < this.PALACE_NAMES.length ? this.PALACE_NAMES[palace] : '未知宫';
    if (count >= 3) {
      return `三奇齐聚${palaceName}，力量最强`;
    }
    if (count === 2) {
      return `双奇相会于${palaceName}，力量较强`;
    }
    return '三奇分散在不同宫位，力量分散';
  }

  private calculateOverallFortune(huiCount: number, rumuCount: number): string {
    if (rumuCount > 0) {
      return '凶';
    }
    if (huiCount >= 3) {
      return '大吉';
    }
    if (huiCount === 2) {
      return '吉';
    }
    return '平';
  }

  private calculateFortuneLevelBySanqi(huiCount: number, rumuCount: number): number {
    if (rumuCount > 0) {
      return 1;
    }
    if (huiCount >= 3) {
      return 5;
    }
    if (huiCount === 2) {
      return 4;
    }
    return 2;
  }

  private generateSanqiAdvice(huiCount: number, rumuCount: number): string[] {
    const advice: string[] = [];
    if (rumuCount > 0) {
      advice.push('有三奇入墓，事情难成');
      advice.push('建议择他日行事');
    } else if (huiCount >= 3) {
      advice.push('三奇相会，诸事皆宜');
      advice.push('可主动出击，求财必得');
    } else if (huiCount === 2) {
      advice.push('双奇相会，力量较好');
      advice.push('需配合其他因素判断');
    } else {
      advice.push('三奇分散，力量减弱');
      advice.push('谋事需多加谨慎');
    }
    return advice;
  }

  // ==================== 十二神吉凶查询方法 ====================

  /**
   * 查询指定十二神的吉凶信息
   * @param godName 神名
   */
  public async queryShiershenJixiong(godName: string): Promise<ShiershenQueryResult | null> {
    const rules = await this.loadShiershenJixiongRules();
    if (!rules) {
      return null;
    }

    // 查找对应的神
    let targetGod: ShiershenGod | null = null;
    for (let i = 0; i < rules.gods.length; i++) {
      if (rules.gods[i].name === godName) {
        targetGod = rules.gods[i];
        break;
      }
    }

    if (!targetGod) {
      return null;
    }

    const isJi = targetGod.fortuneLevel >= 4;
    const colorTag = this.getColorTagByLevel(targetGod.fortuneLevel);

    const result: ShiershenQueryResult = {
      god: targetGod,
      isJi: isJi,
      actionAdvice: isJi ? '可主动行动' : '需谨慎行事',
      colorTag: colorTag
    };

    return result;
  }

  /**
   * 获取所有十二神列表
   */
  public async getAllShiershenList(): Promise<ShiershenGod[]> {
    const rules = await this.loadShiershenJixiongRules();
    if (!rules) {
      return [];
    }
    return rules.gods;
  }

  /**
   * 获取吉神列表
   */
  public async getJiGodsList(): Promise<ShiershenGod[]> {
    const rules = await this.loadShiershenJixiongRules();
    if (!rules) {
      return [];
    }
    const jiGods: ShiershenGod[] = [];
    for (let i = 0; i < rules.gods.length; i++) {
      if (rules.gods[i].fortuneLevel >= 4) {
        jiGods.push(rules.gods[i]);
      }
    }
    return jiGods;
  }

  /**
   * 获取凶神列表
   */
  public async getXiongGodsList(): Promise<ShiershenGod[]> {
    const rules = await this.loadShiershenJixiongRules();
    if (!rules) {
      return [];
    }
    const xiongGods: ShiershenGod[] = [];
    for (let i = 0; i < rules.gods.length; i++) {
      if (rules.gods[i].fortuneLevel <= 2) {
        xiongGods.push(rules.gods[i]);
      }
    }
    return xiongGods;
  }

  private getColorTagByLevel(level: number): string {
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

  // ==================== 通用JSON加载方法 ====================

  private async loadJsonFile<T>(path: string): Promise<T | null> {
    if (!this.context) {
      console.error('RulesManager not initialized with context');
      return null;
    }
    try {
      const value = await this.context.resourceManager.getRawFileContent(path);
      const str = buffer.from(value.buffer).toString();
      return ArkJSON.parse(str) as T;
    } catch (err) {
      console.error(`Failed to load rules data: ${path}`, err);
      return null;
    }
  }
}

// 内部状态结果接口
interface StateResult {
  stateKey: string;
  reason: string;
  seasonDesc: string;
}
