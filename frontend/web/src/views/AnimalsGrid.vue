<template>
  <main class="page" aria-labelledby="title">
    <h1 id="title" class="visually-hidden">Animals Play — Learn • Play • Act</h1>

    <section class="wrap">
      <div class="carousel glass" role="tablist" aria-label="Choose an animal">
        <button class="nav left" @click="scrollBy(-1)" aria-label="Previous">‹</button>

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

        <button class="nav right" @click="scrollBy(1)" aria-label="Next">›</button>

        <div class="mode">
          <button class="btn" :class="{ on: mode === 'cartoon' }" @click="mode = 'cartoon'">Cartoon</button>
          <button class="btn" :class="{ on: mode === 'photo' }" @click="mode = 'photo'">Photo</button>
        </div>
      </div>

      <div class="stage glass" ref="stageEl" role="region" aria-live="polite" aria-label="Ocean stage">
        <div class="sky"></div>
        <div class="sun" aria-hidden="true"></div>
        <div class="ocean">
          <div class="wave w1"></div>
          <div class="wave w2"></div>
          <div class="wave w3"></div>
        </div>
        <div class="beach"></div>

        <transition name="pop">
          <div v-if="current" class="animal-box" :key="current.slug + mode" ref="animalEl">
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
              :alt="current ? current.name + ' cartoon' : 'cartoon'"
              @error="onImgError"
            />
          </div>
        </transition>

        <transition name="bubble">
          <div
            v-if="current"
            class="bubble"
            role="dialog"
            :aria-label="'Message from ' + current.name"
            :style="{ '--arrow-left': arrowLeft }"
          >
            <div class="bubble-title">Hi! I’m {{ current.name }} 🫧</div>
            <ul>
              <li v-for="line in current.lines" :key="line">{{ line }}</li>
            </ul>
          </div>
        </transition>
      </div>
    </section>
  </main>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'

const CDN = 'https://gvwrmcyksmswvduehrtd.supabase.co/storage/v1/object/public'
const BUCKET = 'bluetrails'
const PRIMARY_DIR = 'animal-page'
const FALLBACK_DIR = 'animal%20page' 

const animals = [
  {
    slug: 'burrunan-dolphin',
    name: 'Burrunan Dolphin',
    file: 'burranan.png',
    cartoon: 'dolphin-cartoon.png',
    lines: [
      'Please bin your rubbish and cut loops – ghost lines can tangle my fins.',
      'I’m scared of plastic bags and fishing lines.',
      'Choose reusable bottles. Less plastic, safer oceans!'
    ]
  },
  {
    slug: 'southern-right-whale',
    name: 'Southern Right Whale',
    file: 'Southern-Right-Whale.jpg',
    cartoon: 'whale-cartoon.png',
    lines: [
      'Keep balloons away from beaches – we can swallow them by mistake.',
      'Slow boats and “quiet seas” help us talk to our calves.',
      'Support rescue teams that free entangled whales.'
    ]
  },
  {
    slug: 'australian-fur-seal',
    name: 'Australian Fur Seal',
    file: 'Australian-Fur-Seal.jpg',
    cartoon: 'seal-cartoon.png',
    lines: [
      'Plastic rings/straps tighten as we grow. Snip them before you bin!',
      'Ghost nets are scary – they trap our necks.',
      'Watch wildlife from a distance. We need space to rest.'
    ]
  },
  {
    slug: 'little-penguin',
    name: 'Little Penguin',
    file: 'little-penguin.jpg',
    cartoon: 'penguin-cartoon.png',
    lines: [
      'Keep beaches clean and dark – lights confuse our chicks.',
      'Please take your fishing hooks home.',
      'Join a mini clean-up with an adult – every small piece helps!'
    ]
  },
  {
    slug: 'weedy-seadragon',
    name: 'Weedy Seadragon',
    file: 'Weedy-seadragon.jpg',
    cartoon: 'seadragon-cartoon.png',
    lines: [
      'We love healthy seagrass. Don’t trample seagrass beds.',
      'Choose reef-safe sunscreen.',
      'Share what you learn – ocean heroes inspire more heroes!'
    ]
  },
  {
    slug: 'australian-fairy-tern',
    name: 'Australian Fairy Tern',
    file: 'Australian-Fairy-Tern.jpg',
    cartoon: 'tern-cartoon.png',
    lines: [
      'Please stay outside our nesting areas on sandy beaches.',
      'Keep dogs on leash near shorebirds.',
      'Tiny plastic looks like food – pick it up!'
    ]
  },
  {
    slug: 'hooded-plover',
    name: 'Hooded Plover (Vic)',
    file: 'Larissa-Hill-Hooded-Plover.jpg',
    cartoon: 'power-cartoon.png', 
    lines: [
      'We nest right on the sand – give us space and follow signs.',
      'Leave no holes/forts on beaches – chicks can fall in.',
      'Take your litter – wind can carry it into the sea.'
    ]
  },
  {
    slug: 'short-tailed-shearwater',
    name: 'Short-tailed Shearwater',
    file: 'Short-tailed-Shearwater.jpg',
    cartoon: 'shearwater.png',
    lines: [
      'Lights at night can confuse us – shield lights near the coast.',
      'Oil and plastics hurt our feathers and stomachs.',
      'Choose reusables. Small actions make big waves!'
    ]
  }
]

const idx = ref(0)
const current = computed(() => animals[idx.value])

const rail = ref(null)
function select(i) {
  idx.value = i
  nextTick(() => {
    updateArrow()
    const el = rail.value && rail.value.children ? rail.value.children[i] : null
    if (el && el.scrollIntoView) el.scrollIntoView({ behavior: 'smooth', inline: 'center' })
  })
}
function scrollBy(step) {
  select((idx.value + step + animals.length) % animals.length)
}

const mode = ref('cartoon')

const imgSrc = (file) => `${CDN}/${BUCKET}/${PRIMARY_DIR}/${file}`
function onImgError(e) {
  const img = e.target
  const src = img.getAttribute('src') || ''
  if (src.indexOf(`/${PRIMARY_DIR}/`) !== -1) {
    img.src = src.replace(`/${PRIMARY_DIR}/`, `/${FALLBACK_DIR}/`)
  } else {
    img.style.display = 'none'
  }
}

const stageEl = ref(null)
const animalEl = ref(null)
const arrowLeft = ref('50%')

function updateArrow() {
  const stage = stageEl.value ? stageEl.value.getBoundingClientRect() : null
  const animal = animalEl.value ? animalEl.value.getBoundingClientRect() : null
  if (!stage || !animal) return
  const centerX = animal.left + animal.width / 2
  const pct = Math.max(6, Math.min(94, ((centerX - stage.left) / stage.width) * 100))
  arrowLeft.value = pct.toFixed(1) + '%'
}

onMounted(() => {
  updateArrow()
  window.addEventListener('resize', updateArrow)
})
</script>

<style scoped>
.page {
  min-height: 100vh;
  padding-top: var(--nav-h);
  padding-bottom: 40px;
  color: #fff;
  background: linear-gradient(180deg, #87CEEB 0%, #E0F6FF 20%, #40E0D0 40%, #20B2AA 60%, #008B8B 80%, #F4A460 90%, #DEB887 100%);
}
.wrap { max-width: min(1100px, 95vw); margin: 0 auto; padding: 16px 16px 0; }
.glass { background: rgba(17,25,40,.56); border: 1px solid rgba(255,255,255,.14); border-radius: 16px; backdrop-filter: blur(8px); box-shadow: 0 12px 30px rgba(0,0,0,.28); }

.carousel { display: flex; align-items: center; gap: 10px; padding: 10px; margin-bottom: 14px; }
.mode { margin-left: auto; display: flex; gap: 8px; }
.btn { height: 32px; padding: 0 10px; border-radius: 10px; border: 1px solid rgba(255,255,255,.2); background: rgba(255,255,255,.12); color: #fff; font-weight: 700; cursor: pointer; }
.btn.on { background: #22d3ee; color: #083344; border-color: #67e8f9; }
.nav { width: 36px; height: 36px; border-radius: 10px; border: 1px solid rgba(255,255,255,.2); background: rgba(255,255,255,.12); color: #fff; font-weight: 900; cursor: pointer; }
.nav:hover { background: rgba(255,255,255,.18); }
.rail { display: flex; gap: 10px; list-style: none; padding: 0; margin: 0; overflow: auto; scroll-snap-type: x mandatory; }
.rail::-webkit-scrollbar { height: 6px; }
.rail::-webkit-scrollbar-thumb { background: #9ca3af; border-radius: 999px; }
.chip { min-width: 170px; scroll-snap-align: center; display: flex; align-items: center; gap: 10px; background: rgba(255,255,255,.12); border: 1px solid rgba(255,255,255,.18); padding: 8px 10px; border-radius: 12px; cursor: pointer; outline: none; }
.chip:hover { background: rgba(255,255,255,.18); }
.chip.active { background: #22d3ee; color: #083344; border-color: #67e8f9; }
.avatar { width: 48px; height: 48px; border-radius: 12px; object-fit: cover; background: #fff; }
.label { font-weight: 800; }

.stage { position: relative; height: 520px; overflow: hidden; }
.sky { position: absolute; inset: 0 0 35% 0; background: linear-gradient(#a5d8ff,#e0f2fe); }
.sun { position: absolute; top: 30px; right: 36px; width: 70px; height: 70px; border-radius: 50%; background: #fde047; box-shadow: 0 0 40px rgba(253,224,71,.8); opacity: .9; }
.ocean { position: absolute; left: 0; right: 0; top: 35%; height: 40%; background: linear-gradient(#60a5fa,#2563eb); overflow: hidden; }
.wave { position: absolute; left: -50%; right: -50%; height: 40px; background: radial-gradient(circle at 10px -10px, transparent 14px, rgba(255,255,255,.5) 15px) 0 0/20px 20px repeat-x; opacity: .55; animation: drift 10s linear infinite; }
.w1 { bottom: 26px; } .w2 { bottom: 14px; opacity: .4; animation-duration: 13s; } .w3 { bottom: 2px; opacity: .35; animation-duration: 16s; }
@keyframes drift { to { transform: translateX(50%); } }
.beach { position: absolute; left: 0; right: 0; bottom: 0; height: 35%; background: linear-gradient(#fde68a,#f59e0b); box-shadow: 0 -10px 30px rgba(0,0,0,.15) inset; }

.animal-box {
  position: absolute; left: 50%; transform: translateX(-50%);
  bottom: 24%;
  width: min(38vw, 340px); height: min(34vw, 300px);
  display: flex; align-items: center; justify-content: center;
  filter: drop-shadow(0 14px 26px rgba(0,0,0,.4));
}
.photo { width: 100%; height: 100%; object-fit: contain; border-radius: 14px; }
.cartoon-img { width: 100%; height: 100%; object-fit: contain; image-rendering: auto; }

.pop-enter-from { transform: translate(-50%, 40%) scale(.85); opacity: 0; }
.pop-enter-active { transition: all .55s cubic-bezier(.2,.9,.2,1); }
.pop-enter-to { transform: translate(-50%, 0%) scale(1); opacity: 1; }

.bubble {
  position: absolute; left: 50%; transform: translateX(-50%);
  bottom: 6%;
  width: min(720px, 92%); color: #0f172a;
  background: #fff; border-radius: 14px; padding: 14px 16px;
  box-shadow: 0 10px 28px rgba(0,0,0,.28);
}
.bubble::after {
  content: ""; position: absolute; bottom: -10px;
  width: 18px; height: 18px; background: #fff; rotate: 45deg;
  left: var(--arrow-left, 50%); transform: translateX(-50%);
  box-shadow: 4px 4px 10px rgba(0,0,0,.08);
}
.bubble-title { font-weight: 900; margin-bottom: 6px; }
.bubble ul { margin: 0; padding-left: 18px; line-height: 1.55; }

/* A11y */
.visually-hidden { position: absolute !important; width: 1px; height: 1px; overflow: hidden; clip: rect(1px,1px,1px,1px); white-space: nowrap; }

@media (max-width: 720px) {
  .stage { height: 520px; }
  .animal-box { width: min(70vw, 300px); height: min(60vw, 260px); }
}
</style>
