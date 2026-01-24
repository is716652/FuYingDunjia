/**
 * BaziDisplay 四柱八字展示组件
 * 
 * 功能：
 * - 四柱（年月日时）排列展示
 * - 干支分层显示，天干地支分别用不同颜色
 * - 柱与柱之间分隔线
 * 
 * 使用示例：
 * BaziDisplay({
 *   yearGan: this.dayInfo.year_gan,
 *   yearZhi: this.dayInfo.year_zhi,
 *   monthGan: this.dayInfo.month_gan,
 *   monthZhi: this.dayInfo.month_zhi,
 *   dayGan: this.dayInfo.day_gan,
 *   dayZhi: this.dayInfo.day_zhi,
 *   shiGan: this.getShizhu().substring(0, 1),
 *   shiZhi: this.getShizhu().substring(1, 2)
 * })
 */

@Component
export struct BaziDisplay {
  @Prop yearGan: string = '';
  @Prop yearZhi: string = '';
  @Prop monthGan: string = '';
  @Prop monthZhi: string = '';
  @Prop dayGan: string = '';
  @Prop dayZhi: string = '';
  @Prop shiGan: string = '';
  @Prop shiZhi: string = '';

  build() {
    Column({ space: 8 }) {
      Text('⚛️ 四柱八字')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2C2416')
        .width('100%')
      
      // 八字四柱排列
      Row({ space: 0 }) {
        // 年柱
        this.buildPillar('年', this.yearGan, this.yearZhi)

        Divider()
          .vertical(true)
          .height(60)
          .color('#eeeeee')
          .strokeWidth(1)

        // 月柱
        this.buildPillar('月', this.monthGan, this.monthZhi)

        Divider()
          .vertical(true)
          .height(60)
          .color('#eeeeee')
          .strokeWidth(1)

        // 日柱
        this.buildPillar('日', this.dayGan, this.dayZhi)

        Divider()
          .vertical(true)
          .height(60)
          .color('#eeeeee')
          .strokeWidth(1)

        // 时柱
        this.buildPillar('时', this.shiGan, this.shiZhi)
      }
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#ffffff')
    .borderRadius(8)
    .border({ width: 1, color: '#eeeeee' })
  }

  @Builder buildPillar(label: string, gan: string, zhi: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#999999')
      Column({ space: 2 }) {
        Text(gan)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#D4A574')
        Text(zhi)
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
}
