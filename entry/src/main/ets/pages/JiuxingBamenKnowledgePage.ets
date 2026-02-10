import { NavigationBar } from '../components/NavigationBar'

/**
 * 九星八门知识解读页面
 * 展示九星和八门的详细知识内容
 */
@Entry
@Component
struct JiuxingBamenKnowledgePage {
  @State currentIndex: number = 0
  
  build() {
    Column() {
      // 顶部导航栏
      NavigationBar({
        title: '九星八门知识解读',
        showBackButton: true,
        backButtonText: '返回'
      })
      
      // 标签页
      Tabs({ barPosition: BarPosition.Start, index: this.currentIndex }) {
        TabContent() {
          this.buildJiuxingContent()
        }
        .tabBar('九星解读')
        
        TabContent() {
          this.buildBamenContent()
        }
        .tabBar('八门吉凶')
      }
      .barWidth('100%')
      .barHeight(50)
      .onChange((index: number) => {
        this.currentIndex = index
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildJiuxingContent() {
    Scroll() {
      Column({ space: 12 }) {
        this.buildStarCard(
          '天蓬星',
          '水',
          '坎一宫',
          '大凶',
          '天蓬星属水，位居坎宫，主凶险、盗贼、争斗。为大凶之星，主破财、伤灾、牢狱之灾。',
          ['# 五行：水，位居北方', '# 大凶：主盗贼、争斗、牢狱', '# 可用：宜捕捉、狩猎、设伏']
        )
        
        this.buildStarCard(
          '天任星',
          '土',
          '坤二宫',
          '小吉',
          '天任星属土，位居坤宫，主忠厚、诚实、稳重。为小吉之星，主田宅、婚姻、师长之事。',
          ['# 五行：土，位居西南', '# 小吉：主田宅、婚姻、师长', '# 特性：忠厚诚实，稳重可靠']
        )
        
        this.buildStarCard(
          '天冲星',
          '木',
          '震三宫',
          '小吉',
          '天冲星属木，位居震宫，主冲动、进取、发展。为小吉之星，主升迁、发展、出行之事。',
          ['# 五行：木，位居东方', '# 小吉：主升迁、发展、出行', '# 特性：积极进取，勇于开拓']
        )
        
        this.buildStarCard(
          '天辅星',
          '木',
          '巽四宫',
          '小吉',
          '天辅星属木，位居巽宫，主辅助、教育、文化。为小吉之星，主师长、文书、教育之事。',
          ['# 五行：木，位居东南', '# 小吉：主师长、文书、教育', '# 特性：温和善良，助人为乐']
        )
        
        this.buildStarCard(
          '天英星',
          '火',
          '离九宫',
          '中平',
          '天英星属火，位居离宫，主文明、口才、艺术。为中平之星，主文书、口舌、是非之事。',
          ['# 五行：火，位居南方', '# 中平：主文书、口舌、艺术', '# 特性：聪明伶俐，能言善辩']
        )
        
        this.buildStarCard(
          '芮星',
          '土',
          '坤二宫',
          '凶',
          '芮星属土，位居坤宫，主病患、迟缓、阻滞。为凶星，主疾病、拖延、办事不顺。',
          ['# 五行：土，位居西南', '# 凶：主疾病、拖延、阻滞', '# 特性：缓慢迟钝，多有阻碍']
        )
        
        this.buildStarCard(
          '天柱星',
          '金',
          '兑七宫',
          '凶',
          '天柱星属金，位居兑宫，主破坏、崩塌、危险。为凶星，主破败、损伤、惊恐之事。',
          ['# 五行：金，位居西方', '# 凶：主破坏、崩塌、危险', '# 特性：刚烈易折，变化无常']
        )
        
        this.buildStarCard(
          '心星',
          '火',
          '离九宫',
          '凶',
          '心星属火，位居离宫，主虚诈、欺骗、虚假。为凶星，主虚伪、欺诈、不实之事。',
          ['# 五行：火，位居南方', '# 凶：主虚诈、欺骗、虚假', '# 特性：虚而不实，变化多端']
        )
        
        this.buildStarCard(
          '天禽星',
          '土',
          '中五宫',
          '大吉',
          '天禽星属土，位居中宫，主调和、平衡、稳定。为大吉之星，主贵人、调和、诸事顺利。',
          ['# 五行：土，位居中央', '# 大吉：主贵人、调和、稳定', '# 特性：中正平和，贵人相助']
        )
      }
      .padding(16)
    }
  }

  @Builder
  buildBamenContent() {
    Scroll() {
      Column({ space: 12 }) {
        this.buildDoorCard(
          '休门',
          '水',
          '坎一宫',
          '大吉',
          '休门属水，居坎宫，主休息、养生、财富。为三吉门之一，主休养生息、聚财蓄力。',
          ['# 五行：水，位居北方', '# 大吉：宜修养、聚财、安居', '# 特性：主休养生息，积蓄力量']
        )
        
        this.buildDoorCard(
          '生门',
          '土',
          '艮八宫',
          '大吉',
          '生门属土，居艮宫，主生长、发展、生机。为三吉门之一，主生意兴隆、事业发展。',
          ['# 五行：土，位居东北', '# 大吉：宜开业、发展、求财', '# 特性：主生生不息，蓬勃发展']
        )
        
        this.buildDoorCard(
          '开门',
          '金',
          '乾六宫',
          '大吉',
          '开门属金，居乾宫，主开创、通达、贵人。为三吉门之一，百事皆宜，尤利求职、开业、谋事。',
          ['# 五行：金，位居西北', '# 大吉：宜开业、求职、上书', '# 特性：主开通顺遂，贵人相助']
        )
        
        this.buildDoorCard(
          '伤门',
          '木',
          '震三宫',
          '凶',
          '伤门属木，居震宫，主伤害、损伤、争斗。为凶门，主伤灾、诉讼、争执之事。',
          ['# 五行：木，位居东方', '# 凶：主伤害、损伤、争斗', '# 特性：易起冲突，多有损伤']
        )
        
        this.buildDoorCard(
          '杜门',
          '木',
          '巽四宫',
          '中平',
          '杜门属木，居巽宫，主阻塞、隐藏、保密。为中平门，主闭塞不通、隐秘之事。',
          ['# 五行：木，位居东南', '# 中平：主阻塞、隐藏、保密', '# 特性：闭塞不通，宜藏不宜露']
        )
        
        this.buildDoorCard(
          '景门',
          '火',
          '离九宫',
          '中平',
          '景门属火，居离宫，主光明、景象、文书。为中平门，主文书、考试、光明之事。',
          ['# 五行：火，位居南方', '# 中平：主文书、考试、光明', '# 特性：光明正大，文书亨通']
        )
        
        this.buildDoorCard(
          '死门',
          '土',
          '坤二宫',
          '凶',
          '死门属土，居坤宫，主死亡、终结、衰败。为凶门，主死亡、终结、消亡之事。',
          ['# 五行：土，位居西南', '# 凶：主死亡、终结、衰败', '# 特性：阴气沉沉，诸事不利']
        )
        
        this.buildDoorCard(
          '惊门',
          '金',
          '兑七宫',
          '凶',
          '惊门属金，居兑宫，主惊恐、害怕、不安。为凶门，主惊吓、恐惧、不安之事。',
          ['# 五行：金，位居西方', '# 凶：主惊恐、害怕、不安', '# 特性：令人惊恐，心神不宁']
        )
        
        this.buildDoorCard(
          '生门',
          '土',
          '艮八宫',
          '大吉',
          '生门属土，居艮宫，主生长、发展、生机。为三吉门之一，主生意兴隆、事业发展。',
          ['# 五行：土，位居东北', '# 大吉：宜开业、发展、求财', '# 特性：主生生不息，蓬勃发展']
        )
      }
      .padding(16)
    }
  }

  @Builder
  buildStarCard(name: string, wuxing: string, position: string, nature: string, description: string, keyPoints: string[]) {
    Column({ space: 12 }) {
      // 标题区域
      Row() {
        Text(name)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Text(nature)
          .fontSize(12)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(this.getNatureColor(nature))
          .fontColor('#FFFFFF')
          .borderRadius(12)
      }
      .width('100%')
      
      // 基本信息
      Row({ space: 16 }) {
        Text(`五行：${wuxing}`)
          .fontSize(14)
          .fontColor('#666666')
        Text(`方位：${position}`)
          .fontSize(14)
          .fontColor('#666666')
      }
      
      // 描述
      Text(description)
        .fontSize(14)
        .fontColor('#333333')
        .lineHeight(22)
      
      // 要点列表
      Column({ space: 6 }) {
        ForEach(keyPoints, (point: string) => {
          Row({ space: 8 }) {
            Text('•')
              .fontSize(14)
              .fontColor('#999999')
            Text(point.substring(2)) // 去掉前面的 '# '
              .fontSize(13)
              .fontColor('#666666')
              .layoutWeight(1)
          }
        })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildDoorCard(name: string, wuxing: string, position: string, nature: string, description: string, keyPoints: string[]) {
    Column({ space: 12 }) {
      // 标题区域
      Row() {
        Text(name)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Text(nature)
          .fontSize(12)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(this.getNatureColor(nature))
          .fontColor('#FFFFFF')
          .borderRadius(12)
      }
      .width('100%')
      
      // 基本信息
      Row({ space: 16 }) {
        Text(`五行：${wuxing}`)
          .fontSize(14)
          .fontColor('#666666')
        Text(`方位：${position}`)
          .fontSize(14)
          .fontColor('#666666')
      }
      
      // 描述
      Text(description)
        .fontSize(14)
        .fontColor('#333333')
        .lineHeight(22)
      
      // 要点列表
      Column({ space: 6 }) {
        ForEach(keyPoints, (point: string) => {
          Row({ space: 8 }) {
            Text('•')
              .fontSize(14)
              .fontColor('#999999')
            Text(point.substring(2)) // 去掉前面的 '# '
              .fontSize(13)
              .fontColor('#666666')
              .layoutWeight(1)
          }
        })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
  }

  /**
   * 根据性质获取颜色
   */
  private getNatureColor(nature: string): string {
    switch (nature) {
      case '大吉':
        return '#4CAF50'
      case '小吉':
        return '#8BC34A'
      case '中平':
        return '#FF9800'
      case '小凶':
        return '#FF5722'
      case '凶':
        return '#F44336'
      case '大凶':
        return '#D32F2F'
      default:
        return '#9E9E9E'
    }
  }
}