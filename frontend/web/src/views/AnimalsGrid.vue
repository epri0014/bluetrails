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

        <transition name="pop" mode="out-in">
          <div
            v-if="current"
            class="animal-box"
            :class="{ hint: showHint }"
            :key="current.slug + mode"
            ref="animalEl"
            @click="openInfo()"
            @keydown.space.prevent="openInfo()"
            tabindex="0"
            role="button"
            :aria-label="'Open info card for ' + current.name"
            title="Tap to learn"
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

            <div v-if="showHint" class="tap-guide" aria-hidden="true">
              <div class="tap-label">Tap me!</div>
              <div class="arrow-down"></div>
              <div class="hand">👆</div>
            </div>
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

    <div
      v-if="showInfo"
      class="info-overlay"
      @click.self="closeInfo"
      role="dialog"
      aria-modal="true"
      :aria-label="'About ' + current.name"
    >
      <article class="info-card">
        <button class="info-close" @click="closeInfo" aria-label="Close">✕</button>

        <header class="info-head">
          <div class="info-title">
            <div class="eyebrow">Victoria • Coasts & Ocean</div>
            <h2 class="cn">{{ current.name }}</h2>
            <div class="latin" v-if="current.sci"><em>{{ current.sci }}</em></div>
          </div>
          <img
            :src="mode === 'photo' ? imgSrc(current.file) : imgSrc(current.cartoon)"
            :alt="current.name"
            class="info-avatar"
            @error="onImgError"
          />
        </header>

        <section class="info-grid">
          <div class="row"><span class="k">Category:</span><span class="v">{{ current.type }}</span></div>
          <div class="row"><span class="k">Habitat in VIC:</span><span class="v">{{ current.habitat }}</span></div>
          <div class="row"><span class="k">Diet:</span><span class="v">{{ current.diet }}</span></div>
          <div class="row"><span class="k">Main threats:</span>
            <ul class="v bullets"><li v-for="t in current.threats" :key="t">{{ t }}</li></ul>
          </div>
          <div class="row"><span class="k">How kids can help:</span>
            <ul class="v bullets"><li v-for="h in current.help" :key="h">{{ h }}</li></ul>
          </div>
          <div class="row"><span class="k">Fun fact:</span><span class="v">{{ current.fun }}</span></div>
        </section>
      </article>
    </div>
  </main>
</template>

<script setup>
import { ref, computed, onMounted, nextTick, onBeforeUnmount } from 'vue'

const CDN = 'https://gvwrmcyksmswvduehrtd.supabase.co/storage/v1/object/public'
const BUCKET = 'bluetrails'
const PRIMARY_DIR = 'animal-page'
const FALLBACK_DIR = 'animal%20page'

const animals = [
  {
    slug: 'burrunan-dolphin', name: 'Burrunan Dolphin', sci: 'Tursiops australis',
    type:'Mammal (dolphin)',
    habitat:'Near-shore waters of Port Phillip Bay and Gippsland Lakes',
    diet:'Small fish and squid',
    threats:[
      'Lost fishing lines and plastic bags can entangle or be swallowed',
      'Fast boats and underwater noise cause stress',
      'Poor water quality reduces food'
    ],
    help:[
      'Pack up fishing lines/hooks and cut plastic loops before binning',
      'Slow down boats and watch from a distance',
      'Choose reusables and join a beach clean-up'
    ],
    fun:'We “talk” with clicks and whistles!',
    file:'burranan.png', cartoon:'dolphin-cartoon.png',
    lines:[
      'Please bin your rubbish and cut loops – ghost lines can tangle my fins.',
      'I’m scared of plastic bags and fishing lines.',
      'Choose reusable bottles. Less plastic, safer oceans!'
    ]
  },
  {
    slug:'southern-right-whale', name:'Southern Right Whale', sci:'Eubalaena australis',
    type:'Mammal (whale)',
    habitat:'Winter/spring along VIC coast (breeding and resting bays)',
    diet:'Tiny krill and copepods filtered from the water',
    threats:[
      'Entanglement in ropes and nets',
      'Ship strikes and underwater noise',
      'Ingesting marine debris'
    ],
    help:[
      'Keep balloons away from beaches and secure party waste',
      'Slow boats and follow “quiet seas” guidelines',
      'Support rescue teams that free entangled whales'
    ],
    fun:'We have rough white “callosities” on our heads—like fingerprints!',
    file:'Southern-Right-Whale.jpg', cartoon:'whale-cartoon.png',
    lines:[
      'Keep balloons away from beaches – we can swallow them by mistake.',
      'Slow boats and “quiet seas” help us talk to our calves.',
      'Support rescue teams that free entangled whales.'
    ]
  },
  {
    slug:'australian-fur-seal', name:'Australian Fur Seal', sci:'Arctocephalus pusillus doriferus',
    type:'Mammal (seal)',
    habitat:'Rocky islands and reefs around Bass Strait & Port Phillip Heads',
    diet:'Fish, squid and crustaceans',
    threats:[
      'Plastic rings/straps tighten as pups grow',
      'Ghost nets and lines cut skin and necks',
      'Human disturbance at haul-outs'
    ],
    help:[
      'Snip plastic loops and straps before binning',
      'Take lines and lures home',
      'Watch wildlife from a distance—let us rest'
    ],
    fun:'We “walk” on land using our flippers like hands!',
    file:'Australian-Fur-Seal.jpg', cartoon:'seal-cartoon.png',
    lines:[
      'Plastic rings/straps tighten as we grow. Snip them before you bin!',
      'Ghost nets are scary – they trap our necks.',
      'Watch wildlife from a distance. We need space to rest.'
    ]
  },
  {
    slug:'little-penguin', name:'Little Penguin', sci:'Eudyptula minor',
    type:'Bird (penguin)',
    habitat:'Burrows on islands and urban coasts (e.g., St Kilda breakwater)',
    diet:'Small fish, krill and squid',
    threats:[
      'Light pollution confuses chicks and adults',
      'Fishing hooks/lines and plastics',
      'Loose dogs and trampling of burrows'
    ],
    help:[
      'Keep beaches clean and dark at night',
      'Take fishing hooks/line home',
      'Join a clean-up—every small piece helps'
    ],
    fun:'We are the world’s smallest penguins!',
    file:'little-penguin.jpg', cartoon:'penguin-cartoon.png',
    lines:[
      'Keep beaches clean and dark – lights confuse our chicks.',
      'Please take your fishing hooks home.',
      'Join a mini clean-up with an adult – every small piece helps!'
    ]
  },
  {
    slug:'weedy-seadragon', name:'Weedy Seadragon', sci:'Phyllopteryx taeniolatus',
    type:'Fish (seahorse relative)',
    habitat:'Kelp and seagrass beds along rocky reefs',
    diet:'Tiny shrimp and plankton',
    threats:[
      'Loss of seagrass/kelp habitat',
      'Poor water quality',
      'Collecting and disturbance'
    ],
    help:[
      'Don’t trample seagrass; enter water from sandy spots',
      'Choose reef-safe sunscreen',
      'Share ocean-friendly habits with friends'
    ],
    fun:'Dads carry the eggs on their tails!',
    file:'Weedy-seadragon.jpg', cartoon:'seadragon-cartoon.png',
    lines:[
      'We love healthy seagrass. Don’t trample seagrass beds.',
      'Choose reef-safe sunscreen.',
      'Share what you learn – ocean heroes inspire more heroes!'
    ]
  },
  {
    slug:'australian-fairy-tern', name:'Australian Fairy Tern', sci:'Sternula nereis nereis',
    type:'Bird (tern)',
    habitat:'Sandy spits and beaches of bays and estuaries',
    diet:'Small fish caught by plunge-diving',
    threats:[
      'People and vehicles crushing nests on sand',
      'Dogs and foxes disturbing colonies',
      'Plastic bits mistaken for food'
    ],
    help:[
      'Stay outside signed nesting areas',
      'Keep dogs on a leash near shorebirds',
      'Pick up tiny plastics—help parents feed real fish'
    ],
    fun:'We hover then dive like little arrows!',
    file:'Australian-Fairy-Tern.jpg', cartoon:'tern-cartoon.png',
    lines:[
      'Please stay outside our nesting areas on sandy beaches.',
      'Keep dogs on leash near shorebirds.',
      'Tiny plastic looks like food – pick it up!'
    ]
  },
  {
    slug:'hooded-plover', name:'Hooded Plover', sci:'Thinornis cucullatus',
    type:'Bird (shorebird)',
    habitat:'Open ocean beaches and dune edges',
    diet:'Tiny insects and beach invertebrates',
    threats:[
      'Nests right on sand—easily trampled',
      'Holes/forts trap chicks',
      'Loose dogs disturb parents'
    ],
    help:[
      'Follow beach signs and give space to families',
      'Flatten sand forts and fill holes before leaving',
      'Keep dogs leashed near shorebirds'
    ],
    fun:'Our eggs look like pebbles—great camo, easy to miss!',
    file:'Larissa-Hill-Hooded-Plover.jpg', cartoon:'pover-cartoon.png',
    lines:[
      'We nest right on the sand – give us space and follow signs.',
      'Leave no holes/forts on beaches – chicks can fall in.',
      'Take your litter – wind can carry it into the sea.'
    ]
  },
  {
    slug:'short-tailed-shearwater', name:'Short-tailed Shearwater', sci:'Ardenna tenuirostris',
    type:'Bird (seabird)',
    habitat:'Burrows on Bass Strait islands; long-distance migrants',
    diet:'Krill and small fish',
    threats:[
      'Lights at night disorient fledglings',
      'Oil and plastic ingestion',
      'Disturbance at colonies'
    ],
    help:[
      'Shield bright lights near the coast',
      'Reduce plastics and recycle properly',
      'Observe colonies quietly from paths'
    ],
    fun:'We migrate thousands of kilometres every year!',
    file:'Short-tailed-Shearwater.jpg', cartoon:'shearwater.png',
    lines:[
      'Lights at night can confuse us – shield lights near the coast.',
      'Oil and plastics hurt our feathers and stomachs.',
      'Choose reusables. Small actions make big waves!'
    ]
  }
]

const idx = ref(0)
const current = computed(() => animals[idx.value])
const mode = ref('cartoon')

const rail = ref(null)
function select(i){
  idx.value = i
  nextTick(() => {
    updateArrow()
    centerChip(i)
    restartHint()          
  })
}
function scrollBy(step){ select((idx.value + step + animals.length) % animals.length) }
function centerChip(i){
  const r = rail.value; if(!r || !r.children || !r.children[i]) return
  const item = r.children[i]
  const rr = r.getBoundingClientRect()
  const ir = item.getBoundingClientRect()
  const delta = (ir.left + ir.width/2) - (rr.left + rr.width/2)
  r.scrollTo({ left: r.scrollLeft + delta, behavior: 'smooth' })
}

const imgSrc = (file) => `${CDN}/${BUCKET}/${PRIMARY_DIR}/${file}`
function onImgError(e){
  const img = e.target
  const src = img.getAttribute('src') || ''
  if (src.includes(`/${PRIMARY_DIR}/`)) img.src = src.replace(`/${PRIMARY_DIR}/`, `/${FALLBACK_DIR}/`)
  else img.style.display = 'none'
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

const showInfo = ref(false)
const showHint = ref(true)
let hintTimer, hintRepeat

function openInfo(){
  showInfo.value = true
  showHint.value = false
  document.body.style.overflow = 'hidden'
}
function closeInfo(){
  showInfo.value = false
  document.body.style.overflow = ''
  restartHint()
}
function restartHint(){
  showHint.value = true
  if (hintTimer) clearTimeout(hintTimer)
  hintTimer = setTimeout(() => (showHint.value = false), 9000) 
}

function onEsc(e){ if(e.key === 'Escape') closeInfo() }

onMounted(() => {
  updateArrow()
  window.addEventListener('resize', updateArrow)
  window.addEventListener('keydown', onEsc)
  restartHint()
  hintRepeat = setInterval(() => { if (!showInfo.value) restartHint() }, 25000)
})
onBeforeUnmount(() => {
  window.removeEventListener('resize', updateArrow)
  window.removeEventListener('keydown', onEsc)
  if (hintTimer) clearTimeout(hintTimer)
  if (hintRepeat) clearInterval(hintRepeat)
})
</script>

<style scoped>
.page{
  min-height:100vh;
  padding-top:var(--nav-h);
  padding-bottom:40px;
  color:#fff;
  background: linear-gradient(180deg, #87CEEB 0%, #E0F6FF 20%, #40E0D0 40%, #20B2AA 60%, #008B8B 80%, #F4A460 90%, #DEB887 100%);
}
.wrap{ max-width:min(1400px, 96vw); margin:0 auto; padding:16px 18px 0; }
.glass{ background:rgba(17,25,40,.56); border:1px solid rgba(255,255,255,.14); border-radius:16px; backdrop-filter:blur(8px); box-shadow:0 12px 30px rgba(0,0,0,.28); }

.carousel{ display:flex; align-items:center; gap:10px; padding:12px; margin-bottom:14px; }
.mode{ margin-left:auto; display:flex; gap:8px; }
.btn{ height:32px; padding:0 10px; border-radius:10px; border:1px solid rgba(255,255,255,.2); background:rgba(255,255,255,.12); color:#fff; font-weight:700; cursor:pointer; }
.btn.on{ background:#22d3ee; color:#083344; border-color:#67e8f9; }
.nav{ width:36px; height:36px; border-radius:10px; border:1px solid rgba(255,255,255,.2); background:rgba(255,255,255,.12); color:#fff; font-weight:900; cursor:pointer; }
.nav:hover{ background:rgba(255,255,255,.18); }

.rail{
  display:flex; gap:12px; list-style:none; padding:0; margin:0;
  overflow-x:auto; overflow-y:hidden;
  scroll-snap-type:x mandatory;
  -webkit-overflow-scrolling:touch;
  overscroll-behavior-x: contain;
}
.rail::-webkit-scrollbar{ height:6px; }
.rail::-webkit-scrollbar-thumb{ background:#9ca3af; border-radius:999px; }

.chip{
  min-width:190px; scroll-snap-align:center;
  display:flex; align-items:center; gap:10px;
  background:rgba(255,255,255,.12); border:1px solid rgba(255,255,255,.18);
  padding:10px 12px; border-radius:12px; cursor:pointer; outline:none;
}
.chip:hover{ background:rgba(255,255,255,.18); }
.chip.active{ background:#22d3ee; color:#083344; border-color:#67e8f9; }
.avatar{ width:56px; height:56px; border-radius:14px; object-fit:cover; background:#fff; }
.label{ font-weight:800; }

.stage{ position:relative; height:clamp(560px, 66vh, 820px); overflow:hidden; }
.sky{ position:absolute; inset:0 0 35% 0; background:linear-gradient(#a5d8ff,#e0f2fe); }
.sun{ position:absolute; top:30px; right:36px; width:70px; height:70px; border-radius:50%; background:#fde047; box-shadow:0 0 40px rgba(253,224,71,.8); opacity:.9; }
.ocean{ position:absolute; left:0; right:0; top:35%; height:40%; background:linear-gradient(#60a5fa,#2563eb); overflow:hidden; }
.wave{ position:absolute; left:-50%; right:-50%; height:40px; background: radial-gradient(circle at 10px -10px, transparent 14px, rgba(255,255,255,.5) 15px) 0 0/20px 20px repeat-x; opacity:.55; animation:drift 10s linear infinite; }
.w1{ bottom:26px; } .w2{ bottom:14px; opacity:.4; animation-duration:13s; } .w3{ bottom:2px; opacity:.35; animation-duration:16s; }
@keyframes drift{ to{ transform:translateX(50%); } }
.beach{ position:absolute; left:0; right:0; bottom:0; height:35%; background:linear-gradient(#fde68a,#f59e0b); box-shadow:0 -10px 30px rgba(0,0,0,.15) inset; }

.animal-box{
  position:absolute; left:50%; transform:translateX(-50%);
  bottom:22%;
  width:clamp(340px, 30vw, 460px);
  height:clamp(300px, 28vw, 420px);
  display:flex; align-items:center; justify-content:center;
  filter: drop-shadow(0 14px 26px rgba(0,0,0,.4));
  cursor:pointer; outline:none;
}
.animal-box.hint::after{
  content:"";
  position:absolute; inset:-10px; border-radius:18px;
  border:2px dashed rgba(255,255,255,.55);
  animation: pulse 1.6s ease-out infinite;
  pointer-events:none;
}
@keyframes pulse{ 0%{opacity:.8;transform:scale(1)} 100%{opacity:0;transform:scale(1.07)} }

.tap-guide{
  position:absolute; top:-58px; left:50%; transform:translateX(-50%);
  display:flex; flex-direction:column; align-items:center; gap:6px;
  pointer-events:none;
}
.tap-label{
  background:#22d3ee; color:#083344; font-weight:900;
  padding:6px 10px; border-radius:999px; box-shadow:0 6px 14px rgba(0,0,0,.25);
}
.arrow-down{
  width:0; height:0;
  border-left:14px solid transparent;
  border-right:14px solid transparent;
  border-top:18px solid #22d3ee;
  animation: arrowBounce 1s ease-in-out infinite;
}
.hand{ font-size:26px; filter: drop-shadow(0 4px 8px rgba(0,0,0,.35)); animation: handWiggle 1.4s ease-in-out infinite; }
@keyframes arrowBounce{ 0%,100%{transform:translateY(0)} 50%{transform:translateY(6px)} }
@keyframes handWiggle{ 0%,100%{transform:rotate(0)} 30%{transform:rotate(-10deg)} 60%{transform:rotate(8deg)} }

.photo,.cartoon-img{ width:100%; height:100%; object-fit:contain; border-radius:14px; image-rendering:auto; }

.pop-enter-from{ transform: translate(-50%, 40%) scale(.85); opacity:0; }
.pop-enter-active{ transition: all .45s cubic-bezier(.2,.9,.2,1); }
.pop-enter-to{ transform: translate(-50%, 0%) scale(1); opacity:1; }
.pop-leave-active{ position:absolute; left:50%; transform:translateX(-50%); }

.bubble{ position:absolute; left:50%; transform:translateX(-50%); bottom:6%;
  width:min(900px, 92%); color:#0f172a; background:#fff; border-radius:14px; padding:14px 16px; box-shadow:0 10px 28px rgba(0,0,0,.28);
}
.bubble::after{ content:""; position:absolute; bottom:-10px; width:18px; height:18px; background:#fff; rotate:45deg; left: var(--arrow-left, 50%); transform: translateX(-50%); box-shadow: 4px 4px 10px rgba(0,0,0,.08); }
.bubble-title{ font-weight:900; margin-bottom:6px; }
.bubble ul{ margin:0; padding-left:18px; line-height:1.55; }

.info-overlay{ position:fixed; inset:0; background:rgba(0,0,0,.45); display:flex; align-items:center; justify-content:center; padding:24px; z-index:50; }
.info-card{
  width:min(1100px, 98vw);
  max-height:min(92vh, 1200px);
  overflow:auto; background:#2e7d32; border:16px solid #f2c64d; border-radius:16px;
  box-shadow:0 20px 60px rgba(0,0,0,.45); color:#fff;
}
.info-close{ position:sticky; top:0; right:0; float:right; margin:10px; width:36px; height:36px; border-radius:999px; border:none; background:#00000033; color:#fff; font-weight:900; cursor:pointer; }
.info-head{ display:flex; align-items:center; gap:18px; padding:10px 18px 0 18px; }
.info-title .eyebrow{ font-size:12px; letter-spacing:.12em; opacity:.85; text-transform:uppercase; }
.info-title .cn{ margin:.1em 0 .2em; font-size: clamp(22px, 3.6vw, 30px); font-weight:900; }
.info-title .latin{ opacity:.95; }
.info-avatar{ width:140px; height:140px; border-radius:999px; object-fit:cover; border:6px solid #1b5e20; box-shadow:0 6px 18px rgba(0,0,0,.35); }
.info-grid{ padding:12px 18px 18px; display:grid; gap:12px; }
.row{ display:flex; gap:12px; align-items:flex-start; }
.k{ min-width:11.5em; color:#f2c64d; font-weight:900; letter-spacing:.12em; text-transform:uppercase; }
.v{ flex:1; }
.bullets{ margin:0; padding-left:18px; }

.visually-hidden{ position:absolute !important; width:1px; height:1px; overflow:hidden; clip:rect(1px,1px,1px,1px); white-space:nowrap; }

@media (max-width: 720px){
  .chip{ min-width:170px; }
  .avatar{ width:48px; height:48px; }
  .stage{ height:520px; }
  .animal-box{ width:min(70vw, 300px); height:min(60vw, 260px); }
  .info-avatar{ width:110px; height:110px; }
  .k{ min-width:9em; }
}
</style>
