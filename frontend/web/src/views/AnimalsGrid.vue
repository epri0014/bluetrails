<template>
  <main class="page" :style="{ background: heroBg }" aria-labelledby="title">
    <h1 id="title" class="visually-hidden">Animals at Risk</h1>

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
  { slug: 'sea-turtle',  name: 'Sea Turtles',        file: 'sea-turtle.jpg'  },
  { slug: 'sea-birds',   name: 'Seabirds',           file: 'sea-birds.jpg'   },
  { slug: 'seals',       name: 'Seals & Sea Lions',  file: 'seals.jpg'       },
  { slug: 'dolphins',    name: 'Dolphins',           file: 'dolphins.jpg'    },
  { slug: 'whale',       name: 'Whales',             file: 'whale.jpg'       },
  { slug: 'sea-otters',  name: 'Sea Otters',         file: 'sea-otters.jpg'  },
  { slug: 'coral',       name: 'Coral Reefs',        file: 'Coral.jpg'       }, 
  { slug: 'shark',       name: 'Sharks',             file: 'shark.jpg'       },
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

.wrap{
  max-width:1150px;
  margin:0 auto;
  padding:32px 20px 48px;
}

.grid{
  display:grid;
  grid-template-columns: repeat(auto-fill, minmax(290px, 1fr));
  gap:28px;
}

.card{
  display:flex; flex-direction:column;
  border-radius:10px; overflow:hidden; background:#fff;
  box-shadow:0 6px 16px rgba(0,0,0,.16);
  text-decoration:none; color:#111;
  transition: transform .12s ease, box-shadow .12s ease;
  border:1px solid rgba(0,0,0,.06);
}
.card:hover{ transform: translateY(-4px); box-shadow:0 12px 28px rgba(0,0,0,.22); }
.card:focus-visible{ outline:3px solid #1e90ff; outline-offset:2px; }

.thumb{ width:100%; height:220px; object-fit:cover; display:block; }

.meta{ padding:18px 20px; background:#fff; border-top:1px solid #eee; }
.title{ font-weight:800; font-size:20px; color:#111; margin-bottom:10px; }
.more{ font-size:12px; letter-spacing:.12em; color:#222; opacity:.85; display:flex; align-items:center; gap:8px; text-transform:uppercase; }
.icon{ font-weight:900; }

.card.ph{
  background:
    radial-gradient(100% 100% at 0% 0%, rgba(14,165,233,.22), transparent 50%),
    radial-gradient(100% 100% at 100% 100%, rgba(3,105,161,.22), transparent 40%),
    linear-gradient(135deg, #eaf3ff, #e7edff);
  min-height: 300px;
}

.visually-hidden{
  position:absolute !important; width:1px; height:1px; overflow:hidden;
  clip:rect(1px,1px,1px,1px); white-space:nowrap;
}
</style>
