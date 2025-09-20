<template>
  <div class="water-container">
    <div class="iframe-wrap">
      <LoadingOverlay v-if="loading" :message="`🌊 ${$t('loading.water')}`" />
      <iframe
        ref="frame"
        src="https://019911fb-5550-ad05-7994-5cd5737f0ef1.share.connect.posit.cloud/"
        class="water-iframe"
        title="Water Quality Shiny App"
        frameborder="0"
        allowfullscreen
        @load="onLoad"
      ></iframe>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import LoadingOverlay from '../components/LoadingOverlay.vue'

const loading = ref(true)
const frame = ref(null)

function onLoad() {
  loading.value = false
}
</script>

<style scoped>
.water-container {
  position: fixed;
  top: var(--nav-h, 80px);
  left: 0;
  right: 0;
  bottom: 0;
  width: 100vw;
  height: calc(100vh - var(--nav-h, 80px));
  margin: 0;
  padding: 0;
  overflow: hidden;
  background: #000;
  z-index: 1;
}

.iframe-wrap {
  position: relative;
  width: 100%;
  height: 100%;
  overflow: hidden;
}

.water-iframe {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border: none;
  display: block;
  overflow: auto;
}
</style>
