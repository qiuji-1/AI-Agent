<template>
  <div class="chat-container">
    <div class="chat-header">
      <button class="back-btn" @click="goBack">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M19 12H5"></path>
          <path d="M12 19l-7-7 7-7"></path>
        </svg>
      </button>
      <h2>AI 超级智能体</h2>
      <div class="chat-id">
        <span class="label">会话 ID:</span>
        <span class="value">{{ chatId }}</span>
      </div>
    </div>
    
    <div ref="messagesContainer" class="chat-messages">
      <div 
        v-for="(msg, index) in messages" 
        :key="index"
        :class="['message-item', msg.isUser ? 'user-message' : 'ai-message']"
      >
        <div class="avatar">
          <svg v-if="msg.isUser" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
            <circle cx="12" cy="7" r="4"></circle>
          </svg>
          <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M12 2a3 3 0 0 0-3 3v7a3 3 0 0 0 6 0V5a3 3 0 0 0-3-3z"></path>
            <path d="M19 15v2a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2v-2"></path>
            <path d="M19 9h-6"></path>
          </svg>
        </div>
        <div class="message-content">
          <p>{{ msg.content }}</p>
        </div>
      </div>
      <div v-if="isLoading" class="loading-indicator">
        <div class="loading-dots">
          <span></span>
          <span></span>
          <span></span>
        </div>
      </div>
    </div>
    
    <div class="chat-input">
      <input 
        v-model="inputMessage"
        type="text" 
        placeholder="输入消息..." 
        class="message-input"
        @keyup.enter="sendMessage"
        :disabled="isLoading"
      />
      <button 
        class="send-btn" 
        @click="sendMessage"
        :disabled="isLoading || !inputMessage.trim()"
      >
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
        </svg>
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const messagesContainer = ref(null)
const messages = ref([])
const inputMessage = ref('')
const isLoading = ref(false)
const chatId = ref('')

const generateChatId = () => {
  return 'chat_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9)
}

const goBack = () => {
  router.push('/')
}

const scrollToBottom = () => {
  nextTick(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
    }
  })
}

const sendMessage = () => {
  if (!inputMessage.value.trim() || isLoading.value) return
  
  const userMessage = inputMessage.value.trim()
  messages.value.push({
    content: userMessage,
    isUser: true
  })
  inputMessage.value = ''
  isLoading.value = true
  
  scrollToBottom()
  
  const url = `/api/ai/manus/chat?message=${encodeURIComponent(userMessage)}`
  const eventSource = new EventSource(url)
  
  let aiResponse = ''
  
  eventSource.onmessage = (event) => {
    aiResponse += event.data
    
    const lastAiMessage = messages.value[messages.value.length - 1]
    if (lastAiMessage && !lastAiMessage.isUser) {
      lastAiMessage.content = aiResponse
    } else {
      messages.value.push({
        content: aiResponse,
        isUser: false
      })
    }
    scrollToBottom()
  }
  
  eventSource.onerror = () => {
    eventSource.close()
    isLoading.value = false
  }
  
  eventSource.onclose = () => {
    isLoading.value = false
  }
}

onMounted(() => {
  chatId.value = generateChatId()
  messages.value.push({
    content: '您好！我是AI超级智能体，拥有强大的工具调用能力，有什么可以帮助您的吗？',
    isUser: false
  })
})
</script>

<style scoped>
.chat-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background-color: #f5f7fa;
}

.chat-header {
  display: flex;
  align-items: center;
  padding: 15px 20px;
  background: linear-gradient(135deg, #0f3460 0%, #16213e 100%);
  color: white;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.2);
}

.back-btn {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  border-radius: 50%;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  cursor: pointer;
  margin-right: 15px;
  transition: background 0.2s;
}

.back-btn:hover {
  background: rgba(255, 255, 255, 0.3);
}

.chat-header h2 {
  flex: 1;
  font-size: 1.2rem;
  font-weight: 600;
}

.chat-id {
  display: flex;
  align-items: center;
  background: rgba(255, 255, 255, 0.2);
  padding: 5px 12px;
  border-radius: 20px;
  font-size: 0.75rem;
}

.chat-id .label {
  margin-right: 5px;
  opacity: 0.8;
}

.chat-id .value {
  font-family: monospace;
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  display: flex;
  flex-direction: column;
}

.message-item {
  display: flex;
  margin-bottom: 20px;
  max-width: 80%;
}

.user-message {
  margin-left: auto;
  flex-direction: row-reverse;
}

.user-message .avatar {
  background: linear-gradient(135deg, #00d4ff 0%, #0099cc 100%);
}

.user-message .message-content {
  background: linear-gradient(135deg, #00d4ff 0%, #0099cc 100%);
  color: white;
  border-radius: 18px 18px 4px 18px;
}

.ai-message {
  margin-right: auto;
}

.ai-message .avatar {
  background: #e8f4f8;
}

.ai-message .message-content {
  background: white;
  color: #1a1a2e;
  border-radius: 18px 18px 18px 4px;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  margin: 0 10px;
  color: white;
}

.ai-message .avatar {
  color: #0099cc;
}

.message-content {
  padding: 12px 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.message-content p {
  margin: 0;
  line-height: 1.5;
  font-size: 0.95rem;
}

.loading-indicator {
  display: flex;
  justify-content: flex-start;
  padding-left: 50px;
  margin-bottom: 20px;
}

.loading-dots {
  display: flex;
  gap: 6px;
}

.loading-dots span {
  width: 8px;
  height: 8px;
  background: #0099cc;
  border-radius: 50%;
  animation: loading 1.4s infinite ease-in-out;
}

.loading-dots span:nth-child(2) {
  animation-delay: 0.2s;
}

.loading-dots span:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes loading {
  0%, 80%, 100% {
    transform: scale(0);
  }
  40% {
    transform: scale(1);
  }
}

.chat-input {
  display: flex;
  padding: 15px 20px;
  background: white;
  border-top: 1px solid #e8eef5;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.05);
}

.message-input {
  flex: 1;
  padding: 12px 20px;
  border: 1px solid #e8eef5;
  border-radius: 30px;
  font-size: 0.95rem;
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
}

.message-input:focus {
  border-color: #0099cc;
  box-shadow: 0 0 0 3px rgba(0, 153, 204, 0.15);
}

.message-input:disabled {
  background: #f5f7fa;
  color: #999;
}

.send-btn {
  background: linear-gradient(135deg, #00d4ff 0%, #0099cc 100%);
  border: none;
  border-radius: 50%;
  width: 44px;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  margin-left: 12px;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
}

.send-btn:hover:not(:disabled) {
  transform: scale(1.05);
  box-shadow: 0 4px 15px rgba(0, 153, 204, 0.4);
}

.send-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
