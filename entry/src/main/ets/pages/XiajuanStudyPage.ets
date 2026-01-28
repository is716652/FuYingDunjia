import { NavigationBar } from '../components/NavigationBar'

@Entry
@Component
struct XiajuanStudyPage {
  build() {
    Column({ space: 0 }) {
      NavigationBar({ title: '下卷符咒研习' })

      Scroll() {
        Column({ space: 16 }) {
          // 说明区
          Column({ space: 6 }) {
            Text('《景祐遁甲符应经·卷之下》研习')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#2C2416')
            Text('本页汇总下卷中与“攻守禁区、出行闭局、安营布阵”相关的规则与符咒，仅用于学术研习。')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(20)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 8 })

          // 五不可击原文摘录
          Column({ space: 8 }) {
            Text('一、五不可击（原文摘录）')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')
            Text('汤谓曰：第一不击天乙宫，二不击九天宫，三不击生门宫，四不击九地宫，五不击直使宫。己上皆不可击，我军居之，必雄盛矣。')
              .fontSize(13)
              .fontColor('#4A3B20')
              .lineHeight(22)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFF8F0')
          .borderRadius(8)

          // 玉女反闭局 - 启动咒
          Column({ space: 8 }) {
            Text('二、玉女反闭局 · 启请咒')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')

            // 说明
            Text('当月遁甲无奇门时，不宜出行，可依下卷所载“玉女反闭局”之法行事。其启请咒文如下，仅作研习诵读参考：')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(20)

            // 符咒块
            this.buildSpellBlock('玉女反闭启请咒',
              '维年月日时，某敢昭告于天父地母、六甲、六丁、玉女、六戊藏形之神，某好乐长生之术，行不择日，出不问时。今欲为某事，虔告天地神祇，丁甲大神，谨按天文，拜请六丁、玉女真君，画地局，出天门，入地户，闭金关，乘玉辂，玉女青龙、白虎、朱雀、玄武、勾陈、螣蛇、六合、六甲神十二，狩士神灵，乘我而行，到某所，左右巡防，随行随止，随卧随起，辟除盗贼，鬼魅消亡。君子见我喜乐，非常小人见我欢跃，惶惶男女见我共待酒浆，百恶鬼贼见我则亡。今日禹步上应天罡，玉女侍傍，下辟不祥，万精厌伏，所向无殃，所但病疾所供者，逢所击者破，所求者得。')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#F5F1E8')
          .borderRadius(8)

          // 行千里法 - 出门咒
          Column({ space: 8 }) {
            Text('三、行千里法 · 出门咒')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')

            Text('用于远行时的出门咒，下卷原文如下，仅作文化研习，不作现实行为指引：')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(20)

            this.buildSpellBlock('行千里出门咒',
              '六甲九章，天员地方，四时五行，日月为光，禹道治道，蚩尤避兵，苍龙扶毂，白虎扶衡，荧惑在前，引避除不祥，北斗诛伐，去凶殃，五神从我，周游四方，当我者死，向我者亡，左社右稷，寇贼伏匿，行者有喜，留者有福，五神护祐，所求者得，急急如律令。')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#F0FFFF')
          .borderRadius(8)

          // 出三奇吉门 - 三门咒摘要
          Column({ space: 8 }) {
            Text('四、出三奇吉门 · 三门咒')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')

            Text('下卷对出六乙门、六丙门、六丁门分别载有禹步咒文，此处按门分类展示，便于对照三奇应用。')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(20)

            this.buildSpellBlock('出六乙门咒',
              '白虎除道路，当首导吾，慎勿惧，仁德之士，便来助，急急如律令。')

            this.buildSpellBlock('出六丙门咒',
              '天罡扬威武，当从青龙与白虎行，诛天贼及天虏，敢有不从伏天牢斧。')

            this.buildSpellBlock('出六丁门咒',
              '六丁玉女名神，毋呼而问之道所在，当从斗表入斗裹，清冷之渊，多神忤折，以自障，勿惊骇，凡出三奇吉门，事速亦可直去，志心。')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFF5F5')
          .borderRadius(8)
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F1E8')
  }

  @Builder
  private buildSpellBlock(title: string, content: string) {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFE082')

      Text(content)
        .fontSize(13)
        .fontColor('#FFF8E1')
        .lineHeight(22)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#3E2723')
    .borderRadius(8)
  }
}
