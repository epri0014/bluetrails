<template>
  <main class="page">
    <!-- Loading overlay -->
    <div v-if="loading" class="loading">
      <div class="spinner"></div>
      <p>Gathering ocean story...</p>
    </div>

    <div v-else class="accordion">
      <!-- Section 1 - Causes of Pollution -->
      <section class="card" :class="{ open: active === 1 }">
        <header @click="setActive(1)">
          <h2>Causes of Pollution</h2>
        </header>
        <div v-if="active === 1" class="body">
          <!-- Avatar bubble -->
          <!--<div class="speech-bubble orange">
            <ul>
              <li v-for="(j, idx) in cause.justifications" :key="idx">
                {{ j }}
              </li>
            </ul>
          </div>-->

          <!-- Pollution causes list -->
          <ul class="causes">
            <li v-for="c in pollutionCauses" :key="c.id">
              <span class="icon">{{ c.icon }}</span>
              <div class="text">
                <div class="title">{{ c.title }}</div>
                <div class="desc">{{ c.description }}</div>
              </div>
            </li>
          </ul>

          <button class="btn next" @click="setActive(2)">
            👉 See how this affects me and my ocean friends
          </button>
        </div>
      </section>

      <!-- Section 2 - Marine Life Facts -->
      <section class="card" :class="{ open: active === 2 }">
        <header @click="setActive(2)">
          <h2>Marine Life Facts</h2>
        </header>
        <div v-if="active === 2" class="body">
          <ul class="facts">
            <li v-for="f in funFacts" :key="f.id">🐠 {{ f.fact_text }}</li>
          </ul>

          <button class="btn next" @click="setActive(3)">
            👉 Now here's how YOU can help
          </button>
        </div>
      </section>

      <!-- Section 3 - Eco Actions + Reward -->
      <section class="card" :class="{ open: active === 3 }">
        <header @click="setActive(3)">
          <h2>Eco-Actions & Reward</h2>
        </header>
        
        <div v-if="active === 3" class="body">
        <div class="speech-bubble red" v-if="checked.length < ecoActions.length">
          Check all the list!
        </div>
          <!-- Checklist -->
          <ul class="actions">
            <li v-for="a in ecoActions" :key="a.id">
              <label>
                <input type="checkbox" v-model="checked" :value="a.id" />
                {{ a.action_text }}
              </label>
            </li>
          </ul>

          <!-- Avatar bubble after checklist -->
          <div
            v-if="checked.length === ecoActions.length"
            class="speech-bubble green"
          >
            Great job! You're helping me and my fishy friends 🐟
          </div>

          <!-- Reward -->
          <div v-if="checked.length === ecoActions.length" class="reward">
            🎖️
            <button class="btn green" @click="downloadBadge">
              Download badge: Ocean Hero - Defender of {{ site?.name }}
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
  alert(`Congratz! You are an Ocean Hero - Defender of ${site?.name}`)
  router.push('/choose')
}
</script>

<style scoped>
.page {
  padding-top: var(--nav-h);
  min-height: 100vh;
  background: #fafafa;
  position: relative;
}

/* Loading overlay */
.loading {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background: rgba(250, 249, 247, 0.9);
  z-index: 100;
  font-weight: 600;
  color: #333;
}
.spinner {
  width: 48px;
  height: 48px;
  border: 4px solid #ddd;
  border-top: 4px solid #0ea5e9;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 12px;
}
@keyframes spin {
  to { transform: rotate(360deg); }
}

.accordion {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.card {
  border: 1px solid #ddd;
  border-radius: 12px;
  background: #fff;
}
.card header {
  padding: 14px;
  font-weight: 700;
  cursor: pointer;
  border-bottom: 1px solid #eee;
}
.card .body {
  padding: 16px;
}

/* Speech bubble */
.speech-bubble {
  border: 2px solid;
  border-radius: 12px;
  padding: 12px 16px;
  margin-bottom: 14px;
  font-size: 14px;
}
.speech-bubble.orange { background: #fff3e0; border-color: #f59e0b; }
.speech-bubble.red { background: #fee2e2; border-color: #ef4444; }
.speech-bubble.green { background: #e6f9e6; border-color: #22c55e; }

/* Lists */
.causes li, .facts li, .actions li {
  margin-bottom: 8px;
  display: flex;
  gap: 8px;
}

.icon { font-size: 20px; }
.title { font-weight: 700; }

.btn {
  display: inline-block;
  padding: 10px 16px;
  border-radius: 8px;
  font-weight: 600;
  text-decoration: none;
  margin-top: 12px;
}
.btn.next { background: #0ea5e9; color: white; }
.btn.green { background: #22c55e; color: white; }

.reward {
  margin-top: 16px;
  text-align: center;
  font-weight: 700;
}
</style>
