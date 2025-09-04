<template>
  <main class="page">
    <!-- Loading overlay -->
    <LoadingOverlay v-if="loading" message="🐠 Preparing your Ocean Story..." />

    <div v-else class="accordion wrap">
      <!-- Section 1 - Causes of Pollution -->
      <section class="card" :class="{ open: active === 1 }">
        <header @click="setActive(1)">
          <img class="avatar-icon" :src="avatar.image_neutral_url" :alt="avatar.name" />
          <h2>🚯 Causes of Pollution</h2>
        </header>
        <div v-if="active === 1" class="body">
          <div class="speech-bubble orange" v-if="cause?.justifications?.length">
            <ul>
              <li v-for="(j, idx) in cause.justifications" :key="idx">
                {{ j }}
              </li>
            </ul>
          </div>

          <ul class="causes">
            <li v-for="c in pollutionCauses" :key="c.id">
              <span class="icon">{{ c.icon }}</span>
              <div class="text">
                <div class="title">{{ c.title }}</div>
                <div class="desc">{{ c.description }}</div>
              </div>
            </li>
          </ul>

          <button class="btn primary" @click="setActive(2)">
            👉 See how this affects me and my ocean friends
          </button>
        </div>
      </section>

      <!-- Section 2 - Marine Life Facts -->
      <section class="card" :class="{ open: active === 2 }">
        <header @click="setActive(2)">
          <img class="avatar-icon" :src="avatar.image_neutral_url" :alt="avatar.name" />
          <h2>🐬 Marine Life Facts</h2>
        </header>
        <div v-if="active === 2" class="body">
          <!--<div class="speech-bubble blue">
            "You see? Pollution makes life harder for us."
          </div>-->

          <ul class="facts">
            <li v-for="f in funFacts" :key="f.id">🌊 {{ f.fact_text }}</li>
          </ul>

          <button class="btn primary" @click="setActive(3)">
            👉 Now here's how YOU can help
          </button>
        </div>
      </section>

      <!-- Section 3 - Eco Actions + Reward -->
      <section class="card" :class="{ open: active === 3 }">
        <header @click="setActive(3)">
          <img class="avatar-icon" :src="avatar.image_happy_url" :alt="avatar.name" />
          <h2>🌱 Eco-Actions & Reward</h2>
        </header>
        
        <div v-if="active === 3" class="body">
          <div class="speech-bubble red" v-if="checked.length < ecoActions.length">
            ✅ Check all the items below to help the ocean!
          </div>

          <ul class="actions">
            <li v-for="a in ecoActions" :key="a.id">
              <label>
                <input type="checkbox" v-model="checked" :value="a.id" />
                {{ a.action_text }}
              </label>
            </li>
          </ul>

          <div v-if="checked.length === ecoActions.length" class="speech-bubble green">
            🎉 Great job! You're helping me and my fishy friends 🐟
          </div>

          <div v-if="checked.length === ecoActions.length" class="reward">
            🎖️
            <button class="btn green" @click="downloadBadge">
              Download badge: Ocean Hero – Defender of {{ site?.name }}
            </button>
          </div>
        </div>
      </section>
    </div>
  </main>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useStoryStore } from '../store/storyStore'
import { fetchPollutionCauses, fetchFunFacts, fetchEcoActions } from '../services/api'
import { useRouter } from 'vue-router'
import LoadingOverlay from '../components/LoadingOverlay.vue'

const store = useStoryStore()
const avatar = store.avatar
const site = store.site
const cause = store.cause

const active = ref(1)
const pollutionCauses = ref([])
const funFacts = ref([])
const ecoActions = ref([])
const checked = ref([])

const loading = ref(true)
const router = useRouter()

function setActive(section) {
  active.value = section
}

onMounted(async () => {
  if (!cause || !cause.status_ids?.length) {
    router.push("/choose")
    return
  }

  try {
    const causesRes = await fetchPollutionCauses(cause.status_ids)
    pollutionCauses.value = causesRes.items

    const funRes = await fetchFunFacts(avatar.avatar_id)
    funFacts.value = funRes.items

    const ecoRes = await fetchEcoActions()
    ecoActions.value = ecoRes.items
  } finally {
    loading.value = false
  }
})

function downloadBadge() {
  alert(`Congratz! You are an Ocean Hero – Defender of ${site?.name}`)
  router.push('/choose')
}
</script>

<style scoped>
.page {
  padding-top: var(--nav-h);
  min-height: 100vh;
  background-image:
    linear-gradient(180deg, rgba(0,0,0,.25), rgba(0,0,0,.15)),
    url('/hero/background.jpg');
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
}

.accordion {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.card {
  border-radius: 12px;
  background: #fff;
  box-shadow: 0 4px 12px rgba(0,0,0,.15);
  overflow: hidden;
}
.card header {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  font-weight: 800;
  background: #f0f9ff;
  border-bottom: 1px solid #ddd;
  cursor: pointer;
}
.card .body {
  padding: 18px;
}

.avatar-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #0ea5e9;
  background: #fff;
}

/* Speech bubbles */
.speech-bubble {
  border-radius: 12px;
  padding: 12px 16px;
  margin-bottom: 14px;
  font-size: 15px;
  line-height: 1.5;
}
.speech-bubble.orange { background: #fff3e0; border: 2px solid #f59e0b; }
.speech-bubble.red { background: #fee2e2; border: 2px solid #ef4444; }
.speech-bubble.green { background: #e6f9e6; border: 2px solid #22c55e; }
.speech-bubble.blue { background: #e0f2fe; border: 2px solid #0ea5e9; }

/* Lists */
.causes li, .facts li, .actions li {
  margin-bottom: 10px;
  display: flex;
  gap: 10px;
  align-items: flex-start;
}

.icon { font-size: 22px; }
.title { font-weight: 700; margin-bottom: 2px; }

.actions input {
  margin-right: 8px;
}

/* Buttons */
.btn {
  display: inline-block;
  padding: 12px 18px;
  border-radius: 10px;
  font-weight: 700;
  margin-top: 14px;
  cursor: pointer;
  transition: transform 0.15s ease;
}
.btn.primary { background: #0ea5e9; color: white; }
.btn.green { background: #22c55e; color: white; }
.btn:hover { transform: scale(1.05); }

.reward {
  margin-top: 16px;
  text-align: center;
  font-weight: 700;
}
</style>
