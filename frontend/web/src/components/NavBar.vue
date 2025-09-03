<!-- src/components/NavBar.vue -->
<template>
  <header class="nav">
    <div class="wrap">
      <RouterLink to="/" class="brand">OCEAN KIDS</RouterLink>
    </div>
  </header>
</template>

<script setup>
</script>

<style scoped>
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
