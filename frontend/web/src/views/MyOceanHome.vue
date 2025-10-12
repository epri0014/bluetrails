<!-- src/views/MyOceanHome.vue -->
<template>
  <main class="page">
    <!-- Back button -->
    <button class="back-btn glass" @click="goBack">
      ← Back
    </button>

    <!-- Loading state with skeleton -->
    <div v-if="loading" class="skeleton-container">
      <div class="skeleton-header glass">
        <div class="skeleton-avatar"></div>
        <div class="skeleton-text-block">
          <div class="skeleton-line short"></div>
          <div class="skeleton-line"></div>
          <div class="skeleton-line medium"></div>
        </div>
      </div>

      <div class="skeleton-cards">
        <div v-for="i in 5" :key="i" class="skeleton-card glass">
          <div class="skeleton-card-header">
            <div class="skeleton-emoji"></div>
            <div class="skeleton-title"></div>
            <div class="skeleton-chip"></div>
          </div>
          <div class="skeleton-line"></div>
          <div class="skeleton-value"></div>
        </div>
      </div>

      <div class="skeleton-vote glass">
        <div class="skeleton-line medium"></div>
        <div class="skeleton-buttons">
          <div class="skeleton-btn"></div>
          <div class="skeleton-btn"></div>
          <div class="skeleton-btn"></div>
        </div>
      </div>
    </div>

    <!-- Error state -->
    <div v-else-if="error" class="error-container glass">
      <p>❌ {{ error }}</p>
      <button @click="goBack" class="btn-back">Go Back</button>
    </div>

    <!-- Content -->
    <template v-else-if="prediction">
      <section class="header glass">
        <img :src="animalData?.cartoon_image_url" :alt="animalData?.name" class="avatar" />
        <div class="title">
          <div class="eyebrow">From {{ animalData?.name }}</div>
          <h2>"This is my home, <span class="site-name">{{ siteName }}</span>."</h2>
          <p class="lead">
            Today my home looks like this. Can you tell me:
            <strong>Is my home okay?</strong>
          </p>
        </div>
      </section>

      <section class="cards">
        <article class="card glass" v-for="metric in metricsList" :key="metric.key" :class="`card-${metric.level}`">
          <div class="row1">
            <span class="emoji">{{ metric.emoji }}</span>
            <h3>{{ metric.title }}</h3>
            <span class="chip" :class="metric.level">{{ labelOf(metric.level) }}</span>
          </div>
          <p class="desc" v-html="metric.desc"></p>
          <div class="value-with-tooltip">
            <div class="value">
              <span class="num" v-if="metric.value !== null">{{ metric.value }}</span>
              <span class="unit" v-if="metric.unit">{{ metric.unit }}</span>
            </div>
            <div class="tooltip">
              <span class="tooltip-icon">💡</span>
              <span class="tooltip-text">{{ metric.tip }}</span>
            </div>
          </div>
        </article>
      </section>

      <section class="vote glass">
        <div class="q">What do you think about my home today?</div>
        <div class="btns">
          <button class="btn green" @click="vote('green')">Safe</button>
          <button class="btn yellow" @click="vote('amber')">Caution</button>
          <button class="btn red" @click="vote('red')">Unsafe</button>
        </div>
      </section>
    </template>

    <!-- Validation Modal -->
    <div v-if="showModal" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop :class="{ correct: isCorrect }">
        <div v-if="isCorrect" class="confetti-container">
          <div class="confetti" v-for="i in 50" :key="i"></div>
        </div>

        <img
          :src="animalData?.cartoon_image_url"
          :alt="animalData?.name"
          class="modal-avatar"
          :class="{ bounce: isCorrect }"
        />

        <h3 v-if="isCorrect">🎉 Awesome!</h3>
        <h3 v-else>Keep Learning!</h3>

        <p class="modal-message">{{ modalMessage }}</p>

        <div class="modal-actions">
          <button class="btn-secondary" @click="closeModal">Close</button>
          <button class="btn-primary" @click="restartChallenge">Restart Challenge</button>
        </div>
      </div>
    </div>
  </main>
</template>

<script setup>
import { ref, onMounted, computed, inject } from 'vue'
import { useRouter } from 'vue-router'
import { getEpaPrediction } from '../services/api.js'
import { getAnimalBySlug } from '../services/api.js'

const router = useRouter()
const challengeState = inject('challengeState', null)

// Get data from wrapper
const selectedAnimal = challengeState?.selectedAnimal?.value
const selectedSite = challengeState?.selectedSite?.value
const siteId = String(selectedSite?.site_id || '')
const siteName = String(selectedSite?.site_name || 'My Beach')
const slug = String(selectedAnimal?.slug || '')

const prediction = ref(null)
const animalData = ref(null)
const loading = ref(true)
const error = ref(null)
const picked = ref('')
const showModal = ref(false)
const isCorrect = ref(false)
const modalMessage = ref('')

// Get today's date in YYYY-MM-DD format
const getTodayDate = () => {
  const today = new Date()
  const year = today.getFullYear()
  const month = String(today.getMonth() + 1).padStart(2, '0')
  const day = String(today.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

// Fetch data on mount
onMounted(async () => {
  try {
    loading.value = true
    error.value = null

    if (!siteId || !slug) {
      error.value = 'Missing site information. Please go back and select a habitat.'
      loading.value = false
      return
    }

    const todayDate = getTodayDate()

    // Fetch both prediction and animal data in parallel
    const [predictionData, animalDataResponse] = await Promise.all([
      getEpaPrediction(siteId, todayDate),
      getAnimalBySlug(slug, 'en')
    ])

    prediction.value = predictionData
    animalData.value = animalDataResponse

  } catch (err) {
    console.error('Failed to load water quality data:', err)
    error.value = 'Failed to load water quality data for today. Please try again later.'
  } finally {
    loading.value = false
  }
})

// Go back
const goBack = () => {
  if (challengeState) {
    challengeState.navigate({ type: 'back' })
  } else {
    router.push('/')
  }
}

// Build metrics list from prediction data
const metricsList = computed(() => {
  if (!prediction.value) return []

  return [
    {
      key: 'algae',
      title: prediction.value.chl_a_display_name,
      emoji: prediction.value.chl_a_icon,
      level: prediction.value.chl_a_status,
      value: prediction.value.chl_a !== null ? prediction.value.chl_a.toFixed(1) : null,
      unit: ' µg/L',
      desc: prediction.value.chl_a_description,
      tip: prediction.value.chl_a_indicator
    },
    {
      key: 'clarity',
      title: prediction.value.turb_display_name,
      emoji: prediction.value.turb_icon,
      level: prediction.value.turb_status,
      value: prediction.value.turbidity !== null ? prediction.value.turbidity.toFixed(1) : null,
      unit: ' NTU',
      desc: prediction.value.turb_description,
      tip: prediction.value.turb_indicator
    },
    {
      key: 'oxygen',
      title: prediction.value.do_mg_display_name,
      emoji: prediction.value.do_mg_icon,
      level: prediction.value.do_mg_status,
      value: prediction.value.do_mg_l !== null ? prediction.value.do_mg_l.toFixed(1) : null,
      unit: ' mg/L',
      desc: prediction.value.do_mg_description,
      tip: prediction.value.do_mg_indicator
    },
    {
      key: 'nutrients',
      title: prediction.value.n_total_display_name,
      emoji: prediction.value.n_total_icon,
      level: prediction.value.n_total_status,
      value: prediction.value.n_total !== null ? prediction.value.n_total.toFixed(1) : null,
      unit: ' mg/L',
      desc: prediction.value.n_total_description,
      tip: prediction.value.n_total_indicator
    },
    {
      key: 'temperature',
      title: prediction.value.temp_display_name,
      emoji: prediction.value.temp_icon,
      level: prediction.value.temp_status,
      value: prediction.value.temperature !== null ? prediction.value.temperature.toFixed(1) : null,
      unit: ' °C',
      desc: prediction.value.temp_description,
      tip: prediction.value.temp_indicator
    }
  ]
})

// Map status codes to labels
function labelOf(level) {
  return level === 'green' ? 'Safe' : level === 'amber' ? 'Caution' : 'Unsafe'
}

// Vote handler with validation
function vote(level) {
  picked.value = level
  const correctAnswer = prediction.value?.overall_status || 'green'

  if (level === correctAnswer) {
    isCorrect.value = true
    modalMessage.value = `Great job! My home is indeed ${labelOf(level).toLowerCase()} today. You really know your ocean science!`
    playCheerSound()
  } else {
    isCorrect.value = false
    modalMessage.value = `Thanks for trying! Actually, my home is ${labelOf(correctAnswer).toLowerCase()} today. ${getExplanation(correctAnswer, level)}`
  }

  showModal.value = true
  localStorage.setItem(`vote:${slug}:${siteId}`, level)
}

// Get explanation for wrong answers
function getExplanation(correct, guess) {
  if (correct === 'green' && guess === 'amber') {
    return "Don't worry! The water quality is actually better than you thought."
  } else if (correct === 'green' && guess === 'red') {
    return "Good news! The water quality is much better than you thought."
  } else if (correct === 'amber' && guess === 'green') {
    return "Be a bit more careful! Some parameters need attention."
  } else if (correct === 'amber' && guess === 'red') {
    return "It's not that bad! The water quality is concerning but not dangerous yet."
  } else if (correct === 'red' && guess === 'green') {
    return "Oh no! The water quality is actually quite poor right now. Stay safe!"
  } else if (correct === 'red' && guess === 'amber') {
    return "It's worse than that! The water quality is quite poor right now."
  }
  return "Let's learn more about ocean health together!"
}

// Play cheer sound (same as QuizView)
function playCheerSound() {
  try {
    const audio = new Audio('/sound/children-saying-yay-praise-and-worship-jesus-299607.mp3')
    audio.volume = 0.5
    audio.play().catch(e => console.log('Audio play prevented:', e))
  } catch (e) {
    console.log('Audio not available:', e)
  }
}

// Close modal
function closeModal() {
  showModal.value = false
}

// Restart challenge
function restartChallenge() {
  if (challengeState) {
    challengeState.navigate({ type: 'restart' })
  } else {
    router.push('/challenge')
  }
}
</script>

<style scoped>
.page{
  min-height: 100vh;
  padding: calc(var(--nav-h, 80px) + 16px) 16px 36px;
  background: linear-gradient(180deg,#87CEEB 0%, #E0F6FF 30%, #40E0D0 55%, #20B2AA 72%, #008B8B 86%, #F4A460 92%, #DEB887 100%);
  position: relative;
}

.glass{
  background: rgba(255,255,255,.6);
  border: 1px solid rgba(255,255,255,.35);
  border-radius: 16px;
  backdrop-filter: blur(8px);
  box-shadow: 0 12px 30px rgba(0,0,0,.18);
}

/* Back button */
.back-btn{
  position: absolute;
  top: calc(var(--nav-h, 80px) + 24px);
  left: 24px;
  padding: 10px 20px;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  border: 2px solid #0369a1;
  color: #0369a1;
  transition: all 0.2s ease;
  z-index: 100;
}

.back-btn:hover{
  background: #0369a1;
  color: white;
  transform: translateX(-4px);
}

/* Header */
.header{
  max-width: 1100px;
  margin: 16px auto 10px;
  padding: 14px 18px;
  display: flex;
  gap: 14px;
  align-items: center;
}

.avatar{
  width: 72px;
  height: 72px;
  border-radius: 50%;
  object-fit: cover;
  background: #fff;
  border: 3px solid #0369a1;
}

.eyebrow{
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: .12em;
  opacity: .75;
}

.title h2{
  margin: .1em 0;
}

.site-name{
  text-decoration: underline;
}

/* Loading and error states */
.loading-container, .error-container{
  max-width: 600px;
  margin: 60px auto;
  text-align: center;
  padding: 32px;
}

.loading-container p, .error-container p{
  font-size: 18px;
  font-weight: 700;
  margin: 0 0 16px 0;
}

.btn-back{
  padding: 10px 24px;
  background: #0369a1;
  color: white;
  border: 2px solid #0369a1;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-back:hover{
  background: #0284c7;
  transform: translateY(-2px);
}

/* Cards */
.cards{
  max-width: 1100px;
  margin: 12px auto;
  padding: 8px;
  display: grid;
  gap: 14px;
  grid-template-columns: repeat(auto-fill, minmax(260px,1fr));
}

.card{
  padding: 14px 16px;
  transition: all 0.3s ease;
}

/* Card backgrounds based on status */
.card-green{
  background: linear-gradient(135deg, rgba(232, 247, 236, 0.95) 0%, rgba(182, 229, 195, 0.85) 100%);
}

.card-amber{
  background: linear-gradient(135deg, rgba(255, 247, 226, 0.95) 0%, rgba(242, 209, 137, 0.85) 100%);
}

.card-red{
  background: linear-gradient(135deg, rgba(255, 232, 230, 0.95) 0%, rgba(241, 176, 173, 0.85) 100%);
}

.row1{
  display: grid;
  grid-template-columns: auto 1fr auto;
  align-items: center;
  gap: 10px;
}

.emoji{
  font-size: 20px;
}

.chip{
  font-size: 12px;
  padding: 3px 8px;
  border-radius: 999px;
  border: 1px solid rgba(0,0,0,.1);
}

.chip.green{
  background: #e8f7ec;
  border-color: #b6e5c3;
}

.chip.amber{
  background: #fff7e2;
  border-color: #f2d189;
}

.chip.red{
  background: #ffe8e6;
  border-color: #f1b0ad;
}

.desc{
  margin: .3rem 0 .6rem;
  opacity: .9;
}

.value-with-tooltip{
  position: relative;
  display: flex;
  align-items: center;
  gap: 8px;
}

.value{
  font-weight: 800;
  font-size: 20px;
}

.value .unit{
  font-weight: 600;
  font-size: 14px;
  margin-left: 4px;
  opacity: .8;
}

/* Tooltip */
.tooltip{
  position: relative;
  display: inline-flex;
  align-items: center;
  cursor: help;
}

.tooltip-icon{
  font-size: 18px;
  transition: transform 0.2s ease;
}

.tooltip:hover .tooltip-icon{
  transform: scale(1.2);
}

.tooltip-text{
  visibility: hidden;
  opacity: 0;
  position: absolute;
  bottom: 130%;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(15, 23, 42, 0.95);
  color: white;
  padding: 10px 14px;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 600;
  line-height: 1.4;
  white-space: normal;
  width: 220px;
  text-align: left;
  z-index: 1000;
  transition: opacity 0.3s ease, visibility 0.3s ease;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.3);
}

.tooltip-text::after{
  content: '';
  position: absolute;
  top: 100%;
  left: 50%;
  transform: translateX(-50%);
  border: 6px solid transparent;
  border-top-color: rgba(15, 23, 42, 0.95);
}

.tooltip:hover .tooltip-text{
  visibility: visible;
  opacity: 1;
}

/* Vote section */
.vote{
  max-width: 1100px;
  margin: 10px auto 30px;
  padding: 14px 16px;
  text-align: center;
}

.vote .q{
  font-weight: 800;
  margin-bottom: 10px;
}

.btns{
  display: flex;
  gap: 10px;
  justify-content: center;
  flex-wrap: wrap;
}

.btn{
  border-radius: 999px;
  padding: 10px 16px;
  font-weight: 800;
  border: 0;
  cursor: pointer;
  box-shadow: 0 10px 22px rgba(0,0,0,.15);
}

.btn.green{
  background: #1ec28b;
  color: #fff;
}

.btn.yellow{
  background: #f0c145;
  color: #222;
}

.btn.red{
  background: #e45b5b;
  color: #fff;
}

.thanks{
  margin-top: 10px;
  font-weight: 700;
}

/* Skeleton Loading */
.skeleton-container{
  max-width: 1100px;
  margin: 0 auto;
  padding: 20px;
}

.skeleton-header{
  display: flex;
  gap: 14px;
  align-items: center;
  padding: 14px 18px;
  margin-bottom: 12px;
}

.skeleton-avatar{
  width: 72px;
  height: 72px;
  border-radius: 50%;
  background: linear-gradient(90deg, #e0e7ff 25%, #c7d2fe 50%, #e0e7ff 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
}

.skeleton-text-block{
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.skeleton-line{
  height: 16px;
  background: linear-gradient(90deg, #e0e7ff 25%, #c7d2fe 50%, #e0e7ff 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
  border-radius: 4px;
}

.skeleton-line.short{
  width: 30%;
}

.skeleton-line.medium{
  width: 70%;
}

.skeleton-cards{
  display: grid;
  gap: 14px;
  grid-template-columns: repeat(auto-fill, minmax(260px,1fr));
  margin-bottom: 10px;
}

.skeleton-card{
  padding: 14px 16px;
}

.skeleton-card-header{
  display: grid;
  grid-template-columns: auto 1fr auto;
  gap: 10px;
  align-items: center;
  margin-bottom: 12px;
}

.skeleton-emoji{
  width: 24px;
  height: 24px;
  border-radius: 4px;
  background: linear-gradient(90deg, #e0e7ff 25%, #c7d2fe 50%, #e0e7ff 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
}

.skeleton-title{
  height: 18px;
  background: linear-gradient(90deg, #e0e7ff 25%, #c7d2fe 50%, #e0e7ff 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
  border-radius: 4px;
}

.skeleton-chip{
  width: 60px;
  height: 20px;
  border-radius: 999px;
  background: linear-gradient(90deg, #e0e7ff 25%, #c7d2fe 50%, #e0e7ff 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
}

.skeleton-value{
  height: 24px;
  width: 50%;
  margin-top: 8px;
  background: linear-gradient(90deg, #e0e7ff 25%, #c7d2fe 50%, #e0e7ff 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
  border-radius: 4px;
}

.skeleton-vote{
  padding: 14px 16px;
  text-align: center;
}

.skeleton-buttons{
  display: flex;
  gap: 10px;
  justify-content: center;
  margin-top: 12px;
}

.skeleton-btn{
  width: 120px;
  height: 40px;
  border-radius: 999px;
  background: linear-gradient(90deg, #e0e7ff 25%, #c7d2fe 50%, #e0e7ff 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
}

@keyframes skeleton-loading {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

/* Modal */
.modal-overlay{
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.7);
  display: grid;
  place-items: center;
  z-index: 2000;
  padding: 20px;
  animation: fade-in 0.3s ease;
}

@keyframes fade-in {
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal-content{
  position: relative;
  background: rgba(255, 255, 255, 0.98);
  border: 4px solid #0369a1;
  border-radius: 24px;
  padding: 36px 32px;
  max-width: 500px;
  width: 100%;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.4);
  text-align: center;
  backdrop-filter: blur(10px);
  animation: modal-pop 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
  overflow: hidden;
}

.modal-content.correct{
  border-color: #1ec28b;
}

@keyframes modal-pop {
  0% {
    transform: scale(0.8) translateY(20px);
    opacity: 0;
  }
  100% {
    transform: scale(1) translateY(0);
    opacity: 1;
  }
}

.modal-avatar{
  width: 120px;
  height: 120px;
  border-radius: 50%;
  object-fit: cover;
  margin: 0 auto 20px;
  border: 4px solid #0369a1;
  background: white;
}

.modal-avatar.bounce{
  animation: bounce-avatar 0.6s ease-in-out 3;
}

@keyframes bounce-avatar {
  0%, 100% { transform: translateY(0) scale(1); }
  25% { transform: translateY(-20px) scale(1.05); }
  50% { transform: translateY(-10px) scale(1.02); }
  75% { transform: translateY(-5px) scale(1.01); }
}

.modal-content h3{
  margin: 0 0 16px;
  font-size: 32px;
  font-weight: 900;
  color: #0f172a;
}

.modal-message{
  margin: 0 0 24px;
  font-size: 18px;
  color: #475569;
  line-height: 1.6;
  font-weight: 600;
}

.modal-actions{
  display: flex;
  gap: 12px;
  justify-content: center;
  flex-wrap: wrap;
}

.modal-actions button{
  padding: 14px 28px;
  border: 3px solid #000;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 900;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-secondary{
  background: #f1f5f9;
  color: #475569;
}

.btn-secondary:hover{
  background: #e2e8f0;
  transform: translateY(-2px);
}

.btn-primary{
  background: #0369a1;
  color: white;
}

.btn-primary:hover{
  background: #0284c7;
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(3, 105, 161, 0.3);
}

/* Confetti */
.confetti-container{
  position: absolute;
  inset: 0;
  pointer-events: none;
  overflow: hidden;
}

.confetti{
  position: absolute;
  width: 10px;
  height: 10px;
  background: #f0c145;
  top: -10px;
  animation: confetti-fall 3s linear forwards;
}

.confetti:nth-child(2n){ background: #1ec28b; }
.confetti:nth-child(3n){ background: #0369a1; }
.confetti:nth-child(4n){ background: #e45b5b; }
.confetti:nth-child(5n){ background: #a855f7; width: 8px; height: 8px; }
.confetti:nth-child(7n){ width: 6px; height: 6px; }

.confetti:nth-child(odd){ animation-duration: 2.5s; }
.confetti:nth-child(even){ animation-duration: 3.5s; }

.confetti:nth-child(1){ left: 10%; animation-delay: 0s; }
.confetti:nth-child(2){ left: 20%; animation-delay: 0.1s; }
.confetti:nth-child(3){ left: 30%; animation-delay: 0.2s; }
.confetti:nth-child(4){ left: 40%; animation-delay: 0.3s; }
.confetti:nth-child(5){ left: 50%; animation-delay: 0s; }
.confetti:nth-child(6){ left: 60%; animation-delay: 0.1s; }
.confetti:nth-child(7){ left: 70%; animation-delay: 0.2s; }
.confetti:nth-child(8){ left: 80%; animation-delay: 0.3s; }
.confetti:nth-child(9){ left: 90%; animation-delay: 0s; }
.confetti:nth-child(10){ left: 15%; animation-delay: 0.4s; }
.confetti:nth-child(11){ left: 25%; animation-delay: 0.5s; }
.confetti:nth-child(12){ left: 35%; animation-delay: 0.6s; }
.confetti:nth-child(13){ left: 45%; animation-delay: 0.4s; }
.confetti:nth-child(14){ left: 55%; animation-delay: 0.5s; }
.confetti:nth-child(15){ left: 65%; animation-delay: 0.6s; }
.confetti:nth-child(16){ left: 75%; animation-delay: 0.4s; }
.confetti:nth-child(17){ left: 85%; animation-delay: 0.5s; }
.confetti:nth-child(18){ left: 95%; animation-delay: 0.6s; }
.confetti:nth-child(19){ left: 12%; animation-delay: 0.7s; }
.confetti:nth-child(20){ left: 22%; animation-delay: 0.8s; }
.confetti:nth-child(21){ left: 32%; animation-delay: 0.7s; }
.confetti:nth-child(22){ left: 42%; animation-delay: 0.8s; }
.confetti:nth-child(23){ left: 52%; animation-delay: 0.7s; }
.confetti:nth-child(24){ left: 62%; animation-delay: 0.8s; }
.confetti:nth-child(25){ left: 72%; animation-delay: 0.7s; }
.confetti:nth-child(26){ left: 82%; animation-delay: 0.8s; }
.confetti:nth-child(27){ left: 92%; animation-delay: 0.7s; }
.confetti:nth-child(28){ left: 8%; animation-delay: 0.9s; }
.confetti:nth-child(29){ left: 18%; animation-delay: 1s; }
.confetti:nth-child(30){ left: 28%; animation-delay: 0.9s; }
.confetti:nth-child(31){ left: 38%; animation-delay: 1s; }
.confetti:nth-child(32){ left: 48%; animation-delay: 0.9s; }
.confetti:nth-child(33){ left: 58%; animation-delay: 1s; }
.confetti:nth-child(34){ left: 68%; animation-delay: 0.9s; }
.confetti:nth-child(35){ left: 78%; animation-delay: 1s; }
.confetti:nth-child(36){ left: 88%; animation-delay: 0.9s; }
.confetti:nth-child(37){ left: 98%; animation-delay: 1s; }
.confetti:nth-child(38){ left: 5%; animation-delay: 0.2s; }
.confetti:nth-child(39){ left: 15%; animation-delay: 0.3s; }
.confetti:nth-child(40){ left: 25%; animation-delay: 0.4s; }
.confetti:nth-child(41){ left: 35%; animation-delay: 0.5s; }
.confetti:nth-child(42){ left: 45%; animation-delay: 0.6s; }
.confetti:nth-child(43){ left: 55%; animation-delay: 0.2s; }
.confetti:nth-child(44){ left: 65%; animation-delay: 0.3s; }
.confetti:nth-child(45){ left: 75%; animation-delay: 0.4s; }
.confetti:nth-child(46){ left: 85%; animation-delay: 0.5s; }
.confetti:nth-child(47){ left: 95%; animation-delay: 0.6s; }
.confetti:nth-child(48){ left: 10%; animation-delay: 0.7s; }
.confetti:nth-child(49){ left: 50%; animation-delay: 0.8s; }
.confetti:nth-child(50){ left: 90%; animation-delay: 0.9s; }

@keyframes confetti-fall {
  0% {
    top: -10px;
    transform: translateX(0) rotateZ(0deg);
  }
  100% {
    top: 100%;
    transform: translateX(50px) rotateZ(360deg);
  }
}

@media (max-width: 768px){
  .header{
    flex-direction: column;
    text-align: center;
  }

  .back-btn{
    left: 16px;
    padding: 8px 16px;
    font-size: 14px;
  }

  .cards, .skeleton-cards{
    grid-template-columns: 1fr;
  }

  .tooltip-text{
    width: 180px;
  }

  .modal-content{
    padding: 28px 24px;
  }

  .modal-avatar{
    width: 100px;
    height: 100px;
  }

  .modal-content h3{
    font-size: 28px;
  }

  .modal-message{
    font-size: 16px;
  }

  .modal-actions{
    flex-direction: column;
  }

  .modal-actions button{
    width: 100%;
  }
}
</style>
