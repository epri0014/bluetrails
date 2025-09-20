<template>
  <footer class="site-footer">
    <div class="footer-content">
      <div class="waves">
        <div class="wave wave1"></div>
        <div class="wave wave2"></div>
        <div class="wave wave3"></div>
      </div>
      <div class="footer-text">
        <div class="main-text">🌊 {{ $t('footer.mainText') }} 🐠</div>
        <div class="sub-text">{{ $t('footer.subText') }}</div>
      </div>
    </div>
  </footer>
</template>

<style scoped>
.site-footer {
  margin-top: auto;
  position: relative;
  background: linear-gradient(135deg, #0ea5e9 0%, #06b6d4 50%, #0891b2 100%);
  color: #fff;
  overflow: hidden;
  min-height: 120px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.footer-content {
  position: relative;
  z-index: 2;
  text-align: center;
  padding: 24px 20px;
}

.waves {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 40px;
  overflow: hidden;
}

.wave {
  position: absolute;
  top: -20px;
  left: -50%;
  right: -50%;
  height: 40px;
  background: repeating-linear-gradient(
    90deg,
    transparent 0px,
    transparent 15px,
    rgba(255, 255, 255, 0.1) 15px,
    rgba(255, 255, 255, 0.1) 30px
  );
  border-radius: 50%;
  animation: wave-animation 6s linear infinite;
}

.wave1 {
  animation-duration: 6s;
  opacity: 0.6;
}

.wave2 {
  animation-duration: 8s;
  opacity: 0.4;
  animation-delay: -2s;
}

.wave3 {
  animation-duration: 10s;
  opacity: 0.3;
  animation-delay: -4s;
}

@keyframes wave-animation {
  0% {
    transform: translateX(-50%) rotate(0deg);
  }
  100% {
    transform: translateX(50%) rotate(360deg);
  }
}

.footer-text {
  position: relative;
  z-index: 3;
}

.main-text {
  font-size: 18px;
  font-weight: 800;
  margin-bottom: 8px;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
  color: #fff;
  background: linear-gradient(45deg, #fff, #f0f9ff, #dbeafe);
  background-size: 200% 200%;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: shimmer 3s ease-in-out infinite;
}

.sub-text {
  font-size: 14px;
  font-weight: 600;
  opacity: 0.95;
  color: #fff;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

@keyframes shimmer {
  0%, 100% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
}

@media (max-width: 768px) {
  .main-text {
    font-size: 16px;
  }
  .sub-text {
    font-size: 12px;
  }
  .footer-content {
    padding: 20px 16px;
  }
}
</style>
