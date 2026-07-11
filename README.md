# RentNote · 租房台账

轻松管理租房台账，到期智能提醒。

一款 HarmonyOS 元服务，帮助你追踪房源、管理租期、监控租金与到期倒计时，并通过桌面卡片实时掌握租房状态。

## 功能概览

### 首页 — 当前租住

- 当前租住房源卡片：名称、地址、月租、押金、标签、备注
- 租期进度条：已住天数 / 总天数，临近到期自动变色提醒
- 到期倒计时显示
- 续租意愿标记：续租 / 不租 / 待定

### 备选 — 房源比较

- 地图模式查看备选房源位置（Map Kit）
- 长按进入编辑模式，支持批量选择与删除
- 左滑快捷操作：选定 / 删除
- 选定备选房源自动成为当前租住（原租住降为备选）

### 我的 — 个人设置

- 个人资料编辑（头像、昵称、签名）
- 到期提醒设置（提前 7/15/30/60 天，推送/声音/振动）
- 数据导入导出（JSON 格式）
- 清除数据
- 隐私政策 / 用户协议 / 关于

### 桌面卡片

- 2×4 动态卡片，实时显示本月租金与到期倒计时
- 点击 "+" 快捷添加房源
- 数据变更自动刷新卡片

## 技术架构

```
MVVM + Navigation 单栈路由

View (Pages/Components)
  ↓
ViewModel (HomeViewModel / AddPropertyViewModel / PropertyDetailViewModel)
  ↓
Repository (PropertyRepository — 单例，Preferences 持久化)
  ↓
Model (PropertyInfo / PropertyDTO / TagCategory / UserProfile)
```

### 状态管理

- 主流程使用 V2 装饰器：`@ComponentV2`、`@Local`、`@Param`、`@Event`、`@Provider`/`@Consumer`、`@Monitor`、`@ObservedV2`/`@Trace`
- 桌面卡片使用 V1 装饰器（框架限制）：`@Component` + `@LocalStorageProp`
- 跨页面刷新通过 `@Provider`/`@Consumer` 共享 `refreshFlag` 计数器
- 卡片导航状态通过 `AppStorageV2` + `WidgetNavigateState` 传递

### 数据持久化

- 基于 `@kit.ArkData` Preferences API
- 存储名：`RentNotePrefs`
- 数据版本迁移机制（当前 v4），首次安装预置 5 条示例数据
- 图片存储于沙箱目录 `context.filesDir/property_images`
- 序列化模型 `PropertyDTO` 与响应式模型 `PropertyInfo` 分离

### 导航

- 单入口页 `Index` + `NavigationMode.Stack`
- 所有二级页面通过 `route_map.json` 注册为 `NavDestination`
- `NavPathStack` 通过 `@Provider`/`@Consumer` 全局共享

## 项目结构

```
RentNote/
├── AppScope/
│   ├── app.json5                          # 应用配置（元服务）
│   └── resources/                         # 应用级资源
├── entry/
│   └── src/main/
│       ├── module.json5                   # 模块配置、权限、Ability
│       ├── ets/
│       │   ├── common/
│       │   │   └── DesignTokens.ets       # 设计系统常量
│       │   ├── components/
│       │   │   ├── HeaderBar.ets          # 通用页头
│       │   │   └── MenuItemRow.ets        # 通用菜单项
│       │   ├── entryability/
│       │   │   └── EntryAbility.ets       # 主 Ability 生命周期
│       │   ├── model/
│       │   │   ├── PropertyModel.ets      # 数据模型
│       │   │   └── TagModel.ets           # 标签模型
│       │   ├── pages/
│       │   │   ├── Index.ets              # 主入口（三 Tab）
│       │   │   ├── HomeContent.ets        # 首页 Tab
│       │   │   ├── CandidateContent.ets   # 备选 Tab
│       │   │   ├── MyContent.ets          # 我的 Tab
│       │   │   ├── AddPropertyPage.ets    # 添加/编辑房源
│       │   │   ├── PropertyDetailPage.ets # 房源详情
│       │   │   ├── MapPickerPage.ets      # 地图选点
│       │   │   ├── ProfileEditPage.ets    # 资料编辑
│       │   │   ├── NotificationPage.ets   # 提醒设置
│       │   │   ├── DataImportPage.ets     # 数据导入
│       │   │   ├── DataExportPage.ets     # 数据导出
│       │   │   ├── AboutPage.ets          # 关于
│       │   │   ├── PrivacyPage.ets        # 隐私政策
│       │   │   └── AgreementPage.ets      # 用户协议
│       │   ├── repository/
│       │   │   └── PropertyRepository.ets # 数据持久化单例
│       │   ├── viewmodel/
│       │   │   ├── HomeViewModel.ets
│       │   │   ├── AddPropertyViewModel.ets
│       │   │   └── PropertyDetailViewModel.ets
│       │   └── widget/
│       │       ├── EntryFormAbility.ets   # 卡片 Extension
│       │       └── pages/
│       │           └── RentWidgetCard.ets # 卡片 UI
│       └── resources/
│           ├── base/
│           │   ├── element/               # 字符串、颜色、尺寸
│           │   ├── media/                 # 图标、图片
│           │   └── profile/               # 路由、页面、卡片配置
│           └── ...
├── EntryCard/                             # 卡片快照预览图
├── sign/                                  # 签名材料
├── build-profile.json5                    # 构建配置
└── oh-package.json5                       # 依赖配置
```

## 权限

| 权限 | 用途 |
|------|------|
| `ohos.permission.INTERNET` | 网络访问 |
| `ohos.permission.APPROXIMATELY_LOCATION` | 地图粗略定位 |
| `ohos.permission.LOCATION` | 地图精确定位 |

## 依赖

无第三方运行时依赖，仅使用 HarmonyOS 系统 Kit：

| Kit | 用途 |
|-----|------|
| `@kit.ArkData` | Preferences 数据持久化 |
| `@kit.ArkUI` | UI 组件与状态管理 |
| `@kit.FormKit` | 桌面卡片 |
| `@kit.AbilityKit` | Ability 生命周期 |
| `@kit.MapKit` | 地图组件与逆地理编码 |
| `@kit.MediaLibraryKit` | 图片选择 |
| `@kit.CoreFileKit` | 文件读写与选择器 |

## 开发环境

- **SDK**: HarmonyOS 6.1.1(24)
- **DevEco Studio**: 推荐最新版
- **运行设备**: Phone / Tablet

## 构建

1. 使用 DevEco Studio 打开项目
2. 配置签名（`sign/` 目录下的 .p12 / .cer / .p7b 文件）
3. 选择 Build > Build App(s) 构建安装包
4. 选择 Run 运行到设备/模拟器

## 许可

Copyright © 2026 wangmc
