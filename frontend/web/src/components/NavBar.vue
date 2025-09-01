<template>
  <header class="nav">
    <div class="wrap">
      <!-- 左边 -->
      <a class="brand" href="/">
        <span class="logo">🟦</span>
        <span class="brand-text">BLUE TRAILS</span>
      </a>

      <!-- 右边 -->
      <div class="right">
        <nav class="menu">
          <RouterLink to="/" class="pill" :class="{ active: isActive('/') }">HOME</RouterLink>
          <RouterLink to="/explore" class="pill" :class="{ active: isActive('/explore') }">EXPLORE</RouterLink>
          <RouterLink to="/favourites" class="pill" :class="{ active: isActive('/favourites') }">FAVOURITES</RouterLink>
          <RouterLink to="/settings" class="pill" :class="{ active: isActive('/settings') }">SETTINGS</RouterLink>
        </nav>
        <RouterLink to="/login" class="login">LOGIN</RouterLink>
      </div>
    </div>
  </header>
</template>

<script setup>
import { RouterLink, useRoute } from 'vue-router'
const route = useRoute()
const isActive = (p) => route?.path === p
</script>

<style scoped>
.nav {
  position: sticky;
  top: 0;
  z-index: 60;
  backdrop-filter: blur(10px);
  background: color-mix(in oklab, #ffffff 80%, transparent);
  border-bottom: 1px solid #e9edf3;
}
.wrap {
  max-width: 1200px;
  margin: 0 auto;
  padding: .7rem 1rem;
  display: flex;
  align-items: center;
  justify-content: space-between; /* 👈 左右两端对齐 */
}
.brand {
  display: flex;
  align-items: center;
  gap: .55rem;
  text-decoration: none;
}
.logo {
  display: grid;
  place-items: center;
  width: 26px;
  height: 26px;
  border-radius: 6px;
  background: #8de3ff;
}
.brand-text {
  font-weight: 800;
  letter-spacing: .06em;
  color: #0b1b2b;
}
.right {
  display: flex;
  align-items: center;
  gap: .6rem;
}
.menu {
  display: flex;
  gap: .4rem;
}
.pill {
  padding: .45rem .9rem;
  border-radius: 999px;
  text-decoration: none;
  font-weight: 600;
  color: #4b5563;
  border: 1px solid transparent;
}
.pill:hover {
  background: #f3f6fb;
}
.pill.active {
  background: #eef4ff;
  border-color: #cfe1ff;
  color: #1f2a44;
}
.login {
  text-decoration: none;
  font-weight: 700;
  letter-spacing: .02em;
  padding: .5rem 1rem;
  border-radius: 12px;
  border: 1px solid #d8dee8;
  color: #0b1b2b;
  box-shadow: 0 4px 14px rgba(0, 0, 0, .06);
}
.login:hover {
  background: #f7f9fc;
}
@media (max-width: 780px) {
  .menu {
    display: none;
  }
}
</style>
