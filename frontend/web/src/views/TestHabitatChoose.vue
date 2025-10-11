<!-- src/views/TestHabitatChoose.vue -->
<template>
  <main class="page">
    <section class="header glass">
      <img :src="avatar" :alt="animalName" class="avatar" />
      <div class="title">
        <div class="eyebrow">Choose a site for</div>
        <h2>{{ animalName }}</h2>
      </div>
    </section>

    <section class="empty" v-if="sites.length === 0">
      No sites found for this animal (yet).
    </section>

    <section class="sites" v-else>
      <button
        v-for="s in sites"
        :key="s.site_id"
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
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()
const slug = String(route.params.slug || '')

// ---- 你的静态站点数据（按动物 slug 映射）----
const LAKES_ALL = [
  'Lake King North','Lake King South','Lake Reeve East','Lake Reeve West',
  'Lake Victoria','Lake Wellington','Shaving Point'
]
const LAKES_EAST_WEST = ['Lake Reeve East','Lake Reeve West']
const LAKES_EAST_WEST_WELLINGTON = ['Lake Reeve East','Lake Reeve West','Lake Wellington']

const PPB_ALL = [
  'Central','Corio','DMG (B)','Dromana','Hobsons Bay','Long Reef',
  'Middle Ground Shelf','Newport','Patterson River','Popes Eye','Sorrento'
]
const PPB_SUB_1 = ['Dromana','Middle Ground Shelf','Popes Eye','Sorrento']
const PPB_SUB_2 = ['Central','Dromana','Middle Ground Shelf','Popes Eye','Sorrento']
const PPB_SUB_3 = ['Dromana','Long Reef','Patterson River']

const WP_2 = ['Barralier Island','Hastings']
const WP_3 = ['Barralier Island','Corinella','Hastings']
const WP_2_COR = ['Barralier Island','Corinella']

const uniq = (arr) => Array.from(new Set(arr))

const SITES_BY_SLUG = {
  'burrunan-dolphin': uniq([...LAKES_ALL, ...PPB_ALL]),
  'southern-right-whale': uniq([...PPB_SUB_1, ...WP_2]),
  'australian-fur-seal': uniq([...LAKES_EAST_WEST, ...PPB_ALL, ...WP_3]),
  'little-penguin': uniq([...PPB_ALL, ...WP_3]),
  'weedy-seadragon': uniq([...PPB_SUB_2, ...WP_2_COR]),
  'australian-fairy-tern': uniq([...LAKES_EAST_WEST_WELLINGTON, ...PPB_SUB_3, ...WP_2]),
  'hooded-plover': uniq([...LAKES_EAST_WEST, 'Corinella']),
  'short-tailed-shearwater': uniq([...LAKES_EAST_WEST, ...PPB_SUB_1, ...WP_2]),
}

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
const toTitle = s => s.replace(/[-_]+/g,' ').replace(/\b\w/g, m => m.toUpperCase())

const list = SITES_BY_SLUG[slug] || []
const sites = computed(() => list.map((name, i) => ({ site_id: i + 1, site_name: name })))
const animalName = computed(() => ANIMAL_NAMES[slug] || toTitle(slug))

// 占位图（按需替换）
const CDN = 'https://gvwrmcyksmswvduehrtd.supabase.co/storage/v1/object/public'
const BUCKET = 'bluetrails'
const DIR = 'animal-page'
const avatar = computed(() => `${CDN}/${BUCKET}/${DIR}/penguin-cartoon.png`)

const pickSite = (site) => {
  router.push({
    name: 'MyOceanHome',          // ✅ 用 name 而不是 path
    query: { site: site.site_name, slug }
  })
}


</script>

<style scoped>
.page{ min-height:100vh; padding-top:var(--nav-h);
  background:linear-gradient(180deg,#87CEEB 0%, #E0F6FF 30%, #40E0D0 55%, #20B2AA 72%, #008B8B 86%, #F4A460 92%, #DEB887 100%);
}
.glass{ background:rgba(255,255,255,.6); border:1px solid rgba(255,255,255,.35);
  border-radius:16px; backdrop-filter:blur(8px); box-shadow:0 12px 30px rgba(0,0,0,.18);
}
.header{ max-width:960px; margin:16px auto 10px; padding:14px 18px; display:flex; align-items:center; gap:12px; }
.avatar{ width:72px; height:72px; object-fit:cover; border-radius:50%; background:#fff; }
.eyebrow{ font-size:12px; text-transform:uppercase; letter-spacing:.12em; opacity:.75; }
.title h2{ margin:.1em 0; }
.empty{ max-width:960px; margin:20px auto; padding:12px 16px; font-weight:700; opacity:.85; }
.sites{ max-width:1000px; margin:0 auto; padding:16px;
  display:grid; grid-template-columns: repeat(auto-fill, minmax(240px,1fr)); gap:14px;
}
.site{ display:grid; grid-template-columns:auto 1fr auto; align-items:center; gap:10px;
  padding:12px 14px; cursor:pointer; text-align:left; transition:transform .12s, box-shadow .12s;
}
.site:hover{ transform:translateY(-2px); box-shadow:0 16px 34px rgba(0,0,0,.22); }
.pin{ font-size:18px; }
.name{ font-weight:800; }
.go{ font-size:12px; opacity:.8; }
</style>
