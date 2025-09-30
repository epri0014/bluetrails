<template>
  <main class="page" aria-labelledby="title">
    <h1 id="title" class="visually-hidden">{{ $t('animals.pageTitle') }} - {{ $t('animals.learnPlayAct') }}</h1>

    <section class="wrap">
      <div class="carousel glass" ref="railBox" role="tablist" aria-label="Choose an animal">
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

        <div class="stage-nav" aria-hidden="false">
          <button class="stage-btn left" @click="prev" :aria-label="'Previous: ' + prevAnimal.name">
            <img
              :src="previewSrc(prevAnimal)"
              :alt="prevAnimal.name"
              @error="onPreviewError($event, prevAnimal)"
            />
            <span class="chev"><</span>
          </button>

          <button class="stage-btn right" @click="next" :aria-label="'Next: ' + nextAnimal.name">
            <img
              :src="previewSrc(nextAnimal)"
              :alt="nextAnimal.name"
              @error="onPreviewError($event, nextAnimal)"
            />
            <span class="chev">></span>
          </button>
        </div>

        <div v-show="!infoOpen" class="tap-hint" :style="{ left: arrowLeft, top: hintTop }" aria-hidden="true">
          <span class="tap-badge">{{ $t('animals.tapMe') }}</span>
          <span class="tap-hand">👆</span>
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
            <div class="bubble-title">{{ $t('animals.hiIm') }} {{ current.name }} 🫧</div>
            <ul>
              <li v-for="line in current.lines" :key="line">{{ line }}</li>
            </ul>
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
                  <div class="val">{{ current.type }}</div>
                </div>
                <div class="row">
                  <div class="term">{{ $t('animals.habitat') }}</div>
                  <div class="val">{{ current.habitat }}</div>
                </div>

                <div class="row">
                  <div class="term">{{ $t('animals.whatHurtsMe') }}</div>
                  <ul class="val">
                    <li v-for="x in current.threats" :key="x">{{ x }}</li>
                  </ul>
                </div>

                <div class="row">
                  <div class="term">{{ $t('animals.howYouCanHelp') }}</div>
                  <ul class="val">
                    <li v-for="x in current.help" :key="x">{{ x }}</li>
                  </ul>
                </div>

                <div v-if="current.fun && current.fun.length" class="row">
                  <div class="term">{{ $t('animals.funFact') }}</div>
                  <ul class="val">
                    <li v-for="x in current.fun" :key="x">{{ x }}</li>
                  </ul>
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
import { ref, computed, onMounted, nextTick } from 'vue'
import { useI18n } from 'vue-i18n'

const { t, tm } = useI18n()

const CDN = 'https://gvwrmcyksmswvduehrtd.supabase.co/storage/v1/object/public'
const BUCKET = 'bluetrails'
const PRIMARY_DIR = 'animal-page'
const FALLBACK_DIR = 'animal%20page'

// Base animal data (static info only)
const baseAnimals = [
  { slug:'burrunan-dolphin', sci:'Tursiops australis', file:'burranan.png', cartoon:'dolphin-cartoon.png' },
  { slug:'southern-right-whale', sci:'Eubalaena australis', file:'Southern-Right-Whale.jpg', cartoon:'whale-cartoon.png' },
  { slug:'australian-fur-seal', sci:'Arctocephalus pusillus doriferus', file:'Australian-Fur-Seal.jpg', cartoon:'seal-cartoon.png' },
  { slug:'little-penguin', sci:'Eudyptula minor', file:'little-penguin.jpg', cartoon:'penguin-cartoon.png' },
  { slug:'weedy-seadragon', sci:'Phyllopteryx taeniolatus', file:'Weedy-seadragon.jpg', cartoon:'seadragon-cartoon.png' },
  { slug:'australian-fairy-tern', sci:'Sternula nereis', file:'Australian-Fairy-Tern.jpg', cartoon:'tern-cartoon.png' },
  { slug:'hooded-plover', sci:'Thinornis cucullatus', file:'Larissa-Hill-Hooded-Plover.jpg', cartoon:'pover-cartoon.png' },
  { slug:'short-tailed-shearwater', sci:'Ardenna tenuirostris', file:'Short-tailed-Shearwater.jpg', cartoon:'shearwater.png' }
]

// Computed animals with translations
const animals = computed(() => {
  return baseAnimals.map(animal => ({
    ...animal,
    name: t(`animalData.${animal.slug}.name`),
    type: t(`animalData.${animal.slug}.type`),
    habitat: t(`animalData.${animal.slug}.habitat`),
    lines: tm(`animalData.${animal.slug}.lines`),
    threats: tm(`animalData.${animal.slug}.threats`) || [],
    help: tm(`animalData.${animal.slug}.help`) || [],
    fun: tm(`animalData.${animal.slug}.fun`) || []
  }))
})

const idx = ref(0)
const current = computed(() => animals.value[idx.value])

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

const imgSrc = (file) => `${CDN}/${BUCKET}/${PRIMARY_DIR}/${file}`
function onImgError(e){
  const img = e.target
  const src = img.getAttribute('src') || ''
  if (src.includes(`/${PRIMARY_DIR}/`)) img.src = src.replace(`/${PRIMARY_DIR}/`, `/${FALLBACK_DIR}/`)
  else img.src = ''
}

function previewSrc(animal){
  const f = mode.value === 'photo' ? animal.file : (animal.cartoon || animal.file)
  return imgSrc(f)
}
function onPreviewError(ev, animal){
  const el = ev.target
  if (el.src.includes(`/${PRIMARY_DIR}/`)) { el.src = el.src.replace(`/${PRIMARY_DIR}/`, `/${FALLBACK_DIR}/`); return }
  if (mode.value !== 'photo') { el.src = imgSrc(animal.file); return }
  el.style.display = 'none'
}

const stageEl = ref(null)
const animalEl = ref(null)
const arrowLeft = ref('50%')
const hintTop = ref('16px')
function updateArrow(){
  const stage = stageEl.value?.getBoundingClientRect()
  const animal = animalEl.value?.getBoundingClientRect()
  if (!stage || !animal) return
  const centerX = animal.left + animal.width/2
  const pct = Math.max(6, Math.min(94, ((centerX - stage.left) / stage.width) * 100))
  arrowLeft.value = pct.toFixed(1) + '%'
  const railRect = railBox.value?.getBoundingClientRect()
  const safe = 8
  hintTop.value = railRect ? Math.min(Math.max(12, Math.round(railRect.bottom - stage.top + safe)), 64) + 'px' : '16px'
}

const prevIndex = computed(() => (idx.value - 1 + animals.value.length) % animals.value.length)
const nextIndex = computed(() => (idx.value + 1) % animals.value.length)
const prevAnimal = computed(() => animals.value[prevIndex.value])
const nextAnimal = computed(() => animals.value[nextIndex.value])
function prev(){ select(prevIndex.value) }
function next(){ select(nextIndex.value) }

const infoOpen = ref(false)
function openInfo(){ infoOpen.value = true }
function closeInfo(){ infoOpen.value = false }

onMounted(() => {
  updateArrow()
  window.addEventListener('resize', updateArrow)
})
</script>

<style scoped>
.page{
  min-height:100vh; padding-top:var(--nav-h); padding-bottom:40px; color:#fff;
  background: linear-gradient(180deg, #87CEEB 0%, #E0F6FF 20%, #40E0D0 40%, #20B2AA 60%, #008B8B 80%, #F4A460 90%, #DEB887 100%);
}
.wrap{ max-width:min(1400px, 96vw); margin:0 auto; padding:16px 16px 0; }
.glass{ background:rgba(17,25,40,.56); border:1px solid rgba(255,255,255,.14); border-radius:16px; backdrop-filter:blur(8px); box-shadow:0 12px 30px rgba(0,0,0,.28); }

.carousel{ display:flex; align-items:center; gap:10px; padding:10px; margin-bottom:14px; }
.mode{ margin-left:auto; display:flex; gap:8px; }
.btn{ height:32px; padding:0 10px; border-radius:10px; border:1px solid rgba(255,255,255,.2); background:rgba(255,255,255,.12); color:#fff; font-weight:700; cursor:pointer; }
.btn.on{ background:#22d3ee; color:#083344; border-color:#67e8f9; }
.nav{ width:36px; height:36px; border-radius:10px; border:1px solid rgba(255,255,255,.2); background:rgba(255,255,255,.12); color:#fff; font-weight:900; cursor:pointer; }
.nav:hover{ background:rgba(255,255,255,.18); }
.rail{ display:flex; gap:10px; list-style:none; padding:0; margin:0; overflow:auto; scroll-snap-type:x mandatory; }
.rail::-webkit-scrollbar{ height:6px; } .rail::-webkit-scrollbar-thumb{ background:#9ca3af; border-radius:999px; }
.chip{ min-width:180px; scroll-snap-align:center; display:flex; align-items:center; gap:10px; background:rgba(255,255,255,.12); border:1px solid rgba(255,255,255,.18); padding:10px 12px; border-radius:12px; cursor:pointer; outline:none; }
.chip:hover{ background:rgba(255,255,255,.18); }
.chip.active{ background:#22d3ee; color:#083344; border-color:#67e8f9; }
.avatar{ width:56px; height:56px; border-radius:14px; object-fit:cover; background:#fff; }
.label{ font-weight:800; }

.stage{
  position:relative; overflow:hidden; padding-top:18px;
  height: clamp(680px, 75vh, 920px);
}
.sky{ position:absolute; inset:0 0 35% 0; background:linear-gradient(#a5d8ff,#e0f2fe); }
.sun{ position:absolute; top:30px; right:36px; width:70px; height:70px; border-radius:50%; background:#fde047; box-shadow:0 0 40px rgba(253,224,71,.8); opacity:.9; }
.ocean{ position:absolute; left:0; right:0; top:35%; height:40%; background:linear-gradient(#60a5fa,#2563eb); overflow:hidden; }
.wave{ position:absolute; left:-50%; right:-50%; height:40px; background:radial-gradient(circle at 10px -10px, transparent 14px, rgba(255,255,255,.5) 15px) 0 0/20px 20px repeat-x; opacity:.55; animation:drift 10s linear infinite; }
.w1{ bottom:26px; } .w2{ bottom:14px; opacity:.4; animation-duration:13s; } .w3{ bottom:2px; opacity:.35; animation-duration:16s; }
@keyframes drift{ to{ transform:translateX(50%); } }
.beach{ position:absolute; left:0; right:0; bottom:0; height:35%; background:linear-gradient(#fde68a,#f59e0b); box-shadow:0 -10px 30px rgba(0,0,0,.15) inset; }

.stage-nav{ position:absolute; inset:0; display:block; pointer-events:none; z-index:5; }
.stage-btn{
  position:absolute; top:50%; transform:translateY(-50%) scale(.94);
  width:min(18vw, 180px); height:min(24vw, 220px);
  border:none; outline:none; cursor:pointer; border-radius:14px; overflow:hidden;
  background:rgba(255,255,255,.18); box-shadow:0 10px 24px rgba(0,0,0,.28);
  transition:transform .15s ease, box-shadow .15s ease, opacity .15s ease;
  pointer-events:auto; opacity:.98;
}
.stage-btn img{ width:100%; height:100%; object-fit:cover; display:block; filter:saturate(.96) contrast(.97); }
.stage-btn.left{ left:clamp(8px, 2.6vw, 32px); }
.stage-btn.right{ right:clamp(8px, 2.6vw, 32px); }
.stage-btn:hover{ transform:translateY(-50%) scale(.98); box-shadow:0 14px 30px rgba(0,0,0,.35); }
.stage-btn .chev{
  position:absolute; top:8px; inset-inline-start:8px; width:26px; height:26px; border-radius:999px; display:grid; place-items:center;
  background:rgba(0,0,0,.55); color:#fff; font-weight:900; font-size:18px; line-height:1;
}
.stage-btn.right .chev{ inset-inline-start:auto; inset-inline-end:8px; }

.tap-hint{ position:absolute; transform:translateX(-50%); z-index:6; pointer-events:none; display:flex; flex-direction:column; align-items:center; gap:6px; }
.tap-badge{ background:#22d3ee; color:#083344; font-weight:900; padding:6px 10px; border-radius:999px; box-shadow:0 6px 18px rgba(34,211,238,.35);
  animation: hint-pop .6s cubic-bezier(.2,.9,.2,1) 1, hint-pulse 1.5s ease-in-out infinite .6s;
}
.tap-hand{ font-size:22px; filter:drop-shadow(0 3px 6px rgba(0,0,0,.25)); animation: hand-bounce 1.2s ease-in-out infinite; }
@keyframes hint-pop{ from{ transform:scale(.8); opacity:0 } to{ transform:scale(1); opacity:1 } }
@keyframes hint-pulse{ 0%,100%{ filter:drop-shadow(0 0 0 rgba(34,211,238,0)) } 50%{ filter:drop-shadow(0 0 12px rgba(34,211,238,.6)) } }
@keyframes hand-bounce{ 0%,100%{ transform:translateY(0) } 50%{ transform:translateY(6px) } }

.animal-box{
  position:absolute; left:50%; transform:translateX(-50%); bottom:22%;
  width: clamp(420px, 34vw, 520px); height: clamp(360px, 30vw, 460px);
  display:flex; align-items:center; justify-content:center; filter: drop-shadow(0 14px 26px rgba(0,0,0,.4)); z-index:4;
}
.photo, .cartoon-img{ width:100%; height:100%; object-fit:contain; image-rendering:auto; border-radius:14px; }
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

@media (max-width: 720px){
  .stage-btn{ display:none; }
  .animal-box{ width:min(70vw, 320px); height:min(60vw, 280px); }
  .sheet-grid{ grid-template-columns: 1fr; }
  .term{ margin-top:8px; }
}
</style>