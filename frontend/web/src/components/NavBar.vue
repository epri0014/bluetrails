
<template>
  <header class="nav">
    <div class="wrap">
      <RouterLink to="/" class="brand">OCEAN KIDS</RouterLink>

      <nav class="links" aria-label="Primary">
        <RouterLink class="link" to="/explore">Animals at Risk</RouterLink>
        <RouterLink class="link" to="/favourites">How Bad Is It?</RouterLink>
        <RouterLink class="link" to="/settings">Water Quality</RouterLink>
      </nav>

      <button class="hamburger" @click="open = true" aria-label="Open menu">≡</button>
    </div>

    <div class="drawer" v-if="open" @click.self="open = false">
      <div class="panel">
        <button class="close" @click="open = false" aria-label="Close">×</button>
        <RouterLink class="dlink" to="/explore" @click="open=false">Animals at Risk</RouterLink>
        <RouterLink class="dlink" to="/favourites" @click="open=false">How Bad Is It?</RouterLink>
        <RouterLink class="dlink" to="/settings" @click="open=false">Water Quality</RouterLink>
      </div>
    </div>
  </header>
</template>

<script setup>
import { ref } from 'vue'
const open = ref(false)
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

.links{
  margin-left: auto;         
  display: flex;
  gap: 12px;
}
.btn{
  color: #fff;
  text-decoration: none;
  font-weight: 800;
  padding: 8px 12px;
  border-radius: 10px;
  text-shadow: 0 1px 3px rgba(0,0,0,.6);
}
.btn:hover{ background: rgba(255,255,255,.18); }

.hamburger{
  display:none; margin-left:12px;
  width:40px; height:40px; border:none; border-radius:10px;
  background: rgba(255,255,255,.2); color:#fff;
}
@media (max-width:900px){
  .links{ display:none; }
  .hamburger{ display:block; }
}

.drawer{ position:fixed; inset:0; pointer-events:none; }
.drawer.show{ pointer-events:auto; }
.panel{
  position:absolute; right:0; top:0; bottom:0; width:min(88%,360px); background:#fff;
  transform:translateX(100%); transition:.25s; padding:16px; display:flex; flex-direction:column; gap:12px;
  box-shadow:-8px 0 24px rgba(0,0,0,.2);
}
.drawer.show .panel{ transform:translateX(0); }
.close{ align-self:flex-end; width:40px; height:40px; border:none; border-radius:10px; background:#f3f4f6; }
.dlink{ background:#f5f7f9; padding:12px; border-radius:10px; font-weight:800; color:#111; text-decoration:none; }
</style>