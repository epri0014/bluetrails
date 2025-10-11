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
  { path: '/',        name: 'home', component: Home },
  { path: '/animals', name: 'animals', component: AnimalsGrid },
  { path: '/water',   name: 'water',  component: WaterView },
  { path: '/game',    name: 'game',   component: Game },
  { path: '/quiz',    name: 'quiz',   component: QuizView },
  { path: '/stories', name: 'stories', component: StoriesLibrary },
  { path: '/stories/:id',         component: StoryReader },
  { path: '/stories/:id/finish',  component: StoryFinish },
  { path: '/choose',      name: 'ChooseAnimal', component: () => import('@/views/ChooseHero.vue') },
  { path: '/choose/:slug',name: 'HabitatChoose',component: () => import('@/views/TestHabitatChoose.vue') },
  { path: '/home', name: 'MyOceanHome', component: () => import('@/views/MyOceanHome.vue') },
  { path: '/:catchAll(.*)', redirect: '/' },
]


export default createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 })
})
