import { router } from '@kit.ArkUI';

@Entry
@Component
struct DocsPage {
  @State currentDoc: string = 'solar'; // 'solar' 或 'shushu'
  @State content: string = '';
  @State loading: boolean = false;
  @State errorText: string = '';

  aboutToAppear() {
    // 默认加载真太阳时说明
    this.loadMarkdown('真太阳时讲解.md');
  }

  private loadMarkdown(fileName: string) {
    this.loading = true;
    this.errorText = '';
    this.content = '';

    try {
      const context = getContext(this);
      if (!context || !context.resourceManager || !context.resourceManager.getRawFileContent) {
        this.loading = false;
        this.errorText = '无法获取资源管理器，暂时无法加载文档。';
        return;
      }

      context.resourceManager.getRawFileContent(fileName)
        .then((data: Uint8Array) => {
          // 将 UTF-8 编码的字节数组解码为字符串，避免中文乱码
          this.content = this.decodeUtf8(data);
          this.loading = false;
        })
        .catch((err: Error) => {
          console.error('[DocsPage] loadMarkdown error', JSON.stringify(err));
          this.errorText = '文档加载失败，请稍后重试。';
          this.loading = false;
        });
    } catch (e) {
      console.error('[DocsPage] loadMarkdown exception', JSON.stringify(e));
      this.errorText = '文档加载异常，请稍后重试。';
      this.loading = false;
    }
  }

  private switchDoc(doc: string) {
    if (this.currentDoc === doc) {
      return;
    }
    this.currentDoc = doc;
    if (doc === 'solar') {
      this.loadMarkdown('真太阳时讲解.md');
    } else {
      this.loadMarkdown('术数与真太阳时.md');
    }
  }

  private getLines(): string[] {
    if (!this.content) {
      return [];
    }
    return this.content.split('\n');
  }

  // 简单 UTF-8 解码，保证中文不会乱码
  private decodeUtf8(bytes: Uint8Array): string {
    let out = '';
    let i = 0;
    while (i < bytes.length) {
      const c = bytes[i++];
      if (c < 0x80) {
        // 单字节
        out += String.fromCharCode(c);
      } else if ((c & 0xe0) === 0xc0 && i < bytes.length) {
        // 双字节
        const c2 = bytes[i++];
        const code = ((c & 0x1f) << 6) | (c2 & 0x3f);
        out += String.fromCharCode(code);
      } else if ((c & 0xf0) === 0xe0 && i + 1 < bytes.length) {
        // 三字节
        const c2 = bytes[i++];
        const c3 = bytes[i++];
        const code = ((c & 0x0f) << 12) | ((c2 & 0x3f) << 6) | (c3 & 0x3f);
        out += String.fromCharCode(code);
      } else if ((c & 0xf8) === 0xf0 && i + 2 < bytes.length) {
        // 四字节（需要转成代理对）
        const c2 = bytes[i++];
        const c3 = bytes[i++];
        const c4 = bytes[i++];
        let codePoint = ((c & 0x07) << 18) | ((c2 & 0x3f) << 12) | ((c3 & 0x3f) << 6) | (c4 & 0x3f);
        codePoint -= 0x10000;
        const high = 0xd800 + (codePoint >> 10);
        const low = 0xdc00 + (codePoint & 0x3ff);
        out += String.fromCharCode(high, low);
      } else {
        // 非法字节，直接跳过或替换
        out += '?';
      }
    }
    return out;
  }

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
        Text('真太阳时 / 术数说明')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('   ')
          .fontSize(16)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#ffffff')

      Divider().color('#eeeeee')

      // 文档切换标签
      Row({ space: 12 }) {
        Button('真太阳时说明')
          .type(ButtonType.Normal)
          .fontSize(14)
          .backgroundColor(this.currentDoc === 'solar' ? '#D4A574' : '#F5F1E8')
          .fontColor(this.currentDoc === 'solar' ? '#ffffff' : '#2C2416')
          .borderRadius(16)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.switchDoc('solar');
          })

        Button('术数与真太阳时')
          .type(ButtonType.Normal)
          .fontSize(14)
          .backgroundColor(this.currentDoc === 'shushu' ? '#D4A574' : '#F5F1E8')
          .fontColor(this.currentDoc === 'shushu' ? '#ffffff' : '#2C2416')
          .borderRadius(16)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.switchDoc('shushu');
          })
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      // 文本内容区域
      if (this.loading) {
        Column() {
          Text('文档加载中...')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.errorText !== '') {
        Column({ space: 8 }) {
          Text(this.errorText)
            .fontSize(14)
            .fontColor('#cc0000')
        }
        .width('100%')
        .height('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      } else {
        Column({ space: 12 }) {
          Scroll() {
            Column() {
              ForEach(this.getLines(), (line: string) => {
                if (line.startsWith('# ')) {
                  Text(line.substring(2))
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#2C2416')
                    .textAlign(TextAlign.Start)
                    .padding({ top: 8, bottom: 4 })
                } else if (line.startsWith('## ')) {
                  Text(line.substring(3))
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#2C2416')
                    .textAlign(TextAlign.Start)
                    .padding({ top: 6, bottom: 4 })
                } else if (line.trim().startsWith('- ')) {
                  Row({ space: 8 }) {
                    Text('•')
                      .fontSize(14)
                      .fontColor('#2C2416')
                    Text(line.trim().substring(2))
                      .fontSize(14)
                      .fontColor('#2C2416')
                      .lineHeight(20)
                      .textAlign(TextAlign.Start)
                  }
                  .padding({ top: 2, bottom: 2 })
                } else if (line.trim() === '') {
                  Text(' ')
                    .fontSize(8)
                    .lineHeight(10)
                    .textAlign(TextAlign.Start)
                } else {
                  Text(line)
                    .fontSize(14)
                    .fontColor('#2C2416')
                    .lineHeight(20)
                    .textAlign(TextAlign.Start)
                }
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          }
          .layoutWeight(1)

          Button('返回万年历')
            .type(ButtonType.Capsule)
            .fontSize(16)
            .width('100%')
            .height(40)
            .backgroundColor('#D4A574')
            .fontColor('#ffffff')
            .borderRadius(20)
            .onClick(() => {
              router.back();
            })
        }
        .width('100%')
        .height('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F1E8')
  }
}
