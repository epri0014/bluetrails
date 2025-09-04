<template>
  <main class="page">
    <section class="wrap">
      <!-- Loading overlay -->
      <LoadingOverlay v-if="loading" message="🧩 Loading your ocean heroes..." />

      <!-- Hero header box -->
      <div class="hero-box">
        <h1 class="title">🌊 Choose your hero!</h1>
        <p class="subtitle">
          Each of us lives in Port Phillip Bay. Let’s check how healthy our home is today.
        </p>
      </div>

      <div class="grid">
        <!-- Avatar cards (same as before) -->
        <div
          v-for="a in avatars"
          :key="a.avatar_id"
          class="card avatar-card"
          :class="{ selected: selected?.avatar_id === a.avatar_id }"
          @click="selectAvatar(a)"
        >
          <h2 class="name">{{ a.name }} the {{ a.species }}</h2>
          <img class="avatar-img" :src="a.image_neutral_url" :alt="a.name" />

          <div class="regions">
            <span
              v-for="(r, idx) in a.site_short_name.split(',')"
              :key="idx"
              class="region-pill"
            >
              🌍 {{ r.trim() }}
            </span>
          </div>

          <p class="intro">{{ a.intro }}</p>

          <button
            v-if="selected?.avatar_id === a.avatar_id"
            class="btn adventure-btn"
            @click.stop="goNext"
          >
            👉 Start My Adventure!
          </button>
        </div>
      </div>
    </section>
  </main>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { fetchAvatars } from '../services/api'
import { useStoryStore } from '../store/storyStore'
import LoadingOverlay from '../components/LoadingOverlay.vue'

const router = useRouter()
const store = useStoryStore()

const avatars = ref([])
const selected = ref(null)
const loading = ref(true)

onMounted(async () => {
  try {
    avatars.value = await fetchAvatars()
  } finally {
    loading.value = false
  }
})

function selectAvatar(a) {
  selected.value = a
}

function goNext() {
  const sites = selected.value.sites
  const randomSite = sites[Math.floor(Math.random() * sites.length)]

  store.setAvatar(selected.value)
  store.setSite(randomSite)
  router.push('/health')
}
</script>

<style scoped>
.hero-box {
  background: linear-gradient(135deg, #e0f7ff, #cfefff);
  border: 3px solid #0ea5e9;
  border-radius: 18px;
  padding: 24px 18px;
  margin-bottom: 28px;
  text-align: center;
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.15);
}

.hero-box .title {
  font-size: 2rem;
  font-weight: 900;
  color: #0369a1;
  margin-bottom: 10px;
  text-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
}

.hero-box .subtitle {
  font-size: 16px;
  font-weight: 600;
  color: #1b1b1b;
  max-width: 700px;
  margin: 0 auto;
}

.title, 
.subtitle {
  text-align: center;
}

.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 28px;
}

.avatar-card {
  text-align: center;
  cursor: pointer;
  border: 3px solid transparent;
  border-radius: 18px;
  background: #fff;
  padding: 22px 18px;
  transition: transform 0.2s ease, box-shadow 0.2s ease, border 0.2s ease;
}

.avatar-card:hover {
  transform: translateY(-6px) scale(1.03);
  box-shadow: 0 10px 22px rgba(0,0,0,.2);
}

.avatar-card.selected {
  border: 3px solid #0ea5e9;
  background: #e6f9ff;
}

.name {
  font-size: 20px;
  font-weight: 800;
  margin-bottom: 12px;
}

.avatar-img {
  width: 130px;
  height: 130px;
  object-fit: contain;
  margin-bottom: 14px;
  transition: transform 0.3s ease;
}

.avatar-card:hover .avatar-img {
  transform: rotate(-5deg) scale(1.05);
}

.regions {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 6px;
  margin-bottom: 10px;
}

.region-pill {
  background: #f0f9ff;
  color: #0369a1;
  border-radius: 999px;
  padding: 4px 10px;
  font-size: 13px;
  font-weight: 600;
}

.intro {
  font-size: 14px;
  color: #444;
  line-height: 1.5;
  margin-bottom: 12px;
}

.adventure-btn {
  margin-top: auto;
  padding: 12px 28px;
  font-size: 16px;
  font-weight: 800;
  border: none;
  border-radius: 30px;
  background: linear-gradient(90deg, #0ea5e9, #0369a1);
  color: white;
  cursor: pointer;
  transition: background 0.2s ease, transform 0.15s ease;
}

.adventure-btn:hover {
  transform: scale(1.05);
  background: linear-gradient(90deg, #0284c7, #075985);
}
</style>
