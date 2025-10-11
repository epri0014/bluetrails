<!-- src/views/MyOceanHome.vue -->
<template>
  <main class="page">
    <section class="header glass">
      <img :src="avatar" :alt="animalName" class="avatar" />
      <div class="title">
        <div class="eyebrow">From {{ animalName }}</div>
        <h2>“This is my home — <span class="site-name">{{ site }}</span>.”</h2>
        <p class="lead">
          Today my home looks like this. Can you tell me:
          <strong>Is my home okay?</strong>
        </p>
      </div>
    </section>

    <section class="cards">
      <article class="card glass" v-for="m in metricsList" :key="m.key">
        <div class="row1">
          <span class="emoji">{{ m.emoji }}</span>
          <h3>{{ m.title }}</h3>
          <span class="chip" :class="m.level">{{ labelOf(m.level) }}</span>
        </div>
        <p class="desc" v-html="m.desc"></p>
        <div class="value">
          <span class="num" v-if="m.value !== null">{{ m.value }}</span>
          <span class="unit" v-if="m.unit">{{ m.unit }}</span>
        </div>
        <details class="tip">
          <summary>Kid tip</summary>
          <p>{{ m.tip }}</p>
        </details>
      </article>
    </section>

    <section class="vote glass">
      <div class="q">What do you think about my home today?</div>
      <div class="btns">
        <button class="btn green" @click="vote('good')">🟢 Good</button>
        <button class="btn yellow" @click="vote('ok')">🟡 So-so</button>
        <button class="btn red" @click="vote('bad')">🔴 Not good</button>
      </div>
      <p class="thanks" v-if="picked">
        Thanks, Ocean Friend! You said: <strong>{{ labelOf(picked) }}</strong>.
      </p>
    </section>
  </main>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const site = String(route.query.site || 'My Beach')
const slug = String(route.query.slug || 'little-penguin')

onMounted(() => {
  console.log('[MyOceanHome] mounted with', { site, slug })
})

const ANIMAL_NAMES = {
  'burrunan-dolphin': 'Burrunan Dolphin',
  'southern-right-whale': 'Southern Right Whale',
  'australian-fur-seal': 'Australian Fur Seal',
  'little-penguin': 'Little Penguin',
  'weedy-seadragon': 'Weedy Seadragon',
  'australian-fairy-tern': 'Australian Fairy Tern',
  'hooded-plover': 'Hooded Plover (Vic)',
  'short-tailed-shearwater': 'Short-tailed Shearwater',
}
const animalName = computed(() => ANIMAL_NAMES[slug] || slug)

const CDN = 'https://gvwrmcyksmswvduehrtd.supabase.co/storage/v1/object/public'
const avatar = computed(() => `${CDN}/bluetrails/animal-page/penguin-cartoon.png`)

// —— 生成稳定的假数据（基于 site+slug）——
const seed = (site + '|' + slug).split('').reduce((a, c) => (a * 131 + c.charCodeAt(0)) >>> 0, 0)
const pick = (arr, mod = arr.length) => arr[seed % mod]

const algaeLevel    = pick(['ok','good','bad','ok','good','ok'])
const clarityLevel  = pick(['good','ok','bad','good','ok','good'], 6)
const oxygenLevel   = pick(['good','good','ok','bad','ok','good'], 6)
const nutrientLevel = pick(['ok','bad','ok','good','ok','ok'], 6)
const tempLevel     = pick(['good','ok','bad','ok','good','ok'], 6)

function valFor(level, kind) {
  switch (kind) {
    case 'oxygen':   return level === 'good' ? 7.2 : level === 'ok' ? 5.8 : 4.1
    case 'temp':     return level === 'good' ? 20  : level === 'ok' ? 25  : 29
    case 'clarity':  return level === 'good' ? 80  : level === 'ok' ? 50  : 25
    case 'algae':    return level === 'good' ? 1   : level === 'ok' ? 2   : 4
    case 'nutrient': return level === 'good' ? 1   : level === 'ok' ? 2   : 3
    default: return null
  }
}

const metricsList = computed(() => ([
  { key:'algae', title:'Algae', emoji:'🪴', level:algaeLevel, value:valFor(algaeLevel,'algae'), unit:'', 
    desc:`Algae are tiny plants. A little is okay — too much makes fish tired.`,
    tip:`Rain can wash food into water and grow algae fast.` },
  { key:'clarity', title:'Clarity', emoji:'👀', level:clarityLevel, value:valFor(clarityLevel,'clarity'), unit:' /100',
    desc:`Clear like a window is best. Cloudy like lemonade — look first.`,
    tip:`If you can see toes in shallow water, clarity is happier.` },
  { key:'oxygen', title:'Oxygen', emoji:'🫧', level:oxygenLevel, value:valFor(oxygenLevel,'oxygen'), unit:' mg/L',
    desc:`More bubbles means happier sea life — around <b>6 mg/L+</b> is strong.`,
    tip:`Waves and plants add bubbles for me and my friends.` },
  { key:'nutrients', title:'Food for water (nutrients)', emoji:'🍽️', level:nutrientLevel, value:valFor(nutrientLevel,'nutrient'), unit:'',
    desc:`After rain there can be extra food that grows algae fast.`,
    tip:`Less litter & dog poo means cleaner water.` },
  { key:'temperature', title:'Temperature', emoji:'🌡️', level:tempLevel, value:valFor(tempLevel,'temp'), unit:' °C',
    desc:`Cool is comfy. Very warm water makes animals sleepy — take short dips.`,
    tip:`Shade, wind and tides can change temperature.` },
]))

function labelOf(level) {
  return level === 'good' ? 'Good' : level === 'ok' ? 'So-so' : 'Not good'
}

const picked = ref('')
function vote(level) {
  picked.value = level
  localStorage.setItem(`vote:${slug}:${site}`, level)
}
</script>

<style scoped>
.page{ min-height:100vh; padding-top:var(--nav-h);
  background:linear-gradient(180deg,#87CEEB 0%, #E0F6FF 30%, #40E0D0 55%, #20B2AA 72%, #008B8B 86%, #F4A460 92%, #DEB887 100%);
}
.glass{ background:rgba(255,255,255,.6); border:1px solid rgba(255,255,255,.35);
  border-radius:16px; backdrop-filter:blur(8px); box-shadow:0 12px 30px rgba(0,0,0,.18);
}
.header{ max-width:1100px; margin:16px auto 10px; padding:14px 18px; display:flex; gap:14px; align-items:center;}
.avatar{ width:72px; height:72px; border-radius:50%; object-fit:cover; background:#fff;}
.eyebrow{ font-size:12px; text-transform:uppercase; letter-spacing:.12em; opacity:.75;}
.title h2{ margin:.1em 0;}
.site-name{ text-decoration:underline; }

.cards{ max-width:1100px; margin:12px auto; padding:8px; display:grid; gap:14px;
  grid-template-columns: repeat(auto-fill, minmax(260px,1fr));
}
.card{ padding:14px 16px; }
.row1{ display:grid; grid-template-columns:auto 1fr auto; align-items:center; gap:10px; }
.emoji{ font-size:20px; }
.chip{ font-size:12px; padding:3px 8px; border-radius:999px; border:1px solid rgba(0,0,0,.1);}
.chip.good{ background:#e8f7ec; border-color:#b6e5c3; }
.chip.ok{ background:#fff7e2; border-color:#f2d189; }
.chip.bad{ background:#ffe8e6; border-color:#f1b0ad; }
.desc{ margin:.3rem 0 .6rem; opacity:.9; }
.value{ font-weight:800; font-size:20px; }
.value .unit{ font-weight:600; font-size:14px; margin-left:4px; opacity:.8; }

.vote{ max-width:1100px; margin:10px auto 30px; padding:14px 16px; text-align:center;}
.vote .q{ font-weight:800; margin-bottom:10px;}
.btns{ display:flex; gap:10px; justify-content:center; flex-wrap:wrap;}
.btn{ border-radius:999px; padding:10px 16px; font-weight:800; border:0; cursor:pointer; box-shadow:0 10px 22px rgba(0,0,0,.15); }
.btn.green{ background:#1ec28b; color:#fff; }
.btn.yellow{ background:#f0c145; color:#222; }
.btn.red{ background:#e45b5b; color:#fff; }
.thanks{ margin-top:10px; font-weight:700; }
</style>
