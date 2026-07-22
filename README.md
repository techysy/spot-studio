# spot.studio

> 🎯 骑行 & 徒步活动发布平台 — GPX 轨迹渲染 + 机位踩点 📷

[![GitHub Pages](https://img.shields.io/badge/GitHub-Pages-blue)](https://techysy.github.io/spot-studio)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

---

## 🌐 在线访问

**https://techysy.github.io/spot-studio**

---

## ✨ 功能特性

### 🗺️ GPX 轨迹渲染
- 上传或拖拽 GPX 文件，地图自动显示轨迹
- 起终点标记（S/E）
- 街道 / 卫星底图一键切换

### 📷 机位踩点 (POI)
- 在地图上标记拍摄点 📸
- 支持多种兴趣点类型：
  - 📸 拍照点
  - 🚻 厕所
  - 🪑 休息
  - 🏪 补给点
  - 💧 饮水
  - ⚠️ 注意
- POI 数据支持 JSON 导出 / 导入

### ⛰️ 海拔剖面
- Canvas 绘制海拔图
- 距离 / 海拔刻度

### 🚇 隧道过滤
- 梯度检测去除 GPS 异常跳点
- 可调坡度阈值（5%-30%）和平滑窗口
- 实时显示过滤了多少无效爬升

### 🚴 电子骑友
- 匀速模拟骑行（默认 25 km/h，可调）
- 实时动画沿轨迹前进
- 进度条 + 预估到达时间
- 暂停 / 重置控制

### 📊 数据统计
- 距离 (km)
- 爬升 (m)
- 时长（按 25km/h 匀速计算）

### 🔗 路书链接
- Strava
- iGPSPORT
- Garmin Connect

### 📤 分享
- 微博、Twitter 分享
- 复制链接

---

## 🛠️ 技术栈

| 层 | 技术 |
|----|------|
| 地图 | [Leaflet](https://leafletjs.com/) + OpenStreetMap / Esri 卫星 |
| GPX 解析 | 原生 DOMParser |
| 海拔图 | Canvas API |
| 动画 | requestAnimationFrame |
| 样式 | 纯 CSS（无框架依赖） |

---

## 🚀 使用方式

### 方式一：直接打开
双击 `index.html` 即可在浏览器中使用。

### 方式二：GitHub Pages
1. Fork 或克隆本仓库
2. 推送到 GitHub
3. 在 Settings → Pages 中启用 GitHub Pages
4. 访问 `https://你的用户名.github.io/spot-studio`

---

## 📁 项目结构

```
spot-studio/
├── index.html         # 主页面（纯静态，所有功能内联）
├── README.md          # 项目文档
├── CHANGELOG.md       # 变更日志
└── LICENSE            # MIT 许可证
```

---

## 📝 使用说明

1. **上传 GPX**：点击上传区域或拖拽 GPX 文件到页面
2. **查看轨迹**：地图自动显示轨迹，可切换卫星图
3. **添加机位**：点击地图上方工具栏选择类型，再点击地图放置
4. **隧道过滤**：自动开启，可调整参数或关闭
5. **模拟骑行**：点击「出发」观看电子骑友沿轨迹前进
6. **导出数据**：下载 GPX 文件或导出 POI 数据

---

## 📄 License

[MIT](LICENSE)

---

## 👤 作者

- **余师洋**
- GitHub：[@techysy](https://github.com/techysy)
- Strava：[@yangyu](https://www.strava.com/athletes/yangyu)
