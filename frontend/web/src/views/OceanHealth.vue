<template>
  <main class="page">
    <!-- Loading overlay -->
    <LoadingOverlay v-if="loading" message="🌊 Checking today's ocean health..." />

    <div v-else class="wrap grid">
      <!-- Left side -->
      <section class="card left">
        <h2 class="avatar-name">
          {{ avatar?.name }} the {{ avatar?.species }}
          is <span :class="overallMoodClass">{{ moodText }}</span>!
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
      <section class="card right">
        <h2 class="water-title">
          {{ site?.name }} Water Quality
          <span class="overall-icon" :class="overallMoodClass">
            {{ health.overall_class === 'Green' ? '🟢' : health.overall_class === 'Orange' ? '🟠' : '🔴' }}
          </span>
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
      </section>
    </div>
  </main>
</template>

<script setup>
import { onMounted, ref, computed } from 'vue'
import { useStoryStore } from '../store/storyStore'
import { fetchHealth } from '../services/api'
import LoadingOverlay from '../components/LoadingOverlay.vue'

const store = useStoryStore()
const avatar = store.avatar
const site = store.site

const loading = ref(true)
const health = ref({ overall_class: 'Orange', factors: [] })

function saveCause() {
  const problemFactors = health.value.factors.filter(f => f.class_type !== "Green")
  if (problemFactors.length > 0) {
    store.setCause({
      status_ids: problemFactors.map(f => f.status_id),
      justifications: problemFactors.map(f => f.explanation).filter(Boolean)
    })
  }
}

onMounted(async () => {
  health.value = await fetchHealth(avatar.avatar_id, site.id)
  loading.value = false
})

const moodImg = computed(() =>
  health.value.overall_class === "Green"
    ? avatar.image_happy_url
    : avatar.image_sad_url
)

const moodText = computed(() =>
  health.value.overall_class === "Green" ? "Happy" : "Sad"
)

const overallMoodClass = computed(() =>
  health.value.overall_class.toLowerCase()
)

const bubbleMessages = computed(() =>
  health.value.factors.filter(f => f.explanation).map(f => f.explanation)
)
</script>

<style scoped>
.spinner {
  display: flex;
  gap: 8px;
  margin-bottom: 14px;
}

.spinner div {
  width: 14px;
  height: 14px;
  background: #0ea5e9;
  border-radius: 50%;
  animation: bounce 0.6s infinite alternate;
}

.spinner div:nth-child(2) {
  animation-delay: 0.2s;
  background: #22c55e;
}

.spinner div:nth-child(3) {
  animation-delay: 0.4s;
  background: #f59e0b;
}

@keyframes bounce {
  from { transform: translateY(0); }
  to { transform: translateY(-10px); }
}

/* Grid layout */
.grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 28px;
}

.left, .right {
  padding: 24px;
  border-radius: 16px;
}

/* Avatar side */
.avatar-name {
  font-size: 22px;
  margin-bottom: 12px;
  text-align: center;
}
.avatar-name .green { color: #22c55e; }
.avatar-name .orange { color: #f59e0b; }
.avatar-name .red { color: #ef4444; }

.avatar-img {
  width: 160px;
  margin: 0 auto 16px;
  display: block;
  transition: transform 0.3s ease;
}
.green .avatar-img { animation: bounce 1.5s infinite; }

@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-6px); }
}

/* Speech bubbles */
.speech-bubble {
  position: relative;
  border: 2px solid;
  border-radius: 16px;
  padding: 14px 18px;
  margin-top: 16px;
  font-size: 15px;
  line-height: 1.5;
}
.speech-bubble::after {
  content: "";
  position: absolute;
  bottom: -12px;
  left: 40px;
  border-width: 12px 12px 0;
  border-style: solid;
}
.speech-bubble.green { background: #e6f9e6; border-color: #22c55e; }
.speech-bubble.green::after { border-color: #e6f9e6 transparent transparent transparent; }
.speech-bubble.orange { background: #fff7e6; border-color: #f59e0b; }
.speech-bubble.orange::after { border-color: #fff7e6 transparent transparent transparent; }
.speech-bubble.red { background: #ffe5e5; border-color: #ef4444; }
.speech-bubble.red::after { border-color: #ffe5e5 transparent transparent transparent; }

/* Action buttons */
.actions {
  margin-top: 24px;
  text-align: center;
}
.btn {
  display: inline-block;
  padding: 12px 22px;
  border-radius: 30px;
  font-weight: 700;
  text-decoration: none;
}
.btn.green { background: #22c55e; color: #fff; }
.btn.orange { background: #f59e0b; color: #fff; }

/* Right side water quality card */
.water-title {
  font-size: 20px;
  margin-bottom: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.overall-icon { font-size: 24px; }

.factors { list-style: none; padding: 0; margin: 0; }
.factor-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid #eee;
}
.factor-item:last-child { border-bottom: none; }

.icon { font-size: 24px; }
.factor-info { flex: 1; }
.factor-name { font-weight: 700; font-size: 16px; }
.factor-status {
  margin-top: 4px;
  font-size: 14px;
  display: flex;
  gap: 6px;
  align-items: center;
}
.value { color: #555; font-size: 12px; }

.status.green { color: #22c55e; }
.status.orange { color: #f59e0b; }
.status.red { color: #ef4444; }

/* Mobile */
@media (max-width: 768px) {
  .grid { grid-template-columns: 1fr; }
  .avatar-img { width: 120px; }
}
</style>
