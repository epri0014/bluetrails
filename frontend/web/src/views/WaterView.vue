<template>
  <main class="page">
    <div class="iframe-wrapper">
      <div v-if="loading" class="loading-overlay">
        <div class="spinner"></div>
        <p>Loading Interactive app...</p>
      </div>

      <iframe
        src="https://019911fb-5550-ad05-7994-5cd5737f0ef1.share.connect.posit.cloud/"
        title="Water Quality Shiny App"
        frameborder="0"
        allowfullscreen
        @load="onLoad"
      ></iframe>
    </div>
  </main>
</template>

<script setup>
import { ref } from 'vue'
const loading = ref(true)
function onLoad() { loading.value = false }
</script>

<style scoped>
.page {
  /* take full viewport height minus navbar */
  height: calc(100vh - var(--nav-h));
  margin-top: var(--nav-h); /* prevent overlap with fixed NavBar */
}

.iframe-wrapper {
  width: 100%;
  height: 100%;
  position: relative;
}

iframe {
  width: 100%;
  height: 100%;
  border: none;
}

/* Loading overlay */
.loading-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: rgba(250, 249, 247, 0.9);
  z-index: 10;
  font-weight: 600;
  color: var(--muted);
}

.spinner {
  width: 42px;
  height: 42px;
  border: 4px solid #ddd;
  border-top: 4px solid #0EA5E9;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 12px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>
