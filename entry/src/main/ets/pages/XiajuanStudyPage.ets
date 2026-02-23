import { router } from '@kit.ArkUI'
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

          // 实战工具入口
          Column({ space: 8 }) {
            Text('景祐符应·实战工具')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#722ED1')
              .alignSelf(ItemAlign.Start)

            // 第一行：核心智能化
            Row() {
              Column() {
                Text('⭐')
                  .fontSize(18)
                Text('九星休旺')
                  .fontSize(12)
                  .fontColor('#333333')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              .padding(10)
              .backgroundColor('#FFF7E6')
              .borderRadius(8)
              .onClick(() => {
                router.pushUrl({ url: 'pages/JingyouToolsPage' });
              })

              Column() {
                Text('✨')
                  .fontSize(18)
                Text('三奇检测')
                  .fontSize(12)
                  .fontColor('#333333')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              .padding(10)
              .backgroundColor('#F6FFED')
              .borderRadius(8)
              .margin({ left: 8 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/JingyouToolsPage' });
              })

              Column() {
                Text('🔮')
                  .fontSize(18)
                Text('十二神')
                  .fontSize(12)
                  .fontColor('#333333')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              .padding(10)
              .backgroundColor('#E6F7FF')
              .borderRadius(8)
              .margin({ left: 8 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/JingyouToolsPage' });
              })
            }
            .width('100%')

            // 第二行：特色工具
            Row() {
              Column() {
                Text('⚔️')
                  .fontSize(18)
                Text('透天关法')
                  .fontSize(12)
                  .fontColor('#333333')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              .padding(10)
              .backgroundColor('#F9F0FF')
              .borderRadius(8)
              .onClick(() => {
                router.pushUrl({ url: 'pages/JingyouToolsPage' });
              })

              Column() {
                Text('👣')
                  .fontSize(18)
                Text('步罡可视化')
                  .fontSize(12)
                  .fontColor('#333333')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              .padding(10)
              .backgroundColor('#FFF0F6')
              .borderRadius(8)
              .margin({ left: 8 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/JingyouToolsPage' });
              })

              Column()
                .layoutWeight(1)
                .margin({ left: 8 })
            }
            .width('100%')

            // 第三行：辅助工具
            Row() {
              Column() {
                Text('🏕️')
                  .fontSize(18)
                Text('闭六戊')
                  .fontSize(12)
                  .fontColor('#333333')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              .padding(10)
              .backgroundColor('#E6F7FF')
              .borderRadius(8)
              .onClick(() => {
                router.pushUrl({ url: 'pages/JingyouToolsPage' });
              })

              Column() {
                Text('🔄')
                  .fontSize(18)
                Text('神煞转化')
                  .fontSize(12)
                  .fontColor('#333333')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              .padding(10)
              .backgroundColor('#FFF1F0')
              .borderRadius(8)
              .margin({ left: 8 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/JingyouToolsPage' });
              })

              Column()
                .layoutWeight(1)
                .margin({ left: 8 })
            }
            .width('100%')
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 8 })

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

          // 伏匿藏形 - 过太阴咒
          Column({ space: 8 }) {
            Text('五、伏匿藏形 · 过太阴咒')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')

            Text('出处：伍子胥曰。若欲藏匿者，需乘青龙（六甲）历蓬星（六乙）过明堂（六丙）出天门（六戊）入地户（六己）过太阴（六丁）入天藏（六癸）。过太阴时咒曰：')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(20)

            this.buildSpellBlock('过太阴咒',
              '天翻地覆，九遁皆塞，有禾追我，至此而极，强见我者死，追我者亡。吾奉九天玄女道母元君律令，经入天藏，慎勿反顾。庚为天狱，辛为天庭，壬为天牢，宜避之，不可抵向，如误犯即被缚擒之咎。')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#E8F5E9')
          .borderRadius(8)

          // 真人闭六戊法 - 禹步咒
          Column({ space: 8 }) {
            Text('六、真人闭六戊法 · 禹步咒')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')

            Text('用于止宿安营、辟病去害。操作时需画局入口、祷祝四方、安置筹法、唱筹、乘玉女而行，每移一步持咒一句。禹步咒如下：')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(20)

            this.buildSpellBlock('禹步咒',
              '禹步相催，登阳门。白气混混灌我形。天廻地转，步七星。躡罡步斗，齐九灵。我步我长生。我得我长生。恶逆摧伏，妖邪惊。泉炎消滅，我长生，急急如律令。')

            this.buildSpellBlock('禹步毕咒',
              '六甲九章，天员地方，四时五行，青赤白黄太乙为师，日月为光，禹前治道，蚩尤治兵，青龙扶毂，白虎扶衡，荧惑在前，辟除不祥，北斗诛伐，除去凶殃，五神道我，周游八方，当我者死，嫉我者亡，左右社稷，鬼盗伏匿，行者浮喜，留者有福，万神护我，永除盗贼，急急如律令。')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFF8E1')
          .borderRadius(8)

          // 真人闭六戊法 - 吉事远行咒
          Column({ space: 8 }) {
            Text('七、真人闭六戊法 · 吉事远行咒')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')

            Text('欲为吉事，远行见贵人，上官赴任者，出地户入天门，乘玉女而行。咒曰：')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(20)

            this.buildSpellBlock('吉事远行咒',
              '天门天门，今日惟良，玉女侍我左右，遨旁行未四出，不逢祸殃，君子一见喜乐倍常，所求如意，万事吉昌，急急如律令。')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#E1F5FE')
          .borderRadius(8)

          // 真人闭六戊法 - 入阵掩捕咒
          Column({ space: 8 }) {
            Text('八、真人闭六戊法 · 入阵掩捕咒')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')

            Text('欲入阵掩捕之事，出天门，入地户，乘玉女而行。包含入阵咒和三呼玉女咒：')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(20)

            this.buildSpellBlock('入阵咒',
              '喏喏，嚗嚗，行无择日，返无择期，随斗所指。与神俱出，天地反覆，中心所欲，皆得随意，使汝迷惑，以东为西，以南为北，知我者死，汝不得以筹开门，而玄乘玉女。')

            this.buildSpellBlock('三呼玉女咒',
              '（三呼）玉女、玉女、玉女。天神至矣，护我保我，侍我行到某乡里，杳杳冥冥，莫覩其形，人不闻其声，鬼莫视其神，恶我者殃，百邪鬼贼，当我者灭，阻我者亡，千万人中见我者喜，急急如律令。')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FCE4EC')
          .borderRadius(8)

          // 刀画地摄禁咒
          Column({ space: 8 }) {
            Text('九、刀画地摄禁咒')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')

            Text('以刀画地，摄禁诸恶。咒先叩齿七遍，应北斗天罡气，以右手持刀画地。包含两式咒语：')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(20)

            this.buildSpellBlock('刀画咒（第一式）',
              '律令律令，四纵五横，万鬼潜形，吾去千里者，迥万里者，归呵！我者死，叱吾者亡，恶我者自受其殃，急急如律令。')

            this.buildSpellBlock('刀画咒（第二式）',
              '律令律令，四纵五横，猛火烈兵，游行天下。摄捉邪精，所有一切天魔外道，向并吾天罡，勃下灭，急急如律令。')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#F3E5F5')
          .borderRadius(8)

          // 安营咒
          Column({ space: 8 }) {
            Text('十、真人闭六戊法 · 安营咒')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')

            Text('诸欲止宿安营，辟病去害者，当用真人闭六戊法。先置其营，落记在旬中之戊上，以刀从鬼门起左行画地一周，取中央土一斗分置六戊之上，入中央咒曰：')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(20)

            this.buildSpellBlock('安营咒',
              '太山之阳，常山之阴，盗贼不起，虎狼不行，城郭不完，闭以金关千凶，万恶莫之敢干，仍在营中，宿不复出也。')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFF9C4')
          .borderRadius(8)

          // 真人步斗法 - 斗要诵
          Column({ space: 8 }) {
            Text('十一、真人步斗法 · 斗要诵')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')

            Text('出处：步斗经曰。夫步可以通神，当以夜半居星下，白垩画地作九斗星间，相去三尺。天蓬从天罡起，正立天英而歌斗咒。此法为之百日，即与神人通矣。乃诵曰：')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(20)

            this.buildSpellBlock('斗要诵',
              '斗要妙兮，十二神承光明兮，威武陈气髣髴兮，如浮云七变动兮，上应天知变化兮，有吉山入斗宿兮，过天阁合律吕兮，治甲荣履天英兮，度天任清冷渊兮，可陟沉枝天柱兮，拥天心从此度兮，登天禽倚天辅兮，望天冲入天内兮，出天蓬斗道通兮，刚柔际天福禄兮，流后世出幽冥兮，千万载，急急如律令。')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#E0F2F1')
          .borderRadius(8)

          // 遁甲门户神名咒
          Column({ space: 8 }) {
            Text('十二、遁甲门户神名咒')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')

            Text('出处：玉璋曰。大将军出入及行，以六为法，列士卒左旋入太阴中，呼门神名。咒曰：')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(20)

            this.buildSpellBlock('呼门神咒',
              '某甲有急，请神佐我，佑我、匿我、藏我，无使敌人伤我、覆我，盖我五兵，摧折无令至我，当我者亡，使敌人冥冥默默，视我迷惑，为者乱其魂魄，使敌人不敢起。')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFEBEE')
          .borderRadius(8)

          // 魁罡咒
          Column({ space: 8 }) {
            Text('十三、玉女反闭局 · 魁罡咒')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')

            Text('玉女反闭局中的重要咒语，用于步罡时诵念：')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(20)

            this.buildSpellBlock('魁罡咒',
              '吾左魁右魁，右魁左魁，上魁下魁，下魁上魁，吾藏三五之中，魁魁之内，魁魁之裹，颠倒三五，低昂步罡，魁为我生形，吾载日载月，足履北斗二台，七星覆我，五星照我，二十八宿罗列，卫我璇玑，玉衡卫我身形，衣斗履斗，与斗同仪。今步罡三五合，成步，矫跃衡趐，祥紫微三五，腾声乘罡，御斗秉正，天威万世常存，日月同曜，邪道五害皆伏，魁罡之下，无动无作，急急如律令。')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#E8EAF6')
          .borderRadius(8)

          // 真人闭六戊法 - 天门地户咒
          Column({ space: 8 }) {
            Text('十四、真人闭六戊法 · 天门地户咒')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')

            Text('唱筹后，先成者为天门，后成者为地户。天门地户确认咒曰：')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(20)

            this.buildSpellBlock('天门地户咒',
              '乾尊跃灵，坤顺内营，二仪交泰，要合利贞，配天向地，永宁肃清，应感玄黄，上衣下裳，震离坎兑，翊赞扶将，乾坤艮巽，虎步龙翔，今日行筹，玉女侍傍，有急相佐，常辅扶匡，追我者死，捕我者亡，牵牛织女，化成河江，急急如律令。')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFF3E0')
          .borderRadius(8)

          // 逆风镇压咒
          Column({ space: 8 }) {
            Text('十五、逆风镇压咒')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C2416')

            Text('凡军行过恶风，旂杆倒折者，取四穷上土作泥人，长三尺，手持桃弓苇矢，执刀披髮，向风三叩齿咒曰：')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(20)

            this.buildSpellBlock('镇风咒',
              '天有四狗，以守四境；吾有四狗，以守四隅，以城为山，以池为河。寇贼不得过，来者不得进，去者不得还。急急如律令。')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#F1F8E9')
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
