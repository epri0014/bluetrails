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
        <RouterLink class="link" to="/animals">
          <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2C8.13 2 5 5.13 5 9c0 2.38 1.19 4.47 3 5.74V17c0 .55.45 1 1 1s1-.45 1-1v-2.26c.64.16 1.31.26 2 .26s1.36-.1 2-.26V17c0 .55.45 1 1 1s1-.45 1-1v-2.26c1.81-1.27 3-3.36 3-5.74 0-3.87-3.13-7-7-7zm-2 7c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm4 0c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1z"/>
          </svg>
          <span>Meet Our Ocean Friends</span>
        </RouterLink>
        <RouterLink class="link" to="/water">
          <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2S6.5 8 6.5 14c0 3.04 2.46 5.5 5.5 5.5s5.5-2.46 5.5-5.5C17.5 8 12 2 12 2z"/>
          </svg>
          <span>Visit Ocean Friends Home</span>
        </RouterLink>
        <RouterLink class="link" href="#">
          <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M17.5 7c-1.66 0-3 1.34-3 3 0 .35.07.69.18 1H16v2h-1.32c-.11.31-.18.65-.18 1 0 1.66 1.34 3 3 3s3-1.34 3-3V10c0-1.66-1.34-3-3-3zM8 9c0-1.66-1.34-3-3-3S2 7.34 2 10v3c0 1.66 1.34 3 3 3s3-1.34 3-3c0-.35-.07-.69-.18-1H9v-2H7.82c.11-.31.18-.65.18-1zm8-2V5c0-.55-.45-1-1-1H9c-.55 0-1 .45-1 1v2c0 .55.45 1 1 1h6c.55 0 1-.45 1-1z"/>
          </svg>
          <span>Play Ocean Fun Games</span>
        </RouterLink>
      </nav>

      <!-- Mobile menu button -->
      <button class="hamburger" @click="open = true" aria-label="Open menu">☰</button>
    </div>

    <!-- Mobile drawer -->
    <div v-if="open" class="drawer" @click.self="open = false">
      <nav class="panel" aria-label="Mobile">
        <button class="close" @click="open = false" aria-label="Close">×</button>
        <RouterLink class="dlink" to="/animals" @click="open=false">
          <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2C8.13 2 5 5.13 5 9c0 2.38 1.19 4.47 3 5.74V17c0 .55.45 1 1 1s1-.45 1-1v-2.26c.64.16 1.31.26 2 .26s1.36-.1 2-.26V17c0 .55.45 1 1 1s1-.45 1-1v-2.26c1.81-1.27 3-3.36 3-5.74 0-3.87-3.13-7-7-7zm-2 7c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm4 0c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1z"/>
          </svg>
          <span>Meet Our Ocean Friends</span>
        </RouterLink>
        <RouterLink class="dlink" to="/water" @click="open=false">
          <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2S6.5 8 6.5 14c0 3.04 2.46 5.5 5.5 5.5s5.5-2.46 5.5-5.5C17.5 8 12 2 12 2z"/>
          </svg>
          <span>Visit Ocean Friends Home</span>
        </RouterLink>
        <RouterLink class="dlink" href="#" @click="open=false">
          <svg class="icon" viewBox="0 0 24 24" fill="currentColor">
            <path d="M17.5 7c-1.66 0-3 1.34-3 3 0 .35.07.69.18 1H16v2h-1.32c-.11.31-.18.65-.18 1 0 1.66 1.34 3 3 3s3-1.34 3-3V10c0-1.66-1.34-3-3-3zM8 9c0-1.66-1.34-3-3-3S2 7.34 2 10v3c0 1.66 1.34 3 3 3s3-1.34 3-3c0-.35-.07-.69-.18-1H9v-2H7.82c.11-.31.18-.65.18-1zm8-2V5c0-.55-.45-1-1-1H9c-.55 0-1 .45-1 1v2c0 .55.45 1 1 1h6c.55 0 1-.45 1-1z"/>
          </svg>
          <span>Play Ocean Fun Games</span>
        </RouterLink>
      </nav>
    </div>
  </header>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'

const open = ref(false)
const raised = ref(false)

const onScroll = () => {
  // add a soft background after you scroll a bit
  raised.value = window.scrollY > 10
}

const restartHomepage = () => {
  // Emit event to restart homepage or refresh the page
  window.location.reload()
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
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(8px);
  z-index: 999;
  display: flex;
  justify-content: flex-end;
}

.panel{
  background: linear-gradient(135deg, rgba(14, 165, 233, 0.95) 0%, rgba(6, 182, 212, 0.95) 100%);
  backdrop-filter: blur(20px);
  width: min(320px, 85vw);
  height: 100%;
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
  border-left: 2px solid rgba(255, 255, 255, 0.2);
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
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  transition: all .3s ease;
}

.dlink:hover{
  background: rgba(255, 255, 255, 0.2);
  transform: translateX(8px);
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

@media (max-width: 920px){
  .links{ display: none; }
  .hamburger{ display: inline-grid; place-items: center; }
}

</style>
