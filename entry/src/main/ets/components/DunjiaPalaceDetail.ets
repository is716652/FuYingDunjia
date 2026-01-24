import { DunjiaPanResult } from '../utils/DunjiaEngine'
import { PalaceDetailPanel } from './PalaceDetailPanel'

/**
 * 宫位详情显示组件（兼容层）
 * 
 * 功能：
 * - 委托给PalaceDetailPanel组件
 * - 保持对外接口不变
 */
@Component
export struct DunjiaPalaceDetail {
  @Prop panResult: DunjiaPanResult | null = null
  @Prop selectedPalace: number | null = null

  build() {
    PalaceDetailPanel({
      panResult: this.panResult,
      selectedPalace: this.selectedPalace
    })
  }
}
