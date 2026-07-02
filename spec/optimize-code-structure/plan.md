# Implementation Plan: RentNote 代码结构全面优化

**Input**: Feature specification from `spec/optimize-code-structure/spec.md`

## Summary

对 RentNote（租房台账）进行 MVVM 架构重构：将纯 UI 原型升级为基于 Navigation+Tabs 导航、MVVM 分层、内存 Repository 数据共享的功能性应用。替换 router 导航为 Navigation 组件以解决 Tab 切换状态丢失；实现页面间参数传递和房源 CRUD 功能；使用状态管理 V2（@ComponentV2/@ObservedV2/@Trace/@Local/@Param）确保数据响应式更新；修复所有视觉问题（Emoji→SymbolGlyph、统一 HeaderBar、移除假 StatusBar、BarChart 按比例渲染）。

## Technical Context

**Language/Version**: ArkTS (HarmonyOS SDK 6.1.1, API 24)  
**Primary Dependencies**: @kit.ArkUI (Navigation, Tabs, SymbolGlyph), @kit.ArkTS (collections)  
**Storage**: 内存 Mock Repository（暂不实现持久化，预留 Repository 接口供后续替换）  
**Testing**: Hypium (ohosTest), Hamock (unit test)  
**Target Platform**: HarmonyOS Phone/Tablet  
**Project Type**: 元服务 (atomicService) 移动应用  
**Performance Goals**: Tab 切换零延迟无重载，页面间数据同步 < 1s  
**Constraints**: V1/V2 状态装饰器禁止混用；Navigation 路由表需配置 route_map.json  
**Scale/Scope**: 7 页面 + 8 组件 → 重构为 1 入口页 + 3 Tab 内容 + 4 NavDestination 子页面

## Project Structure

### Documentation (this feature)

```text
spec/optimize-code-structure/
├── spec.md              # Feature specification
├── plan.md              # This file
└── tasks.md             # Task breakdown (Phase 3)
```

### Source Code (repository root)

```text
entry/src/main/ets/
├── common/
│   └── DesignTokens.ets           # [保留] 设计令牌系统
├── components/
│   ├── BarChart.ets               # [重构] 按数据比例渲染柱高
│   ├── HeaderBar.ets              # [保留] 通用头部组件
│   ├── MenuItemRow.ets            # [重构] Emoji→SymbolGlyph
│   ├── PropertyCard.ets           # [重构] @Prop→@Param
│   ├── SummaryCard.ets            # [重构] @Prop→@Param
│   └── TabBar.ets                 # [删除] 由 Navigation+Tabs 内置 bar 替代
│   └── StatusBar.ets              # [删除] 移除装饰性假 StatusBar
│   └── WidgetCard.ets             # [保留] 暂不集成
├── model/
│   ├── PropertyModel.ets          # [重构] @ObservedV2+@Trace 装饰器
│   └── TagModel.ets               # [新增] TagCategory 从页面移入
├── repository/
│   └── PropertyRepository.ets     # [新增] 内存 Mock 仓库，CRUD 接口
├── viewmodel/
│   ├── HomeViewModel.ets          # [新增] 首页 VM
│   ├── StatisticsViewModel.ets    # [新增] 统计页 VM
│   ├── AddPropertyViewModel.ets   # [新增] 新增/编辑房源 VM
│   └── PropertyDetailViewModel.ets # [新增] 房源详情 VM
├── pages/
│   ├── Index.ets                  # [重构] Navigation+Tabs 容器入口
│   ├── HomeContent.ets            # [新增] 首页 Tab 内容区（从 Index.ets 抽取）
│   ├── StatisticsContent.ets      # [新增] 统计 Tab 内容区（从 StatisticsPage.ets 改造）
│   ├── MyContent.ets              # [新增] 我的 Tab 内容区（从 MyPage.ets 改造）
│   ├── AddPropertyPage.ets        # [重构] NavDestination，复用新增/编辑
│   ├── PropertyDetailPage.ets     # [重构] NavDestination，接收房源 ID 参数
│   ├── SettingsPage.ets           # [重构] NavDestination，统一 HeaderBar
│   └── AboutPage.ets              # [重构] NavDestination，统一 HeaderBar
└── entryability/
    └── EntryAbility.ets           # [保留] 入口能力

entry/src/main/resources/
└── base/
    └── profile/
        ├── main_pages.json        # [修改] 仅保留 Index 页
        └── route_map.json         # [新增] Navigation 系统路由表
```

**Structure Decision**: 采用 MVVM 四层架构（View → ViewModel → Repository → Model）。页面层使用 Navigation+Tabs 作为根容器，Tab 内容区为独立组件（非独立页面），二级页面通过 NavDestination+路由表注册。状态管理全面迁移到 V2 装饰器体系。

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| V2 状态管理全面迁移 | 需要深度嵌套属性观察和单向数据流 | V1 @Observed 仅浅层观察，嵌套属性变更无法触发 UI 更新，且 V1/V2 禁止混用 |
| Navigation 嵌套 Tabs | Tab 切换保持状态 + 子页面栈管理 | 纯 Tabs 无法管理子页面栈；纯 router 导致页面销毁状态丢失 |
| ViewModel 层引入 | 分离 UI 逻辑与业务逻辑，支持跨页面数据共享 | 直接在 @Component 中写业务逻辑导致代码耦合、无法复用 |

## Research & Decisions

### Decision 1: 状态管理版本选择

**Decision**: 全面采用 V2 状态管理装饰器（@ComponentV2、@ObservedV2、@Trace、@Local、@Param、@Event）

**Rationale**: 
- 项目 API 版本为 6.1.1(24)，完全支持 V2 装饰器（从 API 12 开始支持）
- V2 提供深度嵌套属性观察（@ObservedV2+@Trace），无需逐层 @ObjectLink 绑定
- V2 采用 @Param+@Event 单向数据流，比 @Link 双向绑定更清晰
- V1/V2 装饰器禁止混用（编译报错），必须统一选型
- 官方推荐新项目优先使用 V2

**Alternatives considered**: 
- V1 装饰器（@Component、@Observed、@ObjectLink、@State、@Prop、@Link）— 嵌套观察困难，@Link 双向绑定难维护
- 混合使用 V1+V2 — 编译报错，不可行

### Decision 2: 导航架构

**Decision**: 外层 Navigation 容器 + 内嵌 Tabs 组件，Tab 内容区为组件（非页面），子页面通过 NavDestination 实现

**Rationale**:
- Navigation 作为页面根容器管理页面栈，Tabs 仅负责 Tab 内容切换
- TabContent 包裹的组件不会被销毁，状态自然保留
- 二级页面（详情、新增、设置、关于）通过 NavPathStack pushPathByName 跳转
- 子页面通过 onReady 回调接收参数，通过 pop 返回并传递结果
- 底部 Tab 栏使用 Tabs 的内置 tabBar 配置（@Builder TabBuilder），无需自定义 TabBar 组件

**Alternatives considered**:
- 纯 Tabs 组件 — 无法管理子页面栈（详情页等）
- 保留 router + AppStorage — router.replaceUrl 销毁页面，AppStorage 无法解决根本问题
- Navigation 嵌套 Navigation — 过度复杂，当前单模块不需要

### Decision 3: 数据层架构

**Decision**: 内存 Mock Repository，通过 AppStorageV2 全局共享

**Rationale**:
- 用户明确暂不实现持久化
- AppStorageV2 可在全局范围创建和获取 @ObservedV2 对象，跨页面共享
- Repository 封装 CRUD 接口，后续替换为 relationalStore 实现无需改动 ViewModel
- 预置示例数据通过 Repository 初始化注入

**Alternatives considered**:
- 纯 @Local + 构造函数传参 — Tab 内容区无法直接向 NavDestination 传参
- @Provider/@Consumer — 可行但 AppStorageV2 更适合全局单例数据

### Decision 4: 图标方案

**Decision**: 使用 SymbolGlyph 系统图标替代 Emoji

**Rationale**:
- HarmonyOS 提供丰富的系统预置 Symbol 资源（sys.symbol.*）
- SymbolGlyph 支持自定义颜色、大小、渲染策略和动效
- Emoji 跨设备渲染不一致，无法自定义颜色和样式
- 示例：🏠 → sys.symbol.house，📊 → sys.symbol.chart_bar，👤 → sys.symbol.person

**Alternatives considered**:
- 自定义 SVG 资源 — 需要额外设计资源，系统图标已足够
- 保留 Emoji — 渲染不一致，无法着色

### Decision 5: 编辑房源页面方案

**Decision**: 复用 AddPropertyPage，通过入参区分新增/编辑模式

**Rationale**:
- 新增和编辑表单 UI 完全一致，仅数据预填充不同
- 通过 NavDestination 参数传入可选的 propertyId，有则为编辑模式
- 减少 UI 代码重复，维护单一表单组件

**Alternatives considered**:
- 独立 EditPropertyPage — UI 完全重复，维护成本翻倍

## Data Model

### PropertyInfo（房源实体）

| 属性 | 类型 | @Trace | 说明 |
|------|------|--------|------|
| id | string | ✓ | 唯一标识，UUID 生成 |
| name | string | ✓ | 小区名称 |
| address | string | ✓ | 详细地址 |
| district | string | ✓ | 区域/商圈 |
| tags | string[] | ✓ | 标签列表（付款方式、租期、状况、便利设施） |
| monthlyRent | number | ✓ | 月租金（元） |
| deposit | number | ✓ | 押金（元） |
| startDate | string | ✓ | 租期开始日期 (YYYY-MM-DD) |
| endDate | string | ✓ | 租期结束日期 (YYYY-MM-DD) |
| status | string | ✓ | 状态：renting/expiring/expired |
| billsPaid | number | ✓ | 已缴账单数 |
| imageUrl | string | ✓ | 图片地址 |
| notes | string | ✓ | 备注 |

装饰器：`@ObservedV2`，所有可变属性加 `@Trace`

### TagCategory（标签分类）

| 属性 | 类型 | @Trace | 说明 |
|------|------|--------|------|
| name | string | ✓ | 分类名称 |
| tags | string[] | ✓ | 该分类下的标签列表 |

装饰器：`@ObservedV2`

### StatisticsOverview（统计概览）

| 属性 | 类型 | @Trace | 说明 |
|------|------|--------|------|
| yearlyExpense | number | ✓ | 年度总支出 |
| monthlyAvgRent | number | ✓ | 月均租金 |
| rentingCount | number | ✓ | 在租数量 |

装饰器：`@ObservedV2`，从 Repository 实时计算

### MonthlyRentItem（月度租金条目）

| 属性 | 类型 | 说明 |
|------|------|------|
| month | string | 月份标签 |
| amount | number | 金额 |

普通 class，用于 BarChart 数据源

### PropertyRepository（房源仓库接口契约）

- `getAllProperties(): PropertyInfo[]` — 获取全部房源
- `getPropertyById(id: string): PropertyInfo | undefined` — 按 ID 获取
- `addProperty(property: PropertyInfo): void` — 新增房源
- `updateProperty(property: PropertyInfo): void` — 更新房源
- `deleteProperty(id: string): void` — 删除房源
- `getStatisticsOverview(): StatisticsOverview` — 计算统计概览
- `getMonthlyRentItems(): MonthlyRentItem[]` — 获取月度租金数据
- `getExpiringProperties(days: number): PropertyInfo[]` — 获取即将到期房源

### ViewModel 接口契约

#### HomeViewModel
- `properties: PropertyInfo[]` — 房源列表
- `expiringCount: number` — 即将到期数
- `totalMonthlyExpense: number` — 月度总支出
- `loadData(): void` — 加载数据
- `refreshData(): void` — 刷新数据

#### AddPropertyViewModel
- `isEditMode: boolean` — 是否编辑模式
- `editPropertyId: string` — 编辑的房源 ID
- `saveProperty(data: PropertyInfo): void` — 保存房源（新增或更新）
- `validateForm(data: PropertyInfo): boolean` — 表单验证

#### PropertyDetailViewModel
- `property: PropertyInfo | undefined` — 当前房源
- `loadProperty(id: string): void` — 加载房源数据
- `deleteProperty(id: string): void` — 删除房源

#### StatisticsViewModel
- `overview: StatisticsOverview` — 统计概览
- `monthlyData: MonthlyRentItem[]` — 月度数据
- `expiringProperties: PropertyInfo[]` — 即将到期房源
- `loadData(): void` — 加载统计

## Contracts & Interfaces

### Navigation 路由表 (route_map.json)

```text
路由名称映射：
- "AddProperty"   → AddPropertyPage     (新增/编辑房源)
- "PropertyDetail" → PropertyDetailPage  (房源详情)
- "Settings"       → SettingsPage        (设置)
- "About"          → AboutPage           (关于)
```

### NavDestination 参数传递协议

| 目标页面 | 传入参数 | 返回参数 |
|---------|---------|---------|
| AddPropertyPage | `{ propertyId?: string }` (有则为编辑模式) | `{ saved: boolean }` |
| PropertyDetailPage | `{ propertyId: string }` | `{ deleted?: boolean, propertyId?: string }` |
| SettingsPage | 无 | 无 |
| AboutPage | 无 | 无 |

### SymbolGlyph 图标映射

| 原 Emoji | 系统 Symbol 资源名 | 用途 |
|---------|-------------------|------|
| 🏠 | sys.symbol.house | 首页 Tab |
| 📊 | sys.symbol.chart_bar | 统计 Tab |
| 👤 | sys.symbol.person | 我的 Tab |
| 📅 | sys.symbol.calendar | 日期相关 |
| 💰 | sys.symbol.yen_sign | 金额相关 |
| ➕ | sys.symbol.plus | 新增按钮 |
| 🔙 | sys.symbol.chevron_left | 返回按钮 |
| 🏘️ | sys.symbol.building | 房源图标 |
| ⚙️ | sys.symbol.gear | 设置 |
| ℹ️ | sys.symbol.info | 关于/信息 |
| 📋 | sys.symbol.doc_text | 文档/协议 |
| 🔒 | sys.symbol.lock | 隐私 |
| 🗑️ | sys.symbol.trash | 删除 |
| ✏️ | sys.symbol.pencil | 编辑 |
| 🔔 | sys.symbol.bell | 提醒/通知 |
| 📤 | sys.symbol.share | 导出/分享 |
| 📥 | sys.symbol.arrow_down_doc | 导入 |
| 🔄 | sys.symbol.arrow_clockwise | 刷新/恢复 |

### 首页 main_pages.json 配置

仅保留 `pages/Index` 一个页面入口，所有子页面通过 Navigation 路由表管理。
