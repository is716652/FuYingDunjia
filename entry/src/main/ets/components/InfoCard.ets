/**
 * 通用信息卡片组件
 * 
 * 功能：
 * - 显示标题、副标题、摘要
 * - 显示等级标签
 * - 显示标签列表
 * - 支持点击事件
 * - 统一卡片样式
 * 
 * 使用方式：
 * ```typescript
 * InfoCard({
 *   title: '标题',
 *   subtitle: '副标题',
 *   summary: '详细描述',
 *   level: '基础必学',
 *   tags: ['标签1', '标签2'],
 *   accentColor: '#D4A574',
 *   onClick: () => { // 点击处理 }
 * })
 * ```
 */
@Component
export struct InfoCard {
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop summary: string = ''
  @Prop level: string = ''
  @Prop tags: string[] = []
  @Prop accentColor: string = '#D4A574'
  @Prop cardBackgroundColor: string = '#ffffff'
  @Prop showShadow: boolean = true
  
  onCardClick?: () => void

  build() {
    Column({ space: 10 }) {
      // 标题行
      Row({ space: 8 }) {
        Column({ space: 4 }) {
          // 主标题
          Text(this.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2C2416')
            .textAlign(TextAlign.Start)
          
          // 副标题
          if (this.subtitle) {
            Text(this.subtitle)
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(18)
              .textAlign(TextAlign.Start)
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // 等级标签
        if (this.level) {
          Text(this.level)
            .fontSize(11)
            .fontColor(this.accentColor)
            .textAlign(TextAlign.Center)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(12)
            .border({ width: 1, color: this.accentColor })
        }
      }

      // 摘要
      if (this.summary) {
        Text(this.summary)
          .fontSize(13)
          .fontColor('#444444')
          .lineHeight(19)
          .textAlign(TextAlign.Start)
      }

      // 标签行
      if (this.tags && this.tags.length > 0) {
        Row({ space: 6 }) {
          ForEach(this.tags, (tag: string) => {
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
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor(this.cardBackgroundColor)
    .borderRadius(12)
    .shadow(this.showShadow ? { 
      radius: 8, 
      color: '#22000000', 
      offsetX: 0, 
      offsetY: 2 
    } : undefined)
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick()
      }
    })
  }
}
