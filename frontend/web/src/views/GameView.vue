<template>
  <div class="game-container">
    <div class="iframe-wrap">
      <LoadingOverlay v-if="loading" :message="`🎮 ${$t('loading.game')}`" />
      <iframe
        ref="gameFrame"
        src="/Ocean-Hero-Game/index.html"
        class="game-iframe"
        frameborder="0"
        allowfullscreen
        loading="lazy"
        title="Ocean Hero Game"
        scrolling="yes"
        @load="onLoad"
      ></iframe>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import LoadingOverlay from '../components/LoadingOverlay.vue'

const loading = ref(true)
const gameFrame = ref(null)

function onLoad() {
  loading.value = false
}
</script>

<style scoped>
.game-container {
  position: fixed;
  top: var(--nav-h, 80px);
  left: 0;
  right: 0;
  bottom: 0;
  width: 100%;
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
  display: flex;
  align-items: center;
  justify-content: center;
}

.game-iframe {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border: none;
  display: block;
}

/* Ensure consistent display on all screen sizes */
@media (max-width: 1200px) {
  .game-iframe {
    width: 100%;
    height: 100%;
  }
}

@media (max-width: 768px) {
  .game-iframe {
    width: 100%;
    height: 100%;
  }
}

@media (max-width: 480px) {
  .game-iframe {
    width: 100%;
    height: 100%;
  }
}
</style>
