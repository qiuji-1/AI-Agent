# AI Agent 前端项目技术说明文档

## 1. 项目概述

本项目是一个基于 Vue3 的 AI 聊天应用前端，提供两个核心功能模块：AI 聊天大师和 AI 超级智能体。应用采用现代化的聊天室风格设计，通过 Server-Sent Events (SSE) 实现实时消息推送。

## 2. 技术栈

| 分类 | 技术 | 版本 | 说明 |
| :--- | :--- | :--- | :--- |
| 框架 | Vue | ^3.4.21 | 前端核心框架，使用 Composition API |
| 路由 | Vue Router | ^4.3.2 | 单页应用路由管理 |
| 构建工具 | Vite | ^4.5.2 | 快速构建工具，支持热更新 |
| HTTP 库 | Axios | ^1.6.8 | HTTP 请求库（预留） |

## 3. 项目结构

```
qiu-agent-frontend/
├── index.html                 # HTML 入口文件
├── package.json               # 项目依赖配置
├── vite.config.js             # Vite 配置文件
├── TECHNICAL_DOC.md           # 技术说明文档
└── src/
    ├── main.js                # Vue 应用入口
    ├── App.vue                # 根组件
    ├── router/
    │   └── index.js           # 路由配置
    └── views/
        ├── Home.vue           # 主页 - 应用切换导航
        ├── ChatMaster.vue     # AI 聊天大师页面
        └── SuperAgent.vue     # AI 超级智能体页面
```

### 3.1 文件职责说明

| 文件路径 | 职责 | 说明 |
| :--- | :--- | :--- |
| `src/main.js` | 应用入口 | 初始化 Vue 应用，配置路由 |
| `src/App.vue` | 根组件 | 提供应用容器，挂载路由视图 |
| `src/router/index.js` | 路由管理 | 定义页面路由映射关系 |
| `src/views/Home.vue` | 主页 | 展示应用卡片，提供导航入口 |
| `src/views/ChatMaster.vue` | 聊天大师 | 聊天室界面，调用 `/api/ai/chat/sse` 接口 |
| `src/views/SuperAgent.vue` | 超级智能体 | 聊天室界面，调用 `/api/ai/manus/chat` 接口 |

## 4. 功能模块说明

### 4.1 主页模块 (`Home.vue`)

**功能特性：**
- 展示两个 AI 应用入口卡片
- 卡片悬停动画效果
- 点击卡片跳转到对应页面

**设计风格：**
- 渐变紫色背景
- 卡片式布局
- SVG 图标

### 4.2 AI 聊天大师模块 (`ChatMaster.vue`)

**功能特性：**
- 聊天室风格 UI（用户消息在右侧，AI 消息在左侧）
- 自动生成唯一会话 ID (`chatId`)
- SSE 实时消息推送
- 消息加载动画
- 支持 Enter 键发送
- 消息列表自动滚动

**技术实现：**
- 使用 `EventSource` 实现 SSE 连接
- 动态拼接 AI 响应内容
- 响应式消息列表管理

**接口调用：**
```
GET /api/ai/chat/sse?message={message}&chatId={chatId}
```

### 4.3 AI 超级智能体模块 (`SuperAgent.vue`)

**功能特性：**
- 与聊天大师相同的聊天室 UI
- 科技风格配色（深蓝色 + 青色）
- SSE 实时消息推送

**技术实现：**
- 同上聊天大师

**接口调用：**
```
GET /api/ai/manus/chat?message={message}
```

## 5. 配置与运行

### 5.1 开发环境配置

**Vite 配置 (`vite.config.js`)：**

| 配置项 | 值 | 说明 |
| :--- | :--- | :--- |
| 端口 | 5173 | 开发服务器端口 |
| 代理目标 | http://localhost:8123 | 后端 API 地址 |
| 代理路径 | /api | API 请求路径前缀 |
| 路径别名 | `@` → `src/` | 简化模块引用 |

### 5.2 启动命令

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 构建生产版本
npm run build

# 预览生产构建
npm run preview
```

### 5.3 启动流程

1. **启动后端服务**：确保后端服务运行在 `http://localhost:8123`
2. **安装依赖**：执行 `npm install`
3. **启动前端**：执行 `npm run dev`
4. **访问应用**：打开浏览器访问 `http://localhost:5173`

## 6. API 接口说明

### 6.1 接口列表

| 接口路径 | HTTP 方法 | 所属页面 | 说明 |
| :--- | :--- | :--- | :--- |
| `/api/ai/chat/sse` | GET | ChatMaster | SSE 流式聊天接口 |
| `/api/ai/manus/chat` | GET | SuperAgent | SSE 超级智能体聊天接口 |

### 6.2 接口详细说明

#### 6.2.1 `/api/ai/chat/sse`

**功能：** AI 聊天大师流式响应接口

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
| :--- | :--- | :--- | :--- |
| `message` | string | 是 | 用户输入的消息内容 |
| `chatId` | string | 是 | 会话 ID，用于区分不同会话 |

**响应格式：** SSE 流

#### 6.2.2 `/api/ai/manus/chat`

**功能：** AI 超级智能体流式响应接口

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
| :--- | :--- | :--- | :--- |
| `message` | string | 是 | 用户输入的消息内容 |

**响应格式：** SSE 流

## 7. 开发注意事项

### 7.1 SSE 连接管理

- SSE 连接在消息发送时创建，完成后自动关闭
- 使用 `onmessage` 监听消息块，动态拼接响应内容
- 使用 `onerror` 和 `onclose` 处理异常和连接关闭

### 7.2 样式设计规范

| 页面 | 主题色 | 渐变配色 |
| :--- | :--- | :--- |
| 主页 | 紫色系 | #667eea → #764ba2 |
| 聊天大师 | 紫色系 | #667eea → #764ba2 |
| 超级智能体 | 科技蓝 | #00d4ff → #0099cc |

### 7.3 性能优化

- 使用 `nextTick` 确保 DOM 更新后再滚动
- 消息列表使用 `max-width: 80%` 限制宽度
- SVG 图标内联，减少 HTTP 请求

### 7.4 浏览器兼容性

- 支持现代浏览器（Chrome、Firefox、Edge）
- SSE 需要浏览器支持 `EventSource` API
- 建议使用 ES6+ 兼容的浏览器

## 8. 部署说明

### 8.1 生产构建

```bash
npm run build
```

构建产物输出到 `dist/` 目录。

### 8.2 部署建议

- 部署到静态文件服务器（如 Nginx、Apache）
- 配置反向代理将 `/api` 请求转发到后端服务
- 设置适当的 CORS 策略

## 9. 版本历史

| 版本 | 日期 | 变更说明 |
| :--- | :--- | :--- |
| 1.0.0 | 2026-06 | 初始版本，包含主页、聊天大师、超级智能体三个页面 |

---

**文档版本：** v1.0  
**创建日期：** 2026-06  
**适用项目：** qiu-agent-frontend