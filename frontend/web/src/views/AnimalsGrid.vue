<template>
  <main class="page" aria-labelledby="title">
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
          <img class="thumb" :src="a.src" :alt="a.name" loading="lazy" @error="onImgError" />
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
const base = '/animal-page'
const animals = [
  { slug: 'sea-turtle',  name: 'Sea Turtles',        src: `${base}/sea-turtle.jpg` },
  { slug: 'sea-birds',   name: 'Seabirds',           src: `${base}/sea-birds.jpg` },
  { slug: 'seals',       name: 'Seals & Sea Lions',  src: `${base}/seals.jpg` },
  { slug: 'dolphins',    name: 'Dolphins',           src: `${base}/dolphins.jpg` },
  { slug: 'whale',       name: 'Whales',             src: `${base}/whale.jpg` },
  { slug: 'sea-otters',  name: 'Sea Otters',         src: `${base}/sea-otters.jpg` },
  { slug: 'coral',       name: 'Coral Reefs',        src: `${base}/Coral.jpg` },    // 注意 C 大写
  { slug: 'shark',       name: 'Sharks',             src: `${base}/shark.jpg` },
]

function onImgError(e) {
  const img = e.target
  const card = img.closest('.card')
  img.style.display = 'none'
  card.classList.add('ph')
}
</script>

<style scoped>
.page{
  min-height:100vh;
  padding-top:var(--nav-h);
  padding-bottom:48px;
  background-image:
    linear-gradient(180deg, rgba(0,0,0,.40), rgba(0,0,0,.20)),
    url('/hero/background.jpg');
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
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
  border-radius:8px; overflow:hidden; background:#fff;
  box-shadow:0 4px 14px rgba(0,0,0,.12);
  text-decoration:none; color:#111;
  transition: transform .12s ease, box-shadow .12s ease;
}
.card:hover{ transform: translateY(-4px); box-shadow:0 10px 24px rgba(0,0,0,.18); }
.card:focus-visible{ outline:3px solid #1e90ff; outline-offset:2px; }

.thumb{ width:100%; height:220px; object-fit:cover; display:block; }

.meta{ padding:18px 20px; background:#fff; border-top:1px solid #eee; }
.title{ font-weight:700; font-size:20px; margin-bottom:10px; }
.more{ font-size:12px; letter-spacing:.12em; color:#111; opacity:.75; display:flex; align-items:center; gap:8px; text-transform:uppercase; }
.icon{ font-weight:900; }

.card.ph{
  background:
    radial-gradient(100% 100% at 0% 0%, rgba(14,165,233,.22), transparent 50%),
    radial-gradient(100% 100% at 100% 100%, rgba(3,105,161,.22), transparent 40%),
    linear-gradient(135deg, #e2f3ff, #dfe7ff);
  min-height: 300px;
}

.visually-hidden{
  position:absolute !important; width:1px; height:1px; overflow:hidden;
  clip:rect(1px,1px,1px,1px); white-space:nowrap;
}
</style>