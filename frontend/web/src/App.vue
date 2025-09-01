<template>
  <div class="app">
    <NavBar />
    <router-view />
  </div>
</template>

<script setup>
import NavBar from '@/components/NavBar.vue'
</script>

<style>
html, body, #app { margin: 0; height: 100%; }
</style>
