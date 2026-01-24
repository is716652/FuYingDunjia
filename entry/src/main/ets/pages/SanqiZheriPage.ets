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

  /**
   * 获取日干支类型(宝日/义日/制日/和日/伐日)
   */
  private getRiGanzhiType(): GanzhiTypeInfo {
    if (!this.panResult || !this.panResult.dayInfo) return { type: '未知', level: 0, color: '#999999' };
    
    const ganzhiTypes: Record<string, GanzhiTypeInfo> = {
      // 宝日(干生支)
      '甲午': { type: '宝日', level: 5, color: '#FFD700' },
      '乙巳': { type: '宝日', level: 5, color: '#FFD700' },
      '丙辰': { type: '宝日', level: 5, color: '#FFD700' },
      '丁未': { type: '宝日', level: 5, color: '#FFD700' },
      '戊申': { type: '宝日', level: 5, color: '#FFD700' },
      '己酉': { type: '宝日', level: 5, color: '#FFD700' },
      '庚子': { type: '宝日', level: 5, color: '#FFD700' },
      '辛亥': { type: '宝日', level: 5, color: '#FFD700' },
      '壬寅': { type: '宝日', level: 5, color: '#FFD700' },
      '癸卯': { type: '宝日', level: 5, color: '#FFD700' },
      
      // 伐日(支克干)
      '甲申': { type: '伐日', level: 0, color: '#F44336' },
      '乙酉': { type: '伐日', level: 0, color: '#F44336' },
      '丙子': { type: '伐日', level: 0, color: '#F44336' },
      '丁亥': { type: '伐日', level: 0, color: '#F44336' },
      '戊寅': { type: '伐日', level: 0, color: '#F44336' },
      '己卯': { type: '伐日', level: 0, color: '#F44336' },
      '庚午': { type: '伐日', level: 0, color: '#F44336' },
      '辛巳': { type: '伐日', level: 0, color: '#F44336' },
      '壬辰': { type: '伐日', level: 0, color: '#F44336' },
      '癸未': { type: '伐日', level: 0, color: '#F44336' }
    };
      
    // 从排盘结果获取真实日干支
    const riGanzhi = `${this.panResult.dayInfo.day_gan}${this.panResult.dayInfo.day_zhi}`;
    return ganzhiTypes[riGanzhi] || { type: '和日', level: 3, color: '#4CAF50' };
  }
  
  /**
   * 获取时辰属性(五阳时/五阴时)
   */
  private getShichenType(): ShichenTypeInfo {
    if (!this.panResult || !this.panResult.hourGanZhi) return { type: '未知', desc: '', color: '#999999' };
      
    // 从排盘结果获取真实时辰天干
    const shiGan = this.panResult.hourGanZhi.charAt(0);
    const yangGan = ['甲', '乙', '丙', '丁', '戊'];
      
    if (yangGan.includes(shiGan)) {
      return {
        type: '五阳时',
        desc: '利客先发,高旗鸣鼓',
        color: '#FF9800'
      };
    } else {
      return {
        type: '五阴时',
        desc: '利主后动,低旗衔枕',
        color: '#3F51B5'
      };
    }
  }

  /**
   * 获取择日建议
   */
  private getZheriSuggestion(): string {
    const riType = this.getRiGanzhiType();
    const shiType = this.getShichenType();
    
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
        Text(this.getZheriSuggestion())
          .fontSize(13)
          .fontColor('#2C2416')
          .lineHeight(20)
          .width('100%')
          .padding(12)
          .backgroundColor('#FFF8F0')
          .borderRadius(8)
          .border({ width: 1, color: '#FFE4B5' })
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
