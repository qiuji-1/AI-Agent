import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'
import ChatMaster from '../views/ChatMaster.vue'
import SuperAgent from '../views/SuperAgent.vue'
import InterviewReview from '../views/InterviewReview.vue'

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
  },
  {
    path: '/interview-review',
    name: 'InterviewReview',
    component: InterviewReview
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
