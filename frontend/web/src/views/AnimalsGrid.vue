<template>
  <main class="page" :style="{ background: heroBg }" aria-labelledby="title">
    <h1 id="title" class="visually-hidden">Animals at Risk</h1>

    <!-- Intro banner -->
    <section class="wrap">
      <div class="intro glass" role="note" aria-label="About these animals">
        <div class="intro-left">
          <div class="eyebrow">Victoria • Marine Wildlife</div>
          <h2 class="intro-title">Animals at Risk in VIC</h2>
          <p class="intro-text">
            These are coastal and marine animals found in Victoria that can be harmed by ocean
            pollution. Tap a card to learn what hurts them and how kids can help keep our seas safe. 🌊🐧
          </p>
        </div>
        <div class="intro-right">
          <span class="pill">VIC</span>
        </div>
      </div>
    </section>

    <!-- Cards -->
    <section class="wrap">
      <div class="grid" role="list">
        <RouterLink
          v-for="a in animals"
          :key="a.slug"
          class="card"
          role="listitem"
          :to="`/animals/${a.slug}`"
          :aria-label="`Learn about ${a.name}`"
        >
          <img
            class="thumb"
            :src="imgSrc(a.file)"
            :alt="a.name"
            loading="lazy"
            @error="onImgError"
          />
          <figcaption class="meta">
            <div class="title">{{ a.name }}</div>
            <div class="more"><span class="icon">≡</span> SEE MORE</div>
          </figcaption>
        </RouterLink>
      </div>
    </section>
  </main>
</template>

<script setup>
const CDN = 'https://gvwrmcyksmswvduehrtd.supabase.co/storage/v1/object/public'
const BUCKET = 'bluetrails'

const heroBg =
  `linear-gradient(180deg, rgba(0,0,0,.55) 0%, rgba(0,0,0,.35) 33%, rgba(0,0,0,.20) 100%), ` +
  `url('${CDN}/${BUCKET}/hero/background.jpg') center/cover fixed no-repeat`

const PRIMARY_DIR = 'animal-page'
const FALLBACK_DIR = 'animal%20page'

const animals = [
  { slug: 'burrunan-dolphin',     name: 'Burrunan Dolphin',         file: 'burranan.png' },
  { slug: 'southern-right-whale', name: 'Southern Right Whale',     file: 'Southern-Right-Whale.jpg' },
  { slug: 'australian-fur-seal',  name: 'Australian Fur Seal',      file: 'Australian-Fur-Seal.jpg' },
  { slug: 'little-penguin',       name: 'Little Penguin',           file: 'little-penguin.jpg' },
  { slug: 'weedy-seadragon',      name: 'Weedy Seadragon',          file: 'Weedy-seadragon.jpg' },
  { slug: 'australian-fairy-tern',name: 'Australian Fairy Tern',    file: 'Australian-Fairy-Tern.jpg' },
  { slug: 'hooded-plover',        name: 'Hooded Plover (Vic)',      file: 'Larissa-Hill-Hooded-Plover.jpg' },
  { slug: 'short-tailed-shearwater', name: 'Short-tailed Shearwater', file: 'Short-tailed-Shearwater.jpg' },
]

const imgSrc = (file) => `${CDN}/${BUCKET}/${PRIMARY_DIR}/${file}`
function onImgError(e) {
  const img = e.target
  const src = img.getAttribute('src') || ''
  if (src.includes(`/${PRIMARY_DIR}/`)) {
    img.src = src.replace(`/${PRIMARY_DIR}/`, `/${FALLBACK_DIR}/`)
  } else {
    const card = img.closest('.card')
    if (card) card.classList.add('ph')
    img.style.display = 'none'
  }
}
</script>

<style scoped>
.page{
  min-height:100vh;
  padding-top:var(--nav-h);
  padding-bottom:56px;
  color:#fff;
}

/* ---------- Intro banner ---------- */
.glass{
  background: rgba(17,25,40,.58);
  border: 1px solid rgba(255,255,255,.14);
  border-radius: 14px;
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  box-shadow: 0 10px 30px rgba(0,0,0,.28);
}

.wrap{
  max-width:1150px;
  margin:0 auto;
  padding:18px 20px 0;
}

.intro{
  display:flex;
  align-items:center;
  justify-content:space-between;
  gap:18px;
  padding:16px 18px;
  margin-bottom:16px;
}
.eyebrow{
  font-size:12px;
  letter-spacing:.12em;
  text-transform:uppercase;
  opacity:.8;
}
.intro-title{
  margin:.2em 0 .25em;
  font-size: clamp(20px, 4.2vw, 28px);
  font-weight:900;
  line-height:1.15;
  text-shadow: 0 6px 18px rgba(0,0,0,.45);
}
.intro-text{
  margin:0;
  max-width:700px;
  line-height:1.65;
  color:#e9eef6;
  opacity:.95;
}
.pill{
  display:inline-flex; align-items:center; justify-content:center;
  padding:6px 10px;
  background:#22d3ee; color:#083344; font-weight:900;
  border-radius:999px; letter-spacing:.08em; box-shadow:0 6px 18px rgba(34,211,238,.35);
}

/* ---------- Cards ---------- */
.grid{
  display:grid;
  grid-template-columns: repeat(auto-fill, minmax(290px, 1fr));
  gap:28px;
  margin-top:8px;
}

.card{
  display:flex; flex-direction:column;
  border-radius:12px; overflow:hidden; background:#fff;
  box-shadow:0 6px 16px rgba(0,0,0,.16);
  text-decoration:none; color:#111;
  transition: transform .12s ease, box-shadow .12s ease;
  border:1px solid rgba(0,0,0,.06);
}
.card:hover{ transform: translateY(-4px); box-shadow:0 14px 28px rgba(0,0,0,.22); }
.card:focus-visible{ outline:3px solid #1e90ff; outline-offset:2px; }

.thumb{ width:100%; height:220px; object-fit:cover; display:block; }

.meta{ padding:18px 20px; background:#fff; border-top:1px solid #eee; }
.title{ font-weight:800; font-size:20px; color:#111; margin-bottom:10px; }
.more{ font-size:12px; letter-spacing:.12em; color:#222; opacity:.85; display:flex; align-items:center; gap:8px; text-transform:uppercase; }
.icon{ font-weight:900; }

/* Placeholder when image fails */
.card.ph{
  background:
    radial-gradient(100% 100% at 0% 0%, rgba(14,165,233,.22), transparent 50%),
    radial-gradient(100% 100% at 100% 100%, rgba(3,105,161,.22), transparent 40%),
    linear-gradient(135deg, #eaf3ff, #e7edff);
  min-height: 300px;
}

/* A11y helper */
.visually-hidden{
  position:absolute !important; width:1px; height:1px; overflow:hidden;
  clip:rect(1px,1px,1px,1px); white-space:nowrap;
}

@media (max-width: 720px){
  .intro{ flex-direction:column; align-items:flex-start; }
  .pill{ align-self:flex-start; }
}
</style>
