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

    return {
      dunType: ju.dunType,
      juLabel: `${ju.dunType === DunType.YANG ? '阳遁' : '阴遁'}${ju.juNumber}局`,
      input,
      zhiFuPalace: ju.zhiFuPalace,
      zhiShiPalace: ju.zhiShiPalace,
      palaces,
      ruleHits,
      summary
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
   */
  private calculateZhiFuZhiShi(ju: JuInfo, hourGanZhi: HourGanZhi): ZhiFuZhiShiInfo {
    // 根据时干确定值符（六甲时直符移动）
    // 简化：根据局数与时干计算
    const ganList = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    
    // 值符跟随时干：甲在局数宫，乙在下一宫...
    // 简化算法：从局数宫开始，每个时轰移动一步
    const baseGanIndex = ganList.indexOf('甲'); // 0
    const offset = (hourGanZhi.ganIndex - baseGanIndex + 10) % 10;
    
    // 阳遁顺飞，阴遁逆飞
    let zhiFuPalace: number;
    if (ju.dunType === DunType.YANG) {
      zhiFuPalace = (ju.juNumber - 1 + offset) % 9;
    } else {
      zhiFuPalace = (ju.juNumber - 1 - offset + 90) % 9;
    }
    
    // 值使跟随值符（简化：与值符同宫或相邻）
    // 正规算法：值使跟随时支对应的门
    const zhiShiPalace = zhiFuPalace; // 简化：与值符同宫
    
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
   */
  private calculateJu(date: Date, dayInfo: CalendarDayInfo): JuInfo {
    // 获取最近节气
    const solarTerm = SolarTermCalculator.getInstance().getSolarTermByDate(date);
    const solarTermName = solarTerm ? solarTerm.name : dayInfo.solar_term;
    
    // 判断阴遁还是阳遁（冬至后阳遁，夏至后阴遁）
    const dunType = this.getDunType(solarTermName);
    
    // 根据节气与元数查局数表
    const juNumber = this.getJuNumber(solarTermName, dayInfo, dunType);
    
    // 计算值符值使位置（简化版：先返回固定位置）
    const zhiFuPalace = 4; // 临时：中宫
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
    
    // 简化：根据日干判断上中下元（甲己日判断仲孟季）
    const yuanIndex = this.getYuanIndex(dayInfo.day_gan);
    return juArray[yuanIndex];
  }

  /**
   * 获取上中下元索引（0=上，1=中，2=下）
   */
  private getYuanIndex(dayGan: string): number {
    // 简化实现：根据日干粗略判断
    const ganIndex = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'].indexOf(dayGan);
    return ganIndex % 3;
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
    const doors = this.layoutDoors(ju.juNumber, ju.dunType);
    
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
   * 布九星（简化版：直接按局数顺飞或逆飞）
   */
  private layoutStars(juNumber: number, dunType: DunType): string[] {
    const starNames = ['天蓬', '天芮', '天冲', '天辅', '天禽', '天心', '天柱', '天任', '天英'];
    const result: string[] = new Array(9).fill('');
    
    // 简化：阳遁顺飞，阴遁逆飞
    const startPalace = juNumber - 1; // 局数对应起始宫（简化）
    if (dunType === DunType.YANG) {
      for (let i = 0; i < 9; i++) {
        result[(startPalace + i) % 9] = starNames[i];
      }
    } else {
      for (let i = 0; i < 9; i++) {
        result[(startPalace - i + 9) % 9] = starNames[i];
      }
    }
    
    return result;
  }

  /**
   * 布八门（简化版：直接按局数顺飞或逆飞）
   */
  private layoutDoors(juNumber: number, dunType: DunType): string[] {
    const doorNames = ['休门', '死门', '伤门', '杜门', '', '开门', '惊门', '生门', '景门'];
    const result: string[] = new Array(9).fill('');
    
    // 简化：阳遁顺飞，阴遁逆飞
    const startPalace = juNumber - 1;
    if (dunType === DunType.YANG) {
      for (let i = 0; i < 9; i++) {
        if (i !== 4) { // 中宫无门
          result[(startPalace + i) % 9] = doorNames[i];
        }
      }
    } else {
      for (let i = 0; i < 9; i++) {
        if (i !== 4) {
          result[(startPalace - i + 9) % 9] = doorNames[i];
        }
      }
    }
    
    return result;
  }

  /**
   * 布三奇六仪（天干）
   * @param isTianPan true=天盘（暗干），false=地盘（明干）
   */
  private layoutTianGan(ju: JuInfo, hourGanZhi: HourGanZhi, isTianPan: boolean): string[] {
    const ganList = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    const result: string[] = new Array(9).fill('');
    
    if (isTianPan) {
      // 天盘：三奇六仪按局数从甲开始飞布
      // 简化：从局数宫开始，按顺序排列甲乙丙丁戊己庚辛壬癸
      const startPalace = ju.juNumber - 1;
      for (let i = 0; i < 9; i++) {
        const ganIndex = i % 10;
        if (ju.dunType === DunType.YANG) {
          result[(startPalace + i) % 9] = ganList[ganIndex];
        } else {
          result[(startPalace - i + 9) % 9] = ganList[ganIndex];
        }
      }
    } else {
      // 地盘：固定布局（与九宫固定对应）
      // 地盘排列：戊己庚辛壬癸甲乙丙
      const diPanGans = ['戊', '己', '庚', '辛', '甲', '壬', '癸', '乙', '丙'];
      for (let i = 0; i < 9; i++) {
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
