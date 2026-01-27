// DunjiaPanel.ets
// 遁甲研习台 - 研习模块导航入口页

import router from '@ohos.router'
import { NavigationBar } from '../components/NavigationBar'
import { InfoCard } from '../components/InfoCard'

interface DunjiaSection {
  id: string;
  title: string;
  subtitle: string;
  summary: string;
  level: string;
  tags: string[];
  accentColor?: string;
  route?: string;
}

@Entry
@Component
struct DunjiaPanel {
  @State sections: DunjiaSection[] = [
    {
      id: 'palace',
      title: '九宫排盘研习',
      subtitle: '实时查看当前时间的九宫盘面',
      summary: '展示完整的九星、八门、三奇六仪、八神等盘面信息，核对《遁甲排盘规则体系》所讲的阴阳遁局、符头三元、直符直使运转规则。',
      level: '基础必学',
      tags: ['排盘规则', '实时盘面', '规则核对'],
      accentColor: '#D4A574',
      route: 'pages/DunjiaPalacePage'
    },
    {
      id: 'interpretation',
      title: '九星八门知识解读',
      subtitle: '深入理解九星八门的象意与吉凶',
      summary: '基于《遁甲九星断语》，学习每颗星的能量特征、宜忌事项、季节旺衰；掌握八门的吉凶分类、适用场景、门迫判断等核心知识。',
      level: '进阶研习',
      tags: ['九星断语', '八门吉凶', '旺相休囚'],
      route: 'pages/JiuxingBamenKnowledgePage'
    },
    {
      id: 'patterns',
      title: '格局识别与判断',
      subtitle: '学会识别吉格凶格及其应用',
      summary: '基于《遁甲格局与吉凶规则》，掌握三奇得使、三遁、青龙回首等大吉之格；学会辨别庚格、击刑、门迫、四凶神等大凶之局。',
      level: '高级分析',
      tags: ['格局识别', '吉凶判断', '组合分析'],
      route: 'pages/GejuKnowledgePage'
    },
    {
      id: 'application',
      title: '三奇应验与择日',
      subtitle: '实战应用与时机把握',
      summary: '基于《遁甲三奇应验》和《遁甲择日与应用》，学习三奇到宫的应验现象、干支择日、利客利主判断、五阳五阴时等实战技法。',
      level: '实战演练',
      tags: ['三奇应验', '择日法', '时机把握'],
      route: 'pages/SanqiZheriPage'
    },
    {
      id: 'cases',
      title: '古籍案例重演',
      subtitle: '重现《遁甲符应经》经典案例',
      summary: '选择宋代官修典籍中的经典案例，逐步重演排盘、格局判断、吉凶推演的完整流程，理解古人如何综合运用各项规则。',
      level: '综合应用',
      tags: ['古籍案例', '实战推演', '综合运用'],
      route: 'pages/ClassicalCasesPage'
    }
  ];

  build() {
    Column({ space: 0 }) {
      // 顶部导航栏
      NavigationBar({ title: '遁甲研习台' })

      Scroll() {
        Column({ space: 16 }) {
          // 顶部说明卡片
          Column({ space: 6 }) {
            Text('遁甲研习台（模块导航）')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#2C2416')
              .textAlign(TextAlign.Start)
            Text('本页提供奇门遁甲各研习模块的入口，点击卡片进入对应模块。所有功能以学术研习为目的，不提供个人预测。')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(18)
              .textAlign(TextAlign.Start)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 8 })

          // 研习模块卡片列表
          ForEach(this.sections, (section: DunjiaSection) => {
            InfoCard({
              title: section.title,
              subtitle: section.subtitle,
              summary: section.summary,
              level: section.level,
              tags: section.tags,
              accentColor: section.accentColor,
              onCardClick: () => {
                if (section.route) {
                  router.pushUrl({ url: section.route })
                } else {
                  console.info(`[遁甲研习台] 模块 ${section.id} 暂未实现`)
                }
              }
            })
          })
        }
        .padding({ left: 16, right: 16, top: 0, bottom: 16 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F1E8')
  }
}
