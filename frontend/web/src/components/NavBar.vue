<template>
  <header class="nav" :class="{ raised }" role="banner">
    <div class="wrap">
      <!-- Brand (left) -->
      <RouterLink to="/" class="brand">BLUETRAILS</RouterLink>

      <!-- Desktop links (right) -->
      <nav class="links" aria-label="Primary">
        <RouterLink class="link" to="/animals">Animals at Risk</RouterLink>
        <RouterLink class="link" to="/hero">Be an Ocean Hero</RouterLink>
        <RouterLink class="link" to="/water">Know your Water</RouterLink>
      </nav>

      <!-- Mobile menu button -->
      <button class="hamburger" @click="open = true" aria-label="Open menu">☰</button>
    </div>

    <!-- Mobile drawer -->
    <div v-if="open" class="drawer" @click.self="open = false">
      <nav class="panel" aria-label="Mobile">
        <button class="close" @click="open = false" aria-label="Close">×</button>
        <RouterLink class="dlink" to="/animals" @click="open=false">Animals at Risk</RouterLink>
        <RouterLink class="dlink" to="/hero" @click="open=false">Be an Ocean Hero</RouterLink>
        <RouterLink class="dlink" to="/water" @click="open=false">Know your Water</RouterLink>
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

onMounted(() => window.addEventListener('scroll', onScroll, { passive: true }))
onBeforeUnmount(() => window.removeEventListener('scroll', onScroll))
</script>

<style scoped>
:root { --nav-h: 64px; }

.nav{
  position: fixed; inset: 0 0 auto 0; height: var(--nav-h);
  z-index: 1000;
  background: transparent;
  color: #fff;
  transition: background .18s ease, box-shadow .18s ease, backdrop-filter .18s ease;
}

.wrap{
  width: 100%;
  max-width: none;          
  padding: 0 28px;          
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;   
  gap: 16px;
}

.brand{
  font-weight: 900;
  letter-spacing: .6px;
  color: #fff;
  text-decoration: none;
  text-shadow: 0 2px 8px rgba(0,0,0,.45);
}

.links{
  display: flex;
  align-items: center;
  gap: 18px;                 
  margin-left: 0;           
}

.link{
  color:#fff; text-decoration:none; font-weight:700;
  padding: 8px 12px; border-radius: 10px;
  text-shadow: 0 1px 4px rgba(0,0,0,.45);
}
.link:hover{ background: rgba(255,255,255,.14); }

.hamburger{ display:none; width:40px; height:40px; border:none; border-radius:10px; background:rgba(255,255,255,.18); color:#fff; }
@media (max-width: 920px){
  .links{ display:none; }
  .hamburger{ display:inline-grid; place-items:center; }
}

</style>
