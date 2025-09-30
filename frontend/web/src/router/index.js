import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/NewHomeView.vue'
import AnimalsGrid from '../views/AnimalsGrid.vue'
import WaterView from '../views/WaterView.vue'
import Game from '../views/Game.vue'
import QuizView from '../views/QuizView.vue'

const routes = [
  { path: '/', name: 'home', component: Home },
  { path: '/animals', name: 'animals', component: AnimalsGrid },
  { path: '/water', name: 'water', component: WaterView },
  { path: '/game', name: 'game', component: Game },
  { path: '/quiz', name: 'quiz', component: QuizView },
  { path: '/:pathMatch(.*)*', redirect: '/' }
]

export default createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 })
})
