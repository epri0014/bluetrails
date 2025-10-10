import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/NewHomeView.vue'
import AnimalsGrid from '../views/AnimalsGrid.vue'
import WaterView from '../views/WaterView.vue'
import Game from '../views/Game.vue'
import QuizView from '../views/QuizView.vue'
import StoriesLibrary from '../views/StoriesLibrary.vue';
import StoryReader from '../views/StoryReader.vue';
import StoryFinish from '../views/StoryFinish.vue';

const routes = [
  { path: '/', name: 'home', component: Home },
  { path: '/animals', name: 'animals', component: AnimalsGrid },
  { path: '/water', name: 'water', component: WaterView },
  { path: '/game', name: 'game', component: Game },
  { path: '/quiz', name: 'quiz', component: QuizView },
  { path: '/stories', component: StoriesLibrary },
  { path: '/stories/:id', component: StoryReader },
  { path: '/stories/:id/finish', component: StoryFinish },
  { path: '/:catchAll(.*)', redirect: '/' },
  { path: '/choose', name: 'ChooseAnimal', component: () => import('../views/ChooseHero.vue'),},
  { path: '/choose/:slug', name: 'TestHabitatChoose', component: () => import('@/views/TestHabitatChoose.vue')}

]

export default createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 })
})
