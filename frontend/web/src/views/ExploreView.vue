<template>
  <div class="map-page">
    <!-- 筛选条 -->
    <header class="bar">
      <h2>Explore Australia — Beaches</h2>

      <div class="filters">
        <!-- 活动筛选 -->
        <label class="field">
          <span>Activity</span>
          <select v-model="activity">
            <option value="">Any</option>
            <option v-for="a in activities" :key="a" :value="a">{{ a }}</option>
          </select>
        </label>

        <!-- 州筛选 -->
        <label class="field">
          <span>State</span>
          <select v-model="state">
            <option value="">All</option>
            <option v-for="s in states" :key="s" :value="s">{{ s }}</option>
          </select>
        </label>

        <button class="clear" @click="resetFilters">Clear</button>
      </div>

      <div class="tips">Click dots • drag to move • scroll to zoom</div>
    </header>

    <!-- 地图容器 -->
    <div id="map" class="map"></div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onBeforeUnmount } from 'vue'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

let map, beachLayer

// === 示例数据（后续可替换为后端/JSON 返回） ===
const beaches = [
  { name: 'Bondi Beach',       state: 'NSW', lat: -33.8915, lng: 151.2767, activities: ['Swimming', 'Surfing', 'Sunbathing'] },
  { name: 'Manly Beach',       state: 'NSW', lat: -33.7943, lng: 151.2875, activities: ['Swimming', 'Surfing', 'Kayaking'] },
  { name: 'Byron Bay (Main)',  state: 'NSW', lat: -28.6434, lng: 153.6110, activities: ['Surfing', 'Snorkelling', 'Sunbathing'] },
  { name: 'Surfers Paradise',  state: 'QLD', lat: -28.0027, lng: 153.4290, activities: ['Surfing', 'Swimming', 'Nightlife'] },
  { name: 'Noosa Main Beach',  state: 'QLD', lat: -26.3893, lng: 153.0903, activities: ['Swimming', 'Family', 'Kayaking'] },
  { name: 'Whitehaven Beach',  state: 'QLD', lat: -20.2820, lng: 149.0370, activities: ['Sunbathing', 'Snorkelling', 'Wildlife'] },
  { name: 'St Kilda Beach',    state: 'VIC', lat: -37.8676, lng: 144.9720, activities: ['Swimming', 'Kitesurfing', 'Sunbathing'] },
  { name: 'Glenelg Beach',     state: 'SA',  lat: -34.9805, lng: 138.5147, activities: ['Swimming', 'Family', 'Sunset'] },
  { name: 'Cottesloe Beach',   state: 'WA',  lat: -31.9947, lng: 115.7513, activities: ['Snorkelling', 'Swimming', 'Sunset'] },
  { name: 'Scarborough Beach', state: 'WA',  lat: -31.8955, lng: 115.7522, activities: ['Surfing', 'Swimming', 'Sunbathing'] },
]

// 可选项：活动/州
const activities = [...new Set(beaches.flatMap(b => b.activities))].sort()
const states     = [...new Set(beaches.map(b => b.state))].sort()

// 筛选状态
const activity = ref('') // 选中的活动（空=不限）
const state    = ref('') // 选中的州（空=不限）

// 计算筛选结果
const filteredBeaches = computed(() => {
  return beaches.filter(b => {
    const byActivity = activity.value ? b.activities.includes(activity.value) : true
    const byState    = state.value ? b.state === state.value : true
    return byActivity && byState
  })
})

function resetFilters() {
  activity.value = ''
  state.value = ''
}

// 重新渲染点
function drawDots(data) {
  if (!beachLayer) beachLayer = L.featureGroup().addTo(map)
  beachLayer.clearLayers()

  data.forEach(b => {
    const dot = L.circleMarker([b.lat, b.lng], {
      radius: 6, weight: 1, color: '#0ea5e9', opacity: 0.9, fillColor: '#60a5fa', fillOpacity: 0.9
    })
      .bindPopup(`<b>${b.name}</b><br/>${b.state}<br/><small>${b.activities.join(' · ')}</small>`)
      .on('mouseover', () => dot.setStyle({ radius: 8, fillOpacity: 1 }))
      .on('mouseout',  () => dot.setStyle({ radius: 6, fillOpacity: 0.9 }))

    dot.addTo(beachLayer)
  })

  if (data.length) {
    const bounds = L.latLngBounds(data.map(b => [b.lat, b.lng]))
    map.fitBounds(bounds.pad(0.2))
  }
}

onMounted(() => {
  // 地图
  map = L.map('map', { center: [-25.2744, 133.7751], zoom: 4, minZoom: 3, maxZoom: 18, worldCopyJump: true })
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: '&copy; OpenStreetMap contributors' }).addTo(map)

  // 初次绘制
  drawDots(filteredBeaches.value)

  // 限制拖动范围（可选）
  const au = L.latLngBounds(L.latLng(-46, 109), L.latLng(-9, 159))
  map.setMaxBounds(au.pad(0.35))

  // 修正尺寸
  setTimeout(() => map.invalidateSize(), 0)
})

// 监听筛选变化 → 重绘
watch(filteredBeaches, (val) => {
  if (map) drawDots(val)
}, { immediate: false })

onBeforeUnmount(() => {
  if (map) { map.remove(); map = null }
})
</script>

<style scoped>
.map-page {
  display: grid;
  grid-template-rows: auto 1fr;
  height: 100vh;
}

/* 顶部筛选条 */
.bar {
  display:flex; align-items: center; gap:1rem; flex-wrap: wrap;
  padding:.6rem 1rem;
  backdrop-filter: blur(6px);
  background: color-mix(in oklab, #ffffff 70%, transparent);
  border-bottom: 1px solid #e9edf3;
}
.bar h2 {
  margin:0; font-size:1.05rem; letter-spacing:.02em; font-weight:800; color:#0b1b2b;
}
.filters {
  display:flex; align-items:center; gap:.6rem; flex-wrap: wrap;
}
.field { display:flex; align-items:center; gap:.35rem; }
.field span { font-size:.9rem; color:#334155; }
.field select {
  appearance: none;
  padding: .45rem .7rem;
  border-radius: 10px;
  border: 1px solid #d8dee8;
  background: #fff;
  font-size:.92rem; color:#0b1b2b;
}
.clear {
  padding:.45rem .8rem; border-radius:10px; border:1px solid #d8dee8;
  background:#f7f9fc; font-weight:600; cursor:pointer;
}
.clear:hover { background:#eef2f7; }

.tips { margin-left:auto; color:#475569; font-size:.9rem; opacity:.9; }
@media (max-width: 920px){ .tips{ display:none; } }

/* 地图铺满剩余空间 */
.map { width:100%; height:100%; outline:none; border-top:1px solid #eef2f7; }
</style>
