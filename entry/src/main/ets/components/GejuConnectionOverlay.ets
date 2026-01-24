import { GejuPattern } from '../utils/DunjiaEngine'

/**
 * 格局连线覆盖层组件
 * 
 * 功能：
 * - 在九宫格上绘制格局连线
 * - 显示格局关系可视化
 * - 支持高亮选中格局
 */

export interface ConnectionPoint {
  x: number;
  y: number;
  palaceIndex: number;
}

@Component
export struct GejuConnectionOverlay {
  @Prop patterns: GejuPattern[] = []
  @Prop selectedPattern: string | null = null
  @Prop gridWidth: number = 0
  @Prop gridHeight: number = 0

  /**
   * 获取宫位中心坐标
   */
  private getPalaceCenter(index: number): ConnectionPoint {
    // 九宫格布局：3x3
    // 0 1 2
    // 3 4 5
    // 6 7 8
    const row = Math.floor(index / 3);
    const col = index % 3;
    
    const cellWidth = this.gridWidth / 3;
    const cellHeight = this.gridHeight / 3;
    
    return {
      x: col * cellWidth + cellWidth / 2,
      y: row * cellHeight + cellHeight / 2,
      palaceIndex: index
    };
  }

  /**
   * 获取格局连线颜色
   */
  private getPatternLineColor(pattern: GejuPattern): string {
    if (pattern.name.includes('天遁') || pattern.name.includes('三奇得使')) {
      return '#FF6B35'; // 特殊格局，橙色
    } else if (pattern.name.includes('地遁') || pattern.name.includes('人遁')) {
      return '#D4A574'; // 主要格局，金色
    } else if (pattern.name.includes('青龙回首') || pattern.name.includes('伏吟')) {
      return '#4A90E2'; // 特殊关系，蓝色
    }
    return '#999999'; // 默认灰色
  }

  /**
   * 判断是否高亮显示
   */
  private isHighlighted(pattern: GejuPattern): boolean {
    return this.selectedPattern !== null && pattern.name === this.selectedPattern;
  }

  build() {
    Stack() {
      // 绘制所有格局连线
      Canvas(this.getContext('canvas'))
        .width('100%')
        .height('100%')
        .onReady(() => {
          this.drawConnections();
        })
    }
    .width(this.gridWidth)
    .height(this.gridHeight)
  }

  /**
   * 绘制连线
   */
  private drawConnections() {
    const context = this.getContext('canvas').getContext('2d');
    if (!context) return;

    context.clearRect(0, 0, this.gridWidth, this.gridHeight);

    // 遍历所有格局
    this.patterns.forEach((pattern: GejuPattern) => {
      if (pattern.palaceIndices.length < 2) return; // 少于2个宫位不绘制连线

      const isHighlight = this.isHighlighted(pattern);
      const color = this.getPatternLineColor(pattern);
      const lineWidth = isHighlight ? 3 : 2;
      const alpha = isHighlight ? 1.0 : 0.5;

      // 设置样式
      context.strokeStyle = color;
      context.lineWidth = lineWidth;
      context.globalAlpha = alpha;
      context.lineCap = 'round';

      // 绘制连线（连接所有相关宫位）
      context.beginPath();
      const firstPoint = this.getPalaceCenter(pattern.palaceIndices[0]);
      context.moveTo(firstPoint.x, firstPoint.y);

      for (let i = 1; i < pattern.palaceIndices.length; i++) {
        const point = this.getPalaceCenter(pattern.palaceIndices[i]);
        context.lineTo(point.x, point.y);
      }

      context.stroke();

      // 高亮状态下，在连线上绘制格局名称
      if (isHighlight && pattern.palaceIndices.length === 2) {
        const point1 = this.getPalaceCenter(pattern.palaceIndices[0]);
        const point2 = this.getPalaceCenter(pattern.palaceIndices[1]);
        const midX = (point1.x + point2.x) / 2;
        const midY = (point1.y + point2.y) / 2;

        context.font = '12px sans-serif';
        context.fillStyle = color;
        context.textAlign = 'center';
        context.textBaseline = 'middle';
        context.globalAlpha = 1.0;
        context.fillText(pattern.name, midX, midY - 10);
      }
    });

    context.globalAlpha = 1.0;
  }

  private getContext(id: string): CanvasRenderingContext2D {
    // 占位方法，实际由ArkTS框架处理
    return {} as CanvasRenderingContext2D;
  }
}
