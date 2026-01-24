/**
 * CalendarGrid 日历网格组件
 * 
 * 功能：
 * - 显示星期标题行（周一～周日）
 * - 显示6×7日期网格（包含上月尾部、当月、下月开头）
 * - 支持日期选中状态高亮
 * - 日期点击事件回调
 * 
 * 使用示例：
 * CalendarGrid({
 *   calendarDays: this.calendarDays,
 *   selectedDate: this.selectedDate,
 *   onDaySelected: (dayCell: DayCell) => {
 *     this.onDaySelected(dayCell);
 *   }
 * })
 */

export interface DayCell {
  day: number;          // 公历日期数字
  isCurrentMonth: boolean;  // 是否当月
  date: Date;           // 完整日期对象
  lunarDay?: string;    // 农历日期（如“初一”、“十五”）
}

@Component
export struct CalendarGrid {
  @Prop calendarDays: DayCell[] = [];
  @Prop selectedDate: Date = new Date();
  
  onDaySelected?: (dayCell: DayCell) => void;
  
  private weekDays: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  // 判断是否为选中日期
  isSelectedDate(dayCell: DayCell): boolean {
    return dayCell.date.getFullYear() === this.selectedDate.getFullYear() &&
           dayCell.date.getMonth() === this.selectedDate.getMonth() &&
           dayCell.date.getDate() === this.selectedDate.getDate();
  }

  build() {
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
  }

  @Builder buildDayCell(dayCell: DayCell) {
    Column({ space: 2 }) {
      // 公历日期
      Text(dayCell.day.toString())
        .fontSize(16)
        .fontColor(dayCell.isCurrentMonth ? '#2C2416' : '#cccccc')
        .fontWeight(this.isSelectedDate(dayCell) ? FontWeight.Bold : FontWeight.Normal)
      
      // 农历日期
      if (dayCell.lunarDay) {
        Text(dayCell.lunarDay)
          .fontSize(10)
          .fontColor(dayCell.isCurrentMonth ? '#999999' : '#dddddd')
          .maxLines(1)
      }
    }
    .width(`${100/7}%`)
    .height(60)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.isSelectedDate(dayCell) ? '#E8F4FD' : '#ffffff')
    .border({
      width: this.isSelectedDate(dayCell) ? 2 : 0,
      color: '#4A90E2'
    })
    .borderRadius(6)
    .onClick(() => {
      if (this.onDaySelected) {
        this.onDaySelected(dayCell);
      }
    })
  }
}
