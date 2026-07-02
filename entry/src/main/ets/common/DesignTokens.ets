/**
 * 设计令牌 - 从设计稿提取的设计系统常量
 * 所有数值严格遵循设计稿中的原始尺寸
 */

// ============ 阴影配置接口 ============
export interface ShadowConfig {
  radius: number;
  color: string;
  offsetX: number;
  offsetY: number;
}

// ============ 颜色系统 ============
export class Colors {
  // 背景色
  static readonly BG_PRIMARY: string = '#F9F9FB';

  // 主色调
  static readonly PRIMARY: string = '#5046E5';
  static readonly PRIMARY_LIGHT: string = '#F0EDFF';

  // 语义色
  static readonly SUCCESS: string = '#10B981';
  static readonly SUCCESS_LIGHT: string = '#F0FDF4';
  static readonly WARNING: string = '#F59E0B';
  static readonly WARNING_LIGHT: string = '#FEF3C7';
  static readonly DANGER: string = '#EF4444';
  static readonly DANGER_LIGHT: string = '#FEF2F2';
  static readonly DANGER_BORDER: string = '#FECACA';

  // 文字色
  static readonly TEXT_PRIMARY: string = '#0F1419';
  static readonly TEXT_SECONDARY: string = '#6B7280';
  static readonly TEXT_MUTED: string = '#9CA3AF';
  static readonly TEXT_WHITE: string = '#FFFFFF';

  // 卡片和表面
  static readonly CARD_BG: string = '#FFFFFF';
  static readonly DIVIDER: string = '#F3F4F6';
  static readonly DIVIDER_LIGHT: string = '#F3F3F5';
  static readonly DIVIDER_DARK: string = '#E7E7EA';

  // 标签分类色 (新增房源页-标签筛选卡片)
  static readonly TAG_LABEL: string = '#8C8C94';      // 分类标签文字
  static readonly TAG_PAYMENT_BG: string = '#F0EDFF';  // 付款方式-选中背景
  static readonly TAG_PAYMENT_TEXT: string = '#7859D9'; // 付款方式-选中文字
  static readonly TAG_LEASE_BG: string = '#E0F0FF';    // 租赁类型-选中背景
  static readonly TAG_LEASE_TEXT: string = '#3878D9';   // 租赁类型-选中文字
  static readonly TAG_CONDITION_BG: string = '#E5FCF2'; // 房屋条件-选中背景
  static readonly TAG_CONDITION_TEXT: string = '#22A94A';// 房屋条件-选中文字
  static readonly TAG_SURROUND_BG: string = '#FFF0D9';  // 周边便利-选中背景
  static readonly TAG_SURROUND_TEXT: string = '#DE6B1A'; // 周边便利-选中文字
}

// ============ 字体栈 ============
export class Fonts {
  // 中文字体 - Noto Sans SC
  static readonly CN: string = 'Noto Sans SC';
  // 数字/日期字体 - Inter
  static readonly NUMBER: string = 'Inter';
}

// ============ 字号系统 (从设计稿还原) ============
export class FontSizes {
  static readonly TITLE_LARGE: number = 24;   // 关于页应用名
  static readonly TITLE: number = 22;          // 详情页房源名、数据值
  static readonly PAGE_TITLE: number = 18;     // 页面标题
  static readonly SECTION_TITLE: number = 16;  // 区块标题
  static readonly BODY_LARGE: number = 15;     // 导航标题、菜单文字
  static readonly BODY: number = 14;           // 正文
  static readonly BODY_SMALL: number = 13;     // 辅助文字、描述
  static readonly CAPTION: number = 12;        // 说明文字
  static readonly TAB_LABEL: number = 10;      // 底部标签
}

// ============ 间距系统 ============
export class Spacing {
  static readonly PAGE_HORIZONTAL: number = 20;
  static readonly SECTION_GAP: number = 20;
  static readonly CARD_PADDING: number = 20;
  static readonly CARD_PADDING_SM: number = 16;
  static readonly ITEM_GAP: number = 12;
  static readonly ITEM_GAP_SM: number = 8;
  static readonly ITEM_GAP_XS: number = 4;
  static readonly CONTENT_GAP: number = 16;
}

// ============ 圆角系统 ============
export class Radius {
  static readonly CARD: number = 16;
  static readonly CARD_SM: number = 12;
  static readonly BUTTON: number = 14;
  static readonly TAG: number = 14;
  static readonly ICON_BG: number = 10;
  static readonly BAR: number = 4;
  static readonly AVATAR: number = 32;
  static readonly APP_ICON: number = 20;
  static readonly TAB_PILL_OUTER: number = 36;
  static readonly TAB_PILL_INNER: number = 26;
  static readonly BATTERY: number = 3;
}

// ============ 尺寸系统 ============
export class Dimensions {
  static readonly STATUS_BAR_HEIGHT: number = 62;
  static readonly HEADER_HEIGHT: number = 56;
  static readonly TAB_BAR_HEIGHT: number = 95;
  static readonly TAB_PILL_HEIGHT: number = 62;
  static readonly TAB_PILL_WIDTH: number = 348;
  static readonly TAB_PILL_MARGIN: number = 21;

  // 卡片
  static readonly SUMMARY_CARD_HEIGHT: number = 77;
  static readonly PROPERTY_CARD_HEIGHT: number = 80;
  static readonly PROFILE_CARD_HEIGHT: number = 174;
  static readonly MAP_CARD_HEIGHT: number = 180;
  static readonly BILL_CARD_HEIGHT: number = 91;
  static readonly CHART_CARD_HEIGHT: number = 219;

  // 按钮
  static readonly BUTTON_HEIGHT: number = 48;
  static readonly FAB_SIZE: number = 56;

  // 头像
  static readonly AVATAR_SIZE: number = 64;
  static readonly APP_ICON_SIZE: number = 80;

  // 图标尺寸
  static readonly ICON_SIZE_TAB: number = 16;      // Tab 栏图标
  static readonly ICON_SIZE_CARD: number = 22;     // 卡片图标
  static readonly ICON_SIZE_MENU: number = 18;     // 菜单项图标
  static readonly ICON_SIZE_FAB: number = 24;      // FAB 按钮图标
  static readonly ICON_SIZE_DETAIL: number = 36;   // 详情页大图标
  static readonly ICON_SIZE_APP: number = 36;      // 应用图标（关于页）
}

// ============ 阴影系统 ============
export class Shadows {
  // 卡片阴影: offset(0,2) blur(12) opacity(0.06)
  static readonly CARD: ShadowConfig = {
    radius: 12,
    color: 'rgba(0,0,0,0.06)',
    offsetX: 0,
    offsetY: 2
  };

  // 列表项阴影: offset(0,1) blur(8) opacity(0.04)
  static readonly LIST_ITEM: ShadowConfig = {
    radius: 8,
    color: 'rgba(0,0,0,0.04)',
    offsetX: 0,
    offsetY: 1
  };

  // 底部导航阴影: offset(0,4) blur(16) opacity(0.08)
  static readonly TAB_BAR: ShadowConfig = {
    radius: 16,
    color: 'rgba(0,0,0,0.08)',
    offsetX: 0,
    offsetY: 4
  };

  // 桌面卡片阴影: offset(0,4) blur(20) opacity(0.1)
  static readonly WIDGET: ShadowConfig = {
    radius: 20,
    color: 'rgba(0,0,0,0.1)',
    offsetX: 0,
    offsetY: 4
  };
}
