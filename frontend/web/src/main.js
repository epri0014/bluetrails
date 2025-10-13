import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from './router'
import i18n from './i18n'
import App from './App.vue'
import './assets/global.css'
import 'leaflet/dist/leaflet.css'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)   // <-- register Pinia
app.use(router)
app.use(i18n)    // <-- register i18n
app.mount('#app')
