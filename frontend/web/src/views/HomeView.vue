<template>
  <main class="hero">
    <!-- 背景图：用你的 assets/hero.jpg；如果暂无，可换任意 URL -->
    <img class="bg" src="@/assets/hero.jpg" alt="Tropical beach" />
    <div class="overlay"></div>

    <section class="content">
      <h1 class="title">
        Find safe and sustainable beaches tailored just for you!
      </h1>
      <p class="subtitle">
        Let us be your guide to discovering the wonders with safety and ease.
      </p>

      <div class="icons" aria-label="Popular beach activities">
        <span title="Snorkelling">🤿</span>
        <span title="Kayaking">🛶</span>
        <span title="Swimming">🏊</span>
        <span title="Sunbathing">🌞</span>
        <span title="Wildlife friendly">🦭</span>
      </div>

      <RouterLink to="/explore" class="cta">
        <span class="cta-main">Find my Beach</span>
        <span class="cta-sub">Not sure? Tell us your preferences!</span>
      </RouterLink>
    </section>
  </main>
</template>

<script setup>
import { RouterLink } from 'vue-router'
</script>

<style scoped>
.hero{
  position:relative; min-height: calc(100vh - 64px);
  display:grid; place-items:center start; color:#fff;
}
.bg{ position:absolute; inset:0; width:100%; height:100%; object-fit:cover; }
.overlay{
  position:absolute; inset:0;
  background:
    linear-gradient(90deg, rgba(4,16,29,.55) 0%, rgba(4,16,29,.15) 55%, rgba(4,16,29,.55) 100%),
    linear-gradient(0deg, rgba(0,0,0,.15), rgba(0,0,0,.15));
}
.content{ position:relative; z-index:1; max-width:1100px; padding: 2.6rem 1.2rem; }
.title{
  font-size: clamp(2.2rem, 4.6vw + .5rem, 4rem);
  line-height:1.08; font-weight:900; max-width: 22ch;
  text-shadow: 0 6px 22px rgba(0,0,0,.35);
}
.subtitle{
  margin-top: .9rem; font-size: clamp(1rem, 1.1vw + .6rem, 1.25rem); opacity:.92;
  text-shadow: 0 2px 10px rgba(0,0,0,.25);
}
.icons{ display:flex; gap: .9rem; font-size: 1.9rem; margin: 1.2rem 0 1.6rem; }
.icons span{ filter: drop-shadow(0 6px 12px rgba(0,0,0,.25)); }

.cta{
  display:inline-flex; flex-direction:column; text-decoration:none;
  color:#0b1b2b; background:#f7fbffcc; border:1px solid #d9eaff; backdrop-filter: blur(6px);
  padding: .95rem 1.15rem; border-radius:16px;
  box-shadow: 0 8px 28px rgba(0,0,0,.22), 0 2px 8px rgba(0,0,0,.08);
  transition: transform .15s ease, box-shadow .2s ease, background .2s ease;
}
.cta:hover{
  transform: translateY(-1px);
  box-shadow: 0 10px 34px rgba(0,0,0,.26), 0 4px 10px rgba(0,0,0,.10);
  background:#ffffffee;
}
.cta-main{ font-weight:900; letter-spacing:.01em; }
.cta-sub{ font-size:.92rem; color:#344861; opacity:.95; }

@media (max-width: 720px){
  .icons{ font-size: 1.6rem; }
  .cta{ padding: .85rem 1rem; }
}
</style>
