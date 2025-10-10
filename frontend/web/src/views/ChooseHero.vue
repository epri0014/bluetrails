<template>
  <main class="choose-page">
    <section class="intro glass">
      <h2>🌊 Choose your hero!</h2>
      <p>Each of us lives in Port Phillip Bay. Let’s check how healthy our home is today.</p>
    </section>

    <section class="grid">
      <div
        v-for="a in animals"
        :key="a.slug"
        class="card"
        @click="goToHabitat(a.slug)"
      >
        <div class="img-wrap">
          <img :src="a.cartoon" :alt="a.name" />
        </div>
        <h3 class="name">{{ a.name }}</h3>
        <p class="hint">Tap to choose</p>
      </div>
    </section>
  </main>
</template>

<script setup>
import { useRouter } from 'vue-router'
const CDN = 'https://gvwrmcyksmswvduehrtd.supabase.co/storage/v1/object/public'
const BUCKET = 'bluetrails'
const DIR = 'animal-page'
const src = (file) => `${CDN}/${BUCKET}/${DIR}/${file}`

const animals = [
  { slug:'burrunan-dolphin',      name:'Burrunan Dolphin',       cartoon: src('dolphin-cartoon.png') },
  { slug:'southern-right-whale',  name:'Southern Right Whale',   cartoon: src('whale-cartoon.png') },
  { slug:'australian-fur-seal',   name:'Australian Fur Seal',    cartoon: src('seal-cartoon.png') },
  { slug:'little-penguin',        name:'Little Penguin',         cartoon: src('penguin-cartoon.png') },
  { slug:'weedy-seadragon',       name:'Weedy Seadragon',        cartoon: src('seadragon-cartoon.png') },
  { slug:'australian-fairy-tern', name:'Australian Fairy Tern',  cartoon: src('tern-cartoon.png') },
  { slug:'hooded-plover',         name:'Hooded Plover (Vic)',    cartoon: src('pover-cartoon.png') },
  { slug:'short-tailed-shearwater', name:'Short-tailed Shearwater', cartoon: src('shearwater.png') },
]

const router = useRouter()
const goToHabitat = (slug) => {
  router.push(`/choose/${slug}`)
}
</script>

<style scoped>
.choose-page{
  min-height:100vh;
  padding: calc(var(--nav-h,80px) + 16px) 16px 36px;
  /* 海洋渐变背景 */
  background: linear-gradient(180deg, #a5d8ff 0%, #e0f2fe 25%, #60a5fa 45%, #2563eb 60%, #fde68a 88%, #f59e0b 100%);
}

.glass{
  max-width: 980px; margin: 0 auto 18px;
  background: rgba(255,255,255,.86);
  border: 2px solid rgba(255,255,255,.6);
  border-radius: 16px;
  padding: 16px 18px;
  box-shadow: 0 12px 28px rgba(0,0,0,.18);
  text-align: center;
}

.grid{
  max-width: 1080px; margin: 0 auto;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 18px;
}

.card{
  background: rgba(255,255,255,.92);
  border: 1px solid rgba(0,0,0,.06);
  border-radius: 18px;
  box-shadow: 0 10px 24px rgba(0,0,0,.15);
  padding: 12px;
  cursor: pointer;
  transition: transform .15s ease, box-shadow .15s ease;
}
.card:hover{ transform: translateY(-4px); box-shadow: 0 16px 34px rgba(0,0,0,.2); }

.img-wrap{ aspect-ratio: 4/3; border-radius: 12px; overflow: hidden; background: #e9f3ff; display:grid; place-items:center; }
.img-wrap img{ width:100%; height:100%; object-fit: cover; }

.name{ margin:8px 0 2px; font-weight:900; font-size:16px; color:#0f172a; }
.hint{ margin:0; font-size:12px; color:#0369a1; font-weight:700; }
</style>
