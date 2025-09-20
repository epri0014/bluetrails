<template>
  <header class="nav" :class="{ raised }" role="banner">
    <div class="wrap">
      <!-- Home button (left) -->
      <RouterLink to="/" class="home-btn" aria-label="Home" @click="restartHomepage">
        <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
          <path d="m20 8-6-5.26a3 3 0 0 0-4 0L4 8a3 3 0 0 0-1 2.26V19a3 3 0 0 0 3 3h12a3 3 0 0 0 3-3v-8.74A3 3 0 0 0 20 8ZM14 20h-4v-6h4v6Z"/>
        </svg>
      </RouterLink>

      <!-- Desktop links (right) -->
      <nav class="links" aria-label="Primary">
        <!-- Language Selector -->
        <LanguageSelector />
        <!-- Ocean Friends Dropdown -->
        <div class="dropdown" @mouseenter="showOceanFriendsDropdown = true" @mouseleave="hideOceanFriendsDropdown">
          <div class="link dropdown-trigger" :class="{ 'highlight-bounce': shouldHighlightOceanFriends }">
            <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 2C8.13 2 5 5.13 5 9c0 2.38 1.19 4.47 3 5.74V17c0 .55.45 1 1 1s1-.45 1-1v-2.26c.64.16 1.31.26 2 .26s1.36-.1 2-.26V17c0 .55.45 1 1 1s1-.45 1-1v-2.26c1.81-1.27 3-3.36 3-5.74 0-3.87-3.13-7-7-7zm-2 7c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm4 0c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1z"/>
            </svg>
            <span>{{ $t('nav.oceanFriends') }}</span>
            <svg class="dropdown-arrow" viewBox="0 0 24 24" fill="currentColor">
              <path d="M7 10l5 5 5-5z"/>
            </svg>
          </div>
          <Transition name="dropdown">
            <div v-if="showOceanFriendsDropdown" class="dropdown-menu" @mouseenter="keepOceanFriendsDropdown" @mouseleave="hideOceanFriendsDropdown">
              <RouterLink class="dropdown-item" to="/animals" data-nav-index="0" @click="resetNavbarStates">
                <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M12 2C8.13 2 5 5.13 5 9c0 2.38 1.19 4.47 3 5.74V17c0 .55.45 1 1 1s1-.45 1-1v-2.26c.64.16 1.31.26 2 .26s1.36-.1 2-.26V17c0 .55.45 1 1 1s1-.45 1-1v-2.26c1.81-1.27 3-3.36 3-5.74 0-3.87-3.13-7-7-7zm-2 7c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm4 0c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1z"/>
                </svg>
                <span>{{ $t('nav.meetOceanFriends') }}</span>
              </RouterLink>
              <RouterLink class="dropdown-item" to="/water" data-nav-index="1" @click="resetNavbarStates">
                <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M12 2S6.5 8 6.5 14c0 3.04 2.46 5.5 5.5 5.5s5.5-2.46 5.5-5.5C17.5 8 12 2 12 2z"/>
                </svg>
                <span>{{ $t('nav.visitOceanHome') }}</span>
              </RouterLink>
            </div>
          </Transition>
        </div>

        <!-- Play & Practice Dropdown -->
        <div class="dropdown" @mouseenter="showPlayPracticeDropdown = true" @mouseleave="hidePlayPracticeDropdown">
          <div class="link dropdown-trigger" :class="{ 'highlight-bounce': shouldHighlightPlayPractice }">
            <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
              <path d="M17.5 7c-1.66 0-3 1.34-3 3 0 .35.07.69.18 1H16v2h-1.32c-.11.31-.18.65-.18 1 0 1.66 1.34 3 3 3s3-1.34 3-3V10c0-1.66-1.34-3-3-3zM8 9c0-1.66-1.34-3-3-3S2 7.34 2 10v3c0 1.66 1.34 3 3 3s3-1.34 3-3c0-.35-.07-.69-.18-1H9v-2H7.82c.11-.31.18-.65.18-1zm8-2V5c0-.55-.45-1-1-1H9c-.55 0-1 .45-1 1v2c0 .55.45 1 1 1h6c.55 0 1-.45 1-1z"/>
            </svg>
            <span>{{ $t('nav.playPractice') }}</span>
            <svg class="dropdown-arrow" viewBox="0 0 24 24" fill="currentColor">
              <path d="M7 10l5 5 5-5z"/>
            </svg>
          </div>
          <Transition name="dropdown">
            <div v-if="showPlayPracticeDropdown" class="dropdown-menu" @mouseenter="keepPlayPracticeDropdown" @mouseleave="hidePlayPracticeDropdown">
              <RouterLink class="dropdown-item" to="/game" data-nav-index="2">
                <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M17.5 7c-1.66 0-3 1.34-3 3 0 .35.07.69.18 1H16v2h-1.32c-.11.31-.18.65-.18 1 0 1.66 1.34 3 3 3s3-1.34 3-3V10c0-1.66-1.34-3-3-3zM8 9c0-1.66-1.34-3-3-3S2 7.34 2 10v3c0 1.66 1.34 3 3 3s3-1.34 3-3c0-.35-.07-.69-.18-1H9v-2H7.82c.11-.31.18-.65.18-1zm8-2V5c0-.55-.45-1-1-1H9c-.55 0-1 .45-1 1v2c0 .55.45 1 1 1h6c.55 0 1-.45 1-1z"/>
                </svg>
                <span>{{ $t('nav.playGames') }}</span>
              </RouterLink>
              <RouterLink class="dropdown-item" to="/" data-nav-index="3">
                <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M9 11H7v2h2v-2zm4 0h-2v2h2v-2zm4 0h-2v2h2v-2zm2-7h-1V2h-2v2H8V2H6v2H5c-1.1 0-1.99.9-1.99 2L3 20c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 16H5V9h14v11z"/>
                </svg>
                <span>{{ $t('nav.practiceQuiz') }}</span>
              </RouterLink>
            </div>
          </Transition>
        </div>

        <!-- About Us Button -->
        <RouterLink class="link" to="/" aria-label="About Us">
          <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 17h-2v-2h2v2zm2.07-7.75l-.9.92C13.45 12.9 13 13.5 13 15h-2v-.5c0-1.1.45-2.1 1.17-2.83l1.24-1.26c.37-.36.59-.86.59-1.41 0-1.1-.9-2-2-2s-2 .9-2 2H8c0-2.21 1.79-4 4-4s4 1.79 4 4c0 .88-.36 1.68-.93 2.25z"/>
          </svg>
          <span>{{ $t('nav.aboutUs') }}</span>
        </RouterLink>
      </nav>

      <!-- Mobile menu button -->
      <button class="hamburger" @click="open = true" aria-label="Open menu">☰</button>
    </div>

    <!-- Mobile drawer -->
    <div v-if="open" class="drawer" @click.self="open = false">
      <nav class="panel" aria-label="Mobile">
        <button class="close" @click="open = false" aria-label="Close">×</button>

        <!-- Mobile Language Selector -->
        <div class="mobile-language-selector">
          <LanguageSelector />
        </div>

        <RouterLink class="dlink" to="/animals" @click="open=false; resetNavbarStates()">
          <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2C8.13 2 5 5.13 5 9c0 2.38 1.19 4.47 3 5.74V17c0 .55.45 1 1 1s1-.45 1-1v-2.26c.64.16 1.31.26 2 .26s1.36-.1 2-.26V17c0 .55.45 1 1 1s1-.45 1-1v-2.26c1.81-1.27 3-3.36 3-5.74 0-3.87-3.13-7-7-7zm-2 7c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm4 0c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1z"/>
          </svg>
          <span>{{ $t('nav.meetOceanFriends') }}</span>
        </RouterLink>
        <RouterLink class="dlink" to="/water" @click="open=false; resetNavbarStates()">
          <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2S6.5 8 6.5 14c0 3.04 2.46 5.5 5.5 5.5s5.5-2.46 5.5-5.5C17.5 8 12 2 12 2z"/>
          </svg>
          <span>{{ $t('nav.visitOceanHome') }}</span>
        </RouterLink>
        <RouterLink class="dlink" to="/game" @click="open=false">
          <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M17.5 7c-1.66 0-3 1.34-3 3 0 .35.07.69.18 1H16v2h-1.32c-.11.31-.18.65-.18 1 0 1.66 1.34 3 3 3s3-1.34 3-3V10c0-1.66-1.34-3-3-3zM8 9c0-1.66-1.34-3-3-3S2 7.34 2 10v3c0 1.66 1.34 3 3 3s3-1.34 3-3c0-.35-.07-.69-.18-1H9v-2H7.82c.11-.31.18-.65.18-1zm8-2V5c0-.55-.45-1-1-1H9c-.55 0-1 .45-1 1v2c0 .55.45 1 1 1h6c.55 0 1-.45 1-1z"/>
          </svg>
          <span>{{ $t('nav.playGames') }}</span>
        </RouterLink>
        <RouterLink class="dlink" to="/" @click="open=false">
          <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M9 11H7v2h2v-2zm4 0h-2v2h2v-2zm4 0h-2v2h2v-2zm2-7h-1V2h-2v2H8V2H6v2H5c-1.1 0-1.99.9-1.99 2L3 20c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 16H5V9h14v11z"/>
          </svg>
          <span>{{ $t('nav.practiceQuiz') }}</span>
        </RouterLink>
      </nav>
    </div>
  </header>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import LanguageSelector from './LanguageSelector.vue'

const router = useRouter()
const route = useRoute()

const open = ref(false)
const raised = ref(false)
const showOceanFriendsDropdown = ref(false)
const showPlayPracticeDropdown = ref(false)

// Simple reactive state - no complex computed logic needed
const shouldHighlightOceanFriends = ref(false)
const shouldHighlightPlayPractice = ref(false)

const onScroll = () => {
  // add a soft background after you scroll a bit
  raised.value = window.scrollY > 10
}

const restartHomepage = () => {
  // If already on homepage, restart it; otherwise navigate to homepage
  if (route.path === '/') {
    window.location.reload()
  } else {
    router.push('/')
  }
}

// Reset navbar states when navigating
const resetNavbarStates = () => {
  // Close all dropdowns
  showOceanFriendsDropdown.value = false
  showPlayPracticeDropdown.value = false

  // Reset highlight states
  shouldHighlightOceanFriends.value = false
  shouldHighlightPlayPractice.value = false

  // Remove highlight animation classes from DOM
  const highlightedElements = document.querySelectorAll('.highlight-bounce')
  highlightedElements.forEach(el => el.classList.remove('highlight-bounce'))

  // Clear any pending timeouts
  if (oceanFriendsTimeout) {
    clearTimeout(oceanFriendsTimeout)
    oceanFriendsTimeout = null
  }
  if (playPracticeTimeout) {
    clearTimeout(playPracticeTimeout)
    playPracticeTimeout = null
  }
}

// Watch for route changes and reset navbar states
watch(() => route.path, () => {
  resetNavbarStates()
})

// Dropdown hover handlers with timeout to prevent blinking
let oceanFriendsTimeout = null
let playPracticeTimeout = null

const hideOceanFriendsDropdown = () => {
  oceanFriendsTimeout = setTimeout(() => {
    showOceanFriendsDropdown.value = false
  }, 100)
}

const keepOceanFriendsDropdown = () => {
  if (oceanFriendsTimeout) {
    clearTimeout(oceanFriendsTimeout)
    oceanFriendsTimeout = null
  }
}

const hidePlayPracticeDropdown = () => {
  playPracticeTimeout = setTimeout(() => {
    showPlayPracticeDropdown.value = false
  }, 100)
}

const keepPlayPracticeDropdown = () => {
  if (playPracticeTimeout) {
    clearTimeout(playPracticeTimeout)
    playPracticeTimeout = null
  }
}

onMounted(() => window.addEventListener('scroll', onScroll, { passive: true }))
onBeforeUnmount(() => window.removeEventListener('scroll', onScroll))
</script>

<style scoped>
:root { --nav-h: 80px; }

.nav{
  position: fixed; inset: 0 0 auto 0; height: var(--nav-h);
  z-index: 1000;
  background: linear-gradient(135deg, rgba(14, 165, 233, 0.95) 0%, rgba(6, 182, 212, 0.95) 100%);
  backdrop-filter: blur(15px);
  border-bottom: 3px solid rgba(255, 255, 255, 0.3);
  color: #fff;
  transition: all .3s ease;
  box-shadow: 0 8px 32px rgba(14, 165, 233, 0.4);
}

.nav.raised{
  background: linear-gradient(135deg, rgba(14, 165, 233, 0.95) 0%, rgba(6, 182, 212, 0.95) 100%);
  box-shadow: 0 12px 40px rgba(14, 165, 233, 0.4);
}

.wrap{
  width: 100%;
  max-width: none;
  padding: 0 32px;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
}

.home-btn{
  display: flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  border-radius: 16px;
  background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
  color: #fff;
  text-decoration: none;
  transition: all .3s ease;
  box-shadow: 0 4px 16px rgba(251, 191, 36, 0.3);
}

.home-btn:hover{
  transform: translateY(-2px) scale(1.05);
  box-shadow: 0 8px 24px rgba(251, 191, 36, 0.4);
}

.home-btn .icon{
  width: 24px;
  height: 24px;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.3));
}

.links{
  display: flex;
  align-items: center;
  gap: 24px;
  margin-left: 0;
}

.link{
  display: flex;
  align-items: center;
  gap: 8px;
  color: #fff;
  text-decoration: none;
  font-weight: 700;
  font-size: 14px;
  padding: 12px 18px;
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  border: 2px solid rgba(255, 255, 255, 0.25);
  transition: all .3s ease;
  text-shadow: 0 3px 6px rgba(0,0,0,.5), 0 1px 3px rgba(0,0,0,.8);
}

.link:hover{
  background: rgba(255, 255, 255, 0.2);
  transform: translateY(-1px);
  box-shadow: 0 6px 20px rgba(255, 255, 255, 0.1);
}

.link.router-link-active{
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.25) 0%, rgba(255, 255, 255, 0.15) 100%);
  border-color: rgba(255, 255, 255, 0.4);
}

.link.highlight-bounce {
  animation: navbar-bounce 2s ease-in-out infinite;
  background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
  color: #fff;
  border-color: rgba(255, 255, 255, 0.5);
}

@keyframes navbar-bounce {
  0%, 100% {
    transform: translateY(0px) scale(1);
    box-shadow: 0 6px 20px rgba(255, 255, 255, 0.1);
  }
  50% {
    transform: translateY(-5px) scale(1.05);
    box-shadow: 0 12px 30px rgba(251, 191, 36, 0.4);
  }
}

/* Dropdown Styles */
.dropdown {
  position: relative;
}

.dropdown-trigger {
  cursor: pointer;
}

.dropdown-arrow {
  width: 16px;
  height: 16px;
  transition: transform 0.3s ease;
}

.dropdown:hover .dropdown-arrow {
  transform: rotate(180deg);
}

.dropdown-menu {
  position: absolute;
  top: calc(100% + 10px);
  left: 0;
  min-width: 250px;
  background: linear-gradient(135deg, rgba(14, 165, 233, 0.95) 0%, rgba(6, 182, 212, 0.95) 100%);
  backdrop-filter: blur(20px);
  border-radius: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  box-shadow: 0 15px 40px rgba(14, 165, 233, 0.4);
  overflow: hidden;
  z-index: 1000;
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: 12px;
  color: #fff;
  text-decoration: none;
  font-weight: 600;
  font-size: 14px;
  padding: 16px 20px;
  transition: all 0.3s ease;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.dropdown-item:last-child {
  border-bottom: none;
}

.dropdown-item:hover {
  background: rgba(255, 255, 255, 0.15);
  transform: translateX(5px);
}

.dropdown-item .icon {
  width: 18px;
  height: 18px;
  flex-shrink: 0;
}

/* Dropdown Transitions */
.dropdown-enter-active,
.dropdown-leave-active {
  transition: all 0.3s ease;
}

.dropdown-enter-from {
  opacity: 0;
  transform: translateY(-10px) scale(0.95);
}

.dropdown-leave-to {
  opacity: 0;
  transform: translateY(-10px) scale(0.95);
}

.link .icon{
  width: 20px;
  height: 20px;
  flex-shrink: 0;
  filter: drop-shadow(0 1px 3px rgba(0, 0, 0, 0.3));
}

.hamburger{
  display: none;
  width: 48px;
  height: 48px;
  border: none;
  border-radius: 16px;
  background: rgba(255,255,255,.2);
  color: #fff;
  font-size: 20px;
  transition: all .3s ease;
}

.hamburger:hover{
  background: rgba(255,255,255,.3);
  transform: scale(1.05);
}

.drawer{
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.9);
  backdrop-filter: blur(15px);
  z-index: 1001;
  display: flex;
  justify-content: flex-end;
}

.panel{
  background: linear-gradient(135deg, #0ea5e9 0%, #06b6d4 100%);
  backdrop-filter: blur(20px);
  width: min(320px, 85vw);
  height: 100%;
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
  border-left: 4px solid rgba(255, 255, 255, 0.6);
  box-shadow: -15px 0 40px rgba(14, 165, 233, 0.5);
}

.close{
  align-self: flex-end;
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.2);
  color: #fff;
  font-size: 24px;
  cursor: pointer;
  transition: all .3s ease;
}

.close:hover{
  background: rgba(255, 255, 255, 0.3);
  transform: scale(1.1);
}

.dlink{
  display: flex;
  align-items: center;
  gap: 12px;
  color: #fff;
  text-decoration: none;
  font-weight: 700;
  font-size: 16px;
  padding: 16px 20px;
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.25);
  backdrop-filter: blur(10px);
  border: 2px solid rgba(255, 255, 255, 0.4);
  transition: all .3s ease;
  text-shadow: 0 2px 6px rgba(0,0,0,.8);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.dlink:hover{
  background: rgba(255, 255, 255, 0.4);
  transform: translateX(8px);
  border-color: rgba(255, 255, 255, 0.6);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
}

.dlink .icon{
  width: 24px;
  height: 24px;
  flex-shrink: 0;
  filter: drop-shadow(0 1px 3px rgba(0, 0, 0, 0.3));
}

@media (max-width: 1200px){
  .link span{
    display: none;
  }
  .link{
    padding: 12px;
  }
}

/* Mobile Language Selector Styles */
.mobile-language-selector {
  margin-bottom: 8px;
  padding: 0 4px;
}

.mobile-language-selector .language-selector .language-select {
  width: 100%;
  min-width: auto;
  background: rgba(255, 255, 255, 0.25);
  border: 2px solid rgba(255, 255, 255, 0.4);
  font-size: 14px;
  padding: 12px 16px;
  color: #fff;
  font-weight: 600;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.mobile-language-selector .language-selector .language-select:hover {
  background: rgba(255, 255, 255, 0.4);
  border-color: rgba(255, 255, 255, 0.6);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
}

@media (max-width: 920px){
  .links{ display: none; }
  .hamburger{ display: inline-grid; place-items: center; }
}

</style>
