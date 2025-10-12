<template>
  <main class="choose-page">
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

    <!-- Content -->
    <div class="content">
      <!-- Title Section - styled like QuizView -->
      <div class="title-section">
        <h1 class="main-title">Choose Your Ocean Buddy!</h1>
        <p class="subtitle">Pick an ocean friend to know about them</p>
      </div>

      <!-- Loading state with skeleton -->
      <div v-if="loading" class="animals-grid-container">
        <div class="animals-grid centered-grid">
          <div v-for="i in 3" :key="i" class="skeleton-card">
            <div class="skeleton-image"></div>
            <div class="skeleton-text"></div>
            <div class="skeleton-hint"></div>
          </div>
        </div>
      </div>

      <!-- Error state -->
      <div v-else-if="error" class="error-container">
        <p>❌ {{ error }}</p>
      </div>

      <!-- Animals grid with shuffle icon -->
      <div v-else class="animals-grid-container">
        <section class="animals-grid centered-grid">
          <div
            v-for="(animal, index) in animals"
            :key="animal.slug"
            class="animal-card"
            :class="`card-color-${index}`"
            @click="showConfirmation(animal)"
          >
            <div class="img-wrap">
              <img class="bouncing-img" :src="animal.cartoon_image_url" :alt="animal.name" />
            </div>
            <h3 class="name">{{ animal.name }}</h3>
            <p class="hint blinking-text">Tap to choose</p>
          </div>
        </section>

        <!-- Shuffle Icon -->
        <button
          class="shuffle-icon-btn"
          @click="randomizeAnimals"
          aria-label="Show different ocean buddies"
          title="Show me other buddies!"
        >
          <span class="shuffle-arrows">&raquo;</span>
        </button>
      </div>
    </div>

    <!-- Confirmation Modal -->
    <div v-if="selectedAnimal" class="modal-overlay" @click="cancelSelection">
      <div class="modal-content" @click.stop>
        <h3>Hi, I'm {{ selectedAnimal.name }}!</h3>
        <p>I'm {{ selectedAnimal.type }}. Sure you want to pick me as your buddy?</p>
        <div class="modal-actions">
          <button class="btn-cancel" @click="cancelSelection">Not Sure</button>
          <button class="btn-confirm" @click="confirmSelection">Sure!</button>
        </div>
      </div>
    </div>
  </main>
</template>

<script setup>
import { ref, onMounted, inject } from 'vue'
import { getAnimals } from '../services/api.js'

const challengeState = inject('challengeState', null)
const allAnimals = ref([])  // Store all animals from API
const animals = ref([])      // Display only 3 randomized animals
const loading = ref(true)
const error = ref(null)
const selectedAnimal = ref(null)

// Fisher-Yates shuffle algorithm
const shuffleArray = (array) => {
  const shuffled = [...array]
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]]
  }
  return shuffled
}

// Get 3 random animals from all animals
const randomizeAnimals = () => {
  if (allAnimals.value.length > 0) {
    const shuffled = shuffleArray(allAnimals.value)
    animals.value = shuffled.slice(0, 3)
  }
}

// Fetch animals from API
onMounted(async () => {
  try {
    loading.value = true
    error.value = null
    const data = await getAnimals('en')
    allAnimals.value = data
    randomizeAnimals()
  } catch (err) {
    console.error('Failed to load animals:', err)
    error.value = 'Failed to load ocean friends. Please try again later.'
  } finally {
    loading.value = false
  }
})

// Show confirmation dialog
const showConfirmation = (animal) => {
  selectedAnimal.value = animal
}

// Cancel selection
const cancelSelection = () => {
  selectedAnimal.value = null
}

// Confirm selection and navigate
const confirmSelection = () => {
  if (selectedAnimal.value && challengeState) {
    challengeState.navigate({
      type: 'selectAnimal',
      data: selectedAnimal.value
    })
  }
}
</script>

<style scoped>
.choose-page {
  position: relative;
  min-height: 100vh;
  width: 100%;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  padding-top: var(--nav-h, 80px);
}

/* Animated Background - same as QuizView */
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

/* Content */
.content {
  position: relative;
  z-index: 10;
  width: 100%;
  max-width: 1200px;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* Title Section - styled like QuizView */
.title-section {
  text-align: center;
  margin-bottom: 15px;
  padding: 10px 20px;
}

.main-title {
  font-size: clamp(28px, 5vw, 48px);
  font-weight: 900;
  color: #fff;
  text-shadow: 0 4px 8px rgba(0, 0, 0, 0.7), 0 2px 4px rgba(0, 0, 0, 0.8);
  margin-bottom: 10px;
  animation: bounce-text 2s ease-in-out infinite;
}

.subtitle {
  font-size: clamp(16px, 3vw, 24px);
  font-weight: 700;
  color: #fff;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.6);
  margin: 0;
  animation: fade-in 1s ease-in;
}

@keyframes bounce-text {
  0%, 100% { transform: translateY(0px); }
  25% { transform: translateY(-8px); }
  75% { transform: translateY(-4px); }
}

@keyframes fade-in {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Animals Grid Container with Shuffle Icon */
.animals-grid-container {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 20px;
  padding: 10px;
}

/* Animals Grid */
.animals-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 20px;
}

/* Centered Grid for 3 cards */
.centered-grid {
  grid-template-columns: repeat(3, minmax(160px, 220px));
  justify-content: center;
  max-width: 750px;
}

/* Shuffle Icon Button */
.shuffle-icon-btn {
  position: relative;
  background: rgba(192, 192, 192, 0.85);
  border: 3px solid rgba(255, 255, 255, 0.9);
  border-radius: 50%;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.2);
  flex-shrink: 0;
  animation: blink-icon 2s ease-in-out infinite;
}

.shuffle-icon-btn:hover {
  transform: scale(1.15);
  background: rgba(192, 192, 192, 1);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.3);
}

.shuffle-icon-btn:active {
  transform: scale(1.05);
}

/* Tooltip on hover */
.shuffle-icon-btn::before {
  content: "Show me other buddies!";
  position: absolute;
  top: 50%;
  right: calc(100% + 15px);
  transform: translateY(-50%);
  background: rgba(255, 255, 255, 0.98);
  color: #0369a1;
  padding: 10px 16px;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 900;
  white-space: nowrap;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.3s ease;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
  border: 3px solid #0369a1;
}

.shuffle-icon-btn:hover::before {
  opacity: 1;
}

/* Arrow pointing to button */
.shuffle-icon-btn::after {
  content: "";
  position: absolute;
  top: 50%;
  right: calc(100% + 3px);
  transform: translateY(-50%);
  border: 8px solid transparent;
  border-left-color: #0369a1;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.3s ease;
}

.shuffle-icon-btn:hover::after {
  opacity: 1;
}

.shuffle-arrows {
  font-size: 32px;
  font-weight: 900;
  color: #fff;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
  line-height: 1;
}

@keyframes blink-icon {
  0%, 100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.6;
    transform: scale(0.95);
  }
}

/* Animal Card */
.animal-card {
  background: rgba(255, 255, 255, 0.95);
  border: 3px solid rgba(255, 255, 255, 0.6);
  border-radius: 16px;
  padding: 12px;
  cursor: pointer;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  text-align: center;
  backdrop-filter: blur(10px);
}

.animal-card:hover {
  transform: translateY(-8px) scale(1.02);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
}

/* Colorful Card Backgrounds */
.card-color-0 {
  background: linear-gradient(135deg, #FFB6C1 0%, #FF69B4 50%, #FFB6C1 100%);
  border-color: #FF1493;
}

.card-color-1 {
  background: linear-gradient(135deg, #87CEEB 0%, #4682B4 50%, #87CEEB 100%);
  border-color: #1E90FF;
}

.card-color-2 {
  background: linear-gradient(135deg, #98FB98 0%, #3CB371 50%, #98FB98 100%);
  border-color: #228B22;
}

.img-wrap {
  aspect-ratio: 1;
  border-radius: 50%;
  overflow: hidden;
  background: rgba(255, 255, 255, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 8px;
  border: 3px solid rgba(255, 255, 255, 0.9);
}

.img-wrap img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

/* Bouncing Animation for Animal Photos */
.bouncing-img {
  animation: bounce-image 2s ease-in-out infinite;
}

@keyframes bounce-image {
  0%, 100% {
    transform: translateY(0px) scale(1);
  }
  25% {
    transform: translateY(-12px) scale(1.03);
  }
  50% {
    transform: translateY(0px) scale(1);
  }
  75% {
    transform: translateY(-6px) scale(1.01);
  }
}

.name {
  margin: 6px 0 3px;
  font-weight: 900;
  font-size: 16px;
  color: #0f172a;
  text-align: center;
}

.hint {
  margin: 0;
  font-size: 12px;
  color: #0369a1;
  font-weight: 700;
  text-align: center;
}

/* Blinking Animation for "Tap to choose" Text */
.blinking-text {
  animation: blink-text 1.5s ease-in-out infinite;
}

@keyframes blink-text {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.3;
  }
}

/* Skeleton Loading */
.skeleton-card {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 20px;
  padding: 16px;
  text-align: center;
}

.skeleton-image {
  aspect-ratio: 1;
  border-radius: 50%;
  background: linear-gradient(90deg, #e0e7ff 25%, #c7d2fe 50%, #e0e7ff 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
  margin-bottom: 12px;
}

.skeleton-text {
  height: 20px;
  background: linear-gradient(90deg, #e0e7ff 25%, #c7d2fe 50%, #e0e7ff 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
  border-radius: 4px;
  margin: 8px auto;
  width: 80%;
}

.skeleton-hint {
  height: 14px;
  background: linear-gradient(90deg, #e0e7ff 25%, #c7d2fe 50%, #e0e7ff 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
  border-radius: 4px;
  margin: 4px auto 0;
  width: 60%;
}

@keyframes skeleton-loading {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

/* Error State */
.error-container {
  text-align: center;
  padding: 40px;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 20px;
  color: #dc2626;
  font-size: 18px;
  font-weight: 700;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

/* Modal */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.6);
  display: grid;
  place-items: center;
  z-index: 1000;
  padding: 20px;
}

.modal-content {
  background: rgba(255, 255, 255, 0.98);
  border: 4px solid #0369a1;
  border-radius: 24px;
  padding: 32px 28px;
  max-width: 480px;
  width: 100%;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3);
  text-align: center;
  backdrop-filter: blur(10px);
  animation: modal-pop 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55);
}

@keyframes modal-pop {
  0% {
    transform: scale(0.8);
    opacity: 0;
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}

.modal-content h3 {
  margin: 0 0 12px;
  font-size: 28px;
  font-weight: 900;
  color: #0f172a;
}

.modal-content p {
  margin: 0 0 24px;
  font-size: 18px;
  color: #475569;
  line-height: 1.5;
}

.modal-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
}

.modal-actions button {
  padding: 14px 32px;
  border: 3px solid #000;
  border-radius: 12px;
  font-size: 18px;
  font-weight: 900;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-cancel {
  background: #f1f5f9;
  color: #475569;
}

.btn-cancel:hover {
  background: #e2e8f0;
  transform: translateY(-2px);
}

.btn-confirm {
  background: #0369a1;
  color: white;
}

.btn-confirm:hover {
  background: #0284c7;
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(3, 105, 161, 0.3);
}

/* Responsive */
@media (max-width: 768px) {
  .animals-grid-container {
    gap: 12px;
  }

  .centered-grid {
    grid-template-columns: repeat(3, minmax(120px, 1fr));
    gap: 12px;
  }

  .animal-card {
    padding: 12px;
  }

  .name {
    font-size: 15px;
  }

  .hint {
    font-size: 11px;
  }

  .shuffle-icon-btn {
    width: 50px;
    height: 50px;
  }

  .shuffle-arrows {
    font-size: 26px;
  }

  .shuffle-icon-btn::before {
    font-size: 14px;
    padding: 8px 12px;
  }

  .modal-content {
    padding: 24px 20px;
  }

  .modal-content h3 {
    font-size: 24px;
  }

  .modal-content p {
    font-size: 16px;
  }
}

@media (max-width: 480px) {
  .animals-grid-container {
    flex-direction: column;
    gap: 15px;
  }

  .centered-grid {
    grid-template-columns: 1fr;
    max-width: 280px;
  }

  .shuffle-icon-btn {
    width: 55px;
    height: 55px;
  }

  .shuffle-icon-btn::before {
    content: "Show other buddies!";
    right: auto;
    left: 50%;
    top: calc(100% + 12px);
    transform: translateX(-50%);
  }

  .shuffle-icon-btn::after {
    right: auto;
    left: 50%;
    top: calc(100% + 0px);
    transform: translateX(-50%) rotate(90deg);
  }
}
</style>
