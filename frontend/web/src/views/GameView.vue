<template>
  <div class="game-container">
    <div class="iframe-wrap">
      <!-- Skeleton Loader mimicking start overlay -->
      <div v-if="loading" class="skeleton-overlay">
        <div class="skeleton-panel">
          <div class="skeleton-title shimmer"></div>
          <div class="skeleton-rules">
            <div class="skeleton-rule-line shimmer"></div>
            <div class="skeleton-rule-line shimmer"></div>
            <div class="skeleton-rule-line short shimmer"></div>
          </div>
          <div class="skeleton-buttons">
            <div class="skeleton-btn shimmer"></div>
            <div class="skeleton-btn shimmer"></div>
          </div>
        </div>
      </div>

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
  background: linear-gradient(#cfefff 0% 45%, #78c9ff 45% 55%, #fffae1 55%);
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

/* Skeleton Loader */
.skeleton-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, rgba(255,255,255,.96), rgba(200,230,255,.96));
  backdrop-filter: saturate(120%) blur(2px);
  z-index: 1000;
}

.skeleton-panel {
  width: min(560px, 90vw);
  background: #fff;
  border: 4px solid #000;
  border-radius: 18px;
  padding: 28px;
  text-align: center;
  box-shadow: 12px 12px 0 #0003;
}

.skeleton-title {
  height: 40px;
  width: 80%;
  margin: 0 auto 24px;
  background: #e0e0e0;
  border-radius: 12px;
}

.skeleton-rules {
  text-align: left;
  margin: 16px 0 24px;
  padding: 0 14px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.skeleton-rule-line {
  height: 18px;
  width: 100%;
  background: #e0e0e0;
  border-radius: 8px;
}

.skeleton-rule-line.short {
  width: 70%;
}

.skeleton-buttons {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-top: 20px;
}

.skeleton-btn {
  height: 48px;
  width: 140px;
  background: #e0e0e0;
  border-radius: 14px;
}

/* Shimmer animation */
.shimmer {
  background: linear-gradient(
    90deg,
    #e0e0e0 0%,
    #f0f0f0 50%,
    #e0e0e0 100%
  );
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
}

@keyframes shimmer {
  0% {
    background-position: -200% 0;
  }
  100% {
    background-position: 200% 0;
  }
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

  .skeleton-panel {
    padding: 20px;
  }

  .skeleton-title {
    height: 32px;
  }

  .skeleton-btn {
    height: 40px;
    width: 120px;
  }
}

@media (max-width: 480px) {
  .game-iframe {
    width: 100%;
    height: 100%;
  }

  .skeleton-panel {
    padding: 16px;
  }

  .skeleton-buttons {
    flex-direction: column;
  }

  .skeleton-btn {
    width: 100%;
  }
}
</style>
