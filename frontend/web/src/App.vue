<template>
  <div class="app">
    <NavBar />
    <RouterView />
    <Footer v-if="!isGamePage" />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import NavBar from './components/NavBar.vue'
import Footer from './components/Footer.vue'

const route = useRoute()
const isGamePage = computed(() => route.path === '/game')
</script>
<style>
@import url('https://fonts.googleapis.com/css2?family=Fredoka:wght@300;400;500;600;700&family=Nunito:wght@200;300;400;500;600;700;800;900&display=swap');

:root{
  --nav-h: 80px;
  --brand: linear-gradient(90deg, #0EA5E9 0%, #0369A1 100%);
  --ink: #1b1b1b;
  --bg: #faf9f7;
  --muted: #6b7280;

  font-family: 'Fredoka', 'Nunito', system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, "Noto Sans", sans-serif;
  line-height: 1.5;
}

*{ box-sizing: border-box; }
html, body, #app{ height: 100%; }
body{ margin: 0; background: var(--bg); color: var(--ink); }
a{ color: inherit; text-decoration: none; }
</style>
