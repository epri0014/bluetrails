<script setup>
import { useRouter } from 'vue-router';
import stories from '../data/stories.json';

const router = useRouter();
const openStory = (id) => router.push(`/stories/${id}`);
</script>

<template>
  <div class="adventures">
    <div class="wave-header">
      <h2>🐢 Ocean Adventures</h2>
      <p>Pick a mascot story to start your mini-adventure!</p>
      <div class="bubbles">
        <span v-for="n in 8" :key="n" class="bubble" />
      </div>
    </div>

    <div class="story-grid">
      <article
        v-for="s in stories"
        :key="s.id"
        class="card"
        :style="{ '--accent': s.accent || '#25c5d6' }"
        @click="openStory(s.id)"
      >
        <div class="thumb">
          <img :src="s.cover" :alt="s.title" loading="lazy" />
          <span class="ribbon">NEW</span>
        </div>

        <h3 class="title">{{ s.title }}</h3>
        <p class="subtitle">Mascot: {{ s.mascot }}</p>

        <div class="chips">
          <span class="chip">{{ s.duration || '1–2 min' }}</span>
          <span class="chip">Age {{ s.age || '6+' }}</span>
        </div>
      </article>
    </div>
  </div>
</template>

<style scoped>
.adventures{padding:0 24px 40px}
.wave-header{
  position:relative; text-align:center; padding:28px 12px 48px;
  background:linear-gradient(90deg,#10c2e3,#0aa3c2 60%,#077ea0);
  color:#fff; border-radius:20px; margin:16px 0 28px;
}
.wave-header h2{font-size:28px;margin:0 0 6px;font-weight:800}
.wave-header p{opacity:.95;margin:0}
.bubbles{position:absolute;inset:0;pointer-events:none;overflow:hidden}
.bubble{
  position:absolute; bottom:-10px; left:calc(8% * var(--i,1));
  width:10px;height:10px;border-radius:50%;
  background:#ffffffaa; animation:rise 6s linear infinite;
  filter:blur(.2px)
}
.bubble:nth-child(odd){width:14px;height:14px;animation-duration:7.5s}
.bubble:nth-child(even){animation-delay:1.2s}
.bubble:nth-child(1){--i:1}.bubble:nth-child(2){--i:3}.bubble:nth-child(3){--i:5}
.bubble:nth-child(4){--i:7}.bubble:nth-child(5){--i:9}.bubble:nth-child(6){--i:11}
.bubble:nth-child(7){--i:13}.bubble:nth-child(8){--i:15}
@keyframes rise{to{transform:translateY(-130%);opacity:0}}

.story-grid{
  display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:24px;
}
.card{
  border:1px solid #eee; border-radius:18px; padding:16px; background:#fffef6;
  cursor:pointer; text-align:center; transition:transform .25s, box-shadow .25s;
  box-shadow:0 2px 10px rgba(0,0,0,.06);
}
.card:hover{ transform:translateY(-4px) scale(1.03); box-shadow:0 10px 22px rgba(0,0,0,.12) }
.thumb{position:relative;display:grid;place-items:center;padding:8px}
.thumb img{
  width:min(240px,78%); aspect-ratio:1/1; object-fit:contain;
  border-radius:14px; background:conic-gradient(from 180deg,var(--accent) 0 25%,#fff 0 50%, var(--accent) 0 75%, #fff 0);
  padding:12px;
}
.ribbon{
  position:absolute; top:10px; left:10px; font-size:12px; font-weight:800;
  background:var(--accent,#25c5d6); color:#00313a; padding:4px 8px; border-radius:999px;
}
.title{font-size:20px;font-weight:800;margin:10px 0 4px}
.subtitle{font-size:15px;color:#667}
.chips{display:flex;gap:8px;justify-content:center;margin-top:8px;flex-wrap:wrap}
.chip{
  font-size:12px; padding:6px 10px; border-radius:999px; background:#fff;
  border:1px dashed var(--accent,#25c5d6); color:#07515e
}
@media (max-width:640px){
  .wave-header{border-radius:16px;padding:24px 10px 42px}
  .story-grid{grid-template-columns:1fr}
}
</style>
