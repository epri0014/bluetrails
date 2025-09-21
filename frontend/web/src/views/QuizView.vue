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
        <h1 class="quiz-title">Ocean Friends Quiz!</h1>
        <p class="quiz-subtitle">Test your knowledge about our ocean friends and learn how to protect them!</p>
      </div>

      <!-- Loading State -->
      <div v-if="isLoading" class="loading-section">
        <div class="loading-spinner">🌊</div>
        <p class="loading-text">Loading Ocean Quiz...</p>
      </div>

      <!-- Quiz Card -->
      <div v-else-if="!showResult && currentQuestion" class="quiz-card">
        <!-- Question Section -->
        <div class="question-section" :style="{ background: getQuestionBackground() }">
          <div class="question-content">
            <div v-if="!showFunFact" class="question-front">
              <div class="category-badge">
                <span class="category-icon">{{ getCategoryIcon(currentQuestion.category) }}</span>
                <span class="category-text">{{ getCategoryName(currentQuestion.category) }}</span>
              </div>
              <h2 class="question-text">{{ currentQuestion.question }}</h2>
            </div>

            <div v-else class="question-back">
              <div class="fun-fact-header">
                <span class="fun-fact-icon">💡</span>
                <span class="fun-fact-title">Fun Fact</span>
              </div>
              <p class="fun-fact-text">{{ currentQuestion.funFact }}</p>
            </div>
          </div>
        </div>

        <!-- Answer Options -->
        <div class="options-section">
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

        <!-- Feedback Section -->
        <div v-if="selectedAnswer" class="feedback-section">
          <div class="feedback-bubble" :class="{ correct: isCorrect, incorrect: !isCorrect }">
            <div class="feedback-text">
              <span v-if="isCorrect" class="feedback-message correct">Correct!</span>
              <span v-else class="feedback-message incorrect">
                Oops! The correct answer is {{ currentQuestion.correctAnswer }}.
              </span>
            </div>
          </div>

          <button class="next-btn" @click="nextQuestion">
            {{ currentQuestionIndex === selectedQuestions.length - 1 ? 'Finish Quiz' : 'Next Question' }}
          </button>
        </div>

        <!-- Timer -->
        <div class="timer-section">
          <div class="timer">
            <span class="timer-label">Time Left:</span>
            <span class="timer-value">{{ formatTime(timeLeft) }}</span>
          </div>
        </div>
      </div>

      <!-- Score Section -->
      <div v-if="!isLoading" class="score-section">
        <div class="score-display">
          <span class="score-label">Score:</span>
          <span class="score-value">{{ score }} out of {{ totalQuestions }}</span>
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
          <h2 class="result-title">You scored {{ score }} out of {{ totalQuestions }}!</h2>

          <div class="result-message">
            <div class="result-icon">{{ getResultIcon() }}</div>
            <p class="result-text">{{ getResultMessage() }}</p>
          </div>

          <div class="result-actions">
            <button class="retry-btn" @click="retakeQuiz">
              <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
                <path d="M17.65 6.35C16.2 4.9 14.21 4 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08c-.82 2.33-3.04 4-5.65 4-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"/>
              </svg>
              Retake Quiz
            </button>

            <button class="home-btn" @click="goHome">
              <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
                <path d="m20 8-6-5.26a3 3 0 0 0-4 0L4 8a3 3 0 0 0-1 2.26V19a3 3 0 0 0 3 3h12a3 3 0 0 0 3-3v-8.74A3 3 0 0 0 20 8ZM14 20h-4v-6h4v6Z"/>
              </svg>
              Go to Homepage
            </button>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { quizQuestions, getCategoryBackground, getCategoryIcon } from '../data/quizQuestions.js'

const router = useRouter()

// Quiz state
const currentQuestionIndex = ref(0)
const selectedQuestions = ref([])
const selectedAnswer = ref(null)
const score = ref(0)
const timeLeft = ref(120) // 2 minutes in seconds
const showResult = ref(false)
const showFunFact = ref(false)
const totalQuestions = 5
const answerHistory = ref([])
const isLoading = ref(true)

// Timer
let timer = null

// Computed properties
const currentQuestion = computed(() => {
  const question = selectedQuestions.value[currentQuestionIndex.value]
  return question || null
})

const isCorrect = computed(() => {
  if (!currentQuestion.value || !selectedAnswer.value) return false
  return selectedAnswer.value === currentQuestion.value.correctAnswer
})

// Initialize quiz
const initializeQuiz = () => {
  try {
    console.log('Initializing quiz')

    // Randomly select 5 questions
    const shuffled = [...quizQuestions].sort(() => 0.5 - Math.random())
    selectedQuestions.value = shuffled.slice(0, totalQuestions)

    // Reset state
    currentQuestionIndex.value = 0
    selectedAnswer.value = null
    score.value = 0
    timeLeft.value = 120
    showResult.value = false
    showFunFact.value = false
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
    timeLeft.value--
    if (timeLeft.value <= 0) {
      endQuiz()
    }
  }, 1000)
}

const selectAnswer = (answer) => {
  if (selectedAnswer.value !== null || !currentQuestion.value) return

  selectedAnswer.value = answer
  const correct = answer === currentQuestion.value.correctAnswer

  if (correct) {
    score.value++
  }

  // Track answer for progress bar
  answerHistory.value.push({
    questionIndex: currentQuestionIndex.value,
    correct: correct
  })

  // Show fun fact after 1 second
  setTimeout(() => {
    showFunFact.value = true
  }, 1000)
}

const nextQuestion = () => {
  showFunFact.value = false
  selectedAnswer.value = null

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
  showResult.value = true
}

const retakeQuiz = () => {
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
  if (!currentQuestion.value) return getCategoryBackground('ocean')
  return getCategoryBackground(currentQuestion.value.category)
}

const getCategoryName = (category) => {
  const names = {
    waste: 'Waste & Pollution',
    ocean: 'Ocean Protection',
    animal: 'Marine Animals'
  }
  return names[category] || 'Ocean Protection'
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
    return 'Keep trying! You can learn more about our ocean friends and try again.'
  } else if (score.value <= 4) {
    return 'Great job! You have a good understanding of our ocean friends.'
  }
  return 'Excellent! You are an ocean hero!'
}

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
  padding: 40px 20px;
  display: flex;
  flex-direction: column;
  gap: 30px;
}

/* Title Section */
.title-section {
  text-align: center;
  margin-bottom: 20px;
}

.quiz-title {
  font-size: clamp(36px, 6vw, 64px);
  font-weight: 900;
  color: #fff;
  text-shadow: 0 4px 8px rgba(0, 0, 0, 0.7), 0 2px 4px rgba(0, 0, 0, 0.8);
  margin-bottom: 15px;
  animation: bounce-text 2s ease-in-out infinite;
}

.quiz-subtitle {
  font-size: clamp(16px, 2.5vw, 24px);
  font-weight: 700;
  color: #fff;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.4);
  max-width: 600px;
  margin: 0 auto;
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
}

.question-content {
  width: 100%;
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
  animation: glow-green 1s ease-in-out;
}

.option-btn.incorrect {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  border-color: #dc2626;
  animation: shake 0.5s ease-in-out;
}

.option-btn.neutral {
  opacity: 0.6;
}

@keyframes glow-green {
  0%, 100% { box-shadow: 0 8px 25px rgba(16, 185, 129, 0.3); }
  50% { box-shadow: 0 8px 25px rgba(16, 185, 129, 0.6); }
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-5px); }
  75% { transform: translateX(5px); }
}

/* Feedback Section */
.feedback-section {
  padding: 20px 40px 30px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}

.feedback-bubble {
  background: linear-gradient(135deg, #fff 0%, #f8fafc 100%);
  border-radius: 20px;
  padding: 20px 30px;
  border: 3px solid;
  animation: zoom-in 0.5s ease-out;
}

.feedback-bubble.correct {
  border-color: #10b981;
  color: #065f46;
}

.feedback-bubble.incorrect {
  border-color: #ef4444;
  color: #991b1b;
}

.feedback-message {
  font-size: 18px;
  font-weight: 700;
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

@keyframes zoom-in {
  0% { transform: scale(0.8); opacity: 0; }
  100% { transform: scale(1); opacity: 1; }
}

/* Timer Section */
.timer-section {
  position: absolute;
  bottom: 20px;
  right: 30px;
}

.timer {
  background: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 8px 16px;
  border-radius: 20px;
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  gap: 8px;
}

.timer-label {
  font-size: 14px;
  font-weight: 600;
}

.timer-value {
  font-size: 18px;
  font-weight: 800;
  font-family: monospace;
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
</style>