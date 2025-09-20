<template>
  <div class="loading-overlay">
    <div class="spinner">
      <div></div><div></div><div></div>
    </div>
    <p>{{ message || $t('loading.default') }}</p>
  </div>
</template>

<script setup>
defineProps({
  message: {
    type: String,
    default: ''
  }
})
</script>

<style scoped>
.loading-overlay {
  position: absolute;
  inset: 0;
  background: rgba(255, 255, 255, 0.9);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  font-weight: 700;
  font-size: 18px;
  color: #0369a1;
}

.spinner {
  display: flex;
  gap: 10px;
  margin-bottom: 18px;
}

.spinner div {
  width: 16px;
  height: 16px;
  border-radius: 50%;
  animation: bounce 0.6s infinite alternate;
}

.spinner div:nth-child(1) {
  background: #0ea5e9; /* blue */
}
.spinner div:nth-child(2) {
  background: #22c55e; /* green */
  animation-delay: 0.2s;
}
.spinner div:nth-child(3) {
  background: #f59e0b; /* orange */
  animation-delay: 0.4s;
}

@keyframes bounce {
  from { transform: translateY(0); }
  to   { transform: translateY(-14px); }
}
</style>
