<template>
  <div class="review-container">
    <div class="header">
      <div class="header-left">
        <button class="back-btn" @click="$router.push('/')">&#8592; 返回</button>
        <h1>面试知识点复习</h1>
      </div>
      <div class="stats">
        已掌握 <span class="num mastered-num">{{ masteredCount }}</span>
        / 需复习 <span class="num review-num">{{ reviewCount }}</span>
        / 总共 <span class="num total-num">{{ totalCount }}</span>
        <div class="progress-bar">
          <div class="progress-fill" :style="{ width: progressPercent + '%' }"></div>
        </div>
      </div>
    </div>

    <div class="content">
      <div class="sidebar">
        <button
          class="category-btn ref-btn"
          :class="{ active: showReferences }"
          @click="showReferences = !showReferences"
        >
          &#128214; 官方文档
        </button>
        <button
          v-for="cat in categories"
          :key="cat.id"
          class="category-btn"
          :class="{ active: currentCategory === cat.id && !showReferences }"
          @click="selectCategory(cat.id)"
        >
          {{ cat.name }}
          <span class="count">{{ getCategoryMastered(cat) }}/{{ cat.questions.length }}</span>
        </button>
      </div>

      <div class="main">
        <div v-if="showReferences" class="ref-panel">
          <h2 class="ref-title">官方文档 &amp; 参考资料</h2>
          <div v-for="ref in references" :key="ref.id" class="ref-card">
            <h3 class="ref-card-title">{{ ref.name }}</h3>
            <div class="ref-links">
              <a v-for="link in ref.links" :key="link.url" :href="link.url" target="_blank" class="ref-link">
                {{ link.label }}
              </a>
            </div>
            <div class="ref-summary">
              <p v-for="(point, idx) in ref.summary" :key="idx">{{ point }}</p>
            </div>
          </div>
        </div>

        <div v-else>
          <div class="filter-bar">
            <button
              v-for="f in filters"
              :key="f.value"
              class="filter-btn"
              :class="{ active: currentFilter === f.value }"
              @click="currentFilter = f.value"
            >
              {{ f.label }}
            </button>
          </div>

          <div v-if="filteredQuestions.length === 0" class="empty">
            暂无题目
          </div>

          <div
            v-for="q in filteredQuestions"
            :key="q.id"
            class="q-card"
            :class="getStatus(q.id)"
            @click="toggleAnswer(q.id)"
          >
            <div class="q-title">
              <span>{{ q.question }}</span>
              <span v-if="getStatus(q.id) === 'mastered'" class="badge badge-mastered">已掌握</span>
              <span v-else-if="getStatus(q.id) === 'review'" class="badge badge-review">需复习</span>
            </div>
            <div class="q-tags">
              <span v-for="tag in q.tags" :key="tag" class="q-tag">{{ tag }}</span>
            </div>
            <div v-show="expanded[q.id]" class="q-answer">
              {{ q.answer }}
              <div class="q-source">&#128214; 来源：{{ q.source }}</div>
            </div>
            <div v-show="expanded[q.id]" class="q-actions">
              <button class="btn-mastered" @click.stop="setStatus(q.id, 'mastered')">&#9989; 已掌握</button>
              <button class="btn-review" @click.stop="setStatus(q.id, 'review')">&#128260; 需复习</button>
              <button class="btn-reset" @click.stop="setStatus(q.id, 'unseen')">&#8617; 重置</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const categories = ref([])
const currentCategory = ref('java')
const currentFilter = ref('all')
const expanded = ref({})
const statusMap = ref({})
const showReferences = ref(false)

const references = [
  {
    id: 'java',
    name: 'Java',
    links: [
      { label: 'Oracle Java 官方文档', url: 'https://docs.oracle.com/en/java/' },
      { label: 'JavaGuide（面试指南）', url: 'https://javaguide.cn/' }
    ],
    summary: [
      '反射：运行时获取类信息并动态操作对象，核心类 Class/Method/Field/Constructor',
      '线程池 7 参数：corePoolSize、maximumPoolSize、keepAliveTime、unit、workQueue、threadFactory、handler',
      'HashMap：数组+链表+红黑树（JDK1.8），put 时先算 hash 再定位下标，链表≥8 且数组≥64 转红黑树',
      '异常体系：Throwable → Error / Exception，Exception 分 Checked（必须处理）和 Unchecked（运行时）',
      '接口 vs 抽象类：接口多实现定义行为规范，抽象类单继承提取公共代码'
    ]
  },
  {
    id: 'springboot',
    name: 'Spring Boot',
    links: [
      { label: 'Spring Boot 官方文档', url: 'https://docs.spring.io/spring-boot/reference/' },
      { label: 'Spring Boot GitHub', url: 'https://github.com/spring-projects/spring-boot' }
    ],
    summary: [
      '@SpringBootApplication = @Configuration + @EnableAutoConfiguration + @ComponentScan',
      '自动配置：读取 AutoConfiguration.imports → 加载配置类 → @Conditional 条件判断是否生效',
      '@ConditionalOnClass / @ConditionalOnMissingBean / @ConditionalOnProperty 是核心条件注解',
      'Starter 是依赖集合，自定义 Starter 需创建自动配置类 + 注册文件 + 配置属性类',
      '跨域配置推荐全局 CorsConfig 实现 WebMvcConfigurer，allowCredentials(true) 时不能用 "*"'
    ]
  },
  {
    id: 'springai',
    name: 'Spring AI',
    links: [
      { label: 'Spring AI 官方文档', url: 'https://docs.spring.io/spring-ai/reference/' },
      { label: 'ChatClient API', url: 'https://docs.spring.io/spring-ai/reference/api/chatclient.html' },
      { label: 'Advisors API', url: 'https://docs.spring.io/spring-ai/reference/api/advisors.html' },
      { label: 'RAG 文档', url: 'https://docs.spring.io/spring-ai/reference/api/retrieval-augmented-generation.html' }
    ],
    summary: [
      'ChatClient 是统一对话接口，builder(chatModel).defaultSystem().defaultAdvisors().build() 构建',
      'Tool Calling：模型决定调用工具 → Spring AI 执行 → 结果返回模型 → 生成最终回答',
      'RAG 流程：文档加载 → 分割 → 向量化 → 存入 VectorStore → 检索相似块 → 注入上下文生成',
      'QuestionAnswerAdvisor 实现 Naive RAG，RetrievalAugmentationAdvisor 实现模块化 RAG',
      'Advisor 接口：CallAdvisor（同步）和 StreamAdvisor（流式），adviseCall/adviseStream 是核心方法',
      'ChatMemory：MessageChatMemoryAdvisor 管理对话历史，支持 JDBC/内存持久化'
    ]
  },
  {
    id: 'ai-knowledge',
    name: 'AI 知识（Prompt/RAG/MCP）',
    links: [
      { label: 'OpenAI 文档', url: 'https://platform.openai.com/docs' },
      { label: 'Anthropic 文档', url: 'https://docs.anthropic.com/' },
      { label: 'MCP 官方规范', url: 'https://modelcontextprotocol.io/' },
      { label: 'LangChain 文档', url: 'https://python.langchain.com/docs/' }
    ],
    summary: [
      'Prompt 技巧：角色设定、明确任务、Few-shot 示例、思维链、分隔符、输出格式指定',
      'RAG vs 微调：RAG 知识可实时更新成本低，微调模型学会知识响应快但训练成本高',
      'MCP（Model Context Protocol）：Anthropic 提出的标准协议，统一 AI 与外部工具/数据的交互',
      'MCP 架构：Client ↔ MCP Server ↔ 外部资源，提供 Tools/Resources/Prompts 三种能力',
      'MCP 传输：Stdio（本地进程通信）和 SSE（远程 HTTP 通信）',
      'AI Agent = 规划 + 工具使用 + 记忆 + 反思，区别于普通 ChatBot 的自主执行能力'
    ]
  },
  {
    id: 'database',
    name: '数据库',
    links: [
      { label: 'MySQL 官方文档', url: 'https://dev.mysql.com/doc/' },
      { label: '《MySQL 必知必会》', url: 'https://www.mysql.com/' }
    ],
    summary: [
      'SQL 分类：DDL（CREATE/ALTER/DROP）、DML（INSERT/UPDATE/DELETE）、DQL（SELECT）、DCL、TCL',
      '索引：B+ 树结构，查询 O(log n)，缺点是占空间、降低写性能，WHERE/JOIN/ORDER BY 列适合建索引',
      'ACID：原子性（undo log）、一致性、隔离性（锁+MVCC）、持久性（redo log）',
      '主键唯一标识行，外键引用其他表主键建立关系，一对多在"多"方加外键列'
    ]
  },
  {
    id: 'git',
    name: 'Git',
    links: [
      { label: 'Pro Git 官方书', url: 'https://git-scm.com/book/zh/v2' },
      { label: 'Git 官方文档', url: 'https://git-scm.com/doc' }
    ],
    summary: [
      '工作流：工作区 → git add → 暂存区 → git commit → 本地仓库 → git push → 远程仓库',
      '合并冲突：找到 <<<<<<< 标记 → 手动编辑保留内容 → git add → git commit',
      '分支策略：Git Flow（main/develop/feature）适合固定发布，GitHub Flow（main/feature）适合持续部署',
      '常用命令：clone/add/commit/push/pull/status/log/branch/checkout/merge'
    ]
  },
  {
    id: 'network',
    name: '计算机网络',
    links: [
      { label: 'MDN Web 文档', url: 'https://developer.mozilla.org/zh-CN/' },
      { label: '《计算机网络：自顶向下方法》', url: 'https://gaia.cs.umass.edu/kurose_ross/' }
    ],
    summary: [
      'HTTP 明文端口 80，HTTPS 加密端口 443，HTTPS = HTTP + SSL/TLS 证书加密',
      'TCP 三次握手：SYN → SYN+ACK → ACK；四次挥手：FIN → ACK → FIN → ACK',
      'GET 获取数据（URL 参数、可缓存、幂等），POST 提交数据（body 参数、不可缓存）',
      '跨域：同源策略限制不同源请求，解决方案：后端 CORS 响应头、反向代理 Nginx',
      'RESTful：GET 查询、POST 创建、PUT 全量更新、PATCH 部分更新、DELETE 删除'
    ]
  }
]

const filters = [
  { label: '全部', value: 'all' },
  { label: '未看', value: 'unseen' },
  { label: '需复习', value: 'review' },
  { label: '已掌握', value: 'mastered' }
]

function loadStatus() {
  try {
    statusMap.value = JSON.parse(localStorage.getItem('interviewStatus') || '{}')
  } catch (e) {
    statusMap.value = {}
  }
}

function saveStatus() {
  localStorage.setItem('interviewStatus', JSON.stringify(statusMap.value))
}

function getStatus(id) {
  return statusMap.value[id] || 'unseen'
}

function setStatus(id, status) {
  statusMap.value[id] = status
  saveStatus()
}

function getCategoryMastered(cat) {
  return cat.questions.filter(q => getStatus(q.id) === 'mastered').length
}

const filteredQuestions = computed(() => {
  const cat = categories.value.find(c => c.id === currentCategory.value)
  if (!cat) return []
  let questions = cat.questions
  if (currentFilter.value !== 'all') {
    questions = questions.filter(q => getStatus(q.id) === currentFilter.value)
  }
  return questions
})

const masteredCount = computed(() => {
  return categories.value.reduce((sum, cat) =>
    sum + cat.questions.filter(q => getStatus(q.id) === 'mastered').length, 0)
})

const reviewCount = computed(() => {
  return categories.value.reduce((sum, cat) =>
    sum + cat.questions.filter(q => getStatus(q.id) === 'review').length, 0)
})

const totalCount = computed(() => {
  return categories.value.reduce((sum, cat) => sum + cat.questions.length, 0)
})

const progressPercent = computed(() => {
  if (totalCount.value === 0) return 0
  return Math.round(masteredCount.value / totalCount.value * 100)
})

function toggleAnswer(id) {
  expanded.value[id] = !expanded.value[id]
  if (expanded.value[id] && getStatus(id) === 'unseen') {
    setStatus(id, 'review')
  }
}

function selectCategory(id) {
  currentCategory.value = id
  expanded.value = {}
}

onMounted(async () => {
  loadStatus()
  const res = await fetch('/knowledge-base.json')
  const data = await res.json()
  categories.value = data.categories
})
</script>

<style scoped>
.review-container {
  min-height: 100vh;
  background: #f5f7fa;
}

.header {
  background: #fff;
  padding: 16px 24px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: sticky;
  top: 0;
  z-index: 100;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.back-btn {
  padding: 6px 14px;
  border: 1px solid #ddd;
  background: #fff;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  color: #555;
  transition: all 0.2s;
}

.back-btn:hover {
  border-color: #4f46e5;
  color: #4f46e5;
}

.header h1 {
  font-size: 20px;
  color: #1a1a2e;
}

.stats {
  font-size: 14px;
  color: #666;
  text-align: right;
}

.num {
  font-weight: bold;
}

.mastered-num { color: #10b981; }
.review-num { color: #f59e0b; }
.total-num { color: #4f46e5; }

.progress-bar {
  height: 4px;
  background: #e5e7eb;
  border-radius: 2px;
  margin-top: 6px;
  width: 200px;
  margin-left: auto;
}

.progress-fill {
  height: 100%;
  background: #4f46e5;
  border-radius: 2px;
  transition: width 0.3s;
}

.content {
  max-width: 1000px;
  margin: 0 auto;
  padding: 20px;
  display: flex;
  gap: 20px;
}

.sidebar {
  width: 200px;
  flex-shrink: 0;
}

.category-btn {
  display: block;
  width: 100%;
  padding: 12px 16px;
  margin-bottom: 4px;
  border: none;
  background: #fff;
  border-radius: 8px;
  cursor: pointer;
  text-align: left;
  font-size: 14px;
  color: #555;
  transition: all 0.2s;
}

.category-btn:hover {
  background: #eef2ff;
}

.category-btn.active {
  background: #4f46e5;
  color: #fff;
  font-weight: bold;
}

.category-btn .count {
  float: right;
  font-size: 12px;
  opacity: 0.7;
}

.main {
  flex: 1;
  min-width: 0;
}

.filter-bar {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
  flex-wrap: wrap;
}

.filter-btn {
  padding: 6px 14px;
  border: 1px solid #ddd;
  background: #fff;
  border-radius: 20px;
  cursor: pointer;
  font-size: 13px;
  color: #666;
  transition: all 0.2s;
}

.filter-btn:hover {
  border-color: #4f46e5;
  color: #4f46e5;
}

.filter-btn.active {
  background: #4f46e5;
  color: #fff;
  border-color: #4f46e5;
}

.q-card {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
  cursor: pointer;
  transition: all 0.2s;
  border-left: 4px solid transparent;
}

.q-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.q-card.mastered { border-left-color: #10b981; }
.q-card.review { border-left-color: #f59e0b; }
.q-card.unseen { border-left-color: #e5e7eb; }

.q-title {
  font-size: 15px;
  font-weight: 600;
  color: #1a1a2e;
  margin-bottom: 8px;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}

.badge {
  font-size: 11px;
  padding: 2px 8px;
  border-radius: 10px;
  white-space: nowrap;
  flex-shrink: 0;
}

.badge-mastered { background: #d1fae5; color: #065f46; }
.badge-review { background: #fef3c7; color: #92400e; }

.q-tags {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
  margin-bottom: 8px;
}

.q-tag {
  font-size: 11px;
  padding: 2px 8px;
  background: #f0f0ff;
  color: #4f46e5;
  border-radius: 10px;
}

.q-answer {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid #eee;
  font-size: 14px;
  line-height: 1.8;
  color: #444;
  white-space: pre-wrap;
}

.q-source {
  font-size: 12px;
  color: #999;
  margin-top: 8px;
}

.q-actions {
  display: flex;
  gap: 8px;
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid #eee;
}

.q-actions button {
  padding: 6px 16px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
  transition: all 0.2s;
}

.btn-mastered { background: #d1fae5; color: #065f46; }
.btn-mastered:hover { background: #10b981; color: #fff; }
.btn-review { background: #fef3c7; color: #92400e; }
.btn-review:hover { background: #f59e0b; color: #fff; }
.btn-reset { background: #f3f4f6; color: #6b7280; }
.btn-reset:hover { background: #e5e7eb; }

.empty {
  text-align: center;
  padding: 40px;
  color: #999;
  font-size: 15px;
}

@media (max-width: 768px) {
  .content {
    flex-direction: column;
  }
  .sidebar {
    width: 100%;
    display: flex;
    overflow-x: auto;
    gap: 8px;
    padding-bottom: 8px;
  }
  .category-btn {
    white-space: nowrap;
    width: auto;
    margin-bottom: 0;
  }
  .header {
    flex-direction: column;
    gap: 10px;
    align-items: flex-start;
  }
  .stats {
    text-align: left;
  }
  .progress-bar {
    margin-left: 0;
  }
}

.ref-btn {
  background: #f0f0ff;
  color: #4f46e5;
  font-weight: 600;
  margin-bottom: 8px;
}

.ref-btn:hover {
  background: #e0e0ff;
}

.ref-btn.active {
  background: #4f46e5;
  color: #fff;
}

.ref-panel {
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
}

.ref-title {
  font-size: 20px;
  color: #1a1a2e;
  margin-bottom: 20px;
  padding-bottom: 12px;
  border-bottom: 2px solid #4f46e5;
}

.ref-card {
  margin-bottom: 20px;
  padding-bottom: 20px;
  border-bottom: 1px solid #eee;
}

.ref-card:last-child {
  border-bottom: none;
  margin-bottom: 0;
  padding-bottom: 0;
}

.ref-card-title {
  font-size: 16px;
  color: #4f46e5;
  margin-bottom: 10px;
  font-weight: 600;
}

.ref-links {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  margin-bottom: 12px;
}

.ref-link {
  font-size: 13px;
  color: #4f46e5;
  text-decoration: none;
  padding: 4px 12px;
  background: #f0f0ff;
  border-radius: 16px;
  transition: all 0.2s;
}

.ref-link:hover {
  background: #4f46e5;
  color: #fff;
}

.ref-summary {
  font-size: 14px;
  line-height: 1.8;
  color: #555;
}

.ref-summary p {
  margin-bottom: 6px;
  padding-left: 16px;
  position: relative;
}

.ref-summary p::before {
  content: '•';
  position: absolute;
  left: 0;
  color: #4f46e5;
  font-weight: bold;
}
</style>
