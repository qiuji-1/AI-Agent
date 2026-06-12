<template>
  <div class="home-container">
    <div class="header">
      <h1>AI Agent 应用中心</h1>
      <p>选择您想要使用的AI应用</p>
    </div>
    
    <div class="apps-grid">
      <div class="app-card" @click="navigateTo('/chat-master')">
        <div class="app-icon chat-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
          </svg>
        </div>
        <h2>AI 聊天大师</h2>
        <p>与AI进行智能对话，获取专业的回答</p>
      </div>
      
      <div class="app-card" @click="navigateTo('/super-agent')">
        <div class="app-icon agent-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M12 2a3 3 0 0 0-3 3v7a3 3 0 0 0 6 0V5a3 3 0 0 0-3-3z"></path>
            <path d="M19 15v2a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2v-2"></path>
            <path d="M19 9h-6"></path>
          </svg>
        </div>
        <h2>AI 超级智能体</h2>
        <p>强大的超级智能体，支持多种工具调用</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

const navigateTo = (path) => {
  router.push(path)
}
</script>

<style scoped>
.home-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.header {
  text-align: center;
  margin-bottom: 40px;
}

.header h1 {
  font-size: 2.5rem;
  color: white;
  margin-bottom: 10px;
  text-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
}

.header p {
  font-size: 1.1rem;
  color: rgba(255, 255, 255, 0.8);
}

.apps-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 30px;
  max-width: 800px;
  width: 100%;
}

.app-card {
  background: white;
  border-radius: 16px;
  padding: 30px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
}

.app-card:hover {
  transform: translateY(-10px);
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.2);
}

.app-icon {
  width: 80px;
  height: 80px;
  margin: 0 auto 20px;
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2.5rem;
}

.chat-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.agent-icon {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.app-card h2 {
  font-size: 1.5rem;
  color: #333;
  margin-bottom: 10px;
}

.app-card p {
  font-size: 0.95rem;
  color: #666;
  line-height: 1.6;
}
</style>
