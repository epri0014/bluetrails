<template>
  <main class="quiz-page">
    <!-- Animated Background -->
    <div class="animated-background">
      <div class="sky"></div>
      <div class="sun"></div>
      <div class="ocean">
        <div class="tidal-wave tidal1"></div>
        <div class="tidal-wave tidal2"></div>
      </div>
      <div class="beach"></div>
    </div>

    <!-- Quiz Content -->
    <div class="quiz-content">
      <!-- Title Section -->
      <div class="title-section">
        <h1 class="quiz-title">{{ $t('quiz.title') }}</h1>
      </div>

      <!-- Loading State with Skeleton -->
      <div v-if="isLoading" class="quiz-card">
        <!-- Question Skeleton -->
        <div class="question-section" :style="{ background: getQuestionBackground() }">
          <div class="question-content">
            <div class="question-front">
              <div class="skeleton-badge"></div>
              <div class="skeleton-question">
                <div class="skeleton-line"></div>
                <div class="skeleton-line"></div>
                <div class="skeleton-line short"></div>
              </div>
            </div>
          </div>
        </div>

        <!-- Options Skeleton -->
        <div class="options-section">
          <div class="skeleton-option"></div>
          <div class="skeleton-option"></div>
          <div class="skeleton-option"></div>
        </div>
      </div>

      <!-- Quiz Card -->
      <div v-else-if="!showResult && currentQuestion" class="quiz-card">
        <!-- Question Section -->
        <div class="question-section" :style="{ background: getQuestionBackground() }" :class="{ 'correct-confetti': selectedAnswer && isAnswerCorrect && !showFunFact, 'wrong-blink': selectedAnswer && !isAnswerCorrect && !showFunFact }">
          <!-- Confetti Elements -->
          <div v-if="selectedAnswer && isAnswerCorrect && !showFunFact" class="confetti-container">
            <div v-for="i in 50" :key="i" class="confetti-piece" :style="getConfettiStyle(i)"></div>
          </div>

          <div class="question-content" :class="{ flipped: showFunFact }">
            <div class="question-front">
              <div class="category-badge">
                <span class="category-icon">{{ getCategoryIcon(currentQuestion.category) }}</span>
                <span class="category-text">{{ getCategoryName(currentQuestion.category) }}</span>
              </div>
              <h2 class="question-text">{{ currentQuestion.question }}</h2>
            </div>

            <div class="question-back">
              <div class="fun-fact-header">
                <span class="fun-fact-icon">💡</span>
                <span class="fun-fact-title">{{ $t('quiz.funFact') }}</span>
              </div>
              <p class="fun-fact-text">{{ currentQuestion.funFact }}</p>
            </div>
          </div>

          <!-- Timer moved to top right corner of quiz card -->
          <div class="timer-section-new">
            <div class="timer" :class="{ 'timer-urgent': timeLeft <= 10 }">
              <span class="timer-label">{{ $t('quiz.timeLeft') }}</span>
              <span class="timer-value">{{ formatTime(timeLeft) }}</span>
            </div>
          </div>

          <!-- Question Progress Indicator - top left corner -->
          <div class="progress-section-new">
            <div class="progress-indicator">
              <span class="progress-value">{{ currentQuestionIndex + 1 }}/{{ totalQuestions }}</span>
            </div>
          </div>
        </div>

        <!-- Next Question Button (between question and options) -->
        <Transition name="next-button" appear>
          <div v-if="selectedAnswer && showFunFact" class="next-section-middle">
            <button class="next-btn fade-in-btn aggressive-blink" @click="nextQuestion">
              {{ currentQuestionIndex === selectedQuestions.length - 1 ? $t('quiz.finish') : $t('quiz.nextQuestion') }}
            </button>
          </div>
        </Transition>

        <!-- Answer Options -->
        <div class="options-section" :class="{ 'correct-confetti': selectedAnswer && isAnswerCorrect && !showFunFact, 'wrong-blink': selectedAnswer && !isAnswerCorrect && !showFunFact, 'move-down': selectedAnswer && showFunFact }">
          <!-- Answer Options Confetti -->
          <div v-if="selectedAnswer && isAnswerCorrect && !showFunFact" class="confetti-container">
            <div v-for="i in 30" :key="i" class="confetti-piece" :style="getConfettiStyle(i)"></div>
          </div>

          <button
            v-for="(option, index) in currentQuestion.options"
            :key="index"
            class="option-btn"
            :class="getOptionClass(option)"
            @click="selectAnswer(option)"
            :disabled="selectedAnswer !== null"
          >
            {{ option }}
          </button>
        </div>

      </div>

      <!-- Feedback Overlay -->
      <div v-if="showFeedback" class="feedback-overlay">
        <div class="feedback-bubble-overlay" :class="{ correct: isAnswerCorrect, incorrect: !isAnswerCorrect }">
          <div class="feedback-text">
            <span v-if="isAnswerCorrect" class="feedback-message correct">🎉 {{ $t('quiz.correct') }}</span>
            <span v-else class="feedback-message incorrect">
              😔 {{ $t('quiz.incorrect') }} {{ currentQuestion.correctAnswer }}.
            </span>
          </div>
        </div>
      </div>

      <!-- Score Section -->
      <div v-if="!isLoading" class="score-section">
        <div class="score-display">
          <span class="score-label">{{ $t('quiz.score') }}</span>
          <span class="score-value">{{ score }} {{ $t('quiz.outOf') }} {{ totalQuestions }}</span>
        </div>

        <div class="progress-bar">
          <div
            v-for="(question, index) in selectedQuestions"
            :key="index"
            class="progress-segment"
            :class="getProgressClass(index)"
          ></div>
        </div>
      </div>

      <!-- Result Page -->
      <div v-if="showResult" class="result-section">
        <div class="result-card">
          <h2 class="result-title">{{ $t('quiz.yourScore') }} {{ score }} {{ $t('quiz.outOf') }} {{ totalQuestions }}!</h2>

          <div class="result-message">
            <div class="result-icon">{{ getResultIcon() }}</div>
            <p class="result-text">{{ getResultMessage() }}</p>
          </div>

          <div class="result-actions">
            <button class="retry-btn" @click="retakeQuiz">
              <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
                <path d="M17.65 6.35C16.2 4.9 14.21 4 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08c-.82 2.33-3.04 4-5.65 4-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"/>
              </svg>
              {{ $t('quiz.retakeQuiz') }}
            </button>

            <button class="home-btn" @click="goHome">
              <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
                <path d="m20 8-6-5.26a3 3 0 0 0-4 0L4 8a3 3 0 0 0-1 2.26V19a3 3 0 0 0 3 3h12a3 3 0 0 0 3-3v-8.74A3 3 0 0 0 20 8ZM14 20h-4v-6h4v6Z"/>
              </svg>
              {{ $t('quiz.goHome') }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { getQuizQuestions, getQuestionCategories } from '@/services/api.js'

const router = useRouter()
const { t, locale } = useI18n()

// Quiz state
const currentQuestionIndex = ref(0)
const selectedQuestionIds = ref([])
const selectedAnswer = ref(null)
const score = ref(0)
const timeLeft = ref(120) // 2 minutes in seconds
const showResult = ref(false)
const showFunFact = ref(false)
const showFeedback = ref(false)
const totalQuestions = 5
const answerHistory = ref([])
const isLoading = ref(true)

// Dynamic data from API
const questionsData = ref([])
const categoriesData = ref({})

// Timer
let timer = null
let urgentTimerSound = null

// Load questions from API
const loadQuestions = async () => {
  try {
    const data = await getQuizQuestions(locale.value)
    questionsData.value = data.map(q => {
      const options = typeof q.options_json === 'string' ? JSON.parse(q.options_json) : q.options_json
      const optionsArray = options.map(opt => opt.text)
      const correctAnswer = optionsArray[q.correct_option_index]

      // Shuffle options array
      const shuffledOptions = [...optionsArray].sort(() => Math.random() - 0.5)

      return {
        id: q.id,
        question: q.question_text,
        correctAnswer: correctAnswer,
        options: shuffledOptions,
        funFact: q.fun_fact,
        category: q.category_code
      }
    })
  } catch (error) {
    console.error('Failed to load questions:', error)
  }
}

// Load categories from API
const loadCategories = async () => {
  try {
    const data = await getQuestionCategories(locale.value)
    const categoriesMap = {}
    data.forEach(cat => {
      categoriesMap[cat.code] = {
        name: cat.name,
        background: cat.background_gradient,
        icon: cat.icon
      }
    })
    categoriesData.value = categoriesMap
  } catch (error) {
    console.error('Failed to load categories:', error)
  }
}

// Computed properties - reactive to language changes
const allQuestions = computed(() => {
  return questionsData.value || []
})

const selectedQuestions = computed(() => {
  const questions = allQuestions.value
  return selectedQuestionIds.value.map(id =>
    questions.find(q => q.id === id)
  ).filter(Boolean)
})

const currentQuestion = computed(() => {
  const question = selectedQuestions.value[currentQuestionIndex.value]
  return question || null
})

const isAnswerCorrect = computed(() => {
  if (!currentQuestion.value || !selectedAnswer.value) return false
  return selectedAnswer.value === currentQuestion.value.correctAnswer
})

// Backwards compatibility alias
const isCorrect = computed(() => isAnswerCorrect.value)

// Initialize quiz
const initializeQuiz = async () => {
  try {
    console.log('Initializing quiz')
    isLoading.value = true

    // Load questions and categories from API
    await Promise.all([loadQuestions(), loadCategories()])

    // Randomly select 5 question IDs (preserve selection across language changes)
    if (selectedQuestionIds.value.length === 0) {
      const shuffled = [...questionsData.value].sort(() => 0.5 - Math.random())
      selectedQuestionIds.value = shuffled.slice(0, totalQuestions).map(q => q.id)
    }

    // Reset state
    currentQuestionIndex.value = 0
    selectedAnswer.value = null
    score.value = 0
    timeLeft.value = 120
    showResult.value = false
    showFunFact.value = false
    showFeedback.value = false
    answerHistory.value = []
    isLoading.value = false

    // Start timer
    startTimer()
  } catch (error) {
    console.error('Error initializing quiz:', error)
    isLoading.value = false
  }
}

const startTimer = () => {
  if (timer) clearInterval(timer)
  timer = setInterval(() => {
    const previousTime = timeLeft.value
    timeLeft.value--

    // Start urgent sound when reaching 10 seconds
    if (timeLeft.value === 10 && previousTime === 11) {
      playUrgentTimerSound()
    }

    // Stop urgent sound when timer ends or goes below 1
    if (timeLeft.value <= 0) {
      stopUrgentTimerSound()
      endQuiz()
    }
  }, 1000)
}

const selectAnswer = (answer) => {
  if (selectedAnswer.value !== null || !currentQuestion.value) return

  selectedAnswer.value = answer
  const correct = answer === currentQuestion.value.correctAnswer

  // Play sound effect
  playAnswerSound(correct)

  if (correct) {
    score.value++
  }

  // Track answer for progress bar
  answerHistory.value.push({
    questionIndex: currentQuestionIndex.value,
    correct: correct
  })

  // Show feedback overlay
  showFeedback.value = true

  // Match timing with sound effects duration
  const soundDuration = correct ? 1000 : 2000 // Correct sound ~1s, incorrect sound ~2s
  const feedbackDuration = correct ? 2500 : 3500 // Show feedback a bit longer than sound

  setTimeout(() => {
    showFeedback.value = false

    // Show fun fact after feedback disappears
    setTimeout(() => {
      showFunFact.value = true
    }, 300)
  }, feedbackDuration)
}

const nextQuestion = () => {
  showFunFact.value = false
  selectedAnswer.value = null
  showFeedback.value = false

  if (currentQuestionIndex.value === selectedQuestions.value.length - 1) {
    endQuiz()
  } else {
    currentQuestionIndex.value++
  }
}

const endQuiz = () => {
  if (timer) {
    clearInterval(timer)
    timer = null
  }
  stopUrgentTimerSound()
  showResult.value = true

  // Play children saying yay sound effect
  playResultSound()
}

const retakeQuiz = () => {
  // Reset question selection for new random questions
  selectedQuestionIds.value = []
  initializeQuiz()
}

const goHome = () => {
  router.push('/')
}

// Helper methods
const formatTime = (seconds) => {
  const minutes = Math.floor(seconds / 60)
  const remainingSeconds = seconds % 60
  return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`
}

const getQuestionBackground = () => {
  if (!currentQuestion.value) return 'linear-gradient(135deg, #0ea5e9 0%, #0369a1 100%)'
  const category = categoriesData.value[currentQuestion.value.category]
  return category?.background || 'linear-gradient(135deg, #0ea5e9 0%, #0369a1 100%)'
}

const getCategoryName = (categoryCode) => {
  const category = categoriesData.value[categoryCode]
  return category?.name || categoryCode
}

const getCategoryIcon = (categoryCode) => {
  const category = categoriesData.value[categoryCode]
  return category?.icon || '🌊'
}

const getOptionClass = (option) => {
  if (selectedAnswer.value === null || !currentQuestion.value) return ''

  if (option === currentQuestion.value.correctAnswer) {
    return 'correct'
  } else if (option === selectedAnswer.value) {
    return 'incorrect'
  }
  return 'neutral'
}

const getProgressClass = (index) => {
  const answer = answerHistory.value.find(a => a.questionIndex === index)

  if (answer) {
    return answer.correct ? 'completed-correct' : 'completed-incorrect'
  } else if (index === currentQuestionIndex.value) {
    return 'current'
  }
  return 'pending'
}

const getResultIcon = () => {
  if (score.value <= 2) return '🌊'
  if (score.value <= 4) return '⭐'
  return '🏆'
}

const getResultMessage = () => {
  if (score.value <= 2) {
    return t('quiz.resultMessages.low')
  } else if (score.value <= 4) {
    return t('quiz.resultMessages.good')
  }
  return t('quiz.resultMessages.excellent')
}

// Sound effects
const playAnswerSound = (isCorrect) => {
  try {
    const audio = new Audio()
    if (isCorrect) {
      audio.src = '/sound/sonido-correcto-331225.mp3'
    } else {
      audio.src = '/sound/party-blower-4-207163.mp3'
    }
    audio.volume = 0.3
    audio.play().catch(e => console.log('Audio play failed:', e))
  } catch (error) {
    console.log('Audio error:', error)
  }
}

const playResultSound = () => {
  try {
    const audio = new Audio()
    audio.src = '/sound/children-saying-yay-praise-and-worship-jesus-299607.mp3'
    audio.volume = 0.4
    audio.play().catch(e => console.log('Result audio play failed:', e))
  } catch (error) {
    console.log('Result audio error:', error)
  }
}

const playUrgentTimerSound = () => {
  try {
    if (urgentTimerSound) {
      urgentTimerSound.pause()
      urgentTimerSound.currentTime = 0
    }
    urgentTimerSound = new Audio()
    urgentTimerSound.src = '/sound/time-passing-sound-effect-fast-clock-108403.mp3'
    urgentTimerSound.volume = 0.3
    urgentTimerSound.loop = true
    urgentTimerSound.play().catch(e => console.log('Urgent timer audio play failed:', e))
  } catch (error) {
    console.log('Urgent timer audio error:', error)
  }
}

const stopUrgentTimerSound = () => {
  try {
    if (urgentTimerSound) {
      urgentTimerSound.pause()
      urgentTimerSound.currentTime = 0
      urgentTimerSound = null
    }
  } catch (error) {
    console.log('Stop urgent timer audio error:', error)
  }
}

// Confetti style generation
const getConfettiStyle = (index) => {
  const colors = ['#ff6b6b', '#4ecdc4', '#45b7d1', '#f9ca24', '#f0932b', '#eb4d4b', '#6c5ce7', '#a29bfe']
  return {
    left: Math.random() * 100 + '%',
    backgroundColor: colors[Math.floor(Math.random() * colors.length)],
    animationDelay: Math.random() * 0.5 + 's',
    animationDuration: (1 + Math.random() * 1) + 's'
  }
}

// Watch for locale changes and reload questions
watch(locale, async () => {
  try {
    isLoading.value = true
    await Promise.all([loadQuestions(), loadCategories()])
    isLoading.value = false
  } catch (error) {
    console.error('Failed to reload quiz data for language change:', error)
    isLoading.value = false
  }
})

// Lifecycle
onMounted(() => {
  console.log('Quiz component mounted')
  initializeQuiz()
})

onBeforeUnmount(() => {
  if (timer) {
    clearInterval(timer)
    timer = null
  }
  stopUrgentTimerSound()
})
</script>

<style scoped>
.quiz-page {
  position: relative;
  min-height: 100vh;
  width: 100%;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  padding-top: var(--nav-h);
}

/* Animated Background */
.animated-background {
  position: absolute;
  inset: 0;
  z-index: 1;
}

.sky {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, #87CEEB 0%, #E0F6FF 50%, #87CEEB 100%);
}

.sun {
  position: absolute;
  top: 15%;
  right: 15%;
  width: 120px;
  height: 120px;
  border-radius: 50%;
  background: radial-gradient(circle, #FFD700 0%, #FFA500 100%);
  box-shadow: 0 0 60px rgba(255, 215, 0, 0.6);
  animation: sun-pulse 4s ease-in-out infinite;
}

@keyframes sun-pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

.ocean {
  position: absolute;
  bottom: 20%;
  left: 0;
  right: 0;
  height: 45%;
  background: linear-gradient(180deg, #40E0D0 0%, #20B2AA 30%, #008B8B 70%, #006666 100%);
  overflow: hidden;
}

.tidal-wave {
  position: absolute;
  left: -100%;
  width: 200%;
  height: 80px;
  background: linear-gradient(
    90deg,
    transparent 0%,
    rgba(255, 255, 255, 0.1) 25%,
    rgba(255, 255, 255, 0.2) 50%,
    rgba(255, 255, 255, 0.1) 75%,
    transparent 100%
  );
  border-radius: 40px;
  animation: tidal-motion 12s ease-in-out infinite;
}

.tidal1 {
  bottom: 60%;
  animation-duration: 12s;
  opacity: 0.8;
  animation-delay: 0s;
}

.tidal2 {
  bottom: 40%;
  animation-duration: 15s;
  opacity: 0.6;
  animation-delay: -3s;
}

@keyframes tidal-motion {
  0% { transform: translateX(-50%) scaleY(1); }
  25% { transform: translateX(-25%) scaleY(1.2); }
  50% { transform: translateX(0%) scaleY(1); }
  75% { transform: translateX(25%) scaleY(0.8); }
  100% { transform: translateX(50%) scaleY(1); }
}

.beach {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 20%;
  background: linear-gradient(180deg, #F4A460 0%, #DEB887 50%, #D2691E 100%);
}

/* Quiz Content */
.quiz-content {
  position: relative;
  z-index: 10;
  width: 100%;
  max-width: 900px;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* Title Section */
.title-section {
  text-align: center;
  margin-bottom: 15px;
  padding: 10px 20px;
}

.quiz-title {
  font-size: clamp(28px, 5vw, 48px);
  font-weight: 900;
  color: #fff;
  text-shadow: 0 4px 8px rgba(0, 0, 0, 0.7), 0 2px 4px rgba(0, 0, 0, 0.8);
  margin-bottom: 0;
  animation: bounce-text 2s ease-in-out infinite;
}

@keyframes bounce-text {
  0%, 100% { transform: translateY(0px); }
  25% { transform: translateY(-8px); }
  75% { transform: translateY(-4px); }
}

/* Loading Section */
.loading-section {
  text-align: center;
  padding: 60px 20px;
}

.loading-spinner {
  font-size: 64px;
  animation: bounce-text 2s ease-in-out infinite;
  margin-bottom: 20px;
}

.loading-text {
  font-size: 24px;
  font-weight: 700;
  color: #fff;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.4);
  margin: 0;
}

/* Quiz Card */
.quiz-card {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(248, 250, 252, 0.95) 100%);
  border-radius: 25px;
  padding: 0;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
  border: 3px solid #40E0D0;
  overflow: hidden;
  backdrop-filter: blur(10px);
}

/* Question Section */
.question-section {
  position: relative;
  padding: 40px;
  color: white;
  min-height: 200px;
  display: flex;
  align-items: center;
  justify-content: center;
  perspective: 1000px;
}

.question-content {
  width: 100%;
  transition: transform 1.8s ease-in-out;
  transform-style: preserve-3d;
  position: relative;
}

.question-content.flipped {
  transform: rotateY(180deg);
}

.question-front,
.question-back {
  backface-visibility: hidden;
  position: absolute;
  width: 100%;
  top: 50%;
  left: 0;
  transform: translateY(-50%);
  display: flex;
  flex-direction: column;
  justify-content: center;
  min-height: 120px;
}

.question-back {
  transform: rotateY(180deg) translateY(-50%);
}

/* Question Progress Indicator - positioned like timer */
.progress-section-new {
  position: absolute;
  top: 15px;
  left: 15px;
}

.progress-section-new .progress-indicator {
  background: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 8px 16px;
  border-radius: 20px;
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
}

.progress-section-new .progress-value {
  font-size: 16px;
  font-weight: 800;
  min-width: 40px;
  text-align: center;
}

/* Confetti Effect */
.confetti-container {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  overflow: hidden;
}

.confetti-piece {
  position: absolute;
  width: 8px;
  height: 8px;
  border-radius: 2px;
  animation: confetti-fall 2s ease-out forwards;
  top: -10px;
}

@keyframes confetti-fall {
  0% {
    transform: translateY(-10px) rotate(0deg);
    opacity: 1;
  }
  100% {
    transform: translateY(200px) rotate(720deg);
    opacity: 0;
  }
}

/* Red Blinking Effect for Wrong Answers */
.wrong-blink {
  animation: red-blink 0.6s ease-in-out;
}

@keyframes red-blink {
  0%, 100% {
    filter: none;
  }
  25%, 75% {
    filter: brightness(0.7) hue-rotate(0deg);
    box-shadow: 0 0 30px rgba(239, 68, 68, 0.8);
  }
  50% {
    filter: brightness(0.5) sepia(1) hue-rotate(-50deg) saturate(3);
    box-shadow: 0 0 40px rgba(239, 68, 68, 1);
  }
}

/* Timer positioned at top right corner */
.timer-section-new {
  position: absolute;
  top: 15px;
  right: 15px;
}

.timer-section-new .timer {
  background: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 8px 16px;
  border-radius: 20px;
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  gap: 8px;
}

.timer-section-new .timer-label {
  font-size: 14px;
  font-weight: 600;
}

.timer-section-new .timer-value {
  font-size: 16px;
  font-weight: 800;
}

/* Timer urgent blinking animation when below 10 seconds */
.timer-urgent {
  animation: timer-urgent-blink 0.8s ease-in-out infinite !important;
  background: rgba(251, 146, 60, 0.9) !important;
  border: 2px solid #fb923c !important;
  color: #1a1a1a !important;
}

@keyframes timer-urgent-blink {
  0%, 100% {
    background: rgba(251, 146, 60, 0.9) !important;
    box-shadow: 0 0 20px rgba(251, 146, 60, 0.8);
    transform: scale(1);
    color: #1a1a1a !important;
  }
  50% {
    background: rgba(234, 88, 12, 1) !important;
    box-shadow: 0 0 30px rgba(251, 146, 60, 1);
    transform: scale(1.05);
    color: white !important;
  }
}

.category-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: rgba(255, 255, 255, 0.2);
  padding: 8px 16px;
  border-radius: 20px;
  margin-bottom: 20px;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.category-icon {
  font-size: 20px;
}

.category-text {
  font-weight: 600;
  font-size: 14px;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.question-text {
  font-size: clamp(20px, 3vw, 28px);
  font-weight: 700;
  line-height: 1.4;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.5);
  margin: 0;
}

.fun-fact-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
}

.fun-fact-icon {
  font-size: 32px;
}

.fun-fact-title {
  font-size: 24px;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.fun-fact-text {
  font-size: clamp(18px, 2.5vw, 24px);
  font-weight: 600;
  line-height: 1.5;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.5);
  margin: 0;
}

/* Options Section */
.options-section {
  padding: 30px 40px;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.option-btn {
  padding: 20px 25px;
  font-size: 18px;
  font-weight: 600;
  color: #1e293b;
  background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
  border: 3px solid #cbd5e1;
  border-radius: 15px;
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: left;
}

.option-btn:hover:not(:disabled) {
  background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%);
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.option-btn:disabled {
  cursor: not-allowed;
}

.option-btn.correct {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  border-color: #059669;
  animation: glow-green 1.5s ease-in-out infinite;
}

.option-btn.incorrect {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  border-color: #dc2626;
  animation: shake-vibrate 0.6s ease-in-out;
}

.option-btn.neutral {
  opacity: 0.6;
}


@keyframes glow-green {
  0%, 100% { box-shadow: 0 8px 25px rgba(16, 185, 129, 0.3); }
  50% { box-shadow: 0 8px 25px rgba(16, 185, 129, 0.6); }
}

@keyframes shake-vibrate {
  0%, 100% { transform: translateX(0) rotate(0deg); }
  10% { transform: translateX(-3px) rotate(-1deg); }
  20% { transform: translateX(3px) rotate(1deg); }
  30% { transform: translateX(-3px) rotate(-1deg); }
  40% { transform: translateX(3px) rotate(1deg); }
  50% { transform: translateX(-2px) rotate(-0.5deg); }
  60% { transform: translateX(2px) rotate(0.5deg); }
  70% { transform: translateX(-1px) rotate(-0.25deg); }
  80% { transform: translateX(1px) rotate(0.25deg); }
  90% { transform: translateX(-0.5px) rotate(-0.1deg); }
}

/* Feedback Overlay */
.feedback-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
  pointer-events: none;
}

.feedback-bubble-overlay {
  background: linear-gradient(135deg, #fff 0%, #f8fafc 100%);
  border-radius: 25px;
  padding: 30px 40px;
  border: 4px solid;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  backdrop-filter: blur(10px);
}

.feedback-bubble-overlay.correct {
  animation: feedback-bubble-correct 2.5s ease-in-out forwards;
}

.feedback-bubble-overlay.incorrect {
  animation: feedback-bubble-incorrect 3.5s ease-in-out forwards;
}

.feedback-bubble-overlay.correct {
  border-color: #10b981;
  color: #065f46;
  background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%);
}

.feedback-bubble-overlay.incorrect {
  border-color: #ef4444;
  color: #991b1b;
  background: linear-gradient(135deg, #fef2f2 0%, #fecaca 100%);
}

.feedback-bubble-overlay .feedback-message {
  font-size: 24px;
  font-weight: 800;
  text-align: center;
}

/* Next Section - positioned between question and options */
.next-section-middle {
  padding: 20px 40px;
  display: flex;
  justify-content: center;
  /* Removed borders and background for cleaner animation */
  background: transparent;
}

.next-btn {
  padding: 15px 30px;
  font-size: 18px;
  font-weight: 700;
  color: white;
  background: linear-gradient(135deg, #0ea5e9 0%, #0369a1 100%);
  border: none;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.next-btn:hover {
  background: linear-gradient(135deg, #0369a1 0%, #1e40af 100%);
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(14, 165, 233, 0.4);
}

/* Aggressive Blinking Animation for Next Button */
.aggressive-blink {
  animation: aggressive-blink 1s ease-in-out infinite !important;
}

@keyframes aggressive-blink {
  0%, 100% {
    opacity: 1;
    box-shadow: 0 8px 25px rgba(14, 165, 233, 0.4);
    transform: scale(1);
  }
  50% {
    opacity: 0.4;
    box-shadow: 0 12px 40px rgba(14, 165, 233, 0.8);
    transform: scale(1.02);
  }
}

/* Feedback Overlay Animations - Slower */
@keyframes feedback-bubble-correct {
  0% {
    transform: scale(0.3);
    opacity: 0;
  }
  20% {
    transform: scale(1.05);
    opacity: 1;
  }
  25% {
    transform: scale(1);
    opacity: 1;
  }
  70% {
    transform: scale(1);
    opacity: 1;
  }
  85% {
    transform: scale(0.95);
    opacity: 0.6;
  }
  100% {
    transform: scale(0.7);
    opacity: 0;
  }
}

@keyframes feedback-bubble-incorrect {
  0% {
    transform: scale(0.3);
    opacity: 0;
  }
  15% {
    transform: scale(1.05);
    opacity: 1;
  }
  20% {
    transform: scale(1);
    opacity: 1;
  }
  75% {
    transform: scale(1);
    opacity: 1;
  }
  90% {
    transform: scale(0.95);
    opacity: 0.6;
  }
  100% {
    transform: scale(0.7);
    opacity: 0;
  }
}

@keyframes feedback-fade-out {
  0% {
    transform: scale(1);
    opacity: 1;
  }
  70% {
    transform: scale(0.95);
    opacity: 0.7;
  }
  100% {
    transform: scale(0.8);
    opacity: 0;
  }
}

/* Next button fade-in animation */
.fade-in-btn {
  animation: fade-in-down 1.8s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

@keyframes fade-in-down {
  0% {
    opacity: 0;
    transform: translateY(-100px) scale(0.3);
  }
  40% {
    opacity: 0.4;
    transform: translateY(-30px) scale(0.8);
  }
  80% {
    opacity: 0.9;
    transform: translateY(5px) scale(1.05);
  }
  100% {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

/* Answer options move down animation */
.options-section {
  transition: transform 1.8s cubic-bezier(0.175, 0.885, 0.32, 1.275), margin-top 1.8s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.options-section.move-down {
  transform: translateY(5px);
  margin-top: 0px;
}

@keyframes move-down-smooth {
  0% {
    transform: translateY(0);
    margin-top: 0;
  }
  100% {
    transform: translateY(5px);
    margin-top: 0px;
  }
}

/* Transition for next button fade-out */
.next-button-enter-active {
  transition: all 1.5s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}

.next-button-leave-active {
  transition: all 0.8s ease-in;
}

.next-button-enter-from {
  opacity: 0;
  transform: translateY(-80px) scale(0.5);
}

.next-button-enter-to {
  opacity: 1;
  transform: translateY(0) scale(1);
}

.next-button-leave-from {
  opacity: 1;
  transform: translateY(0) scale(1);
}

.next-button-leave-to {
  opacity: 0;
  transform: translateY(-30px) scale(0.8);
}

/* Score Section */
.score-section {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(248, 250, 252, 0.95) 100%);
  border-radius: 20px;
  padding: 25px;
  border: 3px solid #40E0D0;
  backdrop-filter: blur(10px);
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
}

.score-display {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.score-label {
  font-size: 14px;
  font-weight: 600;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.score-value {
  font-size: 24px;
  font-weight: 800;
  color: #1e293b;
}

.progress-bar {
  display: flex;
  gap: 8px;
  flex: 1;
  justify-content: center;
}

.progress-segment {
  width: 40px;
  height: 20px;
  border-radius: 10px;
  border: 2px solid #e2e8f0;
  transition: all 0.3s ease;
}

.progress-segment.completed-correct {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  border-color: #059669;
}

.progress-segment.completed-incorrect {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  border-color: #dc2626;
}

.progress-segment.current {
  background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
  border-color: #f59e0b;
  animation: pulse 1s ease-in-out infinite;
}

.progress-segment.pending {
  background: #f1f5f9;
  border-color: #cbd5e1;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

/* Result Section */
.result-section {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.8);
  backdrop-filter: blur(15px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.result-card {
  background: linear-gradient(135deg, #fff 0%, #f8fafc 100%);
  border-radius: 25px;
  padding: 50px;
  max-width: 500px;
  width: 90%;
  text-align: center;
  border: 3px solid #40E0D0;
  box-shadow: 0 30px 80px rgba(0, 0, 0, 0.3);
}

.result-title {
  font-size: clamp(24px, 4vw, 36px);
  font-weight: 800;
  color: #1e293b;
  margin-bottom: 30px;
}

.result-message {
  margin-bottom: 40px;
}

.result-icon {
  font-size: 64px;
  margin-bottom: 20px;
}

.result-text {
  font-size: 18px;
  font-weight: 600;
  color: #475569;
  line-height: 1.6;
  margin: 0;
}

.result-actions {
  display: flex;
  gap: 20px;
  justify-content: center;
  flex-wrap: wrap;
}

.retry-btn,
.home-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 15px 25px;
  font-size: 16px;
  font-weight: 700;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.retry-btn {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
}

.retry-btn:hover {
  background: linear-gradient(135deg, #059669 0%, #047857 100%);
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(16, 185, 129, 0.4);
}

.home-btn {
  background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
  color: white;
}

.home-btn:hover {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(251, 191, 36, 0.4);
}

.retry-btn .icon,
.home-btn .icon {
  width: 20px;
  height: 20px;
}

/* Responsive Design */
@media (max-width: 768px) {
  .quiz-content {
    padding: 20px 15px;
    gap: 20px;
  }

  .quiz-card {
    border-radius: 20px;
  }

  .question-section {
    padding: 30px 25px;
    min-height: 160px;
  }

  .options-section {
    padding: 25px;
    gap: 12px;
  }

  .option-btn {
    padding: 16px 20px;
    font-size: 16px;
  }

  .feedback-section {
    padding: 15px 25px 25px;
  }

  .score-section {
    padding: 20px;
    flex-direction: column;
    gap: 15px;
  }

  .progress-bar {
    justify-content: center;
  }

  .progress-segment {
    width: 30px;
    height: 16px;
  }

  .timer-section {
    bottom: 15px;
    right: 20px;
  }

  .result-card {
    padding: 40px 30px;
  }

  .result-actions {
    flex-direction: column;
    align-items: center;
  }

  .retry-btn,
  .home-btn {
    width: 100%;
    max-width: 250px;
  }
}

/* Skeleton Loading Styles */
.skeleton-badge {
  width: 150px;
  height: 36px;
  background: linear-gradient(90deg, rgba(255,255,255,0.1) 25%, rgba(255,255,255,0.2) 50%, rgba(255,255,255,0.1) 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
  border-radius: 20px;
  margin-bottom: 20px;
}

.skeleton-question {
  width: 100%;
}

.skeleton-line {
  height: 20px;
  background: linear-gradient(90deg, rgba(255,255,255,0.1) 25%, rgba(255,255,255,0.2) 50%, rgba(255,255,255,0.1) 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
  border-radius: 4px;
  margin-bottom: 12px;
}

.skeleton-line.short {
  width: 70%;
}

.skeleton-option {
  height: 64px;
  background: linear-gradient(90deg, rgba(0,0,0,0.05) 25%, rgba(0,0,0,0.1) 50%, rgba(0,0,0,0.05) 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
  border-radius: 15px;
  margin-bottom: 15px;
}

@keyframes skeleton-loading {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: -200% 0;
  }
}
</style>