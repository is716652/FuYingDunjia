// DunjiaPanel.ets
// 遁甲研习台 - 研习模块导航入口页

import router from '@ohos.router';

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
      title: '时空盘研习（九宫总览）',
      subtitle: '查看当前时间的完整九宫盘面',
      summary: '展示九星、八门、三奇六仪、八神等完整盘面信息，是所有研习的基础。',
      level: '基础必学',
      tags: ['九宫盘', '排盘', '实时'],
      accentColor: '#D4A574',
      route: 'pages/DunjiaPalacePage'
    },
    {
      id: 'study',
      title: '时空盘研习',
      subtitle: '深入理解盘面结构与规则',
      summary: '通过互动式学习，掌握九星八门的含义、三奇六仪的应用、八神的定位等核心知识。',
      level: '进阶研习',
      tags: ['互动学习', '知识点', '练习']
    },
    {
      id: 'cases',
      title: '古籍案例重演',
      subtitle: '重现经典案例的推演过程',
      summary: '选择《遁甲符应经》等古籍中的经典案例，逐步重演排盘与判断过程，理解古人智慧。',
      level: '实战演练',
      tags: ['古籍', '案例', '推演']
    },
    {
      id: 'analysis',
      title: '结构化趋势分析',
      subtitle: '从结构视角分析盘面特征',
      summary: '识别格局（如三奇得使、天遁地遁等），分析结构特征，提供趋势研判的参考思路。',
      level: '高级分析',
      tags: ['格局识别', '趋势分析', '结构']
    },
    {
      id: 'learning',
      title: '分层研习路线',
      subtitle: '循序渐进的学习路径',
      summary: '根据学习进度，提供从基础到高级的分层研习路线，包含理论学习、案例练习、综合应用等环节。',
      level: '系统学习',
      tags: ['学习路线', '分层', '系统']
    }
  ];

  build() {
    Column({ space: 0 }) {
      // 顶部导航栏
      Row() {
        Text('← 返回')
          .fontSize(16)
          .fontColor('#666666')
          .onClick(() => {
            router.back();
          })
        Text('遁甲研习台')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text(' ')
          .fontSize(16)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#ffffff')

      Divider().color('#eeeeee')

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
            Column({ space: 10 }) {
              // 标题行
              Row({ space: 8 }) {
                Column({ space: 4 }) {
                  Text(section.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#2C2416')
                    .textAlign(TextAlign.Start)
                  Text(section.subtitle)
                    .fontSize(13)
                    .fontColor('#666666')
                    .lineHeight(18)
                    .textAlign(TextAlign.Start)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                // 等级标签
                Text(section.level)
                  .fontSize(11)
                  .fontColor(section.accentColor || '#D4A574')
                  .textAlign(TextAlign.Center)
                  .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                  .borderRadius(12)
                  .border({ width: 1, color: section.accentColor || '#D4A574' })
              }

              // 摘要
              Text(section.summary)
                .fontSize(13)
                .fontColor('#444444')
                .lineHeight(19)
                .textAlign(TextAlign.Start)

              // 标签行
              Row({ space: 6 }) {
                ForEach(section.tags, (tag: string) => {
                  Text(tag)
                    .fontSize(11)
                    .fontColor('#555555')
                    .textAlign(TextAlign.Start)
                    .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                    .backgroundColor('#F5F1E8')
                    .borderRadius(12)
                })
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .backgroundColor('#ffffff')
            .borderRadius(12)
            .shadow({ radius: 8, color: '#22000000', offsetX: 0, offsetY: 2 })
            .onClick(() => {
              if (section.route) {
                router.pushUrl({ url: section.route });
              } else {
                // 暂未实现的模块
                console.info(`[DunjiaPanel] 模块 ${section.id} 暂未实现`);
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
