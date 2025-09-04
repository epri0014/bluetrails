import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/HomeView.vue'
import AnimalsGrid from '../views/AnimalsGrid.vue'
import AnimalDetail from '../views/AnimalDetail.vue'

const Severity = {
  template: `<section style="max-width:1100px;margin:28px auto;padding:0 20px">
               <h1>How Bad Is It?</h1>
             </section>`
}
const Water = {
  template: `<section style="max-width:1100px;margin:28px auto;padding:0 20px">
               <h1>Water Quality</h1>
             </section>`
}

const routes = [
  { path: '/', name: 'home', component: Home },
  { path: '/animals', name: 'animals', component: AnimalsGrid },
  { path: '/animals/:id', name: 'animal-detail', component: AnimalDetail }, 
  { path: '/severity', name: 'severity', component: Severity },
  { path: '/water-quality', name: 'water', component: Water },
  { path: '/:pathMatch(.*)*', redirect: '/' }
]

export default createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 })
})
