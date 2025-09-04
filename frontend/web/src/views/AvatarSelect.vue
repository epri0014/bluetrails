<template>
  <main class="page">
    <section class="wrap">
      <h1 class="title">Choose your hero!</h1>
      <p class="subtitle">Each of us lives in Port Phillip Bay. Let's check how healthy our home is today.</p>

      <div class="grid">
        <div 
          v-for="a in avatars" 
          :key="a.avatar_id" 
          class="card"
          :class="{ selected: selected?.avatar_id === a.avatar_id }"
          @click="selectAvatar(a)"
        >
          <h2 class="name">{{ a.name }} the {{ a.species }}</h2>
          <img class="avatar-img" :src="a.image_neutral_url" :alt="a.name" />
          <p class="region"><strong>Region:</strong> {{ a.site_short_name }}</p>
          <p class="intro">{{ a.intro }}</p>

          <!-- Show button only if this card is selected -->
          <button 
            v-if="selected?.avatar_id === a.avatar_id"
            class="start-btn"
            @click.stop="goNext"
          >
            Start My Adventure!
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

const router = useRouter()
const store = useStoryStore()

const avatars = ref([])
const selected = ref(null)

onMounted(async () => {
  avatars.value = await fetchAvatars()
})

function selectAvatar(a) {
  selected.value = a
}

function goNext() {
  const sites = selected.value.sites
  const randomSite = sites[Math.floor(Math.random() * sites.length)]

  store.setAvatar(selected.value)
  store.setSite(randomSite) // {id, name}
  router.push('/health')
}

</script>

<style scoped>
.page {
  padding-top: var(--nav-h);
  min-height: 100vh;
  background: #fafafa;
}

.wrap {
  max-width: 1100px;
  margin: 0 auto;
  padding: 20px;
  text-align: center;
}

.title {
  font-size: 2rem;
  margin-bottom: 8px;
}

.subtitle {
  color: #555;
  margin-bottom: 24px;
}

.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 20px;
}

.card {
  background: #fff;
  border: 2px solid #ddd;
  border-radius: 12px;
  padding: 18px;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
}

.card:hover {
  border-color: #0EA5E9;
  transform: translateY(-4px);
  box-shadow: 0 6px 16px rgba(0,0,0,0.1);
}

.card.selected {
  border-color: #0EA5E9;
  background: #e6f6ff;
}

.name {
  font-size: 18px;
  font-weight: 700;
  margin-bottom: 12px;
}

.avatar-img {
  width: 120px;
  height: 120px;
  object-fit: contain;
  margin-bottom: 12px;
}

.region {
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 10px;
}

.intro {
  font-size: 14px;
  color: #444;
  line-height: 1.4;
}

.start-btn {
  margin-top: 14px;
  padding: 10px 24px;
  font-size: 16px;
  font-weight: 700;
  border: none;
  border-radius: 8px;
  background: #0EA5E9;
  color: white;
  cursor: pointer;
  transition: background 0.2s ease;
}

.start-btn:hover {
  background: #0369A1;
}
</style>
