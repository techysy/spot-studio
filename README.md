# spot.studio

> 🎯 骑行 & 徒步活动发布平台 — GPX 轨迹渲染 + 机位踩点 📷

[![GitHub Pages](https://img.shields.io/badge/GitHub-Pages-blue)](https://shiyangyu.com/spot-studio)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

---

## 🌐 在线访问

**https://techysy.github.io/spot-studio**

---

## ✨ 功能特性

### 🗺️ GPX 轨迹渲染
- 上传或拖拽 GPX 文件，地图自动显示轨迹
- 起终点标记（S/E）
- 街道 / 卫星 / CARTO 底图一键切换
- **轨迹颜色编码**：按海拔 / 坡度渐变着色，附颜色图例
- **GPX 元数据**：自动读取标题、描述显示为页面标题和副标题

### 📷 机位踩点 (POI)
- 在地图上标记拍摄点 📸
- **自动吸附**到最近的轨迹点，适配多条 GPX 路线
- 上传 GPX 自动加载 `<wpt>` 航点标记
- 导入时自动去重（按坐标+名称）
- 支持多种兴趣点类型：📸 拍照点 / 🚻 厕所 / 🪑 休息 / 🏪 补给 / ☕ 咖啡 / ⚠️ 注意
- POI 数据支持 JSON 导出 / 导出 GPX 时自动写入兴趣点

### ⛰️ 海拔剖面
- Canvas 绘制海拔图，交互联动地图
- **校准海拔**：DEM API 补全缺失数据
- **偏移校正**：GCJ-02 → WGS-84 坐标转换

### ✏️ 轨迹编辑
- 撤销 / 重做
- 添加 / 删除 / 拖拽节点

### 🚇 隧道过滤
- 坡度阈值（5%-30%）+ 平滑窗口可调
- 实时显示过滤了多少无效爬升

### 📏 距离测量 + 📌 距离标记 + 📊 数据统计

---

## 🛠️ 技术栈

| 层 | 技术 |
|----|------|
| 地图 | [Leaflet](https://leafletjs.com/)（本地离线）+ OSM / CARTO / Esri 卫星 |
| GPX 解析 | 原生 DOMParser |
| 海拔图 | Canvas API |
| 样式 | 纯 CSS（无框架依赖） |
| 运行 | 纯静态，双击 HTML 即可离线使用 |

---

## 🚀 使用方式

### 方式一：PowerShell 启动（推荐）

```powershell
# Windows
.\start.ps1                    # 默认启动
.\start.ps1 -Action restart    # 重启
.\start.ps1 -Action stop       # 停止
.\start.ps1 -Action status     # 查看状态
.\start.ps1 -Action menu       # 交互菜单
```

自动检测端口占用、启动 HTTP 服务器、打开浏览器。

### 方式二：直接打开
双击 `spot-studio.html` 即可在浏览器中使用。

### 方式三：GitHub Pages
1. Fork 或克隆本仓库
2. 推送到 GitHub
3. 在 Settings → Pages 中启用 GitHub Pages

---

## 📁 项目结构

```
spot-studio/
├── spot-studio.html          # 主页面（纯静态，所有功能内联）
├── leaflet.js                # Leaflet 库文件（本地离线）
├── leaflet.css               # Leaflet 样式（本地离线）
├── start.ps1                 # Windows PowerShell 启动脚本
├── README.md                 # 项目文档
├── CHANGELOG.md              # 变更日志
└── LICENSE                   # MIT 许可证
```

---

## 📝 使用说明

1. **上传 GPX**：点击上传区域或拖拽 GPX 文件到页面
2. **查看轨迹**：地图自动显示，可切换卫星图
3. **轨迹着色**：底部工具栏选择「海拔/坡度」渐变着色
4. **添加机位**：工具栏选择类型 → 点击地图放置（自动吸附轨迹）
5. **编辑轨迹**：左上角工具栏添加/删除/拖拽节点
6. **距离测量**：点击 📏 按钮激活测距
7. **海拔联动**：鼠标悬浮海拔图查看位置，点击跳转地图
8. **隧道过滤**：点击爬升卡片调整参数
9. **导出数据**：下载 GPX（含兴趣点）或 POI JSON
10. **海拔校准**：点击「🔄 校准海拔」补全缺失海拔

---

## 📄 License

[MIT](LICENSE)

---

## 👤 作者

- **余师洋**
- GitHub：[@techysy](https://github.com/techysy)
- Strava：[@yangyu](https://www.strava.com/athletes/yangyu)
