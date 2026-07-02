# Feature Specification: RentNote 代码结构全面优化

**Created**: 2026-07-02  
**Status**: Draft  
**Input**: User description: "优化目前的代码结构"

## Overview

对 RentNote（租房台账）HarmonyOS 元服务进行全面的架构重构和代码优化。将当前纯 UI 原型（所有数据硬编码、无状态共享、页面间无数据传递）升级为基于 MVVM 架构的功能性应用。核心改造包括：引入 MVVM 分层架构、使用 Navigation+Tabs 组件替换 router 导航以解决状态丢失问题、通过内存 Mock 仓库实现数据共享与传递、修复所有已知视觉和组件问题。暂不实现数据持久化，数据层使用内存仓库，为后续接入真实存储预留接口。

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Tab 切换保持状态 (Priority: P1)

用户在首页浏览房源列表后，切换到"统计"Tab 查看数据，再切回"首页"Tab，之前浏览的列表位置和状态应当保留，页面不会重新加载或重置到顶部。

**Why this priority**: 这是当前最严重的架构缺陷（router.replaceUrl 销毁页面），直接影响用户体验，且 Navigation+Tabs 重构是所有后续功能的基础。

**Independent Test**: 在首页滚动列表 → 切换到统计页 → 切回首页 → 验证列表滚动位置和内容保留。

**Acceptance Scenarios**:

1. **Given** 用户在首页浏览房源列表，**When** 切换到统计 Tab，**Then** 统计页正常显示，首页不销毁
2. **Given** 用户在统计页，**When** 切换回首页 Tab，**Then** 首页列表滚动位置和内容完整保留
3. **Given** 用户在任意 Tab，**When** 切换到其他 Tab，**Then** 所有 Tab 页面状态均保留
4. **Given** 用户在首页新增房源后，**When** 切换到统计 Tab 再切回，**Then** 新增的房源出现在列表中且统计数据已更新

---

### User Story 2 - 查看房源详情 (Priority: P1)

用户在首页点击任意房源卡片，跳转到该房源的详情页，详情页展示对应房源的真实数据（而非当前硬编码的"阳光花园小区"）。点击返回后回到首页列表。

**Why this priority**: 页面间数据传递是核心功能缺失，与 P1 导航重构紧密关联，必须同步实现。

**Independent Test**: 在首页点击不同房源卡片 → 详情页显示对应房源信息 → 返回首页 → 点击另一房源 → 详情页显示不同信息。

**Acceptance Scenarios**:

1. **Given** 首页房源列表有多个房源，**When** 用户点击房源卡片 A，**Then** 跳转到详情页并显示房源 A 的完整信息
2. **Given** 用户在房源 A 详情页，**When** 点击返回按钮，**Then** 回到首页，房源列表状态保留
3. **Given** 用户返回首页后，**When** 点击房源卡片 B，**Then** 跳转到详情页并显示房源 B 的信息（非房源 A）

---

### User Story 3 - 新增房源 (Priority: P1)

用户在首页点击"+"按钮，进入新增房源页面，填写房源信息后点击"保存"，新房源出现在首页列表中，统计数据同步更新。

**Why this priority**: "保存"按钮无功能是高优先级缺陷，且与数据共享和 MVVM 架构紧密关联。

**Independent Test**: 点击"+"→ 填写房源信息 → 保存 → 首页列表出现新房源 → 统计页数据更新。

**Acceptance Scenarios**:

1. **Given** 用户在首页，**When** 点击"+"浮动按钮，**Then** 跳转到新增房源页面
2. **Given** 用户在新增房源页面填写了完整信息，**When** 点击"保存房源"按钮，**Then** 房源被保存，页面返回首页
3. **Given** 用户保存了一个新房源，**When** 查看首页列表，**Then** 新房源出现在列表中
4. **Given** 用户保存了一个月租 3000 的新房源，**When** 查看统计页，**Then** 月均租金和年度支出数据相应更新

---

### User Story 4 - 统计页面数据准确展示 (Priority: P2)

用户切换到统计页，看到的年度总支出、月均租金、在租数量等数据来源于实际房源列表数据（而非硬编码）。柱状图按数据实际金额比例显示各月租金趋势。

**Why this priority**: 统计数据与房源列表关联是核心功能闭环的一部分，BarChart 按比例渲染是重要视觉修复。

**Independent Test**: 首页有若干房源 → 切换到统计页 → 验证摘要数据与房源列表一致 → 柱状图高度按金额比例显示。

**Acceptance Scenarios**:

1. **Given** 首页有 3 条在租房源（月租分别为 2000/3000/4000），**When** 用户查看统计页，**Then** 月均租金显示 3000，在租数量显示 3，年度支出为 108000
2. **Given** 统计页有 6 个月的租金数据（金额不同），**When** 用户查看柱状图，**Then** 各柱高度按金额比例显示，金额高的柱更高
3. **Given** 用户新增一个房源后，**When** 切换到统计页，**Then** 统计摘要数据和柱状图自动更新

---

### User Story 5 - 视觉组件规范化 (Priority: P2)

应用使用系统图标替代 Emoji、统一使用 HeaderBar 组件、移除装饰性假 StatusBar、修复 TagCategory 类定义位置。

**Why this priority**: 视觉规范化和组件统一影响应用专业度和一致性，属于全面重构的必要部分。

**Independent Test**: 逐页检查图标是否为系统图标、HeaderBar 是否统一、StatusBar 是否移除、TagCategory 是否在 model 目录。

**Acceptance Scenarios**:

1. **Given** 应用中所有原 Emoji 图标位置，**When** 页面渲染，**Then** 使用 HarmonyOS 系统 SymbolGlyph 图标替代
2. **Given** 所有二级页面（新增、详情、设置、关于），**When** 页面显示，**Then** 统一使用 HeaderBar 组件渲染顶部导航栏
3. **Given** 应用启动，**When** 页面渲染，**Then** 不再显示装饰性假 StatusBar（时间9:41）
4. **Given** TagCategory 类，**When** 检查代码结构，**Then** 该类定义在 model/ 目录下而非页面文件中

---

### User Story 6 - 房源编辑与删除 (Priority: P3)

用户在房源详情页点击"编辑"按钮，进入编辑页面修改房源信息后保存；点击"删除"按钮，确认后房源从列表移除，统计数据同步更新。

**Why this priority**: 编辑和删除是 CRUD 完整性的必要功能，但依赖前述房源详情和新增功能。

**Independent Test**: 进入详情页 → 编辑 → 保存 → 验证更新 → 删除 → 验证列表和统计更新。

**Acceptance Scenarios**:

1. **Given** 用户在房源详情页，**When** 点击"编辑"按钮，**Then** 跳转到编辑页面，表单预填充当前房源数据
2. **Given** 用户修改了房源信息并保存，**When** 返回详情页，**Then** 显示更新后的信息
3. **Given** 用户在详情页点击"删除"按钮，**When** 确认删除，**Then** 房源从列表移除，页面返回首页
4. **Given** 用户删除了一个房源，**When** 查看统计页，**Then** 统计数据同步更新

### Edge Cases

- 当房源列表为空时，首页和统计页如何显示？（空状态提示）
- 新增房源时必填字段未填写，保存按钮如何处理？（表单验证提示）
- 删除最后一条房源后，统计页显示零值还是空状态？
- 柱状图中某月租金为 0 时如何显示？

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 应用 MUST 使用 Navigation 组件 + Tabs 子组件实现底部 Tab 导航，保证 Tab 切换时页面状态不丢失
- **FR-002**: 应用 MUST 使用 MVVM 架构分层，包含 View（页面/组件）、ViewModel、Model、Repository 四层
- **FR-003**: 应用 MUST 通过内存 Mock 仓库（Repository）管理房源数据，实现跨页面数据共享
- **FR-004**: 页面间跳转 MUST 通过 Navigation 的 NavDestination 机制传递参数（如房源 ID），而非无参跳转
- **FR-005**: 新增房源页面 MUST 实现"保存"按钮的 onClick 逻辑，将表单数据写入 Repository
- **FR-006**: 房源详情页 MUST 根据传入的房源 ID 从 Repository 获取对应房源数据并展示
- **FR-007**: 数据模型类 MUST 使用 @Observed 装饰器，确保嵌套对象属性变更能触发 UI 更新
- **FR-008**: ViewModel MUST 使用 @ObservedV2 装饰器（若 API 版本支持）或 @Observed，通过 @ObjectLink/@Prop 与 View 绑定
- **FR-009**: 统计页摘要数据 MUST 从 Repository 中的房源列表实时计算，而非硬编码
- **FR-010**: 柱状图组件 MUST 按数据金额比例渲染柱高，金额为 0 时显示最小高度
- **FR-011**: 应用 MUST 移除装饰性假 StatusBar 组件，使用系统原生状态栏
- **FR-012**: 应用 MUST 使用 HarmonyOS 系统 SymbolGlyph 图标替代所有 Emoji 图标
- **FR-013**: 所有二级页面 MUST 统一使用 HeaderBar 组件渲染顶部导航栏
- **FR-014**: TagCategory 辅助类 MUST 从 AddPropertyPage 移入 model/ 目录
- **FR-015**: 房源编辑功能 MUST 支持从详情页进入编辑，表单预填充当前数据
- **FR-016**: 房源删除功能 MUST 提供确认弹窗，删除后同步更新列表和统计数据
- **FR-017**: 空列表状态 MUST 显示空状态占位提示（如"暂无房源，点击添加"）
- **FR-018**: 表单提交 MUST 对必填字段进行基本验证，未通过时显示提示信息

### Key Entities

- **PropertyInfo**: 房源实体，包含 id、名称、地址、区域、标签、月租、押金、起止日期、状态、已缴账单数、图片地址
- **TagCategory**: 标签分类实体，包含分类名和该分类下的标签列表
- **StatisticsOverview**: 统计概览，包含年度总支出、月均租金、在租数量，从房源列表计算得出
- **MonthlyRentItem**: 月度租金条目，包含月份和金额，用于柱状图展示
- **PropertyRepository**: 房源数据仓库（内存实现），提供房源的 CRUD 操作和数据查询
- **PropertyViewModel**: 房源视图模型，连接 Repository 与 View，处理业务逻辑和状态转换

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 用户在任意 Tab 间切换时，页面状态 100% 保留（滚动位置、输入内容、选中状态）
- **SC-002**: 用户点击不同房源卡片后，详情页 100% 展示对应房源数据，不再出现硬编码数据
- **SC-003**: 新增房源保存后，首页列表和统计页数据在 1 秒内同步更新
- **SC-004**: 柱状图柱高与数据金额成正比，最大值柱占满图表高度，最小值柱可见（≥4px）
- **SC-005**: 应用中 0 个 Emoji 图标残留，全部替换为系统图标
- **SC-006**: 所有二级页面统一使用 HeaderBar 组件，0 个重复的手动导航栏实现
- **SC-007**: 代码结构符合 MVVM 分层，View/ViewModel/Model/Repository 各层职责清晰，无跨层调用

## Assumptions

- 数据持久化暂不实现，使用内存 Mock Repository，应用重启后数据重置为预置示例数据
- Repository 接口设计预留持久化扩展能力，后续可替换内存实现为 relationalStore 实现
- HarmonyOS API 版本支持 Navigation 组件和 Tabs 子组件的配合使用
- @ObservedV2 装饰器可用性取决于项目 API 版本，如不可用则回退到 @Observed
- 编辑房源页面复用 AddPropertyPage 组件，通过入参区分新增/编辑模式
- 删除确认使用系统 AlertDialog，不引入第三方组件
- WidgetCard（桌面卡片）本次不集成 FormExtensionAbility，仅保留组件文件

## Open Questions

- [NEEDS CLARIFICATION: 编辑房源页面是复用 AddPropertyPage（通过参数区分新增/编辑模式），还是独立创建 EditPropertyPage？复用可减少代码但增加组件复杂度]
- [NEEDS CLARIFICATION: 预置示例数据是否保留当前的"阳光花园小区"等硬编码数据作为 Mock 初始值？]
