<template>
  <div
    ref="guideElement"
    class="floating-guide"
    :style="{ left: position.x + 'px', top: position.y + 'px' }"
    @mousedown="startDrag"
    @touchstart="startDrag"
    role="button"
    tabindex="0"
    @keydown.enter="handleClick"
    :aria-label="ariaLabel"
  >
    <!-- Pulsing Ring -->
    <div class="pulse-ring"></div>

    <!-- Animal Circle -->
    <div
      class="animal-circle"
      @click.stop="toggleBubble"
      @touchstart="handleChildTouchStart"
      @touchend.stop="handleTouchEnd"
    >
      <img v-if="randomAnimal" :src="randomAnimal.cartoon" :alt="randomAnimal.name" />
    </div>

    <!-- Hover Me Text -->
    <div class="hover-text" @click.stop="toggleBubble" @touchstart="handleChildTouchStart" @touchend.stop="handleTouchEnd">
      Hover<br>On Me
    </div>

    <!-- Speech Bubble (shows on hover) -->
    <transition name="bubble-fade">
      <div v-show="isHovered" class="speech-bubble" @mousedown.stop @touchstart.stop>
        <p>{{ message }}</p>
        <button class="bubble-btn" @click.stop="handleClick">
          {{ buttonText }}
        </button>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'

// Props
const props = defineProps({
  // Array of animals to pick from
  availableAnimals: {
    type: Array,
    default: () => []
  },
  // Custom message to display in speech bubble
  message: {
    type: String,
    required: true
  },
  // Button text
  buttonText: {
    type: String,
    default: 'Click here!'
  },
  // Aria label for accessibility
  ariaLabel: {
    type: String,
    default: 'Floating guide'
  }
})

// Emit event when clicked
const emit = defineEmits(['click'])

// Pick a random animal when component mounts
const randomAnimal = ref(null)
const guideElement = ref(null)
const isHovered = ref(false)

// Dragging state
const isDragging = ref(false)
const hasMoved = ref(false)
const position = ref({ x: 0, y: 0 })
const dragStart = ref({ x: 0, y: 0 })

onMounted(() => {
  if (props.availableAnimals && props.availableAnimals.length > 0) {
    const randomIndex = Math.floor(Math.random() * props.availableAnimals.length)
    randomAnimal.value = props.availableAnimals[randomIndex]
  }

  // Set initial position (bottom-right)
  setInitialPosition()

  console.log('FloatingAnimalGuide mounted at position:', position.value)
  console.log('Window size:', window.innerWidth, 'x', window.innerHeight)

  // Add hover listeners for desktop
  if (guideElement.value) {
    guideElement.value.addEventListener('mouseenter', handleMouseEnter)
    guideElement.value.addEventListener('mouseleave', handleMouseLeave)

    // Test touch listener
    guideElement.value.addEventListener('touchstart', (e) => {
      console.log('DIRECT touchstart on guide element detected!')
    }, { passive: false })

    console.log('Guide element found, listeners added')
    console.log('Guide element z-index:', window.getComputedStyle(guideElement.value).zIndex)
    console.log('Guide element pointer-events:', window.getComputedStyle(guideElement.value).pointerEvents)
  } else {
    console.log('ERROR: Guide element not found!')
  }

  // Add click outside handler for mobile
  document.addEventListener('click', handleClickOutside)
  document.addEventListener('touchstart', handleClickOutside)
})

onBeforeUnmount(() => {
  if (guideElement.value) {
    guideElement.value.removeEventListener('mouseenter', handleMouseEnter)
    guideElement.value.removeEventListener('mouseleave', handleMouseLeave)
  }
  document.removeEventListener('mousemove', onDrag)
  document.removeEventListener('mouseup', stopDrag)
  document.removeEventListener('touchmove', onDrag)
  document.removeEventListener('touchend', stopDrag)
  document.removeEventListener('click', handleClickOutside)
  document.removeEventListener('touchstart', handleClickOutside)
})

const setInitialPosition = () => {
  const windowWidth = window.innerWidth
  const windowHeight = window.innerHeight

  // Adjust position based on screen size
  // On mobile, position closer to ensure it's visible and not cut off by navbar
  const isMobile = windowWidth <= 768
  const navbarHeight = 80 // Height of navbar

  // For mobile, ensure it's not too far right and positioned above navbar area
  const offsetX = isMobile ? windowWidth - 140 : windowWidth - 260
  // Position higher from bottom to avoid any interference, accounting for navbar
  const offsetY = isMobile ? windowHeight - 120 : windowHeight - 90

  position.value = {
    x: Math.max(10, Math.min(offsetX, windowWidth - 130)),
    y: Math.max(navbarHeight + 20, Math.min(offsetY, windowHeight - 70))
  }
}

const handleMouseEnter = () => {
  if (!isDragging.value) {
    isHovered.value = true
  }
}

const handleMouseLeave = () => {
  isHovered.value = false
}

const toggleBubble = (e) => {
  if (!isDragging.value) {
    isHovered.value = !isHovered.value
    e.stopPropagation()
  }
}

const handleClickOutside = (e) => {
  // Close bubble if clicking outside the guide element
  if (guideElement.value && !guideElement.value.contains(e.target)) {
    isHovered.value = false
  }
}

const handleChildTouchStart = (e) => {
  // Let the touch event propagate to parent for drag handling
  // but mark that we started from a child element
  console.log('Child touch start triggered')
  startDrag(e)
}

const handleTouchEnd = (e) => {
  // Handle touch end on mobile - only toggle if not dragging
  console.log('Touch end triggered, hasMoved:', hasMoved.value)
  if (!hasMoved.value) {
    isHovered.value = !isHovered.value
    console.log('Bubble toggled, isHovered:', isHovered.value)
  }
}

const handleClick = () => {
  if (!isDragging.value && !hasMoved.value) {
    emit('click')
  }
}

const startDrag = (e) => {
  // Don't set isDragging yet - wait for actual movement
  hasMoved.value = false

  const clientX = e.type === 'touchstart' ? e.touches[0].clientX : e.clientX
  const clientY = e.type === 'touchstart' ? e.touches[0].clientY : e.clientY

  dragStart.value = {
    x: clientX - position.value.x,
    y: clientY - position.value.y,
    startX: clientX,
    startY: clientY
  }

  document.addEventListener('mousemove', onDrag)
  document.addEventListener('mouseup', stopDrag)
  document.addEventListener('touchmove', onDrag)
  document.addEventListener('touchend', stopDrag)

  e.preventDefault()
}

const onDrag = (e) => {
  const clientX = e.type === 'touchmove' ? e.touches[0].clientX : e.clientX
  const clientY = e.type === 'touchmove' ? e.touches[0].clientY : e.clientY

  // Calculate distance moved from start position
  const movedX = Math.abs(clientX - dragStart.value.startX)
  const movedY = Math.abs(clientY - dragStart.value.startY)

  // Only treat as drag if moved more than 5px threshold
  if (movedX > 5 || movedY > 5) {
    if (!isDragging.value) {
      isDragging.value = true
      hasMoved.value = true
      isHovered.value = false // Hide bubble when actually dragging
    }

    let newX = clientX - dragStart.value.x
    let newY = clientY - dragStart.value.y

    // Constrain to viewport (accounting for the full width including text)
    const maxX = window.innerWidth - 120
    const maxY = window.innerHeight - 60

    newX = Math.max(0, Math.min(newX, maxX))
    newY = Math.max(0, Math.min(newY, maxY))

    position.value = { x: newX, y: newY }
  }
}

const stopDrag = () => {
  // Only add delay if actually dragged, otherwise allow immediate click
  if (hasMoved.value) {
    setTimeout(() => {
      isDragging.value = false
      hasMoved.value = false
    }, 100)
  } else {
    // No movement, treat as a click - reset immediately
    isDragging.value = false
    hasMoved.value = false
  }

  document.removeEventListener('mousemove', onDrag)
  document.removeEventListener('mouseup', stopDrag)
  document.removeEventListener('touchmove', onDrag)
  document.removeEventListener('touchend', stopDrag)
}
</script>

<style scoped>
.floating-guide {
  position: fixed;
  z-index: 10000;
  cursor: grab;
  transition: none;
  user-select: none;
  -webkit-user-select: none;
  touch-action: none;
  display: flex;
  align-items: center;
  gap: 8px;
}

.floating-guide:active {
  cursor: grabbing;
}

.floating-guide:focus {
  outline: 2px solid #22d3ee;
  outline-offset: 2px;
  border-radius: 50%;
}

/* Pulsing ring animation */
.pulse-ring {
  position: absolute;
  top: 50%;
  left: 25px;
  transform: translate(-50%, -50%);
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: rgba(34, 211, 238, 0.4);
  box-shadow: 0 0 0 0 rgba(34, 211, 238, 0.7);
  animation: pulse-ring 2s ease-out infinite;
  pointer-events: none;
}

@keyframes pulse-ring {
  0% {
    transform: translate(-50%, -50%) scale(0.95);
    box-shadow: 0 0 0 0 rgba(34, 211, 238, 0.7);
    opacity: 1;
  }
  50% {
    transform: translate(-50%, -50%) scale(1.05);
    box-shadow: 0 0 0 15px rgba(34, 211, 238, 0);
    opacity: 0.5;
  }
  100% {
    transform: translate(-50%, -50%) scale(0.95);
    box-shadow: 0 0 0 0 rgba(34, 211, 238, 0);
    opacity: 1;
  }
}

/* Animal circle with bouncing animation */
.animal-circle {
  position: relative;
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: linear-gradient(135deg, #22d3ee 0%, #06b6d4 100%);
  border: 1.5px solid #fff;
  box-shadow: 0 4px 14px rgba(34, 211, 238, 0.4), 0 2px 6px rgba(0, 0, 0, 0.2);
  overflow: hidden;
  animation: bounce-float 2.5s ease-in-out infinite;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  flex-shrink: 0;
}

.animal-circle img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 50%;
  pointer-events: none;
}

@keyframes bounce-float {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-8px);
  }
}

/* Hover Me Text */
.hover-text {
  font-size: 14px;
  font-weight: 900;
  color: #fff;
  text-align: center;
  line-height: 1.2;
  text-shadow:
    -2px -2px 0 #000,
    2px -2px 0 #000,
    -2px 2px 0 #000,
    2px 2px 0 #000,
    0 0 8px rgba(34, 211, 238, 0.8),
    0 0 16px rgba(34, 211, 238, 0.6),
    0 4px 8px rgba(0, 0, 0, 0.5);
  animation: bounce-float 2.5s ease-in-out infinite, glow-pulse 2s ease-in-out infinite;
  pointer-events: auto;
  cursor: pointer;
  white-space: nowrap;
  flex-shrink: 0;
  letter-spacing: 0.5px;
}

@keyframes glow-pulse {
  0%, 100% {
    text-shadow:
      -2px -2px 0 #000,
      2px -2px 0 #000,
      -2px 2px 0 #000,
      2px 2px 0 #000,
      0 0 8px rgba(34, 211, 238, 0.8),
      0 0 16px rgba(34, 211, 238, 0.6),
      0 4px 8px rgba(0, 0, 0, 0.5);
    opacity: 1;
  }
  50% {
    text-shadow:
      -2px -2px 0 #000,
      2px -2px 0 #000,
      -2px 2px 0 #000,
      2px 2px 0 #000,
      0 0 12px rgba(34, 211, 238, 1),
      0 0 24px rgba(34, 211, 238, 0.8),
      0 4px 8px rgba(0, 0, 0, 0.5);
    opacity: 0.9;
  }
}

/* Speech bubble */
.speech-bubble {
  position: absolute;
  bottom: 65px;
  left: 0;
  min-width: 240px;
  max-width: 280px;
  background: #fff;
  color: #0f172a;
  padding: 12px 14px;
  border-radius: 14px;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
  border: 2px solid #22d3ee;
  pointer-events: none;
  z-index: 10001;
}

.speech-bubble::after {
  content: '';
  position: absolute;
  bottom: -10px;
  left: 15px;
  width: 0;
  height: 0;
  border-left: 10px solid transparent;
  border-right: 10px solid transparent;
  border-top: 10px solid #fff;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.1));
}

.speech-bubble::before {
  content: '';
  position: absolute;
  bottom: -13px;
  left: 13px;
  width: 0;
  height: 0;
  border-left: 12px solid transparent;
  border-right: 12px solid transparent;
  border-top: 12px solid #22d3ee;
}

.speech-bubble p {
  margin: 0 0 10px 0;
  font-size: 13px;
  font-weight: 600;
  line-height: 1.5;
  color: #0f172a;
}

/* Bubble button */
.bubble-btn {
  width: 100%;
  padding: 8px 14px;
  background: linear-gradient(135deg, #22d3ee 0%, #06b6d4 100%);
  color: #fff;
  border: none;
  border-radius: 10px;
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 12px rgba(34, 211, 238, 0.3);
  pointer-events: auto;
}

.bubble-btn:hover {
  background: linear-gradient(135deg, #06b6d4 0%, #0891b2 100%);
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(34, 211, 238, 0.4);
}

.bubble-btn:active {
  transform: translateY(0);
  box-shadow: 0 2px 8px rgba(34, 211, 238, 0.3);
}

/* Bubble fade transition */
.bubble-fade-enter-active {
  transition: all 0.3s ease-out;
}

.bubble-fade-leave-active {
  transition: all 0.2s ease-in;
}

.bubble-fade-enter-from {
  opacity: 0;
  transform: translateY(10px) scale(0.9);
}

.bubble-fade-leave-to {
  opacity: 0;
  transform: translateY(5px) scale(0.95);
}

/* Mobile responsive */
@media (max-width: 768px) {
  .floating-guide {
    gap: 6px;
  }

  .animal-circle {
    width: 45px;
    height: 45px;
    border: 1px solid #fff;
  }

  .pulse-ring {
    width: 45px;
    height: 45px;
    left: 22.5px;
  }

  .hover-text {
    font-size: 12px;
  }

  .speech-bubble {
    bottom: 60px;
    min-width: 200px;
    max-width: 240px;
    padding: 10px 12px;
  }

  .speech-bubble::after {
    left: 12px;
    border-left: 8px solid transparent;
    border-right: 8px solid transparent;
    border-top: 8px solid #fff;
    bottom: -8px;
  }

  .speech-bubble::before {
    left: 10px;
    border-left: 10px solid transparent;
    border-right: 10px solid transparent;
    border-top: 10px solid #22d3ee;
    bottom: -11px;
  }

  .speech-bubble p {
    font-size: 12px;
  }

  .bubble-btn {
    padding: 7px 12px;
    font-size: 12px;
  }
}

/* Landscape mobile */
@media (max-width: 920px) and (orientation: landscape) {
  .floating-guide {
    gap: 5px;
  }

  .animal-circle {
    width: 40px;
    height: 40px;
    border: 1px solid #fff;
  }

  .pulse-ring {
    width: 40px;
    height: 40px;
    left: 20px;
  }

  .hover-text {
    font-size: 11px;
  }

  .speech-bubble {
    bottom: 55px;
    min-width: 180px;
    max-width: 220px;
    padding: 8px 10px;
  }

  .speech-bubble p {
    font-size: 11px;
  }

  .bubble-btn {
    padding: 6px 10px;
    font-size: 11px;
  }
}
</style>
