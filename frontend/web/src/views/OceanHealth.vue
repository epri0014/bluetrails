<template>
  <main class="page">
    <!-- Loading overlay -->
    <div v-if="loading" class="loading">
      <div class="spinner"></div>
      <p>Checking today’s ocean health...</p>
    </div>

    <div v-else class="grid">
      <!-- Left side -->
      <section class="left">
        <h2 class="avatar-name">
          {{ avatar?.name }} the {{ avatar?.species }} is
          <span :class="overallMoodClass">{{ moodText }}</span>!
        </h2>

        <img class="avatar-img" :src="moodImg" :alt="avatar?.name" />

        <!-- Avatar speech bubbles -->
        <div v-if="bubbleMessages.length" class="speech-bubble" :class="overallMoodClass">
          <ul>
            <li v-for="(msg, idx) in bubbleMessages" :key="idx">{{ msg }}</li>
          </ul>
        </div>

        <!-- Extra bubble for Green -->
        <div v-if="health.overall_class === 'Green'" class="speech-bubble green">
          Yay! The water is clear 👀 and I can find fish easily 🐟
        </div>

        <!-- Action buttons -->
        <div class="actions">
          <RouterLink
            v-if="health.overall_class === 'Green'"
            to="/choose"
            class="btn green"
          >
            🔙 Back to Choose Your Hero
          </RouterLink>

          <RouterLink
            v-else
            to="/cause"
            class="btn orange"
            @click.native="saveCause"
          >
            👉 Do you want to know why this happens?
          </RouterLink>
        </div>
      </section>

      <!-- Right side -->
      <section class="right">
        <div class="card">
          <h2>
            {{ site?.name }} Water Quality
            <span class="overall-icon" :class="overallMoodClass">●</span>
          </h2>

          <ul class="factors">
            <li v-for="f in health.factors" :key="f.factor_id" class="factor-item">
              <span class="icon">{{ f.icon }}</span>
              <div class="factor-info">
                <div class="factor-name">{{ f.name }}</div>
                <div class="factor-status">
                  <span :class="['status', f.class_type.toLowerCase()]">
                    {{ f.label }}
                  </span>
                  <span class="value" v-if="f.value !== null">
                    ({{ f.value.toFixed(2) }})
                  </span>
                </div>
              </div>
            </li>
          </ul>
        </div>
      </section>
    </div>
  </main>
</template>

<script setup>
import { onMounted, ref, computed } from 'vue'
import { useStoryStore } from '../store/storyStore'
import axios from 'axios'
import { fetchHealth } from '../services/api'

const store = useStoryStore()
const avatar = store.avatar
const site = store.site

const loading = ref(true)
const health = ref({ overall_class: 'Orange', factors: [] })

function saveCause() {
  // Collect all Orange/Red factors
  const problemFactors = health.value.factors.filter(
    f => f.class_type !== "Green"
  )

  if (problemFactors.length > 0) {
    store.setCause({
      status_ids: problemFactors.map(f => f.status_id),
      justifications: problemFactors
        .map(f => f.explanation)
        .filter(Boolean)
    })
  }
}

onMounted(async () => {
  health.value = await fetchHealth(avatar.avatar_id, site.id)
  loading.value = false
})

const moodImg = computed(() => {
  return health.value.overall_class === "Green"
    ? avatar.image_happy_url
    : avatar.image_sad_url
})

const moodText = computed(() =>
  health.value.overall_class === "Green" ? "Happy" : "Sad"
)

const overallMoodClass = computed(() =>
  health.value.overall_class.toLowerCase()
)

const bubbleMessages = computed(() =>
  health.value.factors
    .filter(f => f.explanation)
    .map(f => f.explanation)
)
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

.grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.left, .right {
  background: #fff;
  padding: 20px;
  border-radius: 12px;
}

.avatar-name {
  font-size: 20px;
  margin-bottom: 10px;
  text-align: center;
}
.avatar-name .green { color: green; }
.avatar-name .orange { color: orange; }
.avatar-name .red { color: red; }

.avatar-img {
  width: 140px;
  height: auto;
  margin: 0 auto 12px;
  display: block;
}

/* speech bubbles */
.speech-bubble {
  position: relative;
  border: 2px solid;
  border-radius: 12px;
  padding: 12px 16px;
  margin-top: 14px;
  font-size: 14px;
  color: #222;
}
.speech-bubble::after {
  content: "";
  position: absolute;
  bottom: -10px;
  left: 30px;
  border-width: 10px 10px 0;
  border-style: solid;
}
.speech-bubble.green { background: #e6f9e6; border-color: #22c55e; }
.speech-bubble.green::after { border-color: #e6f9e6 transparent transparent transparent; }

.speech-bubble.orange { background: #fff3e0; border-color: #f59e0b; }
.speech-bubble.orange::after { border-color: #fff3e0 transparent transparent transparent; }

.speech-bubble.red { background: #fee2e2; border-color: #ef4444; }
.speech-bubble.red::after { border-color: #fee2e2 transparent transparent transparent; }

/* Action buttons */
.actions {
  margin-top: 20px;
  text-align: center;
}
.btn {
  display: inline-block;
  padding: 10px 18px;
  border-radius: 10px;
  font-weight: 700;
  text-decoration: none;
}
.btn.green {
  background: #22c55e;
  color: white;
}
.btn.orange {
  background: #f59e0b;
  color: white;
}

.card { padding: 20px; border: 1px solid #ddd; border-radius: 12px; }
.card h2 { display: flex; align-items: center; gap: 8px; }

.overall-icon { font-size: 18px; }
.overall-icon.green { color: green; }
.overall-icon.orange { color: orange; }
.overall-icon.red { color: red; }

.factors { list-style: none; padding: 0; margin: 0; }
.factor-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid #eee;
}
.factor-item:last-child { border-bottom: none; }

.icon { font-size: 22px; }
.factor-info { flex: 1; text-align: left; }
.factor-name { font-weight: 700; font-size: 15px; }
.factor-status { margin-top: 4px; font-size: 14px; display: flex; gap: 6px; align-items: center; }
.value { color: #555; font-size: 12px; }

.status { font-weight: 700; text-transform: uppercase; }
.status.green { color: green; }
.status.orange { color: orange; }
.status.red { color: red; }

/* Mobile */
@media (max-width: 768px) {
  .grid { grid-template-columns: 1fr; }
  .avatar-img { width: 120px; }
}
</style>
