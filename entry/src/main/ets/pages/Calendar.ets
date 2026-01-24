import { CalendarManager, CalendarDayInfo } from '../utils/CalendarManager';
import { ShichenHelper } from '../utils/ShichenHelper';
import { SolarTimeHelper, CHINA_CITY_LONGITUDES } from '../utils/SolarTimeHelper';
import { SolarTermCalculator } from '../utils/SolarTermCalculator';
import { router } from '@kit.ArkUI';
import { NavigationBar } from '../components/NavigationBar';
import { CalendarHeader } from '../components/CalendarHeader';

interface SelectOption {
  value: string;
}

interface DayCell {
  day: number;          // 日期数字
  isCurrentMonth: boolean;  // 是否当月
  date: Date;           // 完整日期对象
}

@Entry
@Component
struct CalendarPage {
  @State dayInfo: CalendarDayInfo | null = null;
  @State selectedShichenIndex: number = 0;
  @State shichenTexts: string[] = [];
  @State showShichenPicker: boolean = false;
  @State showDatePicker: boolean = false;
  @State selectedDate: Date = new Date();
  @State currentYear: number = new Date().getFullYear();
  @State currentMonth: number = new Date().getMonth() + 1;
  @State calendarDays: DayCell[] = [];
  private weekDays: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  private solarTimeHelper: SolarTimeHelper = new SolarTimeHelper(CHINA_CITY_LONGITUDES.BEIJING);

  aboutToAppear() {
    CalendarManager.getInstance().init(getContext(this));
    // 默认加载当天日期
    const now = new Date();
    this.selectedDate = now;
    this.currentYear = now.getFullYear();
    this.currentMonth = now.getMonth() + 1;
    this.generateCalendar(this.currentYear, this.currentMonth);
    // 初始化时设置为当前系统时辰
    this.selectedShichenIndex = ShichenHelper.getCurrentShichenIndex();
    this.loadDateInfo(now.getFullYear(), now.getMonth() + 1, now.getDate());
  }

  // 生成日历数据
  generateCalendar(year: number, month: number) {
    const firstDay = new Date(year, month - 1, 1);
    const lastDay = new Date(year, month, 0);
    const daysInMonth = lastDay.getDate();
    
    // 获取月份第一天是周几 (0=周日, 1=周一...6=周六)
    let firstWeekDay = firstDay.getDay();
    // 转换为周一开始 (0=周一, 6=周日)
    firstWeekDay = firstWeekDay === 0 ? 6 : firstWeekDay - 1;
    
    const days: DayCell[] = [];
    
    // 填充上月的尾部日期
    if (firstWeekDay > 0) {
      const prevMonthLastDay = new Date(year, month - 1, 0).getDate();
      for (let i = firstWeekDay - 1; i >= 0; i--) {
        const day = prevMonthLastDay - i;
        const date = new Date(year, month - 2, day);
        days.push({ day, isCurrentMonth: false, date });
      }
    }
    
    // 填充当月日期
    for (let i = 1; i <= daysInMonth; i++) {
      const date = new Date(year, month - 1, i);
      days.push({ day: i, isCurrentMonth: true, date });
    }
    
    // 填充下月的开头日期，凑戒42个格子(6周)
    const remainingCells = 42 - days.length;
    for (let i = 1; i <= remainingCells; i++) {
      const date = new Date(year, month, i);
      days.push({ day: i, isCurrentMonth: false, date });
    }
    
    this.calendarDays = days;
  }

  // 切换月份
  changeMonth(offset: number) {
    let newMonth = this.currentMonth + offset;
    let newYear = this.currentYear;
    
    if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    } else if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    }
    
    this.currentMonth = newMonth;
    this.currentYear = newYear;
    this.generateCalendar(newYear, newMonth);
  }

  // 选中日期
  async onDaySelected(dayCell: DayCell) {
    if (!dayCell.isCurrentMonth) {
      // 如果点击的是上/下月的日期，切换月份
      const offset = dayCell.date.getMonth() + 1 > this.currentMonth ? 1 : -1;
      this.changeMonth(offset);
    }
    
    this.selectedDate = dayCell.date;
    const year = dayCell.date.getFullYear();
    const month = dayCell.date.getMonth() + 1;
    const day = dayCell.date.getDate();
    await this.loadDateInfo(year, month, day);
  }

  // 判断是否为选中日期
  isSelectedDate(dayCell: DayCell): boolean {
    return dayCell.date.getFullYear() === this.selectedDate.getFullYear() &&
           dayCell.date.getMonth() === this.selectedDate.getMonth() &&
           dayCell.date.getDate() === this.selectedDate.getDate();
  }

  async loadDateInfo(year: number, month: number, day: number) {
    console.log(`[Calendar] loadDateInfo: ${year}-${month}-${day}`);
    const info = await CalendarManager.getInstance().getDayInfo(year, month, day);
    console.log(`[Calendar] getDayInfo result:`, JSON.stringify(info));
    if (info) {
      // 强制触发状态更新：先置空再赋值
      this.dayInfo = null;
      this.dayInfo = info;
      console.log(`[Calendar] dayInfo updated:`, 
        `${this.dayInfo.year_gan}${this.dayInfo.year_zhi} ` +
        `${this.dayInfo.month_gan}${this.dayInfo.month_zhi} ` +
        `${this.dayInfo.day_gan}${this.dayInfo.day_zhi}`);
      // 不再自动重置时辰，保持用户已选择的时辰
      this.updateShichenOptions();
    } else {
      console.error(`[Calendar] Failed to load date info for ${year}-${month}-${day}`);
    }
  }

  async loadTodayInfo() {
    const now = new Date();
    this.selectedDate = now;
    // 返回今天时，重置为当前系统时辰
    this.selectedShichenIndex = ShichenHelper.getCurrentShichenIndex();
    await this.loadDateInfo(now.getFullYear(), now.getMonth() + 1, now.getDate());
  }

  updateShichenOptions() {
    if (!this.dayInfo) return;
    const allShichen = ShichenHelper.getAllShichen();
    this.shichenTexts = allShichen.map((sc, index) => 
      ShichenHelper.getShichenDisplayText(index, this.dayInfo!.day_gan)
    );
    console.log(`[Calendar] updateShichenOptions: dayGan=${this.dayInfo.day_gan}, ` +
      `selectedIndex=${this.selectedShichenIndex}, ` +
      `currentDisplay=${this.shichenTexts[this.selectedShichenIndex]}`);
  }

  getShizhu(): string {
    if (!this.dayInfo) return '暂无';
    return ShichenHelper.getShizhuInfo(this.dayInfo.day_gan, this.selectedShichenIndex);
  }

  navigateToDunjia() {
    if (!this.dayInfo) return;
    router.pushUrl({
      url: 'pages/DunjiaPanel',
      params: {
        date: this.dayInfo.date,
        year_gan: this.dayInfo.year_gan,
        year_zhi: this.dayInfo.year_zhi,
        month_gan: this.dayInfo.month_gan,
        month_zhi: this.dayInfo.month_zhi,
        day_gan: this.dayInfo.day_gan,
        day_zhi: this.dayInfo.day_zhi,
        shizhu: this.getShizhu(),
        shichen_index: this.selectedShichenIndex
      }
    });
  }

  build() {
    Column({ space: 0 }) {
      // 顶部导航栏
      NavigationBar({
        title: '遁甲符应经',
        rightActionText: '说明',
        onRightAction: () => {
          router.pushUrl({
            url: 'pages/DocsPage'
          });
        }
      });

      Scroll() {
        Column({ space: 16 }) {
          // 月份切换栏
          CalendarHeader({
            year: this.currentYear,
            month: this.currentMonth,
            onPrevMonth: () => {
              this.changeMonth(-1);
            },
            onNextMonth: () => {
              this.changeMonth(1);
            }
          });

          // 日历主体
          Column({ space: 0 }) {
            // 星期标题行
            Row() {
              ForEach(this.weekDays, (weekDay: string) => {
                Text(weekDay)
                  .fontSize(14)
                  .fontColor('#999999')
                  .width(`${100/7}%`)
                  .textAlign(TextAlign.Center)
              })
            }
            .width('100%')
            .height(36)
            .backgroundColor('#F5F1E8')

            // 日期网格 (6周 x 7天)
            Column({ space: 0 }) {
              ForEach([0, 1, 2, 3, 4, 5], (weekIndex: number) => {
                Row({ space: 0 }) {
                  ForEach(this.calendarDays.slice(weekIndex * 7, (weekIndex + 1) * 7), (dayCell: DayCell) => {
                    this.buildDayCell(dayCell)
                  })
                }
                .width('100%')
              })
            }
            .width('100%')
          }
          .width('90%')
          .backgroundColor('#ffffff')
          .borderRadius(12)
          .border({ width: 1, color: '#eeeeee' })

          if (this.dayInfo) {
            // 选中日期详情区
            Column({ space: 12 }) {
              // 日期信息标题
              Column({ space: 8 }) {
                Text(`${this.dayInfo.year}年${this.dayInfo.month}月${this.dayInfo.day}日  ${this.dayInfo.week_name}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2C2416')
                
                // 真太阳时显示 - 醒目样式
                Row({ space: 8 }) {
                  Text('⚡')
                    .fontSize(18)
                  Column({ space: 2 }) {
                    Row({ space: 4 }) {
                      Text('真太阳时')
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#999999')
                      Text(this.solarTimeHelper.formatTrueSolarTime(this.selectedDate))
                        .fontSize(20)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#D4A574')
                    }
                    Text(`本地时间${this.solarTimeHelper.getTimeDifferenceDescription(this.selectedDate)}`)
                      .fontSize(12)
                      .fontColor('#999999')
                    Text('真太阳时说明')
                      .fontSize(12)
                      .fontColor('#D4A574')
                      .onClick(() => {
                        router.pushUrl({
                          url: 'pages/DocsPage'
                        });
                      })
                  }
                }
                .padding(10)
                .backgroundColor('#FFF8F0')
                .borderRadius(8)
                .width('100%')
              }

              // 时辰选择
              Column({ space: 8 }) {
                Row({ space: 8 }) {
                  Text('🕐 选择时辰：')
                    .fontSize(14)
                    .fontColor('#666666')
                }

                Row() {
                  Text(this.shichenTexts[this.selectedShichenIndex] || '请选择')
                    .fontSize(13)
                    .fontColor('#2C2416')
                    .layoutWeight(1)
                  Text('▼')
                    .fontSize(10)
                    .fontColor('#999999')
                }
                .width('100%')
                .padding(10)
                .backgroundColor('#F5F1E8')
                .borderRadius(6)
                .onClick(() => {
                  this.showShichenPicker = true;
                })
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#ffffff')
              .borderRadius(8)

              // 四柱干支 - 八字排列形式
              Column({ space: 8 }) {
                Text('⚛️ 四柱八字')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2C2416')
                  .width('100%')
                
                // 八字四柱排列
                Row({ space: 0 }) {
                  // 年柱
                  Column({ space: 4 }) {
                    Text('年')
                      .fontSize(12)
                      .fontColor('#999999')
                    Column({ space: 2 }) {
                      Text(this.dayInfo.year_gan)
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#D4A574')
                      Text(this.dayInfo.year_zhi)
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#8B4513')
                    }
                  }
                  .layoutWeight(1)
                  .padding(8)
                  .backgroundColor('#FFF8F0')
                  .borderRadius(8)

                  Divider()
                    .vertical(true)
                    .height(60)
                    .color('#eeeeee')
                    .strokeWidth(1)

                  // 月柱
                  Column({ space: 4 }) {
                    Text('月')
                      .fontSize(12)
                      .fontColor('#999999')
                    Column({ space: 2 }) {
                      Text(this.dayInfo.month_gan)
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#D4A574')
                      Text(this.dayInfo.month_zhi)
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#8B4513')
                    }
                  }
                  .layoutWeight(1)
                  .padding(8)
                  .backgroundColor('#FFF8F0')
                  .borderRadius(8)

                  Divider()
                    .vertical(true)
                    .height(60)
                    .color('#eeeeee')
                    .strokeWidth(1)

                  // 日柱
                  Column({ space: 4 }) {
                    Text('日')
                      .fontSize(12)
                      .fontColor('#999999')
                    Column({ space: 2 }) {
                      Text(this.dayInfo.day_gan)
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#D4A574')
                      Text(this.dayInfo.day_zhi)
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#8B4513')
                    }
                  }
                  .layoutWeight(1)
                  .padding(8)
                  .backgroundColor('#FFF8F0')
                  .borderRadius(8)

                  Divider()
                    .vertical(true)
                    .height(60)
                    .color('#eeeeee')
                    .strokeWidth(1)

                  // 时柱
                  Column({ space: 4 }) {
                    Text('时')
                      .fontSize(12)
                      .fontColor('#999999')
                    Column({ space: 2 }) {
                      Text(this.getShizhu().substring(0, 1))
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#D4A574')
                      Text(this.getShizhu().substring(1, 2))
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#8B4513')
                    }
                  }
                  .layoutWeight(1)
                  .padding(8)
                  .backgroundColor('#FFF8F0')
                  .borderRadius(8)
                }
                .width('100%')
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#ffffff')
              .borderRadius(8)
              .border({ width: 1, color: '#eeeeee' })

              // 农历信息
              Column({ space: 8 }) {
                Text('📅 农历信息')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2C2416')
                  .width('100%')
                
                // 农历日期 - 放大显示
                Text(`${this.dayInfo.lunar_year}年 ${this.getLunarMonth()}${this.getLunarDay()}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#2C2416')
                  .width('100%')
                  .margin({ top: 4 })
                
                Text(`生肖：${this.dayInfo.zodiac}`)
                  .fontSize(16)
                  .fontColor('#666666')
                  .width('100%')
                  .margin({ top: 4 })
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#ffffff')
              .borderRadius(8)
              .border({ width: 1, color: '#eeeeee' })

              // 节气节日
              if (this.dayInfo.solar_term || this.dayInfo.festivals) {
                Column({ space: 8 }) {
                  Text('🌸 节气节日')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#2C2416')
                    .width('100%')
                  
                  // 节日信息
                  if (this.dayInfo.festivals) {
                    Text(`节日：${this.dayInfo.festivals}`)
                      .fontSize(14)
                      .fontColor('#666666')
                      .width('100%')
                  }
                  
                  // 节气信息及精确时刻
                  if (this.dayInfo.solar_term) {
                    Column({ space: 4 }) {
                      Text(`节气：${this.dayInfo.solar_term}`)
                        .fontSize(14)
                        .fontColor('#666666')
                        .width('100%')
                      
                      // 显示节气精确时刻
                      if (this.dayInfo.solar_term_time) {
                        Row({ space: 4 }) {
                          Text('⏰ 交节时刻：')
                            .fontSize(13)
                            .fontColor('#999999')
                          Text(SolarTermCalculator.formatSolarTermTime(this.dayInfo.solar_term_time).split(' ')[1])
                            .fontSize(13)
                            .fontWeight(FontWeight.Medium)
                            .fontColor('#D4A574')
                        }
                      }
                    }
                  }
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#ffffff')
                .borderRadius(8)
                .border({ width: 1, color: '#eeeeee' })
              }
            }
            .width('90%')

            // 底部操作区
            Column({ space: 12 }) {
              Button() {
                Row({ space: 8 }) {
                  Text('🔮')
                    .fontSize(20)
                  Text('进入历法推演')
                    .fontSize(18)
                    .fontColor('#ffffff')
                }
              }
              .width('100%')
              .height(50)
              .backgroundColor('#D4A574')
              .borderRadius(25)
              .onClick(() => {
                this.navigateToDunjia();
              })

              Text(`基于 ${this.dayInfo.year}.${this.dayInfo.month}.${this.dayInfo.day} ${ShichenHelper.getAllShichen()[this.selectedShichenIndex].name}`)
                .fontSize(12)
                .fontColor('#999999')
                .textAlign(TextAlign.Center)
            }
            .width('90%')
            .padding({ top: 10, bottom: 30 })
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA')
    .bindContentCover(this.showShichenPicker, this.shichenPickerBuilder(), {
      modalTransition: ModalTransition.DEFAULT
    })
  }

  @Builder buildDayCell(dayCell: DayCell) {
    Stack() {
      Text(dayCell.day.toString())
        .fontSize(16)
        .fontColor(dayCell.isCurrentMonth ? '#2C2416' : '#cccccc')
        .fontWeight(this.isSelectedDate(dayCell) ? FontWeight.Bold : FontWeight.Normal)
    }
    .width(`${100/7}%`)
    .height(50)
    .backgroundColor(this.isSelectedDate(dayCell) ? '#E8F4FD' : '#ffffff')
    .border({
      width: this.isSelectedDate(dayCell) ? 2 : 0,
      color: '#4A90E2'
    })
    .borderRadius(6)
    .onClick(() => {
      this.onDaySelected(dayCell);
    })
  }

  @Builder shichenPickerBuilder() {
    Column() {
      Text('选择时辰')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .padding(16)

      TextPicker({ range: this.shichenTexts, selected: this.selectedShichenIndex })
        .onChange((value: string | string[], index: number | number[]) => {
          if (typeof index === 'number') {
            this.selectedShichenIndex = index;
          }
        })

      Row({ space: 20 }) {
        Button('取消')
          .fontSize(16)
          .backgroundColor('#eeeeee')
          .fontColor('#666666')
          .layoutWeight(1)
          .onClick(() => {
            this.showShichenPicker = false;
          })
        
        Button('确定')
          .fontSize(16)
          .backgroundColor('#D4A574')
          .fontColor('#ffffff')
          .layoutWeight(1)
          .onClick(() => {
            this.showShichenPicker = false;
          })
      }
      .width('90%')
      .padding(16)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#ffffff')
    .borderRadius({ topLeft: 16, topRight: 16 })
  }

  @Builder createInfoCard(title: string, items: string[]) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2C2416')
        .width('100%')
      
      ForEach(items, (item: string) => {
        Text(item)
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
      })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#ffffff')
    .borderRadius(8)
    .border({ width: 1, color: '#eeeeee' })
  }

  getLunarMonth(): string {
    if (!this.dayInfo) return '';
    const months = ['正月', '二月', '三月', '四月', '五月', '六月', 
                    '七月', '八月', '九月', '十月', '冬月', '腊月'];
    return months[this.dayInfo.lunar_month - 1] || `${this.dayInfo.lunar_month}月`;
  }

  getLunarDay(): string {
    if (!this.dayInfo) return '';
    const days = ['初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
                  '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
                  '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'];
    return days[this.dayInfo.lunar_day - 1] || `${this.dayInfo.lunar_day}日`;
  }

  getJieqiJieri(): string[] {
    const result: string[] = [];
    if (this.dayInfo?.festivals) {
      result.push(`节日：${this.dayInfo.festivals}`);
    }
    if (this.dayInfo?.solar_term) {
      result.push(`节气：${this.dayInfo.solar_term}`);
    }
    return result;
  }
}
