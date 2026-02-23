// JingyouToolsPage.ets
// 景祐遁甲符应经二·实战工具页

import { NavigationBar } from '../components/NavigationBar'
import { ToutianGuanTool } from '../components/ToutianGuanTool'
import { BugangVisualizer } from '../components/BugangVisualizer'
import { JiuxingWangShuaiAnalyzer } from '../components/JiuxingWangShuaiAnalyzer'
import { SanqiJixiongDetector } from '../components/SanqiJixiongDetector'
import { ShiershenLookup } from '../components/ShiershenLookup'

@Entry
@Component
struct JingyouToolsPage {
  @State selectedCategory: number = 0; // 0: 第一阶段, 1: 第二阶段
  @State selectedTab: number = 0;
  @State currentMonthZhi: string = '子'; // 当前月令地支

  build() {
    Column() {
      // 导航栏
      NavigationBar({ title: '景祐符应·实战工具' })

      // 分类切换
      Row() {
        this.buildCategoryTab('核心智能化', 0)
        this.buildCategoryTab('特色工具', 1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .backgroundColor('#FFFFFF')

      // Tab切换
      if (this.selectedCategory === 0) {
        Row() {
          this.buildTabItem('九星休旺', 0, '⭐')
          this.buildTabItem('三奇检测', 1, '✨')
          this.buildTabItem('十二神', 2, '🔮')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 4, bottom: 12 })
        .backgroundColor('#FFFFFF')
      } else {
        Row() {
          this.buildTabItem('透天关法', 0, '⚔️')
          this.buildTabItem('步罡图形化', 1, '👣')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 4, bottom: 12 })
        .backgroundColor('#FFFFFF')
      }

      // 内容区域
      Scroll() {
        Column() {
          if (this.selectedCategory === 0) {
            // 第一阶段：核心智能化
            if (this.selectedTab === 0) {
              JiuxingWangShuaiAnalyzer({ monthZhi: this.currentMonthZhi })
            } else if (this.selectedTab === 1) {
              SanqiJixiongDetector()
            } else {
              ShiershenLookup()
            }
          } else {
            // 第二阶段：特色工具
            if (this.selectedTab === 0) {
              ToutianGuanTool()
            } else {
              BugangVisualizer()
            }
          }
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildCategoryTab(title: string, index: number) {
    Text(title)
      .fontSize(14)
      .fontWeight(this.selectedCategory === index ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(this.selectedCategory === index ? '#FFFFFF' : '#666666')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.selectedCategory === index ? '#722ED1' : '#F5F5F5')
      .borderRadius(16)
      .margin({ right: 12 })
      .onClick(() => {
        this.selectedCategory = index;
        this.selectedTab = 0;
      })
  }

  @Builder
  buildTabItem(title: string, index: number, icon: string) {
    Column() {
      Row() {
        Text(icon)
          .fontSize(18)
        Text(title)
          .fontSize(15)
          .fontWeight(this.selectedTab === index ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.selectedTab === index ? '#722ED1' : '#666666')
          .margin({ left: 6 })
      }
      .padding({ left: 20, right: 20, top: 10, bottom: 10 })
      .backgroundColor(this.selectedTab === index ? '#F0E6FF' : '#FFFFFF')
      .borderRadius(20)
      .border({
        width: this.selectedTab === index ? 2 : 1,
        color: this.selectedTab === index ? '#722ED1' : '#E8E8E8'
      })
    }
    .margin({ right: 12 })
    .onClick(() => {
      this.selectedTab = index;
    })
  }
}
