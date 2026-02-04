import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { DunjiaEngine, DunjiaInput, DunjiaSceneType, DunjiaPanResult } from '../main/ets/utils/DunjiaEngine';

export default function localUnitTest() {
  describe('localUnitTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    });
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    });
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    });
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    });
    it('assertContain', 0, () => {
      // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
      let a = 'abc';
      let b = 'b';
      // Defines a variety of assertion methods, which are used to declare expected boolean conditions.
      expect(a).assertContain(b);
      expect(a).assertEqual(a);
    });

    it('dunjia_engine_basic_invariants', 0, async () => {
      const engine: DunjiaEngine = DunjiaEngine.getInstance();
      const input: DunjiaInput = {
        dateTime: new Date(2024, 0, 1, 0, 0, 0),
        longitude: 116.4074,
        sceneType: DunjiaSceneType.GENERAL_STUDY
      };

      const pan: DunjiaPanResult = await engine.computePan(input);

      // 1. 九宫数量必须为 9
      expect(pan.palaces.length).assertEqual(9);

      // 2. 地盘天干固定为 戊、己、庚、辛、壬、癸、丁、丙、乙
      const diGans = pan.palaces.map(p => p.diGan || '');
      expect(diGans.join(',')).assertEqual('戊,己,庚,辛,壬,癸,丁,丙,乙');

      // 3. 九星固定对应一宫到九宫
      const stars = pan.palaces.map(p => p.starName || '');
      expect(stars.join(',')).assertEqual('天蓬,天芮,天冲,天辅,天禽,天心,天柱,天任,天英');

      // 4. 八门固定：一宫休、二宫死、三宫伤、四宫杜、中宫无门、六宫开、七宫惊、八宫生、九宫景
      const doors = pan.palaces.map(p => p.doorName || '');
      expect(doors.join(',')).assertEqual('休门,死门,伤门,杜门,,开门,惊门,生门,景门');
    });
  });
}