<template>
  <main class="home-page">
    <!-- Background Music -->
    <audio ref="backgroundMusic" loop preload="auto">
      <source src="/sound/playful-kids-toys-vlog-music-246603.mp3" type="audio/mpeg">
    </audio>

    <!-- Music Controls -->
    <div class="music-controls" @mouseenter="showVolumeControl = true" @mouseleave="showVolumeControl = false">
      <button
        class="music-control"
        @click="toggleMusic"
        :class="{ active: isPlaying }"
        :aria-label="$t('newHome.toggleMusic')"
      >
        <svg v-if="isPlaying" class="icon" viewBox="0 0 24 24" fill="currentColor">
          <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14H9V8h2v8zm4 0h-2V8h2v8z"/>
        </svg>
        <svg v-else class="icon" viewBox="0 0 24 24" fill="currentColor">
          <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 14.5v-9l6 4.5-6 4.5z"/>
        </svg>
      </button>

      <Transition name="volume-fade">
        <div v-if="showVolumeControl" class="volume-control">
          <input
            type="range"
            min="0"
            max="1"
            step="0.1"
            v-model="volume"
            @input="updateVolume"
            class="volume-slider"
          />
          <div class="volume-icon">🔊</div>
        </div>
      </Transition>
    </div>

    <!-- Animated Background -->
    <div class="animated-background">
      <div class="sky"></div>
      <div class="sun"></div>
      <div class="clouds">
        <div class="cloud cloud1"></div>
        <div class="cloud cloud2"></div>
        <div class="cloud cloud3"></div>
      </div>
      <div class="ocean">
        <div class="tidal-wave tidal1"></div>
        <div class="tidal-wave tidal2"></div>
        <div class="tidal-wave tidal3"></div>
        <div class="tidal-wave tidal4"></div>
      </div>
      <div class="beach"></div>

      <div class="floating-icons">
        <div class="floating-icon" v-for="i in 6" :key="i" :style="getFloatingIconStyle(i)">
          {{ getRandomEmoji() }}
        </div>
      </div>
    </div>

    <!-- Content 1: Welcome Section -->
    <Transition name="instant">
      <section v-if="currentContent === 1" class="welcome-content">
        <div class="welcome-text">
          <h1 class="main-title bounce-animation">{{ $t('newHome.welcomeTitle') }}</h1>
          <p class="subtitle wave-animation">{{ $t('newHome.welcomeSubtitle') }}</p>
        </div>
        <!-- Loading state -->
        <div v-if="isLoadingContent" class="simple-loading">
          <div class="loading-spinner"></div>
        </div>

        <!-- Error state -->
        <div v-else-if="contentError" class="error-section">
          <p class="error-text">{{ contentError }}</p>
          <button class="retry-btn" @click="goToContent2">
            Try Again
          </button>
        </div>

        <!-- Start button -->
        <button v-else class="start-btn aggressive-blink" @click="goToContent2" :disabled="isLoadingContent">
          <span>{{ $t('newHome.start') }}</span>
          <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M8 5v14l11-7z"/>
          </svg>
        </button>
      </section>
    </Transition>

    <!-- Content 2: Avatar Section -->
    <Transition name="fade">
      <section v-if="currentContent === 2" class="avatar-content">
        <div class="avatars-container">
          <div
            v-for="(animal, index) in animals"
            :key="animal.slug"
            class="avatar-image"
            :style="getAvatarCardStyle(index)"
          >
            <img :src="getAvatarImage(animal.cartoon)" :alt="animal.name" />
          </div>
        </div>

        <div class="speech-container">
          <div class="speech-bubble" @click="nextSpeech">
            <div class="speech-text" v-html="currentSpeechText"></div>
            <div class="speech-controls" v-if="!isTyping">
              <div class="back-text" v-if="currentSpeechIndex > 0" @click.stop="previousSpeech">{{ $t('newHome.back') }}</div>
              <div class="spacer" v-if="currentSpeechIndex === 0"></div>
              <div class="click-continue aggressive-blink-text">
                {{ isLastSpeech ? $t('newHome.restart') : $t('newHome.clickContinue') }}
              </div>
            </div>
          </div>
        </div>

      </section>
    </Transition>
  </main>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { getHomeSpeeches, getAnimals } from '@/services/api.js'

const { t, tm, locale } = useI18n()

// Audio control
const backgroundMusic = ref(null)
const isPlaying = ref(false)
const volume = ref(0.3)
const showVolumeControl = ref(false)

const toggleMusic = async () => {
  try {
    if (isPlaying.value) {
      backgroundMusic.value.pause()
      isPlaying.value = false
    } else {
      backgroundMusic.value.volume = volume.value
      await backgroundMusic.value.play()
      isPlaying.value = true
    }
  } catch (error) {
    console.log('Audio play failed:', error)
  }
}

const updateVolume = () => {
  if (backgroundMusic.value) {
    backgroundMusic.value.volume = volume.value
  }
}

// Content control
const currentContent = ref(1)

const goToContent2 = async () => {
  try {
    isLoadingContent.value = true
    contentError.value = null

    // Load dynamic content from API
    await Promise.all([
      loadSpeeches(),
      loadAnimals()
    ])

    // Only proceed to content 2 if loading succeeds
    currentContent.value = 2

    // Start speech sequence after transition
    setTimeout(() => {
      startSpeechSequence()
    }, 500)

  } catch (err) {
    console.error('Failed to load content:', err)
    contentError.value = 'Failed to load ocean adventure. Please check your connection and try again.'
  } finally {
    isLoadingContent.value = false
  }
}

// Dynamic animals data from API
const animalsData = ref([])

// Load animals for home page avatars
const loadAnimals = async () => {
  const data = await getAnimals(locale.value)
  // Transform API data for home page avatars (limit to 6 for display)
  animalsData.value = data.slice(0, 6).map(animal => ({
    slug: animal.slug,
    name: animal.name,
    cartoon: animal.cartoon_image_url // Use full URL from API
  }))
}

// Use dynamic animals data
const animals = computed(() => animalsData.value)

const getAvatarImage = (url) => url // Return full URL directly from API

// Dynamic speeches from API
const speechesData = ref([])

// Overall loading and error state
const isLoadingContent = ref(false)
const contentError = ref(null)

// Load speeches from API
const loadSpeeches = async () => {
  const data = await getHomeSpeeches(locale.value)
  speechesData.value = data.map(speech => speech.content)
}

// Speech system - using API data with fallback
const speechTexts = computed(() => speechesData.value)

const currentSpeechIndex = ref(0)
const currentSpeechText = ref('')
const isTyping = ref(false)
const skipTyping = ref(false)
const isLastSpeech = computed(() => currentSpeechIndex.value === speechTexts.value.length - 1)
const showArrows = ref(false)
const arrowText = ref('')

// Typing animation
const typeText = async (text) => {
  isTyping.value = true
  skipTyping.value = false
  currentSpeechText.value = ''

  for (let i = 0; i <= text.length; i++) {
    // If skip is requested, show full text immediately
    if (skipTyping.value) {
      currentSpeechText.value = text
      break
    }

    currentSpeechText.value = text.slice(0, i)
    await new Promise(resolve => setTimeout(resolve, 30))
  }

  isTyping.value = false

  // Show arrows for specific speech texts, reset on final speech
  if (currentSpeechIndex.value >= 1 && currentSpeechIndex.value <= 6) {
    showNavigationArrow()
  } else if (currentSpeechIndex.value === 7) {
    // Reset navbar animations on final "thank you" speech
    const allElements = document.querySelectorAll('.highlight-bounce')
    allElements.forEach(el => el.classList.remove('highlight-bounce'))
  }
}

// Watch for language changes and reload dynamic content
watch(locale, async () => {
  if (currentContent.value === 2) {
    try {
      await Promise.all([
        loadSpeeches(),
        loadAnimals()
      ])
      if (!isTyping.value) {
        // Update current speech text immediately when language changes
        currentSpeechText.value = speechTexts.value[currentSpeechIndex.value]
      }
    } catch (err) {
      console.error('Failed to reload content for language change:', err)
    }
  }
})

const nextSpeech = () => {
  // If typing is in progress, skip to the end
  if (isTyping.value) {
    skipTyping.value = true
    return
  }

  showArrows.value = false

  // If it's the last speech and user clicks restart
  if (isLastSpeech.value) {
    // Reset navbar animations
    const allElements = document.querySelectorAll('.highlight-bounce')
    allElements.forEach(el => el.classList.remove('highlight-bounce'))

    // Reset to first speech
    currentSpeechIndex.value = 0
  } else {
    currentSpeechIndex.value = (currentSpeechIndex.value + 1) % speechTexts.value.length
  }

  typeText(speechTexts.value[currentSpeechIndex.value])
}

const previousSpeech = () => {
  // If typing is in progress, skip to the end
  if (isTyping.value) {
    skipTyping.value = true
    return
  }

  showArrows.value = false

  // Reset navbar animations when going back to first speech
  if (currentSpeechIndex.value === 1) {
    const allElements = document.querySelectorAll('.highlight-bounce')
    allElements.forEach(el => el.classList.remove('highlight-bounce'))
  }

  currentSpeechIndex.value = currentSpeechIndex.value === 0
    ? speechTexts.value.length - 1
    : currentSpeechIndex.value - 1
  typeText(speechTexts.value[currentSpeechIndex.value])
}

const startSpeechSequence = () => {
  typeText(speechTexts.value[0])
}

// Navigation highlighting
const showNavigationArrow = () => {
  // Remove existing animations from all elements
  const allElements = document.querySelectorAll('.highlight-bounce')
  allElements.forEach(el => el.classList.remove('highlight-bounce'))

  // Map speech index to navigation elements (currentSpeechIndex is 1-based, so subtract 1)
  const speechIndex = currentSpeechIndex.value - 1

  if (speechIndex >= 0) {
    // Use setTimeout to ensure DOM is ready
    setTimeout(() => {
      // Find the appropriate dropdown trigger to animate
      let triggerToAnimate = null

      // Look in the navbar which should be in the header
      const navbar = document.querySelector('header.nav')
      if (navbar) {
        // Find all dropdown triggers in the links section
        const dropdownTriggers = navbar.querySelectorAll('.links .dropdown .dropdown-trigger')

        if (speechIndex <= 2) {
          // Speech 1, 2 & 3: Ocean Friends group (Meet Our Ocean Friends, Visit Ocean Friends Home, Ocean Stories)
          triggerToAnimate = dropdownTriggers[0] // First dropdown (Ocean Friends)
        } else if (speechIndex >= 3 && speechIndex <= 5) {
          // Speech 4, 5 & 6: Play & Practice group (Play Ocean Fun Games, Practice Ocean Quiz, Buddy Challenge)
          triggerToAnimate = dropdownTriggers[1] // Second dropdown (Play & Practice)
        }

        if (triggerToAnimate) {
          triggerToAnimate.classList.add('highlight-bounce')
        }
      }
    }, 100)
  }

  showArrows.value = true
}

// Avatar positioning with varied rotation angles
const getAvatarCardStyle = (index) => {
  const totalCards = animals.length
  const rotationAngles = [-15, 8, -12, 20, -8, 15, -10, 18] // Varied rotation angles
  const rotation = rotationAngles[index % rotationAngles.length]

  return {
    transform: `rotate(${rotation}deg)`,
    zIndex: totalCards - index,
    animationDelay: `${index * 0.2}s`
  }
}

// Floating icons
const floatingEmojis = ['🐠', '🐢', '🦈', '🐙', '⭐', '🌊']
const getRandomEmoji = () => floatingEmojis[Math.floor(Math.random() * floatingEmojis.length)]

const getFloatingIconStyle = (index) => ({
  left: Math.random() * 100 + '%',
  animationDelay: Math.random() * 5 + 's',
  fontSize: (12 + Math.random() * 8) + 'px'
})



onMounted(() => {
  // Simple fade-in animation without anime.js for now
  const mainTitle = document.querySelector('.main-title')
  const subtitle = document.querySelector('.subtitle')
  const startBtn = document.querySelector('.start-btn')

  if (mainTitle) {
    setTimeout(() => mainTitle.style.opacity = '1', 300)
  }
  if (subtitle) {
    setTimeout(() => subtitle.style.opacity = '1', 600)
  }
  if (startBtn) {
    setTimeout(() => startBtn.style.opacity = '1', 900)
  }

  // Setup audio when component mounts and try autoplay
  if (backgroundMusic.value) {
    backgroundMusic.value.volume = 0.3
    // Try to autoplay music (may be blocked by browser)
    setTimeout(async () => {
      try {
        await backgroundMusic.value.play()
        isPlaying.value = true
      } catch (error) {
        console.log('Autoplay blocked by browser. User interaction required.')
      }
    }, 1000)
  }
})

onBeforeUnmount(() => {
  // Cleanup audio when component unmounts
  if (backgroundMusic.value) {
    backgroundMusic.value.pause()
    backgroundMusic.value.currentTime = 0
  }

})
</script>

<style scoped>
.home-page {
  position: relative;
  min-height: 100vh;
  width: 100%;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  padding-top: var(--nav-h);
  cursor: auto;
}

.home-page > .fade-enter-active,
.home-page > .fade-leave-active {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 100%;
  max-width: 1000px;
}

/* Music Controls */
.music-controls {
  position: fixed;
  top: 100px;
  left: 20px;
  z-index: 1000;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.music-control {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  border: none;
  background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 20px rgba(251, 191, 36, 0.4);
  transition: all 0.3s ease;
}

.music-control:hover {
  transform: scale(1.1);
  box-shadow: 0 6px 25px rgba(251, 191, 36, 0.5);
}

.music-control .icon {
  width: 24px;
  height: 24px;
}

.volume-control {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
  background: rgba(0, 0, 0, 0.7);
  padding: 10px;
  border-radius: 10px;
  backdrop-filter: blur(10px);
}

.volume-slider {
  writing-mode: bt-lr;
  -webkit-appearance: slider-vertical;
  width: 30px;
  height: 80px;
  background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
  outline: none;
  border-radius: 15px;
}

.volume-icon {
  font-size: 18px;
}

/* Volume control transitions */
.volume-fade-enter-active,
.volume-fade-leave-active {
  transition: all 0.3s ease;
}

.volume-fade-enter-from {
  opacity: 0;
  transform: translateY(-10px);
}

.volume-fade-leave-to {
  opacity: 0;
  transform: translateY(-10px);
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

.clouds {
  position: absolute;
  inset: 0;
}

.cloud {
  position: absolute;
  background: white;
  border-radius: 50px;
  opacity: 0.8;
}

.cloud:before, .cloud:after {
  content: '';
  position: absolute;
  background: white;
  border-radius: 50px;
}

.cloud1 {
  width: 80px;
  height: 40px;
  top: 20%;
  left: 10%;
  animation: float-cloud 20s linear infinite;
}

.cloud1:before {
  width: 50px;
  height: 40px;
  top: -20px;
  left: 10px;
}

.cloud1:after {
  width: 60px;
  height: 30px;
  top: -10px;
  right: 15px;
}

.cloud2 {
  width: 60px;
  height: 30px;
  top: 30%;
  right: 20%;
  animation: float-cloud 25s linear infinite reverse;
}

.cloud2:before {
  width: 40px;
  height: 30px;
  top: -15px;
  left: 8px;
}

.cloud2:after {
  width: 45px;
  height: 25px;
  top: -8px;
  right: 12px;
}

.cloud3 {
  width: 100px;
  height: 50px;
  top: 10%;
  left: 60%;
  animation: float-cloud 30s linear infinite;
}

.cloud3:before {
  width: 60px;
  height: 50px;
  top: -25px;
  left: 12px;
}

.cloud3:after {
  width: 70px;
  height: 40px;
  top: -12px;
  right: 18px;
}

@keyframes float-cloud {
  from { transform: translateX(-150px); }
  to { transform: translateX(calc(100vw + 150px)); }
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

.tidal3 {
  bottom: 20%;
  animation-duration: 18s;
  opacity: 0.4;
  animation-delay: -6s;
}

.tidal4 {
  bottom: 0%;
  animation-duration: 20s;
  opacity: 0.3;
  animation-delay: -9s;
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

.floating-icons {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.floating-icon {
  position: absolute;
  animation: float-up 8s linear infinite;
  opacity: 0.7;
}

@keyframes float-up {
  0% {
    transform: translateY(100vh) rotate(0deg);
    opacity: 0;
  }
  10% {
    opacity: 0.7;
  }
  90% {
    opacity: 0.7;
  }
  100% {
    transform: translateY(-100px) rotate(360deg);
    opacity: 0;
  }
}

/* Content Sections */
.welcome-content,
.avatar-content {
  position: relative;
  z-index: 10;
  text-align: center;
  width: 100%;
  max-width: 1200px;
  padding: 40px;
}

.simple-loading {
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 30px auto;
  width: 100px;
  height: 100px;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 50%;
  backdrop-filter: blur(15px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.loading-spinner {
  width: 60px;
  height: 60px;
  border: 5px solid rgba(255, 255, 255, 0.3);
  border-top: 5px solid #ffffff;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

.welcome-content .error-section {
  text-align: center;
  margin-top: 20px;
  padding: 30px;
  background: rgba(255, 107, 107, 0.15);
  border-radius: 16px;
  backdrop-filter: blur(15px);
  border: 1px solid rgba(255, 107, 107, 0.3);
}

.welcome-content .error-text {
  color: #ffffff;
  font-size: 16px;
  font-weight: 600;
  margin: 0 0 16px 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
}

.welcome-content .retry-btn {
  background: #22d3ee;
  color: #083344;
  border: none;
  padding: 12px 24px;
  border-radius: 12px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 16px;
}

.welcome-content .retry-btn:hover {
  background: #0891b2;
  transform: translateY(-2px);
}

/* Welcome Content */
.welcome-text {
  margin-bottom: 40px;
}

.main-title {
  font-size: clamp(48px, 8vw, 96px);
  font-weight: 900;
  color: #fff;
  text-shadow:
    0 4px 8px rgba(0, 0, 0, 0.7),
    0 2px 4px rgba(0, 0, 0, 0.8);
  margin-bottom: 20px;
  opacity: 0;
  transition: opacity 0.8s ease;
  position: relative;
}

.subtitle {
  font-size: clamp(18px, 3vw, 28px);
  font-weight: 700;
  color: #fff;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.4);
  margin-bottom: 0;
  max-width: 800px;
  margin-left: auto;
  margin-right: auto;
  opacity: 0;
  transition: opacity 0.8s ease;
}

@keyframes text-shimmer {
  0%, 100% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
}

.start-btn {
  display: inline-flex;
  align-items: center;
  gap: 12px;
  padding: 20px 40px;
  font-size: 24px;
  font-weight: 800;
  color: #fff;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  border: none;
  border-radius: 25px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 8px 30px rgba(16, 185, 129, 0.4);
  text-transform: uppercase;
  letter-spacing: 1px;
  opacity: 0;
  animation: start-btn-blink 2s ease-in-out infinite;
}

.start-btn:hover {
  transform: translateY(-3px) scale(1.05);
  box-shadow: 0 12px 40px rgba(16, 185, 129, 0.5);
}

.start-btn .icon {
  width: 28px;
  height: 28px;
}

@keyframes start-btn-blink {
  0%, 100% {
    opacity: 1;
    box-shadow: 0 8px 30px rgba(16, 185, 129, 0.4);
  }
  50% {
    opacity: 0.7;
    box-shadow: 0 8px 30px rgba(16, 185, 129, 0.7);
  }
}


/* Enhanced Text Animations */
.bounce-animation {
  animation: bounce-text 2s ease-in-out infinite;
}

.wave-animation {
  animation: wave-text 3s ease-in-out infinite;
}

@keyframes bounce-text {
  0%, 100% {
    transform: translateY(0px);
  }
  25% {
    transform: translateY(-8px);
  }
  75% {
    transform: translateY(-4px);
  }
}

@keyframes wave-text {
  0%, 100% {
    transform: rotate(0deg);
  }
  25% {
    transform: rotate(1deg);
  }
  75% {
    transform: rotate(-1deg);
  }
}

/* Aggressive Blinking for Start Button */
.aggressive-blink {
  animation: aggressive-blink 1s ease-in-out infinite !important;
}

@keyframes aggressive-blink {
  0%, 100% {
    opacity: 1;
    box-shadow: 0 8px 30px rgba(16, 185, 129, 0.4);
    transform: scale(1);
  }
  50% {
    opacity: 0.4;
    box-shadow: 0 12px 40px rgba(16, 185, 129, 0.8);
    transform: scale(1.02);
  }
}

/* Avatar Content */
.avatar-content {
  display: grid;
  grid-template-columns: 1fr 1.2fr;
  gap: 30px;
}

.avatar-content .error-state {
  grid-column: 1 / -1;
  text-align: center;
  color: white;
  padding: 40px;
}

.avatar-content .retry-btn {
  background: #22d3ee;
  color: #083344;
  border: none;
  padding: 12px 24px;
  border-radius: 12px;
  font-weight: 700;
  cursor: pointer;
  margin-top: 16px;
  transition: all 0.2s ease;
}

.avatar-content .retry-btn:hover {
  background: #0891b2;
  transform: translateY(-2px);
  align-items: center;
  justify-content: center;
  min-height: 70vh;
  max-width: 1000px;
  margin: 0 auto;
}

.avatars-container {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
  flex-wrap: wrap;
  max-width: 600px;
  margin: 0 auto;
  padding: 20px;
}

.avatar-image {
  width: 100px;
  height: 100px;
  transition: all 0.3s ease;
  cursor: pointer;
  opacity: 0;
  animation: avatar-float-in 0.6s ease forwards, water-wave-bounce 3s ease-in-out infinite;
  animation-delay: 0s, 0.6s;
}

.avatar-image:hover {
  transform: translateY(-10px) scale(1.1) !important;
}

.avatar-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  filter: drop-shadow(0 8px 16px rgba(0, 0, 0, 0.4));
  border-radius: 50%;
  background: #fff;
}

@keyframes avatar-float-in {
  0% {
    opacity: 0;
    transform: translate(var(--start-x, 0), var(--start-y, 0)) scale(0.5);
  }
  100% {
    opacity: 1;
    transform: translate(var(--end-x, 0), var(--end-y, 0)) scale(1);
  }
}

@keyframes water-wave-bounce {
  0%, 100% {
    transform: translateY(0px);
  }
  25% {
    transform: translateY(-8px);
  }
  50% {
    transform: translateY(-4px);
  }
  75% {
    transform: translateY(-12px);
  }
}

.speech-container {
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
}

.speech-bubble {
  background: linear-gradient(135deg, #fff 0%, #f8fafc 100%);
  border-radius: 25px;
  padding: 30px 35px;
  max-width: 500px;
  box-shadow: 0 15px 40px rgba(0, 0, 0, 0.15);
  border: 3px solid #0ea5e9;
  position: relative;
  cursor: pointer;
  transition: all 0.3s ease;
}

.speech-bubble:hover {
  transform: translateY(-5px);
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.2);
}

.speech-bubble::before {
  content: '';
  position: absolute;
  left: -20px;
  top: 50%;
  transform: translateY(-50%);
  width: 0;
  height: 0;
  border-top: 20px solid transparent;
  border-bottom: 20px solid transparent;
  border-right: 20px solid #0ea5e9;
}

.speech-bubble::after {
  content: '';
  position: absolute;
  left: -17px;
  top: 50%;
  transform: translateY(-50%);
  width: 0;
  height: 0;
  border-top: 17px solid transparent;
  border-bottom: 17px solid transparent;
  border-right: 17px solid #fff;
}

.speech-text {
  font-size: 18px;
  font-weight: 600;
  color: #1e293b;
  line-height: 1.6;
  margin-bottom: 10px;
}

.speech-text .nav-highlight {
  font-weight: 800 !important;
  color: #f59e0b !important;
  font-family: 'Fredoka', sans-serif !important;
}

/* Speech Controls */
.speech-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 15px;
  padding-top: 10px;
  border-top: 1px solid rgba(14, 165, 233, 0.2);
}

.spacer {
  flex: 1;
}

.back-text {
  font-size: 12px;
  font-weight: 600;
  color: #7c3aed;
  font-style: italic;
  cursor: pointer;
  transition: all 0.3s ease;
  animation: aggressive-blink-text 1.5s ease-in-out infinite;
}

.back-text:hover {
  color: #5b21b6;
  transform: scale(1.05);
}

.click-continue {
  font-size: 12px;
  font-weight: 600;
  color: #dc2626;
  font-style: italic;
}

.aggressive-blink-text {
  animation: aggressive-blink-text 1.5s ease-in-out infinite;
}

@keyframes aggressive-blink-text {
  0%, 100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.3;
    transform: scale(1.02);
  }
}

@keyframes pulse-text {
  0%, 100% { opacity: 0.7; }
  50% { opacity: 1; }
}


/* Transitions */
.fade-enter-active {
  transition: all 1.2s cubic-bezier(0.25, 0.46, 0.45, 0.94);
  position: absolute;
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
}

.fade-leave-active {
  transition: all 0.8s cubic-bezier(0.55, 0.085, 0.68, 0.53);
  position: absolute;
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
}

.fade-enter-from {
  opacity: 0;
  transform: translate(-50%, -50%) scale(0.9);
  filter: blur(4px);
}

.fade-leave-to {
  opacity: 0;
  transform: translate(-50%, -50%) scale(1.1);
  filter: blur(4px);
}

/* Instant Transition for Content 1 */
.instant-enter-active {
  transition: none;
}

.instant-leave-active {
  transition: none;
}

.instant-enter-from,
.instant-leave-to {
  opacity: 0;
}

/* Responsive Design */
@media (max-width: 1024px) {
  .avatar-content {
    grid-template-columns: 1fr;
    gap: 40px;
    text-align: center;
  }

  .avatars-container {
    gap: 15px;
    max-width: 400px;
    padding: 15px;
  }

  .avatar-image {
    width: 80px;
    height: 80px;
  }
}

@media (max-width: 768px) {
  .home-page {
    padding-top: calc(var(--nav-h) + 20px);
  }

  .welcome-content,
  .avatar-content {
    padding: 20px;
  }

  .start-btn {
    padding: 16px 32px;
    font-size: 20px;
  }

  .speech-bubble {
    padding: 20px 25px;
    max-width: 90%;
  }

  .speech-text {
    font-size: 16px;
  }

  .music-control {
    width: 48px;
    height: 48px;
    top: calc(var(--nav-h) + 10px);
    left: 10px;
  }

  .music-control .icon {
    width: 20px;
    height: 20px;
  }
}
</style>