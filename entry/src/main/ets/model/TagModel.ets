/**
 * 标签分类数据模型
 * 从 AddPropertyPage 移入，使用 @ObservedV2+@Trace 装饰器
 */

@ObservedV2
export class TagCategory {
  @Trace name: string = '';
  @Trace tags: string[] = [];
  @Trace selected: boolean[] = [];

  // 标签样式配置
  tagBg: string = '';
  tagText: string = '';

  constructor(name: string, tagBg: string, tagText: string, tags: string[], initialSelected?: number[]) {
    this.name = name;
    this.tagBg = tagBg;
    this.tagText = tagText;
    this.tags = tags;
    this.selected = tags.map((_val: string, i: number) => initialSelected ? initialSelected.includes(i) : false);
  }
}
