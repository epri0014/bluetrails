import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/NewHomeView.vue'
import AnimalsGrid from '../views/AnimalsGrid.vue'
import AnimalDetail from '../views/AnimalDetail.vue'
import WaterView from '../views/WaterView.vue'
import AvatarSelect from '../views/AvatarSelect.vue'
import OceanHealth from '../views/OceanHealth.vue'
import CausePage from '@/views/CausePage.vue'

const routes = [
  { path: '/', name: 'home', component: Home },
  { path: '/animals', name: 'animals', component: AnimalsGrid },
  { path: '/animals/:id', name: 'animal-detail', component: AnimalDetail }, 
  { path: '/water-quality', name: 'water', component: WaterView },
  { path: '/choose', name: 'choose', component: AvatarSelect },
  { path: '/health', component: OceanHealth },
  { path: '/cause', component: CausePage },
  { path: '/:pathMatch(.*)*', redirect: '/' }
]

export default createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 })
})
