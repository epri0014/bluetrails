<!-- src/components/NavBar.vue -->
<template>
  <header class="nav">
    <div class="wrap">
      <RouterLink to="/" class="brand">
        <svg xmlns="http://www.w3.org/2000/svg" class="icon" viewBox="0 0 24 24" fill="currentColor">
          <path d="M3 12c1.5-2 4.5-2 6 0s4.5 2 6 0 4.5-2 6 0v6H3v-6zM3 18h18v2H3v-2z"/>
        </svg>
        BLUETRAILS
      </RouterLink>

    </div>
  </header>
</template>

<script setup>
</script>

<style scoped>
.brand {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 900;
  font-size: 20px;
  color: #0369a1;
  text-decoration: none;
}

.brand .icon {
  width: 22px;
  height: 22px;
  color: #0ea5e9;
}

.nav{
  position: fixed;
  top: 0; left: 0; right: 0;
  z-index: 100;
  background: transparent;    
  color: #fff;
}

.wrap{
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  height: 64px;
  display: flex;
  align-items: center;
}

.brand{
  font-weight: 900;
  color: #fff;
  text-decoration: none;
  letter-spacing: .5px;
  text-shadow: 0 1px 3px rgba(0,0,0,.6);  
}
</style>
