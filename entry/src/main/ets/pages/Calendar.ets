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
  @State showYearPicker: boolean = false;
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
  async generateCalendar(year: number, month: number) {
    const firstDay = new Date(year, month - 1, 1);
    const lastDay = new Date(year, month, 0);
    const daysInMonth = lastDay.getDate();
      
    let firstWeekDay = firstDay.getDay();
    firstWeekDay = firstWeekDay === 0 ? 6 : firstWeekDay - 1;
      
    const days: DayCell[] = [];
        
    // 收集所有需要查询的日期
    const datesToQuery: Date[] = [];
      
    // 上月尾部日期
    if (firstWeekDay > 0) {
      const prevMonthLastDay = new Date(year, month - 1, 0).getDate();
      for (let i = firstWeekDay - 1; i >= 0; i--) {
        const day = prevMonthLastDay - i;
        const date = new Date(year, month - 2, day);
        datesToQuery.push(date);
      }
    }
      
    // 当月日期
    for (let i = 1; i <= daysInMonth; i++) {
      const date = new Date(year, month - 1, i);
      datesToQuery.push(date);
    }
      
    // 下月开头日期
    const remainingCells = 42 - datesToQuery.length;
    for (let i = 1; i <= remainingCells; i++) {
      const date = new Date(year, month, i);
      datesToQuery.push(date);
    }
      
    // 批量获取所有日期的农历信息
    const lunarInfos = await Promise.all(
      datesToQuery.map(date => this.getLunarDayText(date))
    );
      
    // 组装数据
    let index = 0;
      
    // 上月尾部
    if (firstWeekDay > 0) {
      const prevMonthLastDay = new Date(year, month - 1, 0).getDate();
      for (let i = firstWeekDay - 1; i >= 0; i--) {
        const day = prevMonthLastDay - i;
        const date = new Date(year, month - 2, day);
        days.push({ day, isCurrentMonth: false, date, lunarDay: lunarInfos[index++] });
      }
    }
      
    // 当月
    for (let i = 1; i <= daysInMonth; i++) {
      const date = new Date(year, month - 1, i);
      days.push({ day: i, isCurrentMonth: true, date, lunarDay: lunarInfos[index++] });
    }
      
    // 下月开头
    for (let i = 1; i <= remainingCells; i++) {
      const date = new Date(year, month, i);
      days.push({ day: i, isCurrentMonth: false, date, lunarDay: lunarInfos[index++] });
    }
      
    this.calendarDays = days;
  }
  
  // 获取农历日期文本
  async getLunarDayText(date: Date): Promise<string> {
    const info = await CalendarManager.getInstance().getDayInfo(
      date.getFullYear(),
      date.getMonth() + 1,
      date.getDate()
    );
    if (!info) return '';
      
    const days = ['初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
                  '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
                  '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'];
    return days[info.lunar_day - 1] || '';
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

  // 返回今天
  backToToday() {
    const now = new Date();
    this.selectedDate = now;
    this.currentYear = now.getFullYear();
    this.currentMonth = now.getMonth() + 1;
    this.selectedShichenIndex = ShichenHelper.getCurrentShichenIndex();
    this.generateCalendar(this.currentYear, this.currentMonth);
    this.loadDateInfo(now.getFullYear(), now.getMonth() + 1, now.getDate());
  }

  // 切换年份
  changeYear(newYear: number) {
    this.currentYear = newYear;
    this.showYearPicker = false;
    this.generateCalendar(newYear, this.currentMonth);
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
    const info = await CalendarManager.getInstance().getDayInfo(year, month, day);
    if (info) {
      this.dayInfo = info;
      this.currentShizhu = ShichenHelper.getShizhuInfo(this.dayInfo.day_gan, this.selectedShichenIndex);
      this.updateShichenOptions();
    }
  }

  updateShichenOptions() {
    if (!this.dayInfo) return;
    const allShichen = ShichenHelper.getAllShichen();
    this.shichenTexts = allShichen.map((sc, index) => 
      ShichenHelper.getShichenDisplayText(index, this.dayInfo!.day_gan)
    );
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
            },
            onToday: () => {
              this.backToToday();
            },
            onYearClick: () => {
              this.showYearPicker = true;
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
    .bindContentCover(this.showYearPicker, this.buildYearPicker(), {
      modalTransition: ModalTransition.DEFAULT
    })
  }

  @Builder buildYearPicker() {
    Column({ space: 20 }) {
      Text('选择年份')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2C2416')
        .margin({ top: 20 })

      Grid() {
        ForEach([0, 1, 2, 3, 4, 5, 6, 7, 8], (row: number) => {
          ForEach([0, 1, 2], (col: number) => {
            GridItem() {
              Text((this.currentYear + (row * 3 + col) - 4).toString())
                .fontSize(16)
                .fontColor((this.currentYear + (row * 3 + col) - 4) === this.currentYear ? '#FFFFFF' : '#2C2416')
                .fontWeight((this.currentYear + (row * 3 + col) - 4) === this.currentYear ? FontWeight.Bold : FontWeight.Normal)
                .width('100%')
                .height(50)
                .textAlign(TextAlign.Center)
                .backgroundColor((this.currentYear + (row * 3 + col) - 4) === this.currentYear ? '#D4A574' : '#FFFFFF')
                .borderRadius(8)
                .border({ width: 1, color: (this.currentYear + (row * 3 + col) - 4) === this.currentYear ? '#D4A574' : '#eeeeee' })
                .onClick(() => {
                  this.changeYear(this.currentYear + (row * 3 + col) - 4);
                })
            }
          })
        })
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsTemplate('repeat(9, 1fr)')
      .rowsGap(10)
      .columnsGap(10)
      .width('90%')
      .height(500)

      Button('取消')
        .fontSize(16)
        .fontColor('#666666')
        .backgroundColor('#F5F5F5')
        .width('90%')
        .onClick(() => {
          this.showYearPicker = false;
        })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 16, topRight: 16 })
  }
}
