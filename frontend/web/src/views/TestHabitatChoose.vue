<template>
  <main class="page">
    <!-- Animated Background -->
    <div class="animated-background">
      <div class="sky"></div>
      <div class="sun"></div>
      <div class="ocean">
        <div class="tidal-wave tidal1"></div>
        <div class="tidal-wave tidal2"></div>
      </div>
      <div class="beach"></div>
    </div>

    <!-- Back button -->
    <button class="back-btn glass" @click="goBack">
      ← Back
    </button>

    <!-- Loading state with skeleton -->
    <div v-if="loading" class="content-grid">
      <!-- Left Panel Skeleton -->
      <aside class="left-panel">
        <div class="skeleton-back-btn glass"></div>
        <div class="skeleton-animal-info glass">
          <div class="skeleton-avatar"></div>
          <div class="skeleton-text-block">
            <div class="skeleton-line"></div>
            <div class="skeleton-line short"></div>
            <div class="skeleton-line medium"></div>
          </div>
        </div>
      </aside>

      <!-- Right Panel Skeleton -->
      <section class="right-panel">
        <div class="skeleton-map glass"></div>
      </section>
    </div>

    <!-- Error state -->
    <div v-else-if="error" class="error-container glass">
      <p>❌ {{ error }}</p>
      <button @click="goBack" class="btn-back">Go Back</button>
    </div>

    <!-- Content: Two Column Layout -->
    <div v-else class="content-grid">
      <!-- Left Column: Animal Info -->
      <aside class="left-panel">
        <!-- Back button -->
        <button class="back-btn-inline glass" @click="goBack">
          ← Back
        </button>

        <!-- Animal info card -->
        <div class="animal-info glass">
          <img :src="animalData?.cartoon_image_url" :alt="animalData?.animal_name" class="avatar" />
          <h2>Hi Friends, I'm {{ animalData?.animal_name }}!</h2>
          <p>I can be found in {{ animalData?.animal_habitat }}.</p>
          <p class="instruction">Choose one of my homes on the map!</p>
        </div>
      </aside>

      <!-- Right Column: Map -->
      <section class="right-panel">
        <!-- No sites found -->
        <div class="empty glass" v-if="!sites || sites.length === 0">
          <p>No habitat sites found for {{ animalData?.animal_name }} yet.</p>
        </div>

        <!-- Map with markers -->
        <div class="map-section glass" v-else>
          <div id="habitat-map"></div>

          <!-- Map Legend -->
          <div class="map-legend">
            <div class="legend-item">
              <div class="legend-icon pulsing"></div>
              <span>{{ animalData?.animal_name }}'s Homes</span>
            </div>
          </div>
        </div>
      </section>
    </div>
  </main>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, computed, inject, nextTick } from 'vue'
import { getHabitatsByAnimal } from '../services/api.js'
import L from 'leaflet'

const challengeState = inject('challengeState', null)

const sites = ref([])
const loading = ref(true)
const error = ref(null)
const map = ref(null)
const mapHeight = ref('500px')

// Get unique animal data from the first site
const animalData = computed(() => {
  if (sites.value && sites.value.length > 0) {
    const firstSite = sites.value[0]
    return {
      animal_name: firstSite.animal_name,
      animal_habitat: firstSite.animal_habitat,
      cartoon_image_url: firstSite.animal_cartoon
    }
  }
  return null
})

// Go back to previous page
const goBack = () => {
  if (challengeState) {
    challengeState.navigate({ type: 'back' })
  }
}

// Calculate map height to fit viewport - no longer needed with new layout
const calculateMapHeight = () => {
  // Map now uses flex: 1 to fill available space
  // This function kept for backward compatibility
}

// Initialize map
const initMap = () => {
  if (!sites.value || sites.value.length === 0) {
    console.log('No sites to display on map')
    return
  }

  // Check if map container exists
  const mapContainer = document.getElementById('habitat-map')
  if (!mapContainer) {
    console.error('Map container #habitat-map not found in DOM')
    return
  }

  console.log('Map container dimensions:', mapContainer.offsetWidth, 'x', mapContainer.offsetHeight)

  try {
    // Destroy existing map if any
    if (map.value) {
      map.value.remove()
      map.value = null
    }

    console.log('Initializing map with sites:', sites.value)
    console.log('Map container found:', mapContainer)

    // Filter sites with valid coordinates
    const validSites = sites.value.filter(site =>
      site.latitude != null &&
      site.longitude != null &&
      !isNaN(parseFloat(site.latitude)) &&
      !isNaN(parseFloat(site.longitude))
    )

    console.log('Valid sites with coordinates:', validSites.length)

    if (validSites.length === 0) {
      console.error('No sites with valid coordinates')
      return
    }

    // Get first valid site for center
    const firstSite = validSites[0]
    const centerLat = parseFloat(firstSite.latitude)
    const centerLng = parseFloat(firstSite.longitude)

    // Create map with basic setup - simpler initialization
    map.value = L.map('habitat-map', {
      center: [centerLat, centerLng],
      zoom: 9,
      scrollWheelZoom: true
    })

    console.log('Map created with center:', centerLat, centerLng)

    // Add OpenStreetMap tile layer
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors',
      maxZoom: 18,
      minZoom: 7
    }).addTo(map.value)

    console.log('Tile layer added')

    // Custom pulsing icon
    const pulsingIcon = L.divIcon({
      className: 'pulsing-marker',
      html: '<div class="marker-dot"></div>',
      iconSize: [30, 30],
      iconAnchor: [15, 15],
      popupAnchor: [0, -15]
    })

    // Add pulsing markers for each site
    validSites.forEach(site => {
      const lat = parseFloat(site.latitude)
      const lng = parseFloat(site.longitude)
      console.log(`Adding marker for ${site.site_name_short} at [${lat}, ${lng}]`)

      const marker = L.marker([lat, lng], { icon: pulsingIcon })
        .addTo(map.value)
        .bindPopup(`
          <div class="marker-popup">
            <h3>${site.site_name_short || 'Unknown Site'}</h3>
            <p>${site.water_body_name || ''}</p>
            <button onclick="window.selectSite('${site.site_id}', '${site.site_name_short || 'Unknown'}')">
              Predict for my buddy
            </button>
          </div>
        `)

      // Add hover effect
      marker.on('mouseover', function() {
        this.openPopup()
      })
    })

    console.log('All markers added successfully')

    // Force map to recalculate size
    setTimeout(() => {
      if (map.value) {
        map.value.invalidateSize()
        console.log('Map size invalidated/refreshed')

        // Now fit bounds after invalidate
        const bounds = L.latLngBounds(
          validSites.map(site => [parseFloat(site.latitude), parseFloat(site.longitude)])
        )
        map.value.fitBounds(bounds, {
          padding: [50, 50],
          maxZoom: 10
        })
        console.log('Bounds fitted')
      }
    }, 200)
  } catch (err) {
    console.error('Error initializing map:', err)
    console.error('Error stack:', err.stack)
  }
}

// Handle site selection
const selectSite = (siteId, siteName) => {
  if (challengeState) {
    challengeState.navigate({
      type: 'selectSite',
      data: {
        site_id: siteId,
        site_name: siteName
      }
    })
  }
}

// Make selectSite available globally for popup button
if (typeof window !== 'undefined') {
  window.selectSite = selectSite
}

// Fetch habitats on mount
onMounted(async () => {
  try {
    loading.value = true
    error.value = null

    // Get selected animal from challenge state
    const selectedAnimal = challengeState?.selectedAnimal?.value
    if (!selectedAnimal) {
      error.value = 'No animal selected. Please go back and select an animal.'
      loading.value = false
      return
    }

    const data = await getHabitatsByAnimal(selectedAnimal.slug, 'en')
    sites.value = data
    loading.value = false

    if (data && data.length > 0) {
      // Calculate map height
      calculateMapHeight()

      // Wait for Vue to update the DOM
      await nextTick()
      // Additional delay to ensure DOM is fully ready and rendered
      await new Promise(resolve => setTimeout(resolve, 100))

      console.log('About to initialize map, checking DOM...')
      const mapEl = document.getElementById('habitat-map')
      console.log('Map element exists:', !!mapEl, mapEl)

      initMap()
    }
  } catch (err) {
    console.error('Failed to load habitats:', err)
    error.value = 'Failed to load habitat sites. Please try again later.'
    loading.value = false
  }
})

// Cleanup map on unmount
onBeforeUnmount(() => {
  if (map.value) {
    map.value.remove()
    map.value = null
  }
  if (typeof window !== 'undefined') {
    delete window.selectSite
  }
})

// Recalculate on window resize
if (typeof window !== 'undefined') {
  window.addEventListener('resize', calculateMapHeight)
}

onBeforeUnmount(() => {
  if (typeof window !== 'undefined') {
    window.removeEventListener('resize', calculateMapHeight)
  }
})
</script>

<style scoped>
.page {
  position: relative;
  min-height: 100vh;
  padding: calc(var(--nav-h, 80px) + 16px) 16px 36px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* Animated Background */
.animated-background {
  position: absolute;
  inset: 0;
  z-index: 1;
}

.sky {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, #87CEEB 0%, #E0F6FF 50%, #87CEEB 100%);
}

.sun {
  position: absolute;
  top: 15%;
  right: 15%;
  width: 120px;
  height: 120px;
  border-radius: 50%;
  background: radial-gradient(circle, #FFD700 0%, #FFA500 100%);
  box-shadow: 0 0 60px rgba(255, 215, 0, 0.6);
  animation: sun-pulse 4s ease-in-out infinite;
}

@keyframes sun-pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

.ocean {
  position: absolute;
  bottom: 20%;
  left: 0;
  right: 0;
  height: 45%;
  background: linear-gradient(180deg, #40E0D0 0%, #20B2AA 30%, #008B8B 70%, #006666 100%);
  overflow: hidden;
}

.tidal-wave {
  position: absolute;
  left: -100%;
  width: 200%;
  height: 80px;
  background: linear-gradient(
    90deg,
    transparent 0%,
    rgba(255, 255, 255, 0.1) 25%,
    rgba(255, 255, 255, 0.2) 50%,
    rgba(255, 255, 255, 0.1) 75%,
    transparent 100%
  );
  border-radius: 40px;
  animation: tidal-motion 12s ease-in-out infinite;
}

.tidal1 {
  bottom: 60%;
  animation-duration: 12s;
  opacity: 0.8;
}

.tidal2 {
  bottom: 40%;
  animation-duration: 15s;
  opacity: 0.6;
  animation-delay: -3s;
}

@keyframes tidal-motion {
  0% { transform: translateX(-50%) scaleY(1); }
  25% { transform: translateX(-25%) scaleY(1.2); }
  50% { transform: translateX(0%) scaleY(1); }
  75% { transform: translateX(25%) scaleY(0.8); }
  100% { transform: translateX(50%) scaleY(1); }
}

.beach {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 20%;
  background: linear-gradient(180deg, #F4A460 0%, #DEB887 50%, #D2691E 100%);
}

/* Content Grid - Two Column Layout */
.content-grid {
  position: relative;
  z-index: 10;
  width: 100%;
  max-width: 1600px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: 220px 1fr;
  gap: 16px;
  box-sizing: border-box;
  padding: 0 16px;
  height: calc(100vh - var(--nav-h, 80px) - 80px);
}

.glass {
  background: rgba(255, 255, 255, 0.86);
  border: 2px solid rgba(255, 255, 255, 0.6);
  border-radius: 16px;
  backdrop-filter: blur(8px);
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.18);
}

/* Left Panel */
.left-panel {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

/* Inline Back Button */
.back-btn-inline {
  padding: 8px 12px;
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
  border: 2px solid #0369a1;
  color: #0369a1;
  transition: all 0.2s ease;
  text-align: center;
}

.back-btn-inline:hover {
  background: #0369a1;
  color: white;
  transform: translateX(-4px);
}

/* Animal Info Card */
.animal-info {
  padding: 16px 12px;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 10px;
}

.animal-info .avatar {
  width: 100px;
  height: 100px;
  object-fit: cover;
  border-radius: 50%;
  background: #fff;
  border: 3px solid #0369a1;
  box-shadow: 0 4px 12px rgba(3, 105, 161, 0.3);
}

.animal-info h2 {
  margin: 0;
  font-size: 17px;
  color: #0f172a;
  font-weight: 900;
  line-height: 1.2;
}

.animal-info p {
  margin: 0;
  font-size: 13px;
  color: #475569;
  line-height: 1.4;
}

.animal-info .instruction {
  font-weight: 700;
  color: #0369a1;
  margin-top: 2px;
  font-size: 13px;
}

/* Right Panel */
.right-panel {
  display: flex;
  flex-direction: column;
  height: 100%;
}

/* Old back button - hide it */
.back-btn {
  display: none;
}

/* Skeleton Loading */
.skeleton-back-btn {
  height: 36px;
  background: linear-gradient(90deg, #e0e7ff 25%, #c7d2fe 50%, #e0e7ff 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
  border-radius: 16px;
}

.skeleton-animal-info {
  padding: 16px 12px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
}

.skeleton-avatar {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  background: linear-gradient(90deg, #e0e7ff 25%, #c7d2fe 50%, #e0e7ff 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
}

.skeleton-text-block {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 8px;
  align-items: center;
}

.skeleton-line {
  height: 16px;
  width: 100%;
  background: linear-gradient(90deg, #e0e7ff 25%, #c7d2fe 50%, #e0e7ff 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
  border-radius: 4px;
}

.skeleton-line.short {
  width: 60%;
}

.skeleton-line.medium {
  width: 80%;
}

.skeleton-map {
  height: 100%;
  min-height: 400px;
  background: linear-gradient(90deg, #e0e7ff 25%, #c7d2fe 50%, #e0e7ff 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
  border-radius: 16px;
}

@keyframes skeleton-loading {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

/* Loading and error states */
.error-container {
  position: relative;
  z-index: 10;
  max-width: 600px;
  margin: 60px auto;
  text-align: center;
  padding: 32px;
}

.error-container p {
  font-size: 18px;
  font-weight: 700;
  margin: 0 0 16px 0;
}

.btn-back {
  padding: 10px 24px;
  background: #0369a1;
  color: white;
  border: 2px solid #0369a1;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-back:hover {
  background: #0284c7;
  transform: translateY(-2px);
}

/* Empty state */
.empty {
  padding: 40px 24px;
  text-align: center;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
}

.empty p {
  font-weight: 700;
  font-size: 16px;
  color: #475569;
  margin: 0;
}

/* Map section */
.map-section {
  position: relative;
  padding: 4px;
  box-sizing: border-box;
  height: 100%;
  display: flex;
  flex-direction: column;
}

#habitat-map {
  width: 100%;
  flex: 1;
  min-height: 400px;
  border-radius: 6px;
  overflow: hidden;
  background: #e0e7ff;
  box-sizing: border-box;
}

/* Map Legend */
.map-legend {
  position: absolute;
  top: 16px;
  right: 16px;
  background: rgba(255, 255, 255, 0.95);
  border: 2px solid #0369a1;
  border-radius: 8px;
  padding: 10px 14px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
  z-index: 1000;
  backdrop-filter: blur(8px);
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 10px;
}

.legend-icon {
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: #0369a1;
  border: 2px solid white;
  flex-shrink: 0;
  box-shadow: 0 0 0 0 rgba(3, 105, 161, 0.7);
}

.legend-icon.pulsing {
  animation: legend-pulse 2s ease-in-out infinite;
}

@keyframes legend-pulse {
  0%, 100% {
    box-shadow: 0 0 0 0 rgba(3, 105, 161, 0.7);
    transform: scale(1);
  }
  50% {
    box-shadow: 0 0 0 6px rgba(3, 105, 161, 0);
    transform: scale(1.1);
  }
}

.legend-item span {
  font-size: 13px;
  font-weight: 700;
  color: #0f172a;
  white-space: nowrap;
}

/* Fix Leaflet tile loading issue */
:global(#habitat-map .leaflet-pane),
:global(#habitat-map .leaflet-tile),
:global(#habitat-map .leaflet-marker-icon),
:global(#habitat-map .leaflet-marker-shadow),
:global(#habitat-map .leaflet-tile-container),
:global(#habitat-map .leaflet-map-pane) {
  position: absolute;
}

:global(#habitat-map .leaflet-tile) {
  width: 256px;
  height: 256px;
}

:global(#habitat-map .leaflet-control-zoom),
:global(#habitat-map .leaflet-control-attribution) {
  position: absolute;
}

/* Pulsing Marker Animation */
:global(.pulsing-marker) {
  background: transparent !important;
  border: none !important;
}

:global(.marker-dot) {
  width: 20px;
  height: 20px;
  background: #0369a1;
  border: 3px solid white;
  border-radius: 50%;
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  box-shadow: 0 0 0 0 rgba(3, 105, 161, 0.7);
  animation: pulse-marker 2s ease-in-out infinite;
}

@keyframes pulse-marker {
  0%, 100% {
    box-shadow: 0 0 0 0 rgba(3, 105, 161, 0.7);
    transform: translate(-50%, -50%) scale(1);
  }
  50% {
    box-shadow: 0 0 0 10px rgba(3, 105, 161, 0);
    transform: translate(-50%, -50%) scale(1.1);
  }
}

/* Global popup styles */
:global(.marker-popup h3) {
  margin: 0 0 8px 0;
  font-size: 18px;
  font-weight: 900;
  color: #0f172a;
}

:global(.marker-popup p) {
  margin: 0 0 12px 0;
  font-size: 14px;
  color: #475569;
}

:global(.marker-popup button) {
  padding: 8px 16px;
  background: #0369a1;
  color: white;
  border: 2px solid #0369a1;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s ease;
  width: 100%;
}

:global(.marker-popup button:hover) {
  background: #0284c7;
}

@media (max-width: 968px) {
  .content-grid {
    grid-template-columns: 1fr;
    gap: 16px;
    height: auto;
    min-height: calc(100vh - var(--nav-h, 80px) - 80px);
  }

  .left-panel {
    width: 100%;
  }

  .right-panel {
    height: 500px;
  }

  .animal-info {
    padding: 16px;
  }

  .animal-info .avatar {
    width: 100px;
    height: 100px;
  }

  .animal-info h2 {
    font-size: 18px;
  }

  #habitat-map {
    min-height: 400px;
  }

  .map-legend {
    top: 12px;
    right: 12px;
    padding: 8px 12px;
  }

  .legend-item span {
    font-size: 12px;
  }

  .legend-icon {
    width: 14px;
    height: 14px;
  }
}
</style>
