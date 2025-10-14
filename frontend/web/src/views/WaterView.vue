<template>
  <div class="water-view">
    <div class="water-container">
      <div class="iframe-wrap">
        <!-- Skeleton Loader mimicking water guide layout -->
        <div v-if="loading" class="skeleton-overlay">
        <div class="skeleton-water-guide">
          <!-- Title Section -->
          <div class="skeleton-title-box">
            <div class="skeleton-main-title shimmer"></div>
            <div class="skeleton-subtitle shimmer"></div>
            <div class="skeleton-text-line shimmer"></div>
            <div class="skeleton-text-line short shimmer"></div>
          </div>

          <!-- Main Content: Map + Form -->
          <div class="skeleton-main-content">
            <!-- Left: Map Section -->
            <div class="skeleton-map-section">
              <div class="skeleton-map">
                <!-- Map controls -->
                <div class="skeleton-map-controls">
                  <div class="skeleton-zoom-btn shimmer"></div>
                  <div class="skeleton-zoom-btn shimmer"></div>
                </div>
                <!-- Legend box -->
                <div class="skeleton-legend">
                  <div class="skeleton-legend-item shimmer"></div>
                  <div class="skeleton-legend-item shimmer"></div>
                  <div class="skeleton-legend-item shimmer"></div>
                </div>
                <!-- Region legend -->
                <div class="skeleton-region-legend">
                  <div class="skeleton-region-item shimmer"></div>
                  <div class="skeleton-region-item shimmer"></div>
                  <div class="skeleton-region-item shimmer"></div>
                </div>
                <!-- Map markers -->
                <div class="skeleton-marker marker-1 shimmer"></div>
                <div class="skeleton-marker marker-2 shimmer"></div>
                <div class="skeleton-marker marker-3 shimmer"></div>
              </div>
            </div>

            <!-- Right: Form Section -->
            <div class="skeleton-form-section">
              <div class="skeleton-form">
                <!-- Pick a region -->
                <div class="skeleton-form-group">
                  <div class="skeleton-label shimmer"></div>
                  <div class="skeleton-dropdown shimmer"></div>
                </div>

                <!-- Pick a beach -->
                <div class="skeleton-form-group">
                  <div class="skeleton-label shimmer"></div>
                  <div class="skeleton-dropdown shimmer"></div>
                </div>

                <!-- Pick a day -->
                <div class="skeleton-form-group">
                  <div class="skeleton-label shimmer"></div>
                  <div class="skeleton-datepicker shimmer"></div>
                </div>

                <!-- Buttons -->
                <div class="skeleton-buttons">
                  <div class="skeleton-btn-primary shimmer"></div>
                  <div class="skeleton-btn-secondary shimmer"></div>
                </div>

                <!-- Steps text -->
                <div class="skeleton-steps shimmer"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <iframe
        ref="frame"
        src="https://019911fb-5550-ad05-7994-5cd5737f0ef1.share.connect.posit.cloud/"
        class="water-iframe"
        title="Visit Ocean Friends Home"
        frameborder="0"
        allowfullscreen
        @load="onLoad"
      ></iframe>
      </div>
    </div>

    <!-- Floating Animal Guide - outside water-container to avoid z-index stacking context issue -->
    <FloatingAnimalGuide
      v-if="!loading && animals.length > 0"
      :available-animals="animals"
      :message="$t('floatingGuide.buddyChallengeMessage')"
      :button-text="$t('floatingGuide.buddyChallengeButton')"
      :aria-label="$t('floatingGuide.buddyChallengeAriaLabel')"
      @click="navigateToChallenge"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { getAnimals } from '@/services/api.js'
import FloatingAnimalGuide from '@/components/FloatingAnimalGuide.vue'

const { locale } = useI18n()
const router = useRouter()

const loading = ref(true)
const frame = ref(null)
const animals = ref([])

function onLoad() {
  loading.value = false
}

// Load animals for the floating guide
const loadAnimals = async () => {
  try {
    const data = await getAnimals(locale.value)
    animals.value = data.map(animal => ({
      slug: animal.slug,
      name: animal.name,
      cartoon: animal.cartoon_image_url
    }))
  } catch (err) {
    console.error('Failed to load animals for floating guide:', err)
  }
}

// Navigate to challenge page
function navigateToChallenge() {
  router.push('/challenge')
}

onMounted(() => {
  loadAnimals()
})
</script>

<style scoped>
.water-view {
  position: relative;
  width: 100%;
  height: 100vh;
}

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

/* Skeleton Loader */
.skeleton-overlay {
  position: absolute;
  inset: 0;
  background: #e9ecef;
  z-index: 1000;
  overflow: auto;
}

.skeleton-water-guide {
  width: 100%;
  height: 100%;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* Title Box */
.skeleton-title-box {
  background: #fff;
  border: 3px solid #333;
  border-radius: 16px;
  padding: 24px 28px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.skeleton-main-title {
  height: 32px;
  width: 60%;
  background: #d6d6d6;
  border-radius: 8px;
}

.skeleton-subtitle {
  height: 22px;
  width: 80%;
  background: #d6d6d6;
  border-radius: 6px;
}

.skeleton-text-line {
  height: 18px;
  width: 100%;
  background: #d6d6d6;
  border-radius: 6px;
}

.skeleton-text-line.short {
  width: 65%;
}

/* Main Content: Map + Form */
.skeleton-main-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  flex: 1;
  min-height: 0;
}

/* Map Section */
.skeleton-map-section {
  background: #fff;
  border: 3px solid #333;
  border-radius: 16px;
  padding: 20px;
  position: relative;
}

.skeleton-map {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #c8e6c9 0%, #e8f5e9 30%, #b2dfdb 50%, #80cbc4 100%);
  border-radius: 12px;
  position: relative;
  overflow: hidden;
}

/* Map Controls */
.skeleton-map-controls {
  position: absolute;
  top: 15px;
  left: 15px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  z-index: 10;
}

.skeleton-zoom-btn {
  width: 36px;
  height: 36px;
  background: #fff;
  border-radius: 6px;
  border: 2px solid #333;
}

/* Legend Box */
.skeleton-legend {
  position: absolute;
  top: 15px;
  left: 70px;
  background: #fff;
  border: 2px solid #333;
  border-radius: 12px;
  padding: 12px 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  min-width: 140px;
}

.skeleton-legend-item {
  height: 20px;
  background: #d6d6d6;
  border-radius: 4px;
}

/* Region Legend */
.skeleton-region-legend {
  position: absolute;
  bottom: 15px;
  left: 15px;
  background: #fff;
  border: 2px solid #333;
  border-radius: 12px;
  padding: 12px 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  min-width: 180px;
}

.skeleton-region-item {
  height: 20px;
  background: #d6d6d6;
  border-radius: 4px;
}

/* Map Markers */
.skeleton-marker {
  position: absolute;
  width: 32px;
  height: 32px;
  background: #ff5252;
  border-radius: 50% 50% 50% 0;
  transform: rotate(-45deg);
  border: 3px solid #fff;
  box-shadow: 0 3px 8px rgba(0,0,0,0.3);
}

.skeleton-marker.marker-1 {
  top: 45%;
  left: 25%;
  background: #ffc107;
}

.skeleton-marker.marker-2 {
  top: 30%;
  right: 20%;
  background: #ff5252;
}

.skeleton-marker.marker-3 {
  top: 55%;
  right: 25%;
  background: #ff5252;
}

/* Form Section */
.skeleton-form-section {
  background: #fff;
  border: 3px solid #333;
  border-radius: 16px;
  padding: 24px;
}

.skeleton-form {
  display: flex;
  flex-direction: column;
  gap: 24px;
  height: 100%;
}

.skeleton-form-group {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.skeleton-label {
  height: 20px;
  width: 120px;
  background: #d6d6d6;
  border-radius: 4px;
}

.skeleton-dropdown {
  height: 48px;
  background: #f8f9fa;
  border: 2px solid #dee2e6;
  border-radius: 8px;
}

.skeleton-datepicker {
  height: 48px;
  background: #f8f9fa;
  border: 2px solid #dee2e6;
  border-radius: 8px;
}

.skeleton-buttons {
  display: flex;
  gap: 12px;
  margin-top: 8px;
}

.skeleton-btn-primary {
  height: 44px;
  width: 100px;
  background: #2196f3;
  border-radius: 8px;
}

.skeleton-btn-secondary {
  height: 44px;
  width: 100px;
  background: #f8f9fa;
  border: 2px solid #dee2e6;
  border-radius: 8px;
}

.skeleton-steps {
  height: 18px;
  width: 90%;
  background: #d6d6d6;
  border-radius: 4px;
  margin-top: auto;
}

/* Shimmer animation */
.shimmer {
  background: linear-gradient(
    90deg,
    #d6d6d6 0%,
    #e8e8e8 50%,
    #d6d6d6 100%
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

/* Responsive adjustments */
@media (max-width: 1200px) {
  .skeleton-main-content {
    grid-template-columns: 1fr;
  }

  .skeleton-map-section {
    min-height: 400px;
  }
}

@media (max-width: 768px) {
  .skeleton-water-guide {
    padding: 12px;
    gap: 12px;
  }

  .skeleton-title-box {
    padding: 16px;
  }

  .skeleton-main-title {
    height: 24px;
  }

  .skeleton-form-section {
    padding: 16px;
  }
}
</style>
