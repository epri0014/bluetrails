<template>
  <main class="page">
    <section class="wrap">
      <div class="card iframe-card">
        <!-- Loading overlay -->
        <LoadingOverlay v-if="loading" message="📊 Loading interactive app..." />

        <!-- Shiny iframe -->
        <iframe
          src="https://019911fb-5550-ad05-7994-5cd5737f0ef1.share.connect.posit.cloud/"
          title="Water Quality Shiny App"
          frameborder="0"
          allowfullscreen
          @load="onLoad"
        ></iframe>
      </div>
    </section>
  </main>
</template>

<script setup>
import { ref } from 'vue'
import LoadingOverlay from '../components/LoadingOverlay.vue'

const loading = ref(true)
function onLoad() {
  loading.value = false
}
</script>

<style scoped>
/* Card extension for iframe */
.iframe-card {
  position: relative;
  height: calc(100vh - var(--nav-h)); /* fill screen below navbar */
  width: 100%;
  margin: 0;
  padding: 0;
  border-radius: 0; /* optional: remove rounded corners */
  box-shadow: none; /* optional: remove card shadow */
  background: #fff;
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
  to {
    transform: rotate(360deg);
  }
}
</style>
