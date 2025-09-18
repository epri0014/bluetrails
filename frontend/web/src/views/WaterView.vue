<template>
  <main class="page">
    <section class="wrap">
      <div class="panel glass">
        <header class="panel-head">
          <div class="title-container">
            <h1 class="title">Visit Ocean Friends Home</h1>
            <div class="avatar-group">
              <img v-for="(animal, index) in featuredAnimals"
                   :key="animal.slug"
                   class="mini-avatar"
                   :src="getAvatarImage(animal.cartoon)"
                   :alt="animal.name"
                   :style="{ animationDelay: (index * 0.3) + 's' }" />
            </div>
          </div>
          <div class="actions">
            <button class="btn" @click="reload">
              ↻ Reload
            </button>
            <button class="btn" @click="openNew">
              ⤢ Open in new tab
            </button>
          </div>
        </header>

        <div class="iframe-wrap">
          <LoadingOverlay v-if="loading" message="📊 Loading interactive app..." />
          <iframe
            ref="frame"
            src="https://019911fb-5550-ad05-7994-5cd5737f0ef1.share.connect.posit.cloud/"
            title="Water Quality Shiny App"
            frameborder="0"
            allowfullscreen
            @load="onLoad"
          ></iframe>
        </div>

        <footer class="panel-foot">
          <p class="tip">
            Tip: Choose a date to colour every beach. Pick a beach pin to read kid-friendly insights!
          </p>
        </footer>
      </div>
    </section>
  </main>
</template>

<script setup>
import { ref } from 'vue'
import LoadingOverlay from '../components/LoadingOverlay.vue'

const CDN = 'https://gvwrmcyksmswvduehrtd.supabase.co/storage/v1/object/public'
const BUCKET = 'bluetrails'
const PRIMARY_DIR = 'animal-page'

// Featured animals for mini avatars
const featuredAnimals = [
  { slug: 'burrunan-dolphin', name: 'Burrunan Dolphin', cartoon: 'dolphin-cartoon.png' },
  { slug: 'southern-right-whale', name: 'Southern Right Whale', cartoon: 'whale-cartoon.png' },
  { slug: 'australian-fur-seal', name: 'Australian Fur Seal', cartoon: 'seal-cartoon.png' },
  { slug: 'little-penguin', name: 'Little Penguin', cartoon: 'penguin-cartoon.png' },
  { slug: 'weedy-seadragon', name: 'Weedy Seadragon', cartoon: 'seadragon-cartoon.png' }
]

const loading = ref(true)
const frame = ref(null)

// Get avatar image URL
function getAvatarImage(filename) {
  return `${CDN}/${BUCKET}/${PRIMARY_DIR}/${filename}`
}

function onLoad() {
  loading.value = false
}

function reload() {
  loading.value = true
  if (frame.value) frame.value.src = frame.value.src
}

function openNew() {
  window.open('https://019911fb-5550-ad05-7994-5cd5737f0ef1.share.connect.posit.cloud/', '_blank', 'noopener')
}
</script>

<style scoped>
.page{
  min-height:100vh;
  padding-top:var(--nav-h);
  padding-bottom:24px;
  color:#f6f7fb;
  background: linear-gradient(180deg, #87CEEB 0%, #E0F6FF 20%, #40E0D0 40%, #20B2AA 60%, #008B8B 80%, #F4A460 90%, #DEB887 100%);
}

.wrap{
  max-width:1100px;
  margin:0 auto;
  padding:16px 16px 0;
}

.glass{
  background: rgba(17, 25, 40, .55);
  border: 1px solid rgba(255,255,255,.14);
  border-radius: 16px;
  box-shadow: 0 14px 34px rgba(0,0,0,.35);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
}

.wrap{
  max-width: min(95vw, 1440px); 
  margin: 0 auto;
  padding: 35px 16px;
}

.panel{
  display:flex;
  flex-direction:column;
  min-height: calc(100vh - var(--nav-h) + 320px);
}

.iframe-wrap{
  position:relative;
  flex:1;
  min-height: 760px;
}


.panel-head{
  display:flex;
  align-items:center;
  justify-content:space-between;
  padding:14px 16px;
  border-bottom:1px solid rgba(255,255,255,.10);
}

.title-container{
  display:flex;
  align-items:center;
  gap:16px;
}

.avatar-group{
  display:flex;
  gap:8px;
  align-items:center;
}

.mini-avatar{
  width:32px;
  height:32px;
  border-radius:50%;
  border:2px solid rgba(255,255,255,0.3);
  background:#fff;
  object-fit:cover;
  animation:water-wave-bounce 2s ease-in-out infinite;
  transition:transform 0.3s ease;
}

.mini-avatar:hover{
  transform:scale(1.1);
  border-color:rgba(255,255,255,0.6);
}

.title{
  font-size: clamp(18px, 2.2vw, 22px);
  margin:0;
  font-weight:900;
  letter-spacing:.2px;
}

.actions{ display:flex; gap:10px; }
.btn{
  height:36px; padding:0 12px;
  border-radius:10px; border:1px solid rgba(255,255,255,.18);
  background: rgba(255,255,255,.12); color:#fff; font-weight:700;
  cursor:pointer;
}
.btn:hover{ background: rgba(255,255,255,.18); }

.iframe-wrap{
  position:relative;
  flex:1; 
  min-height: 520px;
}
iframe{
  position:absolute; inset:0;
  width:100%; height:100%;
  border:none; border-radius: 0 0 16px 16px; 
}

.panel-foot{
  padding:10px 16px 14px;
  border-top:1px solid rgba(255,255,255,.10);
}
.tip{
  margin:0;
  font-size:14px;
  color:#e9eef5;
  opacity:.9;
}

.loading-overlay{
  position:absolute;
  inset:0;
  display:flex;
  flex-direction:column;
  align-items:center;
  justify-content:center;
  background: rgba(250, 249, 247, 0.92);
  z-index: 10;
  font-weight: 700;
  color:#334155;
}
.spinner{
  width:42px;height:42px;
  border:4px solid #ddd; border-top:4px solid #0EA5E9;
  border-radius:50%; animation:spin 1s linear infinite;
  margin-bottom:12px;
}
@keyframes spin{ to{ transform:rotate(360deg) } }

@keyframes water-wave-bounce {
  0%, 100% {
    transform:translateY(0px);
  }
  50% {
    transform:translateY(-6px);
  }
}

@media (max-width: 720px){
  .panel{ min-height: calc(100vh - var(--nav-h)); }
  .title{ font-size:18px; }
  .btn{ height:34px; padding:0 10px; }
}
</style>
