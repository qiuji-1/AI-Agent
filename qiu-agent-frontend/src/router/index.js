import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'
import ChatMaster from '../views/ChatMaster.vue'
import SuperAgent from '../views/SuperAgent.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/chat-master',
    name: 'ChatMaster',
    component: ChatMaster
  },
  {
    path: '/super-agent',
    name: 'SuperAgent',
    component: SuperAgent
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
