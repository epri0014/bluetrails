<template>
  <div class="app">
    <NavBar />
    <RouterView />
    <Footer />
  </div>
</template>

<script setup>
import NavBar from './components/NavBar.vue'
import Footer from './components/Footer.vue'
</script>
<style>
:root{
  --nav-h: 64px;
  --brand: linear-gradient(90deg, #0EA5E9 0%, #0369A1 100%);
  --ink: #1b1b1b;
  --bg: #faf9f7;
  --muted: #6b7280;

  font-family: system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, "Noto Sans", sans-serif;
  line-height: 1.5;
}

*{ box-sizing: border-box; }
html, body, #app{ height: 100%; }
body{ margin: 0; background: var(--bg); color: var(--ink); }
a{ color: inherit; text-decoration: none; }
</style>
