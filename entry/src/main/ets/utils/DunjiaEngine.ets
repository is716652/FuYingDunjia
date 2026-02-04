// DunjiaEngine.ets
// 遁甲时空盘核心引擎（基于《遁甲符应经》规则实现）

import { SolarTermCalculator } from './SolarTermCalculator';
import { CalendarManager, CalendarDayInfo } from './CalendarManager';

export enum DunType {
  YANG = 'yang',
  YIN = 'yin'
}

export enum DunjiaSceneType {
  GENERAL_STUDY = 'general_study',       // 普通研习
  STRATEGY_STUDY = 'strategy_study',     // 局势/布局类研习
  TIME_WINDOW_STUDY = 'time_window'      // 时机窗口研习
}

// 宫位编号 0-8 对应九宫：0=一宫坎, 1=二宫坤, 2=三宫震, 3=四宫巽, 4=五宫中, 5=六宫乾, 6=七宫兑, 7=八宫艮, 8=九宫离
export type PalaceIndex = number;

export interface DunjiaInput {
  /** 公历时间，建议使用真太阳时校正后时间 */
  dateTime: Date;
  /** 地理经度，用于真太阳时与节气研习（东经为正） */
  longitude: number;
  /** 研习场景类型 */
  sceneType: DunjiaSceneType;
}

export interface PalaceState {
  palace: PalaceIndex;     // 宫位索引
  palaceName: string;      // 宫名，如"一宫坎"
  palaceElement: string;   // 宫位五行：水、火、木、金、土
  starName?: string;       // 九星名称，如"天蓬"
  doorName?: string;       // 八门名称，如"生门"
  tianGan?: string;        // 天盘天干（暗干）
  diGan?: string;          // 地盘天干（明干）
  deityName?: string;      // 八神名称，如"九天"、"太阴"等
  isZhiFu?: boolean;       // 是否为值符宫
  isZhiShi?: boolean;      // 是否为值使宫
}

export interface RuleHit {
  id: string;              // 规则唯一标识，如"sanqi_deshi"、"qinglong_huishou"
  name: string;            // 规则名称，如"三奇得使"
  level: 'info' | 'hint' | 'focus'; // 提示等级（用于UI呈现权重）
  description: string;     // 面向研习者的结构化说明文案（不做个人预测）
}

export interface EvaluationSummary {
  /** 简短结构特征标签，如"偏向主动推进"、"结构偏稳健" */
  structureTag: string;
  /** 概览说明，用于研习参考 */
  overview: string;
  /** 建议关注的宫位或要素，用于学习提示 */
  focusPoints: string[];
}

export interface DunjiaPanResult {
  /** 阴遁/阳遁 */
  dunType: DunType;
  /** 局数，例如 "阳遁三局" */
  juLabel: string;
  /** 原始输入（便于回显） */
  input: DunjiaInput;
  /** 值符所在宫 */
  zhiFuPalace: PalaceIndex;
  /** 值使所在宫 */
  zhiShiPalace: PalaceIndex;
  /** 九宫详细状态 */
  palaces: PalaceState[];
  /** 命中的结构规则列表（不直接输出吉凶，只说明结构特征） */
  ruleHits: RuleHit[];
  /** 针对当前场景的整体结构评估（研习向描述） */
  summary: EvaluationSummary;
  /** 当日干支信息（包含农历） */
  dayInfo?: CalendarDayInfo;
  /** 时辰干支 */
  hourGanZhi?: string;
  /** 真太阳时偏移量（分钟） */
  solarTimeOffset?: number;
  /** 识别的格局列表 */
  gejuPatterns?: GejuPattern[];
}

/**
 * 格局模式接口
 */
export interface GejuPattern {
  id: string;
  name: string;  // 格局名称，如"三奇得使"、"天遁"
  description: string;  // 格局说明
  palaceIndices: number[];  // 涉及的宫位索引
  level: 'minor' | 'major' | 'special';  // 次要、主要、特殊格局
}

// 核心引擎：负责从时间/地点计算出完整的遁甲盘与结构化分析
export class DunjiaEngine {
  private static instance: DunjiaEngine | null = null;

  private constructor() {}

  static getInstance(): DunjiaEngine {
    if (!DunjiaEngine.instance) {
      DunjiaEngine.instance = new DunjiaEngine();
    }
    return DunjiaEngine.instance;
  }

  /**
   * 从输入参数计算完整的遁甲盘面与结构分析结果。
   */
  public async computePan(input: DunjiaInput): Promise<DunjiaPanResult> {
    const date = input.dateTime;
    
    // 1. 获取干支信息
    const dayInfo = await this.getDayGanZhi(date);
    if (!dayInfo) {
      return this.createEmptyPan(input);
    }

    // 2. 确定阴阳遁与局数
    const ju = this.calculateJu(date, dayInfo);
    
    // 3. 计算当前时轰
    const hour = date.getHours();
    const hourGanZhi = this.getHourGanZhi(dayInfo.day_gan, hour);
    
    // 4. 计算值符值使位置
    const zhiFuZhiShi = this.calculateZhiFuZhiShi(ju, hourGanZhi);
    ju.zhiFuPalace = zhiFuZhiShi.zhiFuPalace;
    ju.zhiShiPalace = zhiFuZhiShi.zhiShiPalace;
    
    // 5. 布九宫（九星、八门、三奇六仪、八神）
    const palaces = this.layoutPalaces(ju, date, dayInfo, hourGanZhi);
    
    // 6. 生成规则命中与结构总结
    const ruleHits: RuleHit[] = [];
    const summary: EvaluationSummary = {
      structureTag: this.generateStructureTag(ju),
      overview: `当前为${ju.dunType === DunType.YANG ? '阳遁' : '阴遁'}${ju.juNumber}局，值符在${palaces[ju.zhiFuPalace].palaceName}，值使在${palaces[ju.zhiShiPalace].palaceName}`,
      focusPoints: [] as string[]
    };
    
    // 8. 识别格局
    const gejuPatterns = this.identifyGejuPatterns(ju, palaces, dayInfo, hourGanZhi);

    return {
      dunType: ju.dunType,
      juLabel: `${ju.dunType === DunType.YANG ? '阳遁' : '阴遁'}${ju.juNumber}局`,
      input,
      zhiFuPalace: ju.zhiFuPalace,
      zhiShiPalace: ju.zhiShiPalace,
      palaces,
      ruleHits,
      summary,
      dayInfo: dayInfo,
      hourGanZhi: `${hourGanZhi.gan}${hourGanZhi.zhi}`,
      solarTimeOffset: this.calculateSolarTimeOffset(input.longitude),
      gejuPatterns: gejuPatterns
    };
  }

  // ========== 内部算法实现 ==========

  /**
   * 计算时轰干支
   */
  private getHourGanZhi(dayGan: string, hour: number): HourGanZhi {
    // 十二时轰对应的地支
    const zhiList = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    
    // 根据小时确定时轰（23-1点为子时，1-3点为丑时...）
    let zhiIndex = 0;
    if (hour >= 23 || hour < 1) {
      zhiIndex = 0; // 子
    } else {
      zhiIndex = Math.floor((hour + 1) / 2);
    }
    
    const hourZhi = zhiList[zhiIndex];
    
    // 根据日干起时法计算时干（甲己起甲子，乙庚起丙子...）
    const ganList = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    const dayGanIndex = ganList.indexOf(dayGan);
    
    // 日干起时表：甲己日从甲子起，乙庚日从丙子起...
    const hourGanStart = (dayGanIndex % 5) * 2;
    const hourGanIndex = (hourGanStart + zhiIndex) % 10;
    const hourGan = ganList[hourGanIndex];
    
    return {
      gan: hourGan,
      zhi: hourZhi,
      ganIndex: hourGanIndex,
      zhiIndex: zhiIndex
    };
  }

  /**
   * 计算值符值使位置
   * 根据《遁甲符应经》规则：
   * - 值符跟随时干：甲在局数宫，乙丙丁...顺次飞布
   * - 值使跟随时支：根据时支确定门的位置
   */
  private calculateZhiFuZhiShi(ju: JuInfo, hourGanZhi: HourGanZhi): ZhiFuZhiShiInfo {
    const ganList = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    
    // 1. 计算值符宫：根据时干偏移量
    // 根据《遁甲符应经二》：以旬头所守宫星为直符，寻卧盘甲子戊即是
    // 时干相对甲的偏移量
    const baseGanIndex = ganList.indexOf('甲'); // 0
    const ganOffset = hourGanZhi.ganIndex - baseGanIndex; // 甲=0, 乙=1, 丙=2...
    
    // 从局数宫开始飞布，根据阴阳遁顺逆飞，跳过中宫
    const startPalace = ju.juNumber - 1; // 阳一局从0（一宫）起，阳二局从1（二宫）起
    let zhiFuPalace = startPalace;
    
    if (ju.dunType === DunType.YANG) {
      // 阳遁顺飞，跳过中宫
      for (let i = 0; i < ganOffset; i++) {
        zhiFuPalace = (zhiFuPalace + 1) % 9;
        // 跳过中宫（索引4）
        if (zhiFuPalace === 4) {
          zhiFuPalace = (zhiFuPalace + 1) % 9;
        }
      }
    } else {
      // 阴遁逆飞，跳过中宫
      for (let i = 0; i < ganOffset; i++) {
        zhiFuPalace = (zhiFuPalace - 1 + 9) % 9;
        // 跳过中宫（索引4）
        if (zhiFuPalace === 4) {
          zhiFuPalace = (zhiFuPalace - 1 + 9) % 9;
        }
      }
    }
    
    // 2. 计算值使宫：根据时支确定（使用calculateZhiShiPalace方法）
    const zhiShiPalace = this.calculateZhiShiPalace(ju.juNumber, ju.dunType, hourGanZhi);
    
    return {
      zhiFuPalace,
      zhiShiPalace
    };
  }
  private async getDayGanZhi(date: Date): Promise<CalendarDayInfo | null> {
    const manager = CalendarManager.getInstance();
    return await manager.getDayInfo(date.getFullYear(), date.getMonth() + 1, date.getDate());
  }

  /**
   * 计算局数（根据节气与元数）
   * 注意：只返回阴阳遁类型和局数，值符值使位置需要时辰信息，在computePan中单独计算
   */
  private calculateJu(date: Date, dayInfo: CalendarDayInfo): JuInfo {
    // 获取最近节气
    const solarTerm = SolarTermCalculator.getInstance().getSolarTermByDate(date);
    const solarTermName = solarTerm ? solarTerm.name : dayInfo.solar_term;
    
    // 判断阴遁还是阳遁（冬至后阳遁，夏至后阴遁）
    const dunType = this.getDunType(solarTermName);
    
    // 根据节气与元数查局数表
    const juNumber = this.getJuNumber(solarTermName, dayInfo, dunType);
    
    // 值符值使位置临时设为中宫，将在computePan中通过calculateZhiFuZhiShi重新计算
    const zhiFuPalace = 4; // 占位值，后续会被覆盖
    const zhiShiPalace = 4;
    
    return {
      dunType,
      juNumber,
      zhiFuPalace,
      zhiShiPalace
    } as JuInfo;
  }

  /**
   * 判断阴阳遁
   */
  private getDunType(solarTermName: string): DunType {
    const yangTerms = ['冬至', '小寒', '大寒', '立春', '雨水', '惊蛰', '春分', '清明', '谷雨', '立夏', '小满', '芒种'];
    return yangTerms.includes(solarTermName) ? DunType.YANG : DunType.YIN;
  }

  /**
   * 根据节气查局数（简化版）
   */
  private getJuNumber(solarTermName: string, dayInfo: CalendarDayInfo, dunType: DunType): number {
    // 根据《遁甲符应经》的阳遁阴遁局数表
    const yangJuMap: Record<string, number[]> = {
      '冬至': [1, 7, 4], '惊蛰': [1, 7, 4],
      '小寒': [2, 8, 5],
      '大寒': [3, 9, 6], '春分': [3, 9, 6],
      '芒种': [6, 3, 9],
      '谷雨': [5, 2, 8], '小满': [5, 2, 8],
      '立春': [8, 5, 2],
      '清明': [4, 1, 7], '立夏': [4, 1, 7]
    };
    
    const yinJuMap: Record<string, number[]> = {
      '夏至': [9, 3, 6], '白露': [9, 3, 6],
      '小暑': [8, 2, 5],
      '大暑': [7, 1, 4], '秋分': [7, 1, 4],
      '立秋': [2, 5, 8],
      '霜降': [5, 8, 2], '小雪': [5, 8, 2],
      '大雪': [4, 7, 1],
      '处暑': [1, 4, 7],
      '立冬': [6, 9, 3], '寒露': [6, 9, 3]
    };
    
    const juMap = dunType === DunType.YANG ? yangJuMap : yinJuMap;
    const juArray = juMap[solarTermName] || [1, 1, 1];
    
    // 根据《遁甲符应经》规则：按地支仲孟季判断上中下元
    const yuanIndex = this.getYuanIndex(dayInfo.day_gan, dayInfo.day_zhi);
    return juArray[yuanIndex];
  }

  /**
   * 获取上中下元索引（0=上，1=中，2=下）
   * 根据《遁甲符应经》规则：甲己日按地支仲孟季判断
   * - 仲日（子午卯酉）→ 上元
   * - 孟日（寅申巳亥）→ 中元
   * - 季日（辰戌丑未）→ 下元
   */
  private getYuanIndex(dayGan: string, dayZhi: string): number {
    // 只有甲日或己日才是符头
    if (dayGan !== '甲' && dayGan !== '己') {
      // 非符头日：暂时返回上元（严格算法需往前找最近符头）
      return 0;
    }
    
    // 根据地支判断仲孟季
    const zhongZhi = ['子', '午', '卯', '酉'];  // 仲 → 上元
    const mengZhi = ['寅', '申', '巳', '亥'];   // 孟 → 中元
    const jiZhi = ['辰', '戌', '丑', '未'];     // 季 → 下元
    
    if (zhongZhi.includes(dayZhi)) {
      return 0;  // 上元
    } else if (mengZhi.includes(dayZhi)) {
      return 1;  // 中元
    } else if (jiZhi.includes(dayZhi)) {
      return 2;  // 下元
    }
    
    return 0;  // 默认上元
  }

  /**
   * 布局九宫（九星、八门、三奇六仪、八神）
   */
  private layoutPalaces(ju: JuInfo, date: Date, dayInfo: CalendarDayInfo, hourGanZhi: HourGanZhi): PalaceState[] {
    const palaceNames: string[] = ['一宫坎', '二宫坤', '三宫震', '四宫巽', '五宫中', '六宫乾', '七宫兑', '八宫艮', '九宫离'];
    const palaceElements: string[] = ['水', '土', '木', '木', '土', '金', '金', '土', '火'];
    
    // 布九星
    const stars = this.layoutStars(ju.juNumber, ju.dunType);
    
    // 布八门
    const doors = this.layoutDoors(ju.juNumber, ju.dunType, hourGanZhi);
    
    // 布三奇六仪（天盘地盘天干）
    const tianPan = this.layoutTianGan(ju, hourGanZhi, true);  // 天盘（暗干）
    const diPan = this.layoutTianGan(ju, hourGanZhi, false);   // 地盘（明干）
    
    // 布八神
    const deities = this.layoutDeities(ju, hourGanZhi);
    
    return palaceNames.map((name: string, index: number): PalaceState => {
      return {
        palace: index as PalaceIndex,
        palaceName: name,
        palaceElement: palaceElements[index],
        starName: stars[index],
        doorName: doors[index],
        tianGan: tianPan[index],
        diGan: diPan[index],
        deityName: deities[index],
        isZhiFu: index === ju.zhiFuPalace,
        isZhiShi: index === ju.zhiShiPalace
      } as PalaceState;
    });
  }

  /**
   * 布九星（固定布局，根据《遁甲符应经》）
   * 九星固定对应九宫（地盘），不随局数飞布
   * 天蓬主一宫、天芮主二宫...天英主九宫
   * 值符是在此固定九星盘上的标记，会根据时辰移动
   */
  private layoutStars(juNumber: number, dunType: DunType): string[] {
    // 九星固定对应九宫（索引0=一宫，1=二宫...8=九宫）
    // 根据《遁甲符应经》：天蓬主一宫、天芮主二宫、天冲主三宫、天辅主四宫、
    // 天禽主五宫、天心主六宫、天柱主七宫、天任主八宫、天英主九宫
    return ['天蓬', '天芮', '天冲', '天辅', '天禽', '天心', '天柱', '天任', '天英'];
  }

  /**
   * 布八门（固定布局，根据《遁甲符应经》）
   * 八门固定对应九宫（地盘），不随局数飞布
   * 休门在坎一、死门在坤二、伤门在震三、杜门在巽四、中宫无门、开门在乾六、惊门在兑七、生门在艮八、景门在离九
   * 值使是在此固定八门盘上的标记，会根据时辰移动
   * @param juNumber 局数
   * @param dunType 阴阳遁
   * @param hourGanZhi 时辰干支信息
   */
  private layoutDoors(juNumber: number, dunType: DunType, hourGanZhi: HourGanZhi): string[] {
    // 八门固定对应九宫（索引0=一宫，1=二宫...8=九宫）
    // 根据《遁甲符应经》：休门在坎一、死门在坤二、伤门在震三、杜门在巽四、
    // 中宫无门、开门在乾六、惊门在兑七、生门在艮八、景门在离九
    return ['休门', '死门', '伤门', '杜门', '', '开门', '惊门', '生门', '景门'];
  }
  
  /**
   * 计算值使宫位
   * 根据《遁甲符应经》：值使门跟随时支移动
   * - 值使门的起始位置：阳遁从休门（一宫），阴遁从景门（九宫）
   * - 每过一个时轰，值使门移动一宫
   * @param juNumber 局数
   * @param dunType 阴阳遁
   * @param hourGanZhi 时辰干支信息
   */
  private calculateZhiShiPalace(juNumber: number, dunType: DunType, hourGanZhi: HourGanZhi): PalaceIndex {
    // 根据《遁甲符应经》白话文第187-190行：
    // 阳遁：直使起于一宫（休门），顺行
    // 阴遁：直使起于九宫（景门），逆行
    
    // 计算时干相对甲的偏移量（用时干索引）
    // 甲=0, 乙=1, 丙=2, 丁=3, 戊=4...
    const ganOffset = hourGanZhi.ganIndex;
    
    let zhiShiPalace: number;
    if (dunType === DunType.YANG) {
      // 阳遁：从一宫（0）开始顺飞，跳过中宫
      zhiShiPalace = 0; // 从一宫起
      for (let i = 0; i < ganOffset; i++) {
        zhiShiPalace = (zhiShiPalace + 1) % 9;
        // 跳过中宫（索引4）
        if (zhiShiPalace === 4) {
          zhiShiPalace = (zhiShiPalace + 1) % 9;
        }
      }
    } else {
      // 阴遁：从九宫（8）开始逆飞，跳过中宫
      zhiShiPalace = 8; // 从九宫起
      for (let i = 0; i < ganOffset; i++) {
        zhiShiPalace = (zhiShiPalace - 1 + 9) % 9;
        // 跳过中宫（索引4）
        if (zhiShiPalace === 4) {
          zhiShiPalace = (zhiShiPalace - 1 + 9) % 9;
        }
      }
    }
    
    return zhiShiPalace as PalaceIndex;
  }

  /**
   * 布三奇六仪（天干）
   * @param isTianPan true=天盘（暗干），false=地盘（明干）
   * @param ju 局信息
   * @param hourGanZhi 时辰干支信息
   */
  private layoutTianGan(ju: JuInfo, hourGanZhi: HourGanZhi, isTianPan: boolean): string[] {
    const ganList = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    const result: string[] = new Array(9).fill('');
    
    if (isTianPan) {
      // 天盘：根据《遁甲符应经》规则精确布局三奇六仪
      // 根据《景祐遁甲符应经二》：阳遁顺布六仪逆布三奇，阴遁逆布六仪顺布三奇
      // 六仪：戊、己、庚、辛、壬、癸
      // 三奇：乙、丙、丁
      
      // 首先确定值符的位置（甲在值符宫）
      const zhiFuPalace = ju.zhiFuPalace;
      
      // 根据局数确定起始宫位（阳一局从一宫起，阴九局从九宫起）
      const startPalace = ju.juNumber - 1;
      
      if (ju.dunType === DunType.YANG) {
        // 阳遁：顺布六仪、逆布三奇
        const liuyi = ['戊', '己', '庚', '辛', '壬', '癸'];  // 六仪
        const sanqi = ['丁', '丙', '乙'];  // 三奇（逆序）
        
        // 1. 从起始宫顺布六仪
        let palaceIndex = startPalace;
        for (const yi of liuyi) {
          // 跳过中宫
          if (palaceIndex === 4) {
            palaceIndex = (palaceIndex + 1) % 9;
          }
          result[palaceIndex] = yi;
          palaceIndex = (palaceIndex + 1) % 9;
        }
        
        // 2. 继续顺飞布三奇（但顺序是逆的：丁、丙、乙）
        for (const qi of sanqi) {
          if (palaceIndex === 4) {
            palaceIndex = (palaceIndex + 1) % 9;
          }
          result[palaceIndex] = qi;
          palaceIndex = (palaceIndex + 1) % 9;
        }
      } else {
        // 阴遁：逆布六仪、顺布三奇
        const liuyi = ['戊', '己', '庚', '辛', '壬', '癸'];  // 六仪
        const sanqi = ['乙', '丙', '丁'];  // 三奇（顺序）
        
        // 1. 从起始宫逆布六仪
        let palaceIndex = startPalace;
        for (const yi of liuyi) {
          // 跳过中宫
          if (palaceIndex === 4) {
            palaceIndex = (palaceIndex - 1 + 9) % 9;
          }
          result[palaceIndex] = yi;
          palaceIndex = (palaceIndex - 1 + 9) % 9;
        }
        
        // 2. 继续逆飞布三奇（顺序是顺的：乙、丙、丁）
        for (const qi of sanqi) {
          if (palaceIndex === 4) {
            palaceIndex = (palaceIndex - 1 + 9) % 9;
          }
          result[palaceIndex] = qi;
          palaceIndex = (palaceIndex - 1 + 9) % 9;
        }
      }
    } else {
      // 地盘：固定布局（与九宫固定对应）
      // 根据《遁甲符应经·中卷》：冬至上元阳一局甲己之日甲子时，
      // 六甲在一宫、六乙在九宫、六丙在八宫、六丁在七宫、六戊在一宫、
      // 六己在二宫、六庚在三宫、六辛在四宫、六壬在五宫、六癸在六宫
      // 地盘排列：戊、己、庚、辛、壬、癸、丁、丙、乙
      // 中宫（索引4）位置在壬
      const diPanGans = ['戊', '己', '庚', '辛', '壬', '癸', '丁', '丙', '乙'];
      for (let i = 0; i < 9 && i < diPanGans.length; i++) {
        result[i] = diPanGans[i];
      }
    }
    
    return result;
  }

  /**
   * 布八神（九天、九地、太阴、六合、白虎、玄武、朱雀、腾蛇）
   */
  private layoutDeities(ju: JuInfo, hourGanZhi: HourGanZhi): string[] {
    const deityNames = ['值符', '腾蛇', '太阴', '六合', '白虎', '玄武', '九地', '九天'];
    const result: string[] = new Array(9).fill('');
    
    // 根据《遁甲符应经》：九天九地太阴六合的定位规则
    // 冬至后阳遁：值符后一为九天，后二为九地，前二为太阴，前三为六合
    // 夏至后阴遁：值符前一为九天，前二为九地，后二为太阴，后三为六合
    
    const zhiFuPalace = ju.zhiFuPalace;
    
    if (ju.dunType === DunType.YANG) {
      // 阳遁：后一九天，后二九地，前二太阴，前三六合
      result[zhiFuPalace] = '值符';
      result[(zhiFuPalace + 1) % 9] = '九天';
      result[(zhiFuPalace + 2) % 9] = '九地';
      result[(zhiFuPalace - 2 + 9) % 9] = '太阴';
      result[(zhiFuPalace - 3 + 9) % 9] = '六合';
      // 其余四位填充其他神煤
      result[(zhiFuPalace + 3) % 9] = '白虎';
      result[(zhiFuPalace + 4) % 9] = '玄武';
      result[(zhiFuPalace - 1 + 9) % 9] = '腾蛇';
    } else {
      // 阴遁：前一九天，前二九地，后二太阴，后三六合
      result[zhiFuPalace] = '值符';
      result[(zhiFuPalace - 1 + 9) % 9] = '九天';
      result[(zhiFuPalace - 2 + 9) % 9] = '九地';
      result[(zhiFuPalace + 2) % 9] = '太阴';
      result[(zhiFuPalace + 3) % 9] = '六合';
      // 其余四位填充其他神煤
      result[(zhiFuPalace - 3 + 9) % 9] = '白虎';
      result[(zhiFuPalace - 4 + 9) % 9] = '玄武';
      result[(zhiFuPalace + 1) % 9] = '腾蛇';
    }
    
    // 中宫特殊处理
    if (result[4] === '') {
      result[4] = '天禽'; // 中宫固定为天禽
    }
    
    return result;
  }

  /**
   * 生成结构标签
   */
  private generateStructureTag(ju: JuInfo): string {
    return `${ju.dunType === DunType.YANG ? '阳遁' : '阴遁'}${ju.juNumber}局研习`;
  }

  /**
   * 创建空盘（当无法获取干支信息时）
   */
  private createEmptyPan(input: DunjiaInput): DunjiaPanResult {
    const palaceNames: string[] = ['一宫坎', '二宫坤', '三宫震', '四宫巽', '五宫中', '六宫乾', '七宫兑', '八宫艮', '九宫离'];
    const palaceElements: string[] = ['水', '土', '木', '木', '土', '金', '金', '土', '火'];

    const palaces: PalaceState[] = palaceNames.map((name: string, index: number): PalaceState => {
      return {
        palace: index as PalaceIndex,
        palaceName: name,
        palaceElement: palaceElements[index]
      } as PalaceState;
    });

    return {
      dunType: DunType.YANG,
      juLabel: '数据加载中',
      input,
      zhiFuPalace: 4,
      zhiShiPalace: 4,
      palaces,
      ruleHits: [],
      summary: {
        structureTag: '',
        overview: '',
        focusPoints: [] as string[]
      }
    };
  }

  /**
   * 便捷方法：从当前时间生成默认输入（可用于"从当前日期进入时空盘"的场景）。
   * longitude 由调用方决定，可使用城市经度或用户自定义经度。
   */
  public createDefaultInput(dateTime: Date, longitude: number): DunjiaInput {
    return {
      dateTime,
      longitude,
      sceneType: DunjiaSceneType.GENERAL_STUDY
    };
  }

  /**
   * 计算真太阳时偏移量
   * @param longitude 经度
   * @returns 偏移量（分钟）
   */
  private calculateSolarTimeOffset(longitude: number): number {
    // 真太阳时偏移量计算公式：(经度 - 120) × 4分钟
    return (longitude - 120) * 4;
  }

  /**
   * 识别奇门遁甲格局
   * @param ju 局信息
   * @param palaces 九宫状态
   * @param dayInfo 当日信息
   * @param hourGanZhi 时辰干支
   */

  /**
   * 识别奇门遁甲格局
   * @param ju 局信息
   * @param palaces 九宫状态
   * @param dayInfo 当日信息
   * @param hourGanZhi 时辰干支
   */
  private identifyGejuPatterns(ju: JuInfo, palaces: PalaceState[], dayInfo: CalendarDayInfo, hourGanZhi: HourGanZhi): GejuPattern[] {
    const patterns: GejuPattern[] = [];
    
    // 1. 识别三奇得使格局（简化版：三奇临值使门）
    // TODO 后续可结合当前甲旬（旬首）与六仪（戊己庚辛壬癸）关系，按“天盘三奇加临地盘六仪”精细化判断
    const sanQiGan = ['乙', '丙', '丁'];
    for (const gan of sanQiGan) {
      const ganPalaceIndex = palaces.findIndex(p => p.tianGan === gan);
      if (ganPalaceIndex !== -1 && ganPalaceIndex === ju.zhiShiPalace) {
        patterns.push({
          id: `sanqi_deshi_${gan}`,
          name: `三奇得使(${gan})`,
          description: `${gan}奇临值使门，为三奇得使格局，主贵人扶助，事半功倍`,
          palaceIndices: [ganPalaceIndex],
          level: 'major'
        });
      }
    }
    
    // 2. 识别三遁格局（天遁、地遁、人遁候选）
    for (let i = 0; i < 9; i++) {
      const palace = palaces[i];
      // 天遁候选：生门 + 丙奇
      if (palace.doorName === '生门' && palace.tianGan === '丙') {
        patterns.push({
          id: `san_dun_tian_dun_${i}`,
          name: '三遁·天遁',
          description: `生门遇丙奇于${palace.palaceName}，为天遁候选格，得日精之蔽`,
          palaceIndices: [i],
          level: 'major'
        });
      }
      // 地遁候选：开门 + 乙奇
      if (palace.doorName === '开门' && palace.tianGan === '乙') {
        patterns.push({
          id: `san_dun_di_dun_${i}`,
          name: '三遁·地遁',
          description: `开门遇乙奇于${palace.palaceName}，为地遁候选格，得月精之蔽`,
          palaceIndices: [i],
          level: 'major'
        });
      }
      // 人遁候选：休门 + 丁奇
      if (palace.doorName === '休门' && palace.tianGan === '丁') {
        patterns.push({
          id: `san_dun_ren_dun_${i}`,
          name: '三遁·人遁',
          description: `休门遇丁奇于${palace.palaceName}，为人遁候选格，得星精之蔽`,
          palaceIndices: [i],
          level: 'major'
        });
      }
    }
    
    // 3. 识别三奇合格局
    // 三奇（乙丙丁）同在一宫（天盘+地盘合看）
    for (let i = 0; i < 9; i++) {
      const palace = palaces[i];
      const allGanInPalace: string[] = [];
      if (palace.tianGan) allGanInPalace.push(palace.tianGan);
      if (palace.diGan) allGanInPalace.push(palace.diGan);
      if (sanQiGan.every(qi => allGanInPalace.includes(qi))) {
        patterns.push({
          id: `sanqi_he_${i}`,
          name: `三奇合局`,
          description: `乙丙丁三奇同聚${palace.palaceName}，为三奇合局，主大吉昌隆`,
          palaceIndices: [i],
          level: 'major'
        });
      }
    }
    
    // 4. 识别伏吟格局
    // 天盘地盘相同
    for (let i = 0; i < 9; i++) {
      if (palaces[i].tianGan && palaces[i].diGan && palaces[i].tianGan === palaces[i].diGan) {
        patterns.push({
          id: `fu_yin_${i}`,
          name: `伏吟`,
          description: `${palaces[i].tianGan}干在${palaces[i].palaceName}伏吟，主静守为宜，不宜轻举妄动`,
          palaceIndices: [i],
          level: 'minor'
        });
      }
    }
    
    // 5. 识别反吹格局
    // 甲子与甲午、甲戌与甲辰、甲申与甲寅相对
    const oppositePairs = [
      ['甲子', '甲午'],
      ['甲戌', '甲辰'],
      ['甲申', '甲寅']
    ];
    for (let i = 0; i < 9; i++) {
      for (let j = i + 1; j < 9; j++) {
        const tianGan1 = palaces[i].tianGan || '';
        const tianGan2 = palaces[j].tianGan || '';
        const diGan1 = palaces[i].diGan || '';
        const diGan2 = palaces[j].diGan || '';
        const hasOpposite = oppositePairs.some(pair => 
          (pair.includes(tianGan1) && pair.includes(diGan2)) || 
          (pair.includes(diGan1) && pair.includes(tianGan2))
        );
        if (hasOpposite) {
          patterns.push({
            id: `fan_yin_${i}_${j}`,
            name: `反吹`,
            description: `${tianGan1}与${tianGan2}在宫位间反吹，主变动、反复，宜谨慎行事`,
            palaceIndices: [i, j],
            level: 'minor'
          });
        }
      }
    }
        
    // 8. 识别青龙返首格局（中卷）
    // 六甲加六丙：天盘甲（或戊己代甲）加地盘丙
    for (let i = 0; i < 9; i++) {
      const palace = palaces[i];
      const tianGan = palace.tianGan || '';
      const diGan = palace.diGan || '';
          
      // 天盘为甲或戊己（代甲），地盘为丙
      if (['甲', '戊', '己'].includes(tianGan) && diGan === '丙') {
        patterns.push({
          id: `qinglong_huishou_${i}`,
          name: `青龙返首`,
          description: `六甲加六丙于${palace.palaceName}，龙回首之象，造举百事皆吉`,
          palaceIndices: [i],
          level: 'special'
        });
      }
    }
        
    // 9. 识别飞鸟跌穴格局（中卷）
    // 六丙加六甲：天盘丙加地盘甲（或戊己）
    for (let i = 0; i < 9; i++) {
      const palace = palaces[i];
      const tianGan = palace.tianGan || '';
      const diGan = palace.diGan || '';
          
      // 天盘为丙，地盘为甲或戊己（代甲）
      if (tianGan === '丙' && ['甲', '戊', '己'].includes(diGan)) {
        patterns.push({
          id: `feiniao_diexue_${i}`,
          name: `飞鸟跌穴`,
          description: `六丙加六甲于${palace.palaceName}，鸟归巢之象，百事皆吉`,
          palaceIndices: [i],
          level: 'special'
        });
      }
    }
        
    // 10. 识别三奇入墓格局（中卷）
    // 乙奇入坤宫（土墓，对应未位在坤），丙丁奇入戌宫（火墓）
    const muMuGong = 1;  // 坤宫（二宫，木墓未位在坤）
    const huoMuGong = 5; // 乾宫（戌位）
        
    // 乙奇入坤宫
    if (palaces[muMuGong].tianGan === '乙') {
      patterns.push({
        id: `sanqi_rumu_yi`,
        name: `三奇入墓`,
        description: `乙奇入坤宫木墓（未位在坤），精华被掩，吉力大减`,
        palaceIndices: [muMuGong],
        level: 'major'
      });
    }
        
    // 丙丁奇入戌宫
    if (palaces[huoMuGong].tianGan === '丙' || palaces[huoMuGong].tianGan === '丁') {
      const qiName = palaces[huoMuGong].tianGan;
      patterns.push({
        id: `sanqi_rumu_${qiName}`,
        name: `三奇入墓`,
        description: `${qiName}奇入戌宫火墓，精华被掩，吉力大减`,
        palaceIndices: [huoMuGong],
        level: 'major'
      });
    }
        
    // 11. 识别六仪击刑格局(中卷)
    // 简化版：只按「甲某日 + 直符加到相应刑位」给出强凶时段警告
    const dayGan = dayInfo.day_gan;
    const dayZhi = dayInfo.day_zhi;
    // 仅在甲日系列时考虑六仪击刑
    if (dayGan === '甲') {
      const zhiIndex = hourGanZhi.zhiIndex; // 直符随时干运行，此处用时支索引近似其加临宫位
      const zhiList = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
      const shiZhi = zhiList[zhiIndex];
      let hit = false;
      // 甲子日直符加卯（子刑卯、卯刑子）
      if (dayZhi === '子' && shiZhi === '卯') hit = true;
      // 甲戌日直符加未（丑戌未三刑）
      if (dayZhi === '戌' && shiZhi === '未') hit = true;
      // 甲申日直符加寅（寅申巳三刑）
      if (dayZhi === '申' && shiZhi === '寅') hit = true;
      // 甲辰日直符加辰（辰午酉未自刑）
      if (dayZhi === '辰' && shiZhi === '辰') hit = true;
      // 甲午日直符加午（午自刑）
      if (dayZhi === '午' && shiZhi === '午') hit = true;
      // 甲寅日直符加巳（对应寅巳刑，原文作“己”此处采工程校勘意见）
      if (dayZhi === '寅' && shiZhi === '巳') hit = true;
      
      if (hit) {
        patterns.push({
          id: `liuyi_jixing`,
          name: `六仪击刑`,
          description: `当前为六仪击刑时段，依据《遁甲符应经》凡举大事多凶不可用`,
          palaceIndices: [],
          level: 'major'
        });
      }
    }
        
    // 12. 识别太白入荧惑格局（中卷）
    // 天盘庚加地盘丙
    for (let i = 0; i < 9; i++) {
      const palace = palaces[i];
      if (palace.tianGan === '庚' && palace.diGan === '丙') {
        patterns.push({
          id: `taibai_ru_yinghuo_${i}`,
          name: `太白入荧惑`,
          description: `庚加丙于${palace.palaceName}，白虎入赤地，利反击、利突袭`,
          palaceIndices: [i],
          level: 'major'
        });
      }
    }
        
    // 13. 识别荧惑入太白格局（中卷）
    // 天盘丙加地盘庚
    for (let i = 0; i < 9; i++) {
      const palace = palaces[i];
      if (palace.tianGan === '丙' && palace.diGan === '庚') {
        patterns.push({
          id: `yinghuo_ru_taibai_${i}`,
          name: `荧惑入太白`,
          description: `丙加庚于${palace.palaceName}，赤炎遇刚金，敌方退却之象`,
          palaceIndices: [i],
          level: 'minor'
        });
      }
    }
        
    // 14. 识别天网四张格局(中卷)
    // 简化版：以“时干为癸”近似“时下得六癸之时”
    if (hourGanZhi.gan === '癸') {
      patterns.push({
        id: `tianwang_sizhang`,
        name: `天网四张`,
        description: `时干癸，近似《遁甲符应经》所述“天网四张，万物尽伤，此时不可举造百事”的强凶时段`,
        palaceIndices: [],
        level: 'major'
      });
    }
    
    return patterns;
  }
}



// 内部类型定义
interface JuInfo {
  dunType: DunType;
  juNumber: number;
  zhiFuPalace: PalaceIndex;
  zhiShiPalace: PalaceIndex;
}

interface HourGanZhi {
  gan: string;          // 时干
  zhi: string;          // 时支
  ganIndex: number;     // 干索引 0-9
  zhiIndex: number;     // 支索引 0-11
}

interface ZhiFuZhiShiInfo {
  zhiFuPalace: PalaceIndex;
  zhiShiPalace: PalaceIndex;
}
