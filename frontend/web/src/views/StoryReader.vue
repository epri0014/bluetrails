<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import stories from '../data/stories.json';

const route = useRoute();
const router = useRouter();
const story = stories.find(s => s.id === route.params.id);

const pageIndex = ref(0);
const isLast = computed(() => pageIndex.value === story.pages.length - 1);
const progress = computed(() => Math.round(((pageIndex.value + 1) / story.pages.length) * 100));

let autoplayTimer = null;
const autoPlay = ref(false);
const narrate = ref(false);
const showMascotBubble = ref(false);

function next(){ if(isLast.value) router.push(`/stories/${story.id}/finish`); else { pageIndex.value++; showMascotBubble.value=false; speak(); } }
function prev(){ if(pageIndex.value>0){ pageIndex.value--; showMascotBubble.value=false; speak(); } }
function toggleAuto(){
  autoPlay.value = !autoPlay.value;
  clearInterval(autoplayTimer);
  if(autoPlay.value){
    autoplayTimer = setInterval(()=> isLast.value ? router.push(`/stories/${story.id}/finish`) : pageIndex.value++, 5000);
  }
}
function speak(){
  if(!narrate.value) return;
  const utter = new SpeechSynthesisUtterance(story.pages[pageIndex.value].text);
  utter.rate = 0.95; utter.pitch = 1.05;
  window.speechSynthesis.cancel(); window.speechSynthesis.speak(utter);
}
function onKey(e){
  if(e.key==='ArrowRight') next();
  else if(e.key==='ArrowLeft') prev();
  else if(e.key===' ') { e.preventDefault(); next(); }
}
let touchX = 0;
function onTouchStart(e){ touchX = e.changedTouches[0].clientX; }
function onTouchEnd(e){
  const dx = e.changedTouches[0].clientX - touchX;
  if(Math.abs(dx) > 40) (dx < 0 ? next() : prev());
}

onMounted(()=> window.addEventListener('keydown', onKey));
onBeforeUnmount(()=>{
  window.removeEventListener('keydown', onKey);
  clearInterval(autoplayTimer);
  window.speechSynthesis?.cancel();
});
</script>

<template>
  <div class="reader ocean-page" :style="{ '--accent': story.accent || '#9fe2ff' }">
    <header class="top">
      <h2>{{ story.title }}</h2>
      <div class="toggles">
        <label><input type="checkbox" v-model="narrate" @change="speak"> 🎙️ Narrate</label>
        <label><input type="checkbox" v-model="autoPlay" @change="toggleAuto"> ▶️ Auto-play</label>
      </div>
    </header>

    <div class="progress">
      <div class="bar" :style="{ width: progress + '%' }"></div>
    </div>

    <!-- 漫画置中 + 吉祥物侧边悬浮 -->
    <section class="page" @touchstart.passive="onTouchStart" @touchend.passive="onTouchEnd">
      <div class="stage">
        <figure class="figure">
          <img :src="story.pages[pageIndex].img" :alt="story.pages[pageIndex].text" loading="eager" />
        </figure>

        <!-- 悬浮在漫画右侧“靠边一点”的吉祥物 -->
        <button
          class="mascot-float ocean-card"
          :style="{ '--accent': story.accent || '#0aa3c2' }"
          @click="showMascotBubble = !showMascotBubble"
          :aria-expanded="showMascotBubble"
          :aria-label="`Show ${story.mascot} tip`"
        >
          <img class="mascot-img" :src="story.cover" :alt="`${story.mascot} mascot`" />
          <span class="bubble" v-show="showMascotBubble">
  {{ story.pages[pageIndex].speech || story.pages[pageIndex].tip || `Hi! I'm ${story.mascot}. Let's learn together!` }}
</span>

        </button>
      </div>

      <!-- 文案 + Tip（Tip 在文字下方） -->
      <div class="caption">
        <p class="text">{{ story.pages[pageIndex].text }}</p>
        <button
          v-if="story.pages[pageIndex].tip"
          class="tip"
          @click="$event.target.classList.toggle('show')"
          aria-label="Show tip"
        >
          💡 Tip
          <span class="bubble">{{ story.pages[pageIndex].tip }}</span>
        </button>
      </div>

      <div class="dots">
        <button
          v-for="(p,i) in story.pages"
          :key="i"
          class="dot"
          :class="{ active: i===pageIndex }"
          @click="pageIndex=i; showMascotBubble=false; speak()"
        />
      </div>
    </section>

    <nav class="nav">
      <button @click="prev" :disabled="pageIndex===0">◀ Prev</button>
      <span>{{ pageIndex + 1 }} / {{ story.pages.length }}</span>
      <button @click="next">{{ isLast ? 'Finish ▶' : 'Next ▶' }}</button>
    </nav>
  </div>
</template>

<style scoped>
/* ===== 全页海洋主题背景 ===== */
.ocean-page{
  --accent: #9fe2ff;
  --mascot-offset: 26px;         /* ✅ 调整吉祥物“靠边一点”的距离（可按需微调） */
  min-height:100vh; padding:16px;
  background:
    radial-gradient(circle at 20% 15%, rgba(255,255,255,.6) 0 30%, transparent 31%) 0 0/120px 120px,
    radial-gradient(circle at 80% 40%, rgba(255,255,255,.4) 0 25%, transparent 26%) 0 0/160px 160px,
    repeating-linear-gradient(180deg, rgba(255,255,255,.15) 0 6px, rgba(255,255,255,0) 7px 18px),
    linear-gradient(180deg,
      color-mix(in srgb, var(--accent) 75%, #ffffff) 0%,
      color-mix(in srgb, var(--accent) 45%, #ffffff) 60%,
      #ffffff 100%);
}

/* Header & progress */
.top{display:flex;justify-content:space-between;align-items:center;margin-bottom:8px}
.top h2{font-size:22px;margin:0}
.toggles label{font-size:14px;margin-left:8px;user-select:none}
.progress{height:8px;background:#eef5f7;border-radius:999px;overflow:hidden;margin:8px 0 14px}
.bar{height:100%;background:linear-gradient(90deg,#10c2e3,#0aa3c2)}

/* ===== 内容卡片（半透明） ===== */
.page{
  border:1px solid rgba(255,255,255,.6);
  border-radius:16px;
  padding:16px;
  background:rgba(255,255,255,0.55);
  box-shadow:0 4px 18px rgba(0,0,0,.08);
  backdrop-filter:blur(4px);
  position:relative;
  overflow:visible; /* 允许吉祥物稍微伸出一点点 */
}

/* ===== 漫画居中舞台 ===== */
.stage{
  position:relative;
  display:grid;
  justify-items:center;          /* ✅ 让漫画水平居中 */
}
.figure{margin:0}
.figure img{
  width:min(100%, 1020px);        /* 最大宽度限制，超宽屏不至于过大 */
  max-height:600px;
  object-fit:contain;
  border-radius:12px;
  background:#f9ffff;
  transition:transform .25s ease;
}
.figure img:hover{ transform:scale(1.02); }

/* ===== 侧边悬浮吉祥物 ===== */
.mascot-float{
  position:absolute;
  top: 24px;
  left: calc(50% + min(410px, 50vw) + var(--mascot-offset)); /* ✅ 以漫画中心为基准，放到右侧“靠边一点” */
  transform: translateX(-50%);  /* 让卡片自身水平居中于该点 */
  z-index:2;
}
.ocean-card{
  overflow:visible;
  border:1px solid #d6ecf3;
  border-radius:16px;
  padding:8px;
  cursor:pointer;
  display:grid;
  place-items:center;
  background:
    radial-gradient(circle at 20% 20%, rgba(255,255,255,.4) 0 25%, transparent 26%) 0 0/120px 120px,
    linear-gradient(180deg, #d4f4ff, var(--accent));
  box-shadow:0 10px 24px rgba(0,0,0,.10);
  z-index:3;
}
.mascot-img{
  width:150px; height:auto; object-fit:contain;
  filter:drop-shadow(0 6px 10px rgba(0,0,0,.18));
  user-select:none; pointer-events:none;
}
.mascot-float .bubble {
  position: absolute;
  right: calc(100% + 10px);
  top: 14px;
  width: 280px;             /* ✅ 你要的固定宽度 */
  max-width: 80vw;          /* 小屏兜底 */
  background: #fffbe6;
  border: 1px solid #f2d98b;
  padding: 10px 12px;
  border-radius: 12px;
  box-shadow: 0 10px 24px rgba(0,0,0,.14);
  text-align: left;
  white-space: normal;      /* ✅ 自动换行 */
  word-wrap: break-word;
  z-index: 10;
}
.mascot-float .bubble::after{
  content:""; position:absolute; left:100%; top:22px;
  border-width:10px; border-style:solid;
  border-color:transparent transparent transparent #fffbe6;
  filter:drop-shadow(2px 2px 0 #f2d98b);
}

/* 文案 + Tip */
.caption{text-align:center;margin-top:12px}
.text{font-size:18px;margin:8px auto 6px;max-width:760px}
.tip{
  display:inline-flex;align-items:center;gap:6px;margin:0 auto;padding:8px 12px;
  border-radius:999px;background:#fff4c2;border:1px solid #f2d98b;font-weight:700;
  position:relative;cursor:pointer
}
.tip .bubble{
  position:absolute;left:50%;transform:translateX(-50%);
  bottom:calc(100% + 10px);background:#fffbe6;border:1px solid #f2d98b;
  padding:10px 12px;border-radius:12px;width:min(90vw,560px);
  box-shadow:0 6px 18px rgba(0,0,0,.12);display:none;text-align:left
}
.tip.show .bubble{display:block;animation:pop .18s ease-out}

.dots{display:flex;justify-content:center;gap:8px;margin:10px 0 0}
.dot{width:10px;height:10px;border-radius:50%;background:#cfe7ee;border:0}
.dot.active{background:#0aa3c2;transform:scale(1.15)}

.nav{margin-top:12px;display:flex;gap:12px;align-items:center;justify-content:center}
.nav button{padding:8px 14px;border-radius:10px;border:1px solid #dbe9ee;background:#fff}
.nav button:enabled:hover{background:#f0fbff}

@keyframes pop{from{transform:translateY(8px) scale(.96);opacity:0}to{transform:translateY(0) scale(1);opacity:1}}

/* ===== 响应式：小屏改为上下排列 ===== */
@media (max-width:1100px){
  /* 让吉祥物更贴近，避免超出视口 */
  .ocean-page{ --mascot-offset: 10px; }
}
@media (max-width:900px){
  .mascot-float{
    position:static; transform:none; left:auto; top:auto; margin-top:8px;
    display:grid; place-items:center;
  }
  .mascot-float .bubble{
    right:auto; left:50%; transform:translateX(-50%);
    top:auto; bottom:calc(100% + 10px);
  }
  .mascot-float .bubble::after{
    left:50%; transform:translateX(-50%);
    top:100%; border-color:#fffbe6 transparent transparent transparent;
  }
}
@media (max-width:640px){
  .figure img{max-height:480px}
}
</style>
