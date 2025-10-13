<template>
  <main class="page" aria-labelledby="title">
    <h1 id="title" class="visually-hidden">{{ $t('animals.pageTitle') }} - {{ $t('animals.learnPlayAct') }}</h1>

    <section class="wrap">
      <!-- Loading skeleton -->
      <div v-if="loading" class="loading-skeleton">
        <!-- Skeleton carousel -->
        <div class="skeleton-carousel glass">
          <div class="skeleton-nav"></div>
          <div class="skeleton-rail">
            <div class="skeleton-chip shimmer"></div>
            <div class="skeleton-chip shimmer"></div>
            <div class="skeleton-chip shimmer"></div>
            <div class="skeleton-chip shimmer"></div>
          </div>
          <div class="skeleton-nav"></div>
          <div class="skeleton-mode">
            <div class="skeleton-btn shimmer"></div>
            <div class="skeleton-btn shimmer"></div>
          </div>
        </div>

        <!-- Skeleton stage -->
        <div class="skeleton-stage glass">
          <div class="sky"></div>
          <div class="sun"></div>
          <div class="ocean">
            <div class="wave w1"></div>
            <div class="wave w2"></div>
            <div class="wave w3"></div>
          </div>
          <div class="beach"></div>

          <div class="skeleton-animal shimmer"></div>
          <div class="skeleton-bubble shimmer"></div>
        </div>
      </div>

      <!-- Error state -->
      <div v-else-if="error" class="error-container glass">
        <div class="error-content">
          <p class="error-message">{{ error }}</p>
          <button @click="loadAnimals" class="retry-btn">Retry Loading</button>
        </div>
      </div>

      <!-- Main content -->
      <div v-else class="carousel glass" ref="railBox" role="tablist" aria-label="Choose an animal">
        <button class="nav left" @click="scrollBy(-1)" :aria-label="$t('animals.previous')"><</button>

        <ul class="rail" ref="rail">
          <li
            v-for="(a, i) in animals"
            :key="a.slug"
            class="chip"
            :class="{ active: i === idx }"
            role="tab"
            :aria-selected="i === idx"
            tabindex="0"
            @click="select(i)"
            @keydown.enter.prevent="select(i)"
          >
            <img class="avatar" :src="imgSrc(a.file)" :alt="a.name" @error="onImgError" />
            <div class="label">{{ a.name }}</div>
          </li>
        </ul>

        <button class="nav right" @click="scrollBy(1)" :aria-label="$t('animals.next')">></button>

        <div class="mode">
          <button class="btn" :class="{ on: mode === 'cartoon' }" @click="mode = 'cartoon'">{{ $t('animals.cartoon') }}</button>
          <button class="btn" :class="{ on: mode === 'photo' }" @click="mode = 'photo'">{{ $t('animals.photo') }}</button>
        </div>
      </div>

      <div
        class="stage glass"
        ref="stageEl"
        role="region"
        aria-live="polite"
        aria-label="Ocean stage"
        tabindex="0"
        @keydown.left.prevent="prev"
        @keydown.right.prevent="next"
      >
        <div class="sky"></div>
        <div class="sun" aria-hidden="true"></div>
        <div class="ocean">
          <div class="wave w1"></div>
          <div class="wave w2"></div>
          <div class="wave w3"></div>
        </div>
        <div class="beach"></div>

        <div v-if="animals.length > 0" class="stage-nav" aria-hidden="false">
          <button class="stage-btn left" @click="prev" :aria-label="'Previous: ' + prevAnimal?.name">
            <img
              :src="previewSrc(prevAnimal)"
              :alt="prevAnimal?.name"
              @error="onPreviewError($event, prevAnimal)"
            />
            <span class="chev"><</span>
          </button>

          <button class="stage-btn right" @click="next" :aria-label="'Next: ' + nextAnimal?.name">
            <img
              :src="previewSrc(nextAnimal)"
              :alt="nextAnimal?.name"
              @error="onPreviewError($event, nextAnimal)"
            />
            <span class="chev">></span>
          </button>
        </div>

        <transition name="pop">
          <div
            v-if="current"
            class="animal-box"
            :key="current.slug + mode"
            ref="animalEl"
            @click="openInfo"
            role="button"
            :aria-label="$t('animals.openInfoFor') + ' ' + current.name"
            tabindex="0"
            @keydown.enter.prevent="openInfo"
          >
            <img
              v-if="mode === 'photo'"
              class="photo"
              :src="imgSrc(current.file)"
              :alt="current.name"
              @error="onImgError"
            />
            <img
              v-else
              class="cartoon-img"
              :src="imgSrc(current.cartoon)"
              :alt="current.name + ' cartoon'"
              @error="onImgError"
            />
            <div v-show="!infoOpen" class="tap-hint" aria-hidden="true">
              <span class="tap-badge">{{ $t('animals.tapMe') }}</span>
              <span class="tap-hand">👆</span>
            </div>
          </div>
        </transition>

        <transition name="bubble">
          <div
            v-if="current"
            class="bubble"
            role="dialog"
            :aria-label="$t('animals.messageFrom') + ' ' + current.name"
            :style="{ '--arrow-left': arrowLeft }"
          >
            <div class="bubble-title typing-text">{{ $t('animals.hiIm') }} {{ current.name }} 🫧</div>
            <ul v-if="!loadingDetail && current.lines && current.lines.length > 0" class="typing-list">
              <li v-for="(line, index) in current.lines" :key="line" :style="{ animationDelay: `${index * 0.5}s` }">{{ line }}</li>
            </ul>
            <div v-else class="skeleton-lines">
              <div class="skeleton-line"></div>
              <div class="skeleton-line"></div>
              <div class="skeleton-line short"></div>
            </div>
          </div>
        </transition>

        <transition name="sheet">
          <div
            v-if="infoOpen"
            class="sheet-mask"
            @click.self="closeInfo"
            role="dialog"
            aria-modal="true"
            :aria-label="current.name + ' facts'"
          >
            <article class="fact-sheet" @click.stop>
              <button class="sheet-close" @click="closeInfo" :aria-label="$t('animals.close')">x</button>

              <header class="sheet-header">
                <img :src="imgSrc(mode==='cartoon' ? current.cartoon : current.file)" :alt="current.name" class="sheet-avatar" @error="onImgError" />
                <div class="sheet-title">
                  <div class="eyebrow">{{ $t('animals.commonName') }}</div>
                  <h2>{{ current.name }}</h2>
                  <div v-if="current.sci" class="sci">{{ $t('animals.scientificName') }}: <i>{{ current.sci }}</i></div>
                </div>
              </header>

              <section class="sheet-grid">
                <div class="row">
                  <div class="term">{{ $t('animals.type') }}</div>
                  <div v-if="!loadingDetail && current.type" class="val">{{ current.type }}</div>
                  <div v-else class="val skeleton-list">
                    <div class="skeleton-line short"></div>
                  </div>
                </div>
                <div class="row">
                  <div class="term">{{ $t('animals.habitat') }}</div>
                  <div v-if="!loadingDetail && current.habitat" class="val">{{ current.habitat }}</div>
                  <div v-else class="val skeleton-list">
                    <div class="skeleton-line short"></div>
                  </div>
                </div>

                <div class="row">
                  <div class="term">{{ $t('animals.whatHurtsMe') }}</div>
                  <ul v-if="!loadingDetail && current.threats && current.threats.length > 0" class="val">
                    <li v-for="x in current.threats" :key="x">{{ x }}</li>
                  </ul>
                  <div v-else class="val skeleton-list">
                    <div class="skeleton-line"></div>
                    <div class="skeleton-line short"></div>
                  </div>
                </div>

                <div class="row">
                  <div class="term">{{ $t('animals.howYouCanHelp') }}</div>
                  <ul v-if="!loadingDetail && current.help && current.help.length > 0" class="val">
                    <li v-for="x in current.help" :key="x">{{ x }}</li>
                  </ul>
                  <div v-else class="val skeleton-list">
                    <div class="skeleton-line"></div>
                    <div class="skeleton-line"></div>
                  </div>
                </div>

                <div class="row">
                  <div class="term">{{ $t('animals.funFact') }}</div>
                  <ul v-if="!loadingDetail && current.fun && current.fun.length > 0" class="val">
                    <li v-for="x in current.fun" :key="x">{{ x }}</li>
                  </ul>
                  <div v-else class="val skeleton-list">
                    <div class="skeleton-line"></div>
                  </div>
                </div>
              </section>
            </article>
          </div>
        </transition>
      </div>
    </section>
  </main>
</template>

<script setup>
import { ref, computed, onMounted, nextTick, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { getAnimals, getAnimalBySlug } from '@/services/api.js'

const { locale } = useI18n()

// Dynamic animals data from API
const animalsData = ref([])
const animalDetails = ref({})
const loading = ref(true)
const loadingDetail = ref(false)
const error = ref(null)

// Load animals from API
const loadAnimals = async () => {
  try {
    loading.value = true
    error.value = null
    const data = await getAnimals(locale.value)

    // Transform API data to match expected format (only basic info)
    animalsData.value = data.map(animal => ({
      slug: animal.slug,
      sci: animal.scientific_name,
      file: animal.photo_image_url, // Use full URL from database
      cartoon: animal.cartoon_image_url, // Use full URL from database
      name: animal.name
    }))
  } catch (err) {
    console.error('Failed to load animals:', err)
    error.value = 'Failed to load animals'
  } finally {
    loading.value = false
  }
}

// Load detailed animal data by slug
const loadAnimalDetail = async (slug) => {
  if (animalDetails.value[slug]) return // Already loaded

  try {
    loadingDetail.value = true
    const data = await getAnimalBySlug(slug, locale.value)

    animalDetails.value[slug] = {
      type: data.type,
      habitat: data.habitat,
      lines: data.lines?.map(line => line.content) || [],
      threats: data.threats?.map(threat => threat.content) || [],
      help: data.help_actions?.map(action => action.content) || [],
      fun: data.fun_facts?.map(fact => fact.content) || []
    }
  } catch (err) {
    console.error('Failed to load animal detail:', err)
    animalDetails.value[slug] = {
      type: '',
      habitat: '',
      lines: [],
      threats: [],
      help: [],
      fun: []
    }
  } finally {
    loadingDetail.value = false
  }
}

// Computed animals with merged detail data
const animals = computed(() => {
  return animalsData.value.map(animal => ({
    ...animal,
    ...(animalDetails.value[animal.slug] || {
      lines: [],
      threats: [],
      help: [],
      fun: []
    })
  }))
})

const idx = ref(0)
const current = computed(() => animals.value[idx.value])

// Watch for current animal changes and load details
watch(current, (newAnimal) => {
  if (newAnimal && !animalDetails.value[newAnimal.slug]) {
    loadAnimalDetail(newAnimal.slug)
  }
}, { immediate: true })

const rail = ref(null)
const railBox = ref(null)
function select(i){
  idx.value = i
  nextTick(() => {
    updateArrow()
    const el = rail.value?.children?.[i]
    el?.scrollIntoView?.({ behavior:'smooth', inline:'center', block:'nearest' })
  })
}
function scrollBy(step){ select((idx.value + step + animals.value.length) % animals.value.length) }

const mode = ref('cartoon')

const imgSrc = (url) => url || '' // Return the full URL directly from database
function onImgError(e){
  const img = e.target
  img.style.display = 'none' // Hide broken images
}

function previewSrc(animal){
  if (!animal) return ''
  const url = mode.value === 'photo' ? animal.file : (animal.cartoon || animal.file)
  return imgSrc(url)
}
function onPreviewError(ev, animal){
  const el = ev.target
  if (!animal) { el.style.display = 'none'; return }
  // Try fallback to photo if cartoon fails
  if (mode.value !== 'photo' && animal.file) {
    el.src = animal.file
    return
  }
  el.style.display = 'none'
}

const stageEl = ref(null)
const animalEl = ref(null)
const arrowLeft = ref('50%')
function updateArrow(){
  const stage = stageEl.value?.getBoundingClientRect()
  const animal = animalEl.value?.getBoundingClientRect()
  if (!stage || !animal) return
  const centerX = animal.left + animal.width/2
  const pct = Math.max(6, Math.min(94, ((centerX - stage.left) / stage.width) * 100))
  arrowLeft.value = pct.toFixed(1) + '%'
}

const prevIndex = computed(() => animals.value.length > 0 ? (idx.value - 1 + animals.value.length) % animals.value.length : 0)
const nextIndex = computed(() => animals.value.length > 0 ? (idx.value + 1) % animals.value.length : 0)
const prevAnimal = computed(() => animals.value.length > 0 ? animals.value[prevIndex.value] : null)
const nextAnimal = computed(() => animals.value.length > 0 ? animals.value[nextIndex.value] : null)
function prev(){ select(prevIndex.value) }
function next(){ select(nextIndex.value) }

const infoOpen = ref(false)
function openInfo(){ infoOpen.value = true }
function closeInfo(){ infoOpen.value = false }

// Watch for locale changes and reload animals
watch(locale, async () => {
  animalDetails.value = {} // Clear cached details
  const currentIdx = idx.value // Preserve current index

  // Reload without showing loading overlay
  try {
    const data = await getAnimals(locale.value)
    animalsData.value = data.map(animal => ({
      slug: animal.slug,
      sci: animal.scientific_name,
      file: animal.photo_image_url,
      cartoon: animal.cartoon_image_url,
      name: animal.name
    }))
    idx.value = currentIdx // Restore position
  } catch (err) {
    console.error('Failed to reload animals:', err)
  }
})

onMounted(async () => {
  await loadAnimals()
  updateArrow()
  window.addEventListener('resize', updateArrow)
})
</script>

<style scoped>
.page{
  height:100vh; padding-top:var(--nav-h); overflow:hidden; color:#fff;
  background: linear-gradient(180deg, #87CEEB 0%, #E0F6FF 20%, #40E0D0 40%, #20B2AA 60%, #008B8B 80%, #F4A460 90%, #DEB887 100%);
}
.wrap{ max-width:min(1400px, 96vw); margin:0 auto; padding:8px 16px 0; height:calc(100vh - var(--nav-h)); display:flex; flex-direction:column; }
.glass{ background:rgba(17,25,40,.56); border:1px solid rgba(255,255,255,.14); border-radius:16px; backdrop-filter:blur(8px); box-shadow:0 12px 30px rgba(0,0,0,.28); }

.carousel{ display:flex; align-items:center; gap:10px; padding:8px 10px; margin-bottom:8px; flex-shrink:0; }
.mode{ margin-left:auto; display:flex; gap:8px; }
.btn{ height:32px; padding:0 10px; border-radius:10px; border:1px solid rgba(255,255,255,.2); background:rgba(255,255,255,.12); color:#fff; font-weight:700; cursor:pointer; }
.btn.on{ background:#22d3ee; color:#083344; border-color:#67e8f9; }
.nav{ width:36px; height:36px; border-radius:10px; border:1px solid rgba(255,255,255,.2); background:rgba(255,255,255,.12); color:#fff; font-weight:900; cursor:pointer; }
.nav:hover{ background:rgba(255,255,255,.18); }
.rail{ display:flex; gap:8px; list-style:none; padding:0; margin:0; overflow:auto; scroll-snap-type:x mandatory; }
.rail::-webkit-scrollbar{ height:6px; } .rail::-webkit-scrollbar-thumb{ background:#9ca3af; border-radius:999px; }
.chip{ min-width:150px; scroll-snap-align:center; display:flex; align-items:center; gap:8px; background:rgba(255,255,255,.12); border:1px solid rgba(255,255,255,.18); padding:8px 10px; border-radius:10px; cursor:pointer; outline:none; }
.chip:hover{ background:rgba(255,255,255,.18); }
.chip.active{ background:#22d3ee; color:#083344; border-color:#67e8f9; }
.avatar{ width:48px; height:48px; border-radius:12px; object-fit:cover; background:#fff; }
.label{ font-weight:800; font-size:14px; }

.stage{
  position:relative; overflow:hidden; padding-top:8px;
  flex:1;
  min-height:0;
}
.sky{ position:absolute; inset:0 0 35% 0; background:linear-gradient(#a5d8ff,#e0f2fe); }
.sun{ position:absolute; top:12px; right:24px; width:60px; height:60px; border-radius:50%; background:#fde047; box-shadow:0 0 40px rgba(253,224,71,.8); opacity:.9; }
.ocean{ position:absolute; left:0; right:0; top:35%; height:40%; background:linear-gradient(#60a5fa,#2563eb); overflow:hidden; }
.wave{ position:absolute; left:-50%; right:-50%; height:40px; background:radial-gradient(circle at 10px -10px, transparent 14px, rgba(255,255,255,.5) 15px) 0 0/20px 20px repeat-x; opacity:.55; animation:drift 10s linear infinite; }
.w1{ bottom:26px; } .w2{ bottom:14px; opacity:.4; animation-duration:13s; } .w3{ bottom:2px; opacity:.35; animation-duration:16s; }
@keyframes drift{ to{ transform:translateX(50%); } }
.beach{ position:absolute; left:0; right:0; bottom:0; height:35%; background:linear-gradient(#fde68a,#f59e0b); box-shadow:0 -10px 30px rgba(0,0,0,.15) inset; }

.stage-nav{ position:absolute; inset:0; display:block; pointer-events:none; z-index:5; }
.stage-btn{
  position:absolute; top:45%; transform:translateY(-50%) scale(.94);
  width:min(14vw, 140px); height:min(18vw, 170px);
  border:none; outline:none; cursor:pointer; border-radius:12px; overflow:hidden;
  background:rgba(255,255,255,.18); box-shadow:0 8px 20px rgba(0,0,0,.28);
  transition:transform .15s ease, box-shadow .15s ease;
  pointer-events:auto;
  animation: blink-preview 3s ease-in-out infinite;
}
.stage-btn img{ width:100%; height:100%; object-fit:cover; display:block; filter:saturate(.96) contrast(.97); }

@keyframes blink-preview {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}
.stage-btn.left{ left:clamp(6px, 2vw, 24px); }
.stage-btn.right{ right:clamp(6px, 2vw, 24px); }
.stage-btn:hover{ transform:translateY(-50%) scale(.98); box-shadow:0 12px 26px rgba(0,0,0,.35); }
.stage-btn .chev{
  position:absolute; top:6px; inset-inline-start:6px; width:24px; height:24px; border-radius:999px; display:grid; place-items:center;
  background:rgba(0,0,0,.55); color:#fff; font-weight:900; font-size:16px; line-height:1;
}
.stage-btn.right .chev{ inset-inline-start:auto; inset-inline-end:6px; }

.tap-hint{ position:absolute; top:10%; left:50%; transform:translateX(-50%); z-index:6; pointer-events:none; display:flex; flex-direction:column; align-items:center; gap:6px; }
.tap-badge{ background:#22d3ee; color:#083344; font-weight:900; padding:6px 10px; border-radius:999px; box-shadow:0 6px 18px rgba(34,211,238,.35);
  animation: hint-pop .6s cubic-bezier(.2,.9,.2,1) 1, hint-pulse 1.5s ease-in-out infinite .6s;
}
.tap-hand{ font-size:22px; filter:drop-shadow(0 3px 6px rgba(0,0,0,.25)); animation: hand-bounce 1.2s ease-in-out infinite; }
@keyframes hint-pop{ from{ transform:scale(.8); opacity:0 } to{ transform:scale(1); opacity:1 } }
@keyframes hint-pulse{ 0%,100%{ filter:drop-shadow(0 0 0 rgba(34,211,238,0)) } 50%{ filter:drop-shadow(0 0 12px rgba(34,211,238,.6)) } }
@keyframes hand-bounce{ 0%,100%{ transform:translateY(0) } 50%{ transform:translateY(6px) } }

.animal-box{
  position:absolute; left:50%; transform:translateX(-50%); bottom:24%;
  width: clamp(340px, 28vw, 420px); height: clamp(290px, 24vw, 360px);
  display:flex; align-items:center; justify-content:center; filter: drop-shadow(0 14px 26px rgba(0,0,0,.4)); z-index:4;
  animation: gentle-bounce 2s ease-in-out infinite;
}
.photo, .cartoon-img{ width:100%; height:100%; object-fit:contain; image-rendering:auto; border-radius:14px; }

@keyframes gentle-bounce {
  0%, 100% {
    transform: translateX(-50%) translateY(0);
  }
  50% {
    transform: translateX(-50%) translateY(-12px);
  }
}
.pop-enter-from{ transform: translate(-50%, 40%) scale(.85); opacity:0; }
.pop-enter-active{ transition: all .55s cubic-bezier(.2,.9,.2,1); }
.pop-enter-to{ transform: translate(-50%, 0%) scale(1); opacity:1; }

.bubble{
  position:absolute; left:50%; transform:translateX(-50%); bottom:6%;
  width:min(980px, 96%); color:#0f172a; background:#fff; border-radius:14px; padding:14px 16px; box-shadow:0 10px 28px rgba(0,0,0,.28);
}
.bubble::after{
  content:""; position:absolute; bottom:-10px; width:18px; height:18px; background:#fff; rotate:45deg;
  left: var(--arrow-left, 50%); transform: translateX(-50%); box-shadow: 4px 4px 10px rgba(0,0,0,.08);
}
.bubble-title{ font-weight:900; margin-bottom:6px; }
.bubble ul{ margin:0; padding-left:18px; line-height:1.55; }

/* Typing animation for bubble text */
.typing-text {
  overflow: hidden;
  border-right: 2px solid transparent;
  white-space: nowrap;
  animation: typing 1.5s steps(40, end), blink-caret 0.75s step-end 5;
  max-width: fit-content;
}

@keyframes typing {
  from {
    width: 0;
  }
  to {
    width: 100%;
  }
}

@keyframes blink-caret {
  from, to {
    border-color: transparent;
  }
  50% {
    border-color: #0f172a;
  }
}

.typing-list li {
  opacity: 0;
  animation: fade-in-text 0.8s ease forwards;
}

@keyframes fade-in-text {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.sheet-mask{
  position:absolute; inset:0; background:rgba(0,0,0,.35); display:grid; place-items:center; z-index:20;
}
.fact-sheet{
  width:min(980px, 92vw);
  background:#2f6f1f;
  border:6px solid #f2c94c;
  border-radius:16px;
  color:#fff;
  box-shadow:0 20px 50px rgba(0,0,0,.45);
  padding:18px 18px 10px;
}
.sheet-close{
  position:absolute; top:8px; right:10px; width:36px; height:36px; border-radius:10px;
  border:none; background:#fff; color:#0f172a; font-size:22px; cursor:pointer;
  box-shadow:0 6px 18px rgba(0,0,0,.25);
}
.sheet-header{ display:flex; align-items:center; gap:16px; margin-bottom:10px; }
.sheet-avatar{ width:120px; height:120px; border-radius:999px; object-fit:cover; border:4px solid #f2c94c; background:#fff; }
.sheet-title h2{ margin:.1em 0 .1em; font-size:28px; line-height:1.2; font-weight:900; }
.eyebrow{ text-transform:uppercase; letter-spacing:.12em; opacity:.9; font-size:12px; color:#ffe08a; }
.sci{ opacity:.95; font-size:14px; }

.sheet-grid{ display:grid; grid-template-columns: 170px 1fr; gap:8px 14px; }
.row{ display:contents; }
.term{ font-weight:800; color:#ffe08a; text-transform:uppercase; letter-spacing:.08em; }
.val{ margin:0; }
.val li{ margin-left:18px; }

.sheet-enter-from{ opacity:0; transform: scale(.96); }
.sheet-enter-active{ transition: all .22s ease; }
.sheet-enter-to{ opacity:1; transform: scale(1); }

.visually-hidden{ position:absolute !important; width:1px; height:1px; overflow:hidden; clip:rect(1px,1px,1px,1px); white-space:nowrap; }

.error-container {
  position: relative;
  min-height: 200px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 14px;
}

.error-content {
  text-align: center;
  color: #fff;
}

.error-message {
  font-size: 18px;
  margin-bottom: 16px;
  font-weight: 600;
}

.retry-btn {
  background: #22d3ee;
  color: #083344;
  border: none;
  padding: 10px 20px;
  border-radius: 10px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s ease;
}

.retry-btn:hover {
  background: #0891b2;
  transform: translateY(-1px);
}

/* Skeleton loading styles */
.skeleton-lines {
  padding: 0;
  margin: 0;
}

.skeleton-line {
  height: 16px;
  background: linear-gradient(90deg, rgba(0,0,0,0.08) 25%, rgba(0,0,0,0.15) 50%, rgba(0,0,0,0.08) 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
  border-radius: 4px;
  margin-bottom: 8px;
}

.skeleton-line.short {
  width: 70%;
}

.skeleton-list .skeleton-line {
  background: linear-gradient(90deg, rgba(0,0,0,0.05) 25%, rgba(0,0,0,0.1) 50%, rgba(0,0,0,0.05) 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
}

@keyframes skeleton-loading {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: -200% 0;
  }
}

@media (max-width: 720px){
  .stage-btn{
    width: 50px;
    height: 50px;
    border-radius: 50%;
    top: 35%;
  }
  .stage-btn img{ display: none; }
  .stage-btn.left::before,
  .stage-btn.right::before {
    content: '←';
    position: absolute;
    inset: 0;
    display: grid;
    place-items: center;
    font-size: 28px;
    font-weight: 900;
    color: #fff;
  }
  .stage-btn.right::before {
    content: '→';
  }
  .stage-btn .chev { display: none; }

  .animal-box{
    width: min(60vw, 280px);
    height: min(50vw, 240px);
    bottom: 32%;
  }

  .bubble {
    bottom: 4%;
    padding: 10px 12px;
    font-size: 13px;
  }
  .bubble-title {
    font-size: 14px;
    margin-bottom: 4px;
  }
  .bubble ul {
    padding-left: 14px;
    line-height: 1.4;
    font-size: 12px;
  }

  .sun {
    top: 8px;
    right: 12px;
    width: 45px;
    height: 45px;
  }

  .fact-sheet {
    width: 95vw;
    max-height: 85vh;
    overflow-y: auto;
    padding: 14px 12px 10px;
  }

  .sheet-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
    margin-bottom: 8px;
  }

  .sheet-avatar {
    width: 80px;
    height: 80px;
    align-self: center;
  }

  .sheet-title h2 {
    font-size: 20px;
  }

  .sheet-close {
    width: 32px;
    height: 32px;
    font-size: 18px;
  }

  .sheet-grid {
    grid-template-columns: 1fr;
    gap: 6px 10px;
    font-size: 13px;
  }

  .term {
    margin-top: 6px;
    font-size: 12px;
  }

  .val {
    font-size: 13px;
  }
}

/* Landscape mobile */
@media (max-width: 920px) and (orientation: landscape) {
  .animal-box {
    width: min(35vw, 240px);
    height: min(30vw, 200px);
    bottom: 38%;
  }

  .bubble {
    bottom: 2%;
    padding: 8px 10px;
    font-size: 11px;
  }
  .bubble-title {
    font-size: 12px;
    margin-bottom: 2px;
  }
  .bubble ul {
    padding-left: 12px;
    line-height: 1.3;
    font-size: 10px;
  }

  .stage-btn {
    width: 45px;
    height: 45px;
    top: 40%;
  }
  .stage-btn.left::before,
  .stage-btn.right::before {
    font-size: 24px;
  }

  .fact-sheet {
    width: 96vw;
    max-height: 90vh;
    overflow-y: auto;
    padding: 12px 10px 8px;
  }

  .sheet-header {
    flex-direction: row;
    gap: 8px;
    margin-bottom: 6px;
  }

  .sheet-avatar {
    width: 60px;
    height: 60px;
  }

  .sheet-title h2 {
    font-size: 16px;
    margin: 0.05em 0;
  }

  .sci {
    font-size: 11px;
  }

  .eyebrow {
    font-size: 10px;
  }

  .sheet-close {
    width: 28px;
    height: 28px;
    font-size: 16px;
    top: 6px;
    right: 6px;
  }

  .sheet-grid {
    gap: 4px 8px;
    font-size: 11px;
  }

  .term {
    margin-top: 4px;
    font-size: 10px;
  }

  .val {
    font-size: 11px;
  }

  .val li {
    margin-left: 12px;
  }
}

/* Skeleton Loading Styles */
.loading-skeleton {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.skeleton-carousel {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 10px;
  margin-bottom: 8px;
  flex-shrink: 0;
}

.skeleton-nav {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.12);
}

.skeleton-rail {
  display: flex;
  gap: 8px;
  flex: 1;
  overflow: hidden;
}

.skeleton-chip {
  min-width: 150px;
  height: 66px;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.12);
}

.skeleton-mode {
  margin-left: auto;
  display: flex;
  gap: 8px;
}

.skeleton-btn {
  width: 80px;
  height: 32px;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.12);
}

.skeleton-stage {
  position: relative;
  overflow: hidden;
  padding-top: 8px;
  flex: 1;
  min-height: 0;
}

.skeleton-animal {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  bottom: 24%;
  width: clamp(340px, 28vw, 420px);
  height: clamp(290px, 24vw, 360px);
  border-radius: 14px;
  background: rgba(255, 255, 255, 0.2);
  z-index: 4;
}

.skeleton-bubble {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  bottom: 6%;
  width: min(980px, 96%);
  height: 80px;
  border-radius: 14px;
  background: rgba(255, 255, 255, 0.9);
}

/* Shimmer animation */
.shimmer {
  background: linear-gradient(
    90deg,
    rgba(255, 255, 255, 0.1) 0%,
    rgba(255, 255, 255, 0.25) 50%,
    rgba(255, 255, 255, 0.1) 100%
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
</style>