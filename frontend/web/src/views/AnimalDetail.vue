<template>
  <main class="detail" :style="{ background: heroBg }">
    <div class="wrap" v-if="a">
      <RouterLink to="/animals" class="back">← Back</RouterLink>

      <h1 class="title">{{ a.name }}</h1>

      <div class="glass intro-card">
        <p class="intro">{{ a.intro }}</p>
      </div>

      <section class="facts glass">
        <div class="facts-inner">
          <ul class="kv">
            <li><span>COMMON NAME:</span> {{ a.name }}</li>
            <li v-if="a.scientific"><span>SCIENTIFIC NAME:</span> {{ a.scientific }}</li>
            <li v-if="a.group"><span>GROUP:</span> {{ a.group }}</li>
            <li v-if="a.type"><span>TYPE:</span> {{ a.type }}</li>
            <li v-if="a.size"><span>SIZE:</span> {{ a.size }}</li>
            <li v-if="a.diet"><span>DIET:</span> {{ a.diet }}</li>
            <li v-if="a.status"><span>STATUS:</span> {{ a.status }}</li>
          </ul>

          <div class="circle">
            <img :src="a.src" :alt="a.name" @error="onImgError" />
          </div>
        </div>
      </section>

      <section class="cards">
        <article class="card-block glass">
          <h2>Meet the {{ a.name }}</h2>
          <p>{{ a.story }}</p>
        </article>

        <article class="card-block glass">
          <h2>Why they matter</h2>
          <p>{{ a.why }}</p>
        </article>

        <article class="card-block glass">
          <h2>How pollution hurts them</h2>
          <ul class="bullets">
            <li v-for="t in a.threats" :key="t">{{ t }}</li>
          </ul>
        </article>

        <article class="card-block glass">
          <h2>How you can help</h2>
          <ul class="bullets">
            <li v-for="h in a.help" :key="h">{{ h }}</li>
          </ul>
        </article>
      </section>
    </div>

    <div class="wrap" v-else>
      <RouterLink to="/animals" class="back">← Back</RouterLink>
      <div class="glass intro-card"><p>Sorry, we couldn't find that animal.</p></div>
    </div>
  </main>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

// ---- Assets (Supabase) ----
const CDN = 'https://gvwrmcyksmswvduehrtd.supabase.co/storage/v1/object/public'
const BUCKET = 'bluetrails'
const PRIMARY_DIR = 'animal-page'
const FALLBACK_DIR = 'animal%20page' // 兼容空格目录

const heroBg =
  `linear-gradient(180deg, rgba(0,0,0,.55) 0%, rgba(0,0,0,.35) 33%, rgba(0,0,0,.20) 100%), ` +
  `url('${CDN}/${BUCKET}/hero/background.jpg') center/cover fixed no-repeat`

const base = `${CDN}/${BUCKET}/${PRIMARY_DIR}`

// ---- Victoria (AU) species ----
const DATA = [
  {
    slug: 'burrunan-dolphin',
    name: 'Burrunan Dolphin',
    scientific: 'Tursiops australis',
    group: 'Mammals',
    type: 'Marine mammal',
    size: 'Up to ~2.7 m',
    diet: 'Fish, squid',
    status: 'Endangered in Victoria',
    src: `${base}/burranan.png`,
    intro: 'The Burrunan Dolphin is a coastal dolphin found in parts of Victoria, including Port Phillip and Gippsland Lakes.',
    story: 'They live in small, social groups and communicate with whistles and clicks. Burrunan Dolphins were only recognised as a distinct species in recent years.',
    why: 'As top predators, they help keep fish populations balanced and indicate the health of our bays.',
    threats: [
      'Pollution and litter (especially plastics) in bays',
      'Boat strikes and noise disturbance',
      'Entanglement in fishing gear'
    ],
    help: [
      'Dispose of fishing line and rubbish properly',
      'Slow down around dolphins; keep distance when boating',
      'Support bay clean-ups and report entanglements'
    ]
  },
  {
    slug: 'southern-right-whale',
    name: 'Southern Right Whale',
    scientific: 'Eubalaena australis',
    group: 'Mammals',
    type: 'Marine mammal',
    size: 'Up to ~15 m',
    diet: 'Tiny crustaceans (krill)',
    status: 'Endangered (recovering)',
    src: `${base}/Southern-Right-Whale.jpg`,
    intro: 'Southern Right Whales visit Victoria’s coast in winter to calve and rest near sheltered shores.',
    story: 'They are slow swimmers with calloused patches on the head (callosities) that make each whale unique.',
    why: 'Whales move nutrients through the ocean and draw people to value and protect the coast.',
    threats: [
      'Entanglement in ropes and nets',
      'Ship strikes and underwater noise',
      'Pollution and climate change affecting food'
    ],
    help: [
      'Support whale-safe fishing practices',
      'Keep a safe distance from whales (follow rules)',
      'Choose products and actions that reduce ocean pollution'
    ]
  },
  {
    slug: 'australian-fur-seal',
    name: 'Australian Fur Seal',
    scientific: 'Arctocephalus pusillus doriferus',
    group: 'Mammals',
    type: 'Marine mammal',
    size: '1.5–2.3 m',
    diet: 'Fish, squid',
    status: 'Protected in Victoria (recovering)',
    src: `${base}/Australian-Fur-Seal.jpg`,
    intro: 'Our most common local seal, with big colonies on Bass Strait islands.',
    story: 'They are powerful swimmers and rest together on rocky haul-outs.',
    why: 'Seals are important predators and help show the health of marine food webs.',
    threats: [
      'Entanglement in lost rope, straps and nets',
      'Plastic pollution on haul-out sites',
      'Disturbance at breeding colonies'
    ],
    help: [
      'Cut loops in rubbish; never leave rope or straps',
      'Give seals space on shore and never feed them',
      'Join or support marine debris clean-ups'
    ]
  },
  {
    slug: 'little-penguin',
    name: 'Little Penguin',
    scientific: 'Eudyptula minor',
    group: 'Birds',
    type: 'Seabird',
    size: '~30–33 cm',
    diet: 'Small fish, squid',
    status: 'Protected (locally managed)',
    src: `${base}/little-penguin.jpg`,
    intro: 'The world’s smallest penguin, famous at Phillip Island and in some urban colonies.',
    story: 'They nest in burrows and return at dusk in the “penguin parade”.',
    why: 'Penguins connect people to wildlife and need clean near-shore waters.',
    threats: [
      'Plastic and oil pollution',
      'Dogs and foxes near nesting areas',
      'Fishing hooks and line'
    ],
    help: [
      'Keep dogs away from nesting beaches',
      'Take litter home; reduce single-use plastic',
      'Report injured wildlife to local carers'
    ]
  },
  {
    slug: 'weedy-seadragon',
    name: 'Weedy Seadragon',
    scientific: 'Phyllopteryx taeniolatus',
    group: 'Fish',
    type: 'Reef fish (seahorse family)',
    size: 'Up to ~45 cm',
    diet: 'Tiny crustaceans',
    status: 'Protected in Victoria',
    src: `${base}/Weedy-seadragon.jpg`,
    intro: 'Victoria’s marine emblem, found on kelp and reef along the coast.',
    story: 'Males carry the eggs under their tail until they hatch—sea-horse style!',
    why: 'Healthy seadragons mean healthy kelp forests and reefs.',
    threats: [
      'Habitat loss from storms and warming seas',
      'Pollution and sediment smothering kelp',
      'Illegal collection'
    ],
    help: [
      'Avoid trampling reefs; dive and snorkel carefully',
      'Reduce runoff (keep drains clear, pick up litter)',
      'Support reef-care and restoration projects'
    ]
  },
  {
    slug: 'australian-fairy-tern',
    name: 'Australian Fairy Tern',
    scientific: 'Sternula nereis nereis',
    group: 'Birds',
    type: 'Seabird',
    size: '~22–25 cm',
    diet: 'Small fish',
    status: 'Endangered in Victoria',
    src: `${base}/Australian-Fairy-Tern.jpg`,
    intro: 'A tiny coastal tern that nests on open sandy spits and islands.',
    story: 'They hover and dive for fish in shallow, clear water.',
    why: 'Fairy terns need quiet, clean beaches—protecting them protects shorelines.',
    threats: [
      'Disturbance at nesting sites (people, dogs, vehicles)',
      'Predation by foxes and cats',
      'Beach litter and plastics'
    ],
    help: [
      'Obey seasonal beach closures and keep dogs leashed',
      'Bin rubbish and help remove plastics',
      'Support local shorebird monitoring'
    ]
  },
  {
    slug: 'hooded-plover',
    name: 'Hooded Plover (Vic)',
    scientific: 'Thinornis cucullatus',
    group: 'Birds',
    type: 'Shorebird',
    size: '~20 cm',
    diet: 'Small invertebrates',
    status: 'Vulnerable in Victoria',
    src: `${base}/Larissa-Hill-Hooded-Plover.jpg`,
    intro: 'This beach-nesting bird lays eggs right on the sand above the surf.',
    story: 'Chicks are tiny and rely on camouflage; they run to feed at the water’s edge.',
    why: 'They signal the health of our surf beaches and dune systems.',
    threats: [
      'People and dogs disturbing nests',
      'Vehicles on beaches crushing eggs',
      'Rubbish attracting predators'
    ],
    help: [
      'Respect fencing and signs; give nesting birds space',
      'Leash dogs on beaches; avoid driving on sand',
      'Take your litter home'
    ]
  },
  {
    slug: 'short-tailed-shearwater',
    name: 'Short-tailed Shearwater',
    scientific: 'Ardenna tenuirostris',
    group: 'Birds',
    type: 'Seabird',
    size: '~40–45 cm',
    diet: 'Krill, small fish',
    status: 'Protected (millions migrate through Vic)',
    src: `${base}/Short-tailed-Shearwater.jpg`,
    intro: 'Also called “muttonbirds”, they migrate from the Arctic to nest on Bass Strait islands.',
    story: 'Chicks grow in burrows; adults travel incredible distances across the ocean.',
    why: 'Mass migrations show how connected oceans are—and why clean seas matter.',
    threats: [
      'Plastic ingestion at sea',
      'Light pollution disorienting fledglings',
      'Oil spills and bycatch'
    ],
    help: [
      'Reduce night lighting near colonies during fledging',
      'Cut plastic use and join clean-ups',
      'Choose seafood from responsible fisheries'
    ]
  }
]

// 根据路由找到物种
const a = computed(() => DATA.find(x => x.slug === useRoute().params.id))

// 图片兜底：目录名切换 + 扩展名互换
function onImgError(e) {
  const img = e.target
  const src = img.getAttribute('src') || ''

  // 1) 先在 jpg / png 之间互换一次
  if (!img.dataset.extSwapped) {
    img.dataset.extSwapped = '1'
    if (/\.jpe?g$/i.test(src)) { img.src = src.replace(/\.jpe?g$/i, '.png'); return }
    if (/\.png$/i.test(src))   { img.src = src.replace(/\.png$/i,   '.jpg'); return }
  }

  // 2) 目录名兜底（animal-page -> animal%20page）
  if (!img.dataset.dirSwapped && src.includes(`/${PRIMARY_DIR}/`)) {
    img.dataset.dirSwapped = '1'
    img.src = src.replace(`/${PRIMARY_DIR}/`, `/${FALLBACK_DIR}/`)
  }
}
</script>

<style scoped>
.detail{
  min-height:100vh;
  padding-top:var(--nav-h);
  padding-bottom:56px;
  color:#f6f7fb;
}

.wrap{
  max-width:980px;
  margin:0 auto;
  padding:0 20px;
}

.back{
  display:inline-block; margin:18px 0 10px;
  color:#fff; text-decoration:none; font-weight:700;
  background: rgba(255,255,255,.14);
  padding:8px 12px; border-radius:12px;
  backdrop-filter: blur(4px);
  border:1px solid rgba(255,255,255,.18);
}

.title{
  font-size: clamp(30px, 6vw, 46px);
  line-height:1.1; margin:.2em 0 .35em;
  text-shadow: 0 8px 30px rgba(0,0,0,.5), 0 2px 10px rgba(0,0,0,.35);
}

.glass{
  background: rgba(17, 25, 40, .55);
  border: 1px solid rgba(255,255,255,.14);
  border-radius: 14px;
  box-shadow: 0 10px 30px rgba(0,0,0,.35);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
}

.intro-card{
  padding:16px 18px;
  margin-bottom:18px;
}
.intro{
  font-size:18px; line-height:1.65;
}

.facts{ margin:18px 0 24px; padding:0; }
.facts-inner{
  position:relative;
  background:#3f8f2e;
  border-radius:12px;
  padding:18px 18px;
  color:#fff;
  box-shadow: inset 0 1px 0 rgba(255,255,255,.06);
}
.kv{ list-style:none; padding:0; margin:0; }
.kv li{
  padding:10px 0;
  border-bottom:1px solid rgba(255,255,255,.22);
  font-size:15px;
}
.kv li:last-child{ border-bottom:none; }
.kv span{
  color:#ffe066; font-weight:800; letter-spacing:.02em; margin-right:8px;
}

.circle{
  position:absolute; right:16px; top:16px;
  width:120px; height:120px; border-radius:50%;
  overflow:hidden; border:4px solid #fff;
  box-shadow:0 8px 16px rgba(0,0,0,.35);
}
.circle img{ width:100%; height:100%; object-fit:cover; }

.cards{
  display:grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap:18px;
}
.card-block{ padding:18px; }
.card-block h2{
  margin:4px 0 10px;
  font-size:22px; font-weight:900;
  text-shadow: 0 2px 8px rgba(0,0,0,.35);
}
.card-block p, .card-block li{
  line-height:1.75;
}
.bullets{ margin:0; padding-left:1.1em; }

@media (max-width: 780px){
  .cards{ grid-template-columns: 1fr; }
  .circle{ position:static; margin:12px auto 0; }
  .facts-inner{ padding-bottom:12px; }
}
</style>
