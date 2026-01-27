import { NavigationBar } from '../components/NavigationBar'
import router from '@ohos.router'

/**
 * 古籍案例数据结构
 */
class ClassicalCase {
  id: string = '';
  title: string = '';
  source: string = '';
  sourceDetail: string = '';
  datetime: CaseDateTime = new CaseDateTime();
  expectedJu: string = '';
  keyPatterns: string[] = [];
  analysis: string[] = [];
  conclusion: string = '';
  studyPoints: string[] = [];
  miniPalaceData: MiniPalaceData = new MiniPalaceData();
}

class CaseDateTime {
  year: number = 0;
  month: number = 0;
  day: number = 0;
  hour: number = 0;
  minute: number = 0;
}

class MiniPalaceData {
  palaces: MiniPalaceInfo[] = [];
  juLabel: string = '';
  zhiFuIndex: number = 0;
  zhiShiIndex: number = 0;
}

class MiniPalaceInfo {
  index: number = 0;
  name: string = '';
  star: string = '';
  door: string = '';
  tianGan: string = '';
  patterns: string[] = [];
}

/**
 * 古籍案例重演页面
 */
@Entry
@Component
struct ClassicalCasesPage {
  @State cases: ClassicalCase[] = this.buildCases()

  aboutToAppear() {
    this.cases = this.buildCases();
  }

  private buildCases(): ClassicalCase[] {
    const caseList: ClassicalCase[] = [];

    // 案例1：冬至阳遁一局·天遁格
    const case1 = new ClassicalCase();
    case1.id = 'case_001';
    case1.title = '冬至阳遁一局·天遁格';
    case1.source = '中卷·释天遁';
    case1.sourceDetail = '原文："丙为月奇，临生门或开休门，谓之天遁，得日精之蔽，宜争讼、陈诉、上书等。"';
    case1.datetime.year = 2024;
    case1.datetime.month = 12;
    case1.datetime.day = 22;
    case1.datetime.hour = 9;
    case1.datetime.minute = 0;
    case1.expectedJu = '阳遁一局';
    case1.keyPatterns = ['天遁', '三奇得使'];
    case1.analysis = [
      '本局为冬至后阳遁一局，丙奇临生门于艮宫',
      '生门为三吉门之首，主生长发展、创造推进',
      '丙为月奇，临生门即构成"天遁"格局',
      '生门同时为值使门，丙奇临值使门又成"三奇得使"'
    ];
    case1.conclusion = '双重吉格叠加，利于公开推进、上书陈诉、主动出击类事项。';
    case1.studyPoints = [
      '理解天遁格的构成要素：丙奇+三吉门',
      '观察三奇得使的叠加效应',
      '掌握阳遁一局的基本布局规律'
    ];

    const miniData1 = new MiniPalaceData();
    miniData1.juLabel = '阳遁一局';
    miniData1.zhiFuIndex = 0;
    miniData1.zhiShiIndex = 7;

    const palaces1: MiniPalaceInfo[] = [];
    for (let i = 0; i < 9; i++) {
      const p = new MiniPalaceInfo();
      p.index = i;
      palaces1.push(p);
    }
    palaces1[0].name = '坎一'; palaces1[0].star = '天蓬'; palaces1[0].door = '休门'; palaces1[0].tianGan = '戊';
    palaces1[1].name = '坤二'; palaces1[1].star = '天任'; palaces1[1].door = '死门'; palaces1[1].tianGan = '己';
    palaces1[2].name = '震三'; palaces1[2].star = '天冲'; palaces1[2].door = '伤门'; palaces1[2].tianGan = '庚';
    palaces1[3].name = '巽四'; palaces1[3].star = '天辅'; palaces1[3].door = '杜门'; palaces1[3].tianGan = '辛';
    palaces1[4].name = '中五'; palaces1[4].star = '天禽'; palaces1[4].door = '-'; palaces1[4].tianGan = '-';
    palaces1[5].name = '乾六'; palaces1[5].star = '天心'; palaces1[5].door = '开门'; palaces1[5].tianGan = '壬';
    palaces1[6].name = '兑七'; palaces1[6].star = '天柱'; palaces1[6].door = '惊门'; palaces1[6].tianGan = '癸';
    palaces1[7].name = '艮八'; palaces1[7].star = '天芮'; palaces1[7].door = '生门'; palaces1[7].tianGan = '丙'; palaces1[7].patterns = ['天遁', '三奇得使'];
    palaces1[8].name = '离九'; palaces1[8].star = '天英'; palaces1[8].door = '景门'; palaces1[8].tianGan = '丁';

    miniData1.palaces = palaces1;
    case1.miniPalaceData = miniData1;
    caseList.push(case1);

    // 案例2：春分阳遁四局·青龙返首
    const case2 = new ClassicalCase();
    case2.id = 'case_002';
    case2.title = '春分阳遁四局·青龙返首';
    case2.source = '中卷·青龙返首';
    case2.sourceDetail = '原文：“六甲加六丙，谓之青龙返首，造举百事皆吉。”';
    case2.datetime.year = 2025;
    case2.datetime.month = 3;
    case2.datetime.day = 20;
    case2.datetime.hour = 11;
    case2.datetime.minute = 0;
    case2.expectedJu = '阳遁四局';
    case2.keyPatterns = ['青龙返首'];
    case2.analysis = [
      '本局为春分后阳遁四局，天盘甲（以戊代甲）加地盘丙',
      '青龙返首为龙回首之象，主声势大振',
      '此格特别利于文书竞争、公开推进类事项',
      '离宫景门配合，更显光明正大之势'
    ];
    case2.conclusion = '大吉格局，造举百事皆宜，尤利公开竞争、文书诉求。';
    case2.studyPoints = [
      '识别六甲加六丙的格局特征',
      '理解“龙回首”的象意内涵',
      '观察阳遁四局的时空特点'
    ];

    const miniData2 = new MiniPalaceData();
    miniData2.juLabel = '阳遁四局';
    miniData2.zhiFuIndex = 3;
    miniData2.zhiShiIndex = 3;

    const palaces2: MiniPalaceInfo[] = [];
    for (let i = 0; i < 9; i++) {
      const p = new MiniPalaceInfo();
      p.index = i;
      palaces2.push(p);
    }
    palaces2[0].name = '坎一'; palaces2[0].star = '天蓬'; palaces2[0].door = '休门'; palaces2[0].tianGan = '己';
    palaces2[1].name = '坤二'; palaces2[1].star = '天任'; palaces2[1].door = '死门'; palaces2[1].tianGan = '庚';
    palaces2[2].name = '震三'; palaces2[2].star = '天冲'; palaces2[2].door = '伤门'; palaces2[2].tianGan = '辛';
    palaces2[3].name = '巽四'; palaces2[3].star = '天辅'; palaces2[3].door = '杜门'; palaces2[3].tianGan = '壬';
    palaces2[4].name = '中五'; palaces2[4].star = '天禽'; palaces2[4].door = '-'; palaces2[4].tianGan = '-';
    palaces2[5].name = '乾六'; palaces2[5].star = '天心'; palaces2[5].door = '开门'; palaces2[5].tianGan = '癸';
    palaces2[6].name = '兌七'; palaces2[6].star = '天柱'; palaces2[6].door = '惊门'; palaces2[6].tianGan = '甲';
    palaces2[7].name = '艮八'; palaces2[7].star = '天芮'; palaces2[7].door = '生门'; palaces2[7].tianGan = '乙';
    palaces2[8].name = '离九'; palaces2[8].star = '天英'; palaces2[8].door = '景门'; palaces2[8].tianGan = '戊'; palaces2[8].patterns = ['青龙返首'];

    miniData2.palaces = palaces2;
    case2.miniPalaceData = miniData2;
    caseList.push(case2);

    // 案例3：夏至阴遁九局·飞鸟跌穴
    const case3 = new ClassicalCase();
    case3.id = 'case_003';
    case3.title = '夏至阴遁九局·飞鸟跌穴';
    case3.source = '中卷·飞鸟跌穴';
    case3.sourceDetail = '原文：“六丙加六甲，谓之飞鸟跌穴，百事皆吉。”';
    case3.datetime.year = 2024;
    case3.datetime.month = 6;
    case3.datetime.day = 21;
    case3.datetime.hour = 15;
    case3.datetime.minute = 0;
    case3.expectedJu = '阴遁九局';
    case3.keyPatterns = ['飞鸟跌穴'];
    case3.analysis = [
      '本局为夏至后阴遁九局，天盘丙加地盘甲（以戊代甲）',
      '飞鸟跌穴为鸟归巢之象，主计划落地、稳健推进',
      '与青龙返首对应，一主声势、一主落实',
      '坤宫死门虽凶，但格局可化解部分凶性'
    ];
    case3.conclusion = '大吉格局，百事皆吉，利于计划落地、稳健推进。';
    case3.studyPoints = [
      '识别六丙加六甲的格局特征',
      '理解“鸟归巢”的象意与青龙返首的对比',
      '观察阴遁九局的时空特点'
    ];

    const miniData3 = new MiniPalaceData();
    miniData3.juLabel = '阴遁九局';
    miniData3.zhiFuIndex = 8;
    miniData3.zhiShiIndex = 1;

    const palaces3: MiniPalaceInfo[] = [];
    for (let i = 0; i < 9; i++) {
      const p = new MiniPalaceInfo();
      p.index = i;
      palaces3.push(p);
    }
    palaces3[0].name = '坎一'; palaces3[0].star = '天蓬'; palaces3[0].door = '休门'; palaces3[0].tianGan = '乙';
    palaces3[1].name = '坤二'; palaces3[1].star = '天任'; palaces3[1].door = '死门'; palaces3[1].tianGan = '丙'; palaces3[1].patterns = ['飞鸟跌穴'];
    palaces3[2].name = '震三'; palaces3[2].star = '天冲'; palaces3[2].door = '伤门'; palaces3[2].tianGan = '丁';
    palaces3[3].name = '巽四'; palaces3[3].star = '天辅'; palaces3[3].door = '杜门'; palaces3[3].tianGan = '己';
    palaces3[4].name = '中五'; palaces3[4].star = '天禽'; palaces3[4].door = '-'; palaces3[4].tianGan = '-';
    palaces3[5].name = '乾六'; palaces3[5].star = '天心'; palaces3[5].door = '开门'; palaces3[5].tianGan = '辛';
    palaces3[6].name = '兌七'; palaces3[6].star = '天柱'; palaces3[6].door = '惊门'; palaces3[6].tianGan = '庚';
    palaces3[7].name = '艮八'; palaces3[7].star = '天芮'; palaces3[7].door = '生门'; palaces3[7].tianGan = '壬';
    palaces3[8].name = '离九'; palaces3[8].star = '天英'; palaces3[8].door = '景门'; palaces3[8].tianGan = '戊';

    miniData3.palaces = palaces3;
    case3.miniPalaceData = miniData3;
    caseList.push(case3);

    // 案例4：秋分阴遁三局·人遁格
    const case4 = new ClassicalCase();
    case4.id = 'case_004';
    case4.title = '秋分阴遁三局·人遁格';
    case4.source = '中卷·释人遁';
    case4.sourceDetail = '原文：“丁为星奇，临杜门，谓之人遁，得星精之蔽，宜潜藏、匿形、和谈等。”';
    case4.datetime.year = 2024;
    case4.datetime.month = 9;
    case4.datetime.day = 22;
    case4.datetime.hour = 21;
    case4.datetime.minute = 0;
    case4.expectedJu = '阴遁三局';
    case4.keyPatterns = ['人遁'];
    case4.analysis = [
      '本局为秋分后阴遁三局，丁奇临杜门于巽宫',
      '杜门主闭塞隐藏，丁为星奇，临杜门即成人遁',
      '人遁得人和之助，最利隐蔽行事、密谋和谈',
      '巽宫为东南方，对应风象，有随风潜入之意'
    ];
    case4.conclusion = '利隐蔽事项，宜潜藏匿形、密谋和谈、闭关修炼。';
    case4.studyPoints = [
      '理解人遁格的构成要素：丁奇+杜门',
      '对比天遁、地遁、人遁三遁的差异',
      '掌握隐蔽类事项的选时原则'
    ];

    const miniData4 = new MiniPalaceData();
    miniData4.juLabel = '阴遁三局';
    miniData4.zhiFuIndex = 2;
    miniData4.zhiShiIndex = 3;

    const palaces4: MiniPalaceInfo[] = [];
    for (let i = 0; i < 9; i++) {
      const p = new MiniPalaceInfo();
      p.index = i;
      palaces4.push(p);
    }
    palaces4[0].name = '坎一'; palaces4[0].star = '天蓬'; palaces4[0].door = '休门'; palaces4[0].tianGan = '癸';
    palaces4[1].name = '坤二'; palaces4[1].star = '天任'; palaces4[1].door = '死门'; palaces4[1].tianGan = '壬';
    palaces4[2].name = '震三'; palaces4[2].star = '天冲'; palaces4[2].door = '伤门'; palaces4[2].tianGan = '戊';
    palaces4[3].name = '巽四'; palaces4[3].star = '天辅'; palaces4[3].door = '杜门'; palaces4[3].tianGan = '丁'; palaces4[3].patterns = ['人遁'];
    palaces4[4].name = '中五'; palaces4[4].star = '天禽'; palaces4[4].door = '-'; palaces4[4].tianGan = '-';
    palaces4[5].name = '乾六'; palaces4[5].star = '天心'; palaces4[5].door = '开门'; palaces4[5].tianGan = '己';
    palaces4[6].name = '兌七'; palaces4[6].star = '天柱'; palaces4[6].door = '惊门'; palaces4[6].tianGan = '庚';
    palaces4[7].name = '艮八'; palaces4[7].star = '天芮'; palaces4[7].door = '生门'; palaces4[7].tianGan = '辛';
    palaces4[8].name = '离九'; palaces4[8].star = '天英'; palaces4[8].door = '景门'; palaces4[8].tianGan = '丙';

    miniData4.palaces = palaces4;
    case4.miniPalaceData = miniData4;
    caseList.push(case4);

    // 案例5：立春阳遁七局·三奇入墓
    const case5 = new ClassicalCase();
    case5.id = 'case_005';
    case5.title = '立春阳遁七局·三奇入墓';
    case5.source = '中卷·三奇入墓';
    case5.sourceDetail = '原文：“乙奇入辰宫为木墓，丙丁奇入戌宫为火墓，三奇入墓则吉力大减。”';
    case5.datetime.year = 2025;
    case5.datetime.month = 2;
    case5.datetime.day = 4;
    case5.datetime.hour = 7;
    case5.datetime.minute = 0;
    case5.expectedJu = '阳遁七局';
    case5.keyPatterns = ['三奇入墓'];
    case5.analysis = [
      '本局为立春后阳遁七局，乙奇落入巽宫（辰位）',
      '辰为木之墓库，乙木入辰即为三奇入墓',
      '三奇入墓主精华被掩、吉力大减',
      '虽有杜门可守，但谋事推进不顺，贵人难得'
    ];
    case5.conclusion = '强凶时段，三奇入墓导致吉力大减，不宜主动推进。';
    case5.studyPoints = [
      '识别三奇入墓的判定条件',
      '理解墓库概念：辰戌丑未四库',
      '观察凶格对整体盘面的影响'
    ];

    const miniData5 = new MiniPalaceData();
    miniData5.juLabel = '阳遁七局';
    miniData5.zhiFuIndex = 6;
    miniData5.zhiShiIndex = 3;

    const palaces5: MiniPalaceInfo[] = [];
    for (let i = 0; i < 9; i++) {
      const p = new MiniPalaceInfo();
      p.index = i;
      palaces5.push(p);
    }
    palaces5[0].name = '坎一'; palaces5[0].star = '天蓬'; palaces5[0].door = '休门'; palaces5[0].tianGan = '戊';
    palaces5[1].name = '坤二'; palaces5[1].star = '天任'; palaces5[1].door = '死门'; palaces5[1].tianGan = '己';
    palaces5[2].name = '震三'; palaces5[2].star = '天冲'; palaces5[2].door = '伤门'; palaces5[2].tianGan = '庚';
    palaces5[3].name = '巽四'; palaces5[3].star = '天辅'; palaces5[3].door = '杜门'; palaces5[3].tianGan = '乙'; palaces5[3].patterns = ['三奇入墓'];
    palaces5[4].name = '中五'; palaces5[4].star = '天禽'; palaces5[4].door = '-'; palaces5[4].tianGan = '-';
    palaces5[5].name = '乾六'; palaces5[5].star = '天心'; palaces5[5].door = '开门'; palaces5[5].tianGan = '壬';
    palaces5[6].name = '兌七'; palaces5[6].star = '天柱'; palaces5[6].door = '惊门'; palaces5[6].tianGan = '辛';
    palaces5[7].name = '艮八'; palaces5[7].star = '天芮'; palaces5[7].door = '生门'; palaces5[7].tianGan = '癸';
    palaces5[8].name = '离九'; palaces5[8].star = '天英'; palaces5[8].door = '景门'; palaces5[8].tianGan = '丁';

    miniData5.palaces = palaces5;
    case5.miniPalaceData = miniData5;
    caseList.push(case5);

    return caseList;
  }

  @Builder
  buildMiniNineGrid(caseData: ClassicalCase) {
    Column({ space: 8 }) {
      Text(caseData.miniPalaceData.juLabel)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#D4A574')
        .textAlign(TextAlign.Center)
        .width('100%')

      Column({ space: 3 }) {
        Row({ space: 3 }) {
          this.buildMiniPalaceCard(caseData.miniPalaceData.palaces[0], caseData.miniPalaceData)
          this.buildMiniPalaceCard(caseData.miniPalaceData.palaces[1], caseData.miniPalaceData)
          this.buildMiniPalaceCard(caseData.miniPalaceData.palaces[2], caseData.miniPalaceData)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row({ space: 3 }) {
          this.buildMiniPalaceCard(caseData.miniPalaceData.palaces[3], caseData.miniPalaceData)
          this.buildMiniPalaceCard(caseData.miniPalaceData.palaces[4], caseData.miniPalaceData)
          this.buildMiniPalaceCard(caseData.miniPalaceData.palaces[5], caseData.miniPalaceData)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row({ space: 3 }) {
          this.buildMiniPalaceCard(caseData.miniPalaceData.palaces[6], caseData.miniPalaceData)
          this.buildMiniPalaceCard(caseData.miniPalaceData.palaces[7], caseData.miniPalaceData)
          this.buildMiniPalaceCard(caseData.miniPalaceData.palaces[8], caseData.miniPalaceData)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  buildMiniPalaceCard(palace: MiniPalaceInfo, gridData: MiniPalaceData) {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column({ space: 2 }) {
        Text(palace.name)
          .fontSize(10)
          .fontColor('#888888')
          .width('100%')
          .textAlign(TextAlign.Center)

        Text(palace.star)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C2416')
          .width('100%')
          .textAlign(TextAlign.Center)

        Text(palace.door)
          .fontSize(11)
          .fontColor('#555555')
          .width('100%')
          .textAlign(TextAlign.Center)

        Divider().color('#f0f0f0').strokeWidth(0.5).margin({ top: 2, bottom: 2 })

        Text(palace.tianGan)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#D4691A')
          .width('100%')
          .textAlign(TextAlign.Center)

        if (palace.patterns.length > 0) {
          Text(palace.patterns[0])
            .fontSize(8)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF6B35')
            .padding({ left: 3, right: 3, top: 1, bottom: 1 })
            .borderRadius(3)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .width('100%')
      .height(85)
      .padding(5)

      if (palace.index === gridData.zhiFuIndex) {
        Text('符')
          .fontSize(9)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor('#D4A574')
          .padding({ left: 4, right: 4, top: 1, bottom: 1 })
          .borderRadius({ topRight: 6, bottomLeft: 6 })
      } else if (palace.index === gridData.zhiShiIndex) {
        Text('使')
          .fontSize(9)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor('#4A6A8B')
          .padding({ left: 4, right: 4, top: 1, bottom: 1 })
          .borderRadius({ topRight: 6, bottomLeft: 6 })
      }
    }
    .width('32%')
    .height(85)
    .backgroundColor(palace.patterns.length > 0 ? '#FFF8F0' : '#FFFFFF')
    .borderRadius(6)
    .border({
      width: palace.index === gridData.zhiFuIndex || palace.index === gridData.zhiShiIndex ? 1.5 : 1,
      color: palace.index === gridData.zhiFuIndex ? '#D4A574' : 
             (palace.index === gridData.zhiShiIndex ? '#4A6A8B' : '#E0E0E0')
    })
  }

  @Builder
  buildCaseCard(caseData: ClassicalCase) {
    Column({ space: 12 }) {
      Column({ space: 6 }) {
        Text(caseData.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C2416')
          .width('100%')

        Text(`📖 ${caseData.source}`)
          .fontSize(12)
          .fontColor('#888888')
          .width('100%')

        Text(caseData.sourceDetail)
          .fontSize(12)
          .fontColor('#666666')
          .lineHeight(18)
          .width('100%')
          .padding(10)
          .backgroundColor('#F8F8F8')
          .borderRadius(6)
          .border({ width: 1, color: '#E0E0E0', style: BorderStyle.Dashed })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Divider().color('#E0E0E0').strokeWidth(1)

      this.buildMiniNineGrid(caseData)

      Divider().color('#E0E0E0').strokeWidth(1)

      Row({ space: 8 }) {
        Text('🎯 关键格局：')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2C2416')
        
        ForEach(caseData.keyPatterns, (pattern: string) => {
          Text(pattern)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF6B35')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(4)
        })
      }
      .width('100%')

      Column({ space: 6 }) {
        Text('📊 分析要点')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2C2416')
          .width('100%')
        
        ForEach(caseData.analysis, (point: string, index: number) => {
          Row({ space: 6 }) {
            Text(`${index + 1}.`)
              .fontSize(12)
              .fontColor('#999999')
            Text(point)
              .fontSize(12)
              .fontColor('#666666')
              .lineHeight(18)
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(10)
      .backgroundColor('#F8F8F8')
      .borderRadius(6)

      Column({ space: 6 }) {
        Text('✓ 结论')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#4CAF50')
          .width('100%')
        
        Text(caseData.conclusion)
          .fontSize(13)
          .fontColor('#2C2416')
          .lineHeight(20)
          .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(10)
      .backgroundColor('#E8F5E9')
      .borderRadius(6)

      Column({ space: 6 }) {
        Text('💡 研习要点')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FF9800')
          .width('100%')
        
        ForEach(caseData.studyPoints, (point: string) => {
          Row({ space: 6 }) {
            Text('•')
              .fontSize(12)
              .fontColor('#FF9800')
            Text(point)
              .fontSize(12)
              .fontColor('#666666')
              .lineHeight(18)
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(10)
      .backgroundColor('#FFF8F0')
      .borderRadius(6)

      Button('查看完整盘面')
        .width('100%')
        .height(44)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#D4A574')
        .fontColor('#FFFFFF')
        .borderRadius(8)
        .onClick(() => {
          const targetDate = new Date(
            caseData.datetime.year,
            caseData.datetime.month - 1,
            caseData.datetime.day,
            caseData.datetime.hour,
            caseData.datetime.minute
          );
          
          // 将Date对象转换为时间戳传递，避免序列化问题
          router.pushUrl({
            url: 'pages/DunjiaPalacePage',
            params: {
              timestamp: targetDate.getTime()
            }
          });
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#22000000', offsetX: 0, offsetY: 4 })
  }

  build() {
    Column({ space: 0 }) {
      NavigationBar({ title: '古籍案例重演' })

      Scroll() {
        Column({ space: 16 }) {
          Text('以下案例均源自《景祐遁甲符应经》原文，每个案例包含九宫示意图、格局分析、研习要点。点击"查看完整盘面"可跳转至九宫研习页查看详细排盘。')
            .fontSize(13)
            .fontColor('#666666')
            .lineHeight(20)
            .width('100%')
            .padding(12)
            .backgroundColor('#FFF8F0')
            .borderRadius(8)

          ForEach(this.cases, (caseData: ClassicalCase) => {
            this.buildCaseCard(caseData)
          })
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F1E8')
  }
}
