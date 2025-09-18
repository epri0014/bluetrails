<template>
  <div class="game-container">
    <div class="iframe-wrap">
      <LoadingOverlay v-if="loading" message="🎮 Loading Ocean Hero Game..." />
      <iframe
        ref="gameFrame"
        src="https://oceanhero-game.pages.dev/"
        class="game-iframe"
        frameborder="0"
        allowfullscreen
        loading="lazy"
        title="Ocean Hero Game"
        scrolling="no"
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
  width: 100vw;
  height: calc(100vh - var(--nav-h, 80px));
  margin: 0;
  padding: 0;
  margin-top: var(--nav-h, 80px);
  overflow: hidden;
  background: #000;
}

.iframe-wrap {
  position: relative;
  width: 100%;
  height: 100%;
  overflow: hidden;
}

.game-iframe {
  position: absolute;
  top: 0;
  left: 0;
  width: 125%;
  height: 125%;
  border: none;
  display: block;
  transform: scale(0.8);
  transform-origin: top left;
  overflow: hidden;
}

/* Mobile responsiveness */
@media (max-width: 768px) {
  .game-iframe {
    width: 140%;
    height: 140%;
    transform: scale(0.71);
  }
}

@media (max-width: 480px) {
  .game-iframe {
    width: 160%;
    height: 160%;
    transform: scale(0.625);
  }
}
</style>