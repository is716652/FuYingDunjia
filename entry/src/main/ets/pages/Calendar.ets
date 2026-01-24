import { CalendarManager, CalendarDayInfo } from '../utils/CalendarManager';
import { ShichenHelper } from '../utils/ShichenHelper';
import { SolarTimeHelper, CHINA_CITY_LONGITUDES } from '../utils/SolarTimeHelper';
import { router } from '@kit.ArkUI';
import { NavigationBar } from '../components/NavigationBar';
import { CalendarHeader } from '../components/CalendarHeader';
import { CalendarGrid, DayCell } from '../components/CalendarGrid';
import { ShichenSelector } from '../components/ShichenSelector';
import { LunarInfoPanel } from '../components/LunarInfoPanel';

@Entry
@Component
struct CalendarPage {
  @State dayInfo: CalendarDayInfo | null = null;
  @State selectedShichenIndex: number = 0;
  @State shichenTexts: string[] = [];
  @State selectedDate: Date = new Date();
  @State currentYear: number = new Date().getFullYear();
  @State currentMonth: number = new Date().getMonth() + 1;
  @State calendarDays: DayCell[] = [];
  @State currentShizhu: string = '暂无';  // 当前时柱，用于响应式更新
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

  async loadDateInfo(year: number, month: number, day: number) {
    console.log(`[Calendar] loadDateInfo: ${year}-${month}-${day}`);
    const info = await CalendarManager.getInstance().getDayInfo(year, month, day);
    console.log(`[Calendar] getDayInfo result:`, JSON.stringify(info));
    if (info) {
      // 直接赋值，不再置null
      this.dayInfo = info;
      // 更新时柱
      this.currentShizhu = ShichenHelper.getShizhuInfo(this.dayInfo.day_gan, this.selectedShichenIndex);
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

          // 日历网格组件
          CalendarGrid({
            calendarDays: this.calendarDays,
            selectedDate: this.selectedDate,
            onDaySelected: (dayCell: DayCell) => {
              this.onDaySelected(dayCell);
            }
          });

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

              // 时辰选择器组件
              ShichenSelector({
                shichenTexts: this.shichenTexts,
                selectedIndex: this.selectedShichenIndex,
                onShichenChanged: (index: number) => {
                  this.selectedShichenIndex = index;
                  // 更新时柱
                  if (this.dayInfo) {
                    this.currentShizhu = ShichenHelper.getShizhuInfo(this.dayInfo.day_gan, index);
                  }
                }
              });

              // 农历信息组件
              LunarInfoPanel({
                lunarYear: this.dayInfo.lunar_year.toString(),
                lunarMonth: this.dayInfo.lunar_month,
                lunarDay: this.dayInfo.lunar_day,
                zodiac: this.dayInfo.zodiac,
                yearGan: this.dayInfo.year_gan,
                yearZhi: this.dayInfo.year_zhi,
                monthGan: this.dayInfo.month_gan,
                monthZhi: this.dayInfo.month_zhi,
                dayGan: this.dayInfo.day_gan,
                dayZhi: this.dayInfo.day_zhi,
                shiGan: this.currentShizhu.substring(0, 1),
                shiZhi: this.currentShizhu.substring(1, 2),
                solarTerm: this.dayInfo.solar_term,
                solarTermTime: this.dayInfo.solar_term_time,
                festivals: this.dayInfo.festivals
              });
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
  }
}
