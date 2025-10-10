<!-- src/views/HabitatChoose.vue -->
<template>
  <main class="page">
    <section class="header glass" v-if="animal">
      <img :src="avatar" :alt="animal.name" class="avatar" />
      <div class="title">
        <div class="eyebrow">Choose a site for</div>
        <h2>{{ animal.name }}</h2>
      </div>
    </section>

    <section class="empty" v-if="!loading && sites.length === 0">
      No sites found for this animal (yet).
    </section>

    <section class="sites" v-else>
      <button
        v-for="s in sites"
        :key="s.site_id || s.site_name"
        class="site glass"
        @click="pickSite(s)"
      >
        <div class="pin">📍</div>
        <div class="name">{{ s.site_name }}</div>
        <div class="go">Pick</div>
      </button>
    </section>
  </main>
</template>

<script setup>
import { onMounted, ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getAnimalBySlug, getHabitatsByAnimal} from '@/services/api'

const route = useRoute()
const router = useRouter()
const slug = route.params.slug

const animal = ref(null)
const sites = ref([])
const loading = ref(false)

// 你们的存图 CDN（和上个页面保持一致）
const CDN = 'https://gvwrmcyksmswvduehrtd.supabase.co/storage/v1/object/public'
const BUCKET = 'bluetrails'
const DIR = 'animal-page'

const avatar = computed(() => {
  if (!animal.value) return ''
  const a = animal.value
  if (a?.cartoon?.startsWith('http')) return a.cartoon
  const fallback = a?.cartoon || a?.file || 'penguin-cartoon.png'
  return `${CDN}/${BUCKET}/${DIR}/${fallback}`
})

onMounted(async () => {
  loading.value = true
  try {
    animal.value = await getAnimalBySlug(slug, 'en')
    sites.value = await getHabitatsByAnimal(slug, 'en')
  } finally {
    loading.value = false
  }
})

const pickSite = (site) => {
  // TODO: 孩子选了站点后的逻辑（示例跳到 /water?site=xxx）
  router.push({ path: '/water', query: { site: site.site_name, slug } })
}
</script>

<style scoped>
.page{
  min-height:100vh;
  padding-top:var(--nav-h);
  background: linear-gradient(180deg,#87CEEB 0%, #E0F6FF 30%, #40E0D0 55%, #20B2AA 72%, #008B8B 86%, #F4A460 92%, #DEB887 100%);
}

.glass{
  background: rgba(255,255,255,.6);
  border:1px solid rgba(255,255,255,.35);
  border-radius:16px;
  backdrop-filter: blur(8px);
  box-shadow:0 12px 30px rgba(0,0,0,.18);
}

.header{
  max-width:960px; margin:16px auto 10px; padding:14px 18px;
  display:flex; align-items:center; gap:12px;
}
.avatar{ width:72px; height:72px; object-fit:cover; border-radius:50%; background:#fff; }
.eyebrow{ font-size:12px; text-transform:uppercase; letter-spacing:.12em; opacity:.75; }
.title h2{ margin:.1em 0; }

.empty{
  max-width:960px; margin:20px auto; padding:12px 16px; font-weight:700; opacity:.85;
}

.sites{
  max-width:1000px; margin:0 auto; padding:16px;
  display:grid; grid-template-columns: repeat(auto-fill, minmax(240px,1fr)); gap:14px;
}
.site{
  display:grid; grid-template-columns: auto 1fr auto; align-items:center; gap:10px;
  padding:12px 14px; cursor:pointer; text-align:left;
  transition: transform .12s ease, box-shadow .12s ease;
}
.site:hover{ transform: translateY(-2px); box-shadow:0 16px 34px rgba(0,0,0,.22); }
.pin{ font-size:18px; }
.name{ font-weight:800; }
.go{ font-size:12px; opacity:.8; }
</style>
