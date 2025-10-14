<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { getAnimals } from '@/services/api.js';
import stories from '../data/stories.json';
import FloatingAnimalGuide from '@/components/FloatingAnimalGuide.vue';

const route = useRoute();
const router = useRouter();
const { locale } = useI18n();
const story = stories.find(s => s.id === route.params.id);
const animals = ref([]);

const pageIndex = ref(0);
const isLast = computed(() => pageIndex.value === story.pages.length - 1);
const progress = computed(() => Math.round(((pageIndex.value + 1) / story.pages.length) * 100));

const showMascotBubble = ref(false);
const isPaused = ref(false);    // 是否暂停
const isFinished = ref(false);  // ✅ 是否播放完毕

const highlightedHTML = ref(story.pages[pageIndex.value]?.text || '');
const currentWordIndex = ref(-1);

const suppressEndHighlight = ref(false);

function cancelSpeech() {
  suppressEndHighlight.value = true;       // 标记为“由我们主动取消”
  window.speechSynthesis.cancel();
}

function speakLine(line) {
  if (!line) return;
  const utter = new SpeechSynthesisUtterance(line);
  utter.lang = 'en-US';
  utter.rate = 0.98;
  utter.pitch = 1.0;
  if (englishVoice) utter.voice = englishVoice;

  cancelSpeech();                 // 先取消上一次
  suppressEndHighlight.value = true; // 不去补最后高亮
  window.speechSynthesis.speak(utter);
}

function speakSpeech() {
  const speech = story.pages[pageIndex.value]?.speech
              || story.pages[pageIndex.value]?.tip
              || `Hi! I'm ${story.mascot}. Let's learn together!`;
  speakLine(speech);
}

function playText() {
  // ✅ 若处于暂停状态，则恢复播放
  if (isPaused.value && window.speechSynthesis.paused) {
    window.speechSynthesis.resume();
    isPaused.value = false;
    return;
  }

  const text = story.pages[pageIndex.value]?.text;
  if (!text) return;

  // ✅ 将文字拆分为单词数组，准备高亮
 const words = text.trim().split(/\s+/);
  highlightedHTML.value = words.map(w => `<span>${w}</span>`).join(' ');

  const utter = new SpeechSynthesisUtterance(text);
  utter.rate = 0.95;
  utter.pitch = 1.05;
  utter.lang = 'en-US';

  utter.onstart = () => {
    isPaused.value = false;
    isFinished.value = false;
    currentWordIndex.value = -1;
  };

  // ✅ 每当朗读到一个单词时触发
utter.onboundary = (event) => {
  console.log('boundary event:', event.charIndex, event.name);
  if (event.charIndex >= 0) {
    const idx = getWordIndexByChar(event.charIndex, text);
    if (idx >= 0 && idx < words.length) {
      currentWordIndex.value = idx;
      updateHighlight(words, idx);
    }
  }
};

// ✅ 播放结束：如果不是我们主动取消，就补最后一次高亮到最后一个词
utter.onend = () => {
  isPaused.value = false;
  isFinished.value = true;

  if (!suppressEndHighlight.value && words.length > 0) {
    currentWordIndex.value = words.length - 1;
    updateHighlight(words, words.length - 1);
  }
};

cancelSpeech();                 // 先取消上一次（会把 suppressEndHighlight 置 true）
suppressEndHighlight.value = false;  // 立刻恢复为“非主动取消”状态（自然结束才补高亮）
window.speechSynthesis.speak(utter);
}

/* 辅助函数：通过字符位置推测当前朗读单词索引 */
function getWordIndexByChar(charIndex, fullText) {
  const before = fullText.slice(0, charIndex);
  return before.trim().split(/\s+/).length - 1;
}

/* 根据当前索引更新高亮 HTML */
function updateHighlight(words, activeIdx) {
  // 把每个单词包裹在 span 里，当前单词加 highlight
  const html = words.map((w, i) => {
    // 防止空字符 / 标点断裂
    const safeWord = w.replace(/[<>&]/g, c => ({'<':'&lt;','>':'&gt;','&':'&amp;'}[c]));
    return i === activeIdx
      ? `<span class="highlight">${safeWord}</span>`
      : `<span>${safeWord}</span>`;
  }).join(' ');
  highlightedHTML.value = html;
}

function syncCaptionToPage() {
  highlightedHTML.value = story.pages[pageIndex.value]?.text || '';
  currentWordIndex.value = -1;
  isPaused.value = false;
  isFinished.value = false;
}

/* ======== 暂停当前语音 ======== */
function pauseText() {
  if (window.speechSynthesis.speaking && !window.speechSynthesis.paused) {
    window.speechSynthesis.pause();
    isPaused.value = true;
  }
}

/* ======== 重新播放（Replay） ======== */
function replayText() {
  cancelSpeech();
  isPaused.value = false;
  isFinished.value = false;
  playText();
}

/* ======== Tip 英语朗读 ======== */
let englishVoice = null;
function pickEnglishVoice() {
  const voices = window.speechSynthesis?.getVoices?.() || [];
  englishVoice =
    voices.find(v => v.lang?.toLowerCase().startsWith('en')) ||
    voices.find(v => v.lang?.toLowerCase().startsWith('en')) ||
    null;
}
pickEnglishVoice();
if ('speechSynthesis' in window) {
  window.speechSynthesis.onvoiceschanged = pickEnglishVoice;
}
function speakTip() {
  const tip = story.pages[pageIndex.value]?.tip;
  if (!tip) return;
  const utter = new SpeechSynthesisUtterance(tip);
  utter.lang = 'en-US';
  utter.rate = 0.98;
  utter.pitch = 1.0;
  if (englishVoice) utter.voice = englishVoice;
  cancelSpeech(); // ✅ 用带 suppress 标记的取消
  suppressEndHighlight.value = true;
  window.speechSynthesis.speak(utter);
}
function toggleTip(e){
  const btn = e.currentTarget;
  btn.classList.toggle('show');
  const expanded = btn.classList.contains('show');
  btn.setAttribute('aria-expanded', expanded ? 'true' : 'false');
  if (expanded) speakTip();
}

function goPage(i) {
  if (i === pageIndex.value) return;
  cancelSpeech();
  showMascotBubble.value = false;
  pageIndex.value = i;
  syncCaptionToPage();
}

/* ======== 翻页导航 ======== */
function next(){
  cancelSpeech();
  if (isLast.value) {
    router.push(`/stories/${story.id}/finish`);
  } else {
    pageIndex.value++;
    showMascotBubble.value = false;
    syncCaptionToPage();
  }
}

function prev(){
  cancelSpeech();
  if (pageIndex.value > 0) {
    pageIndex.value--;
    showMascotBubble.value = false;
    syncCaptionToPage();
  }
}

// Load animals for the floating guide
const loadAnimals = async () => {
  try {
    const data = await getAnimals(locale.value);
    animals.value = data.map(animal => ({
      slug: animal.slug,
      name: animal.name,
      cartoon: animal.cartoon_image_url
    }));
  } catch (err) {
    console.error('Failed to load animals for floating guide:', err);
  }
};

// Navigate to game page
function navigateToGame() {
  router.push('/game');
}

onMounted(() => {
  loadAnimals();
});

onBeforeUnmount(()=> cancelSpeech());
</script>


<template>
  <div class="story-reader-view">
    <div class="reader ocean-page" :style="{ '--accent': story.accent || '#9fe2ff' }">
      <header class="top">
      <h2>{{ story.title }}</h2>
      <div class="progress"><div class="bar" :style="{ width: progress + '%' }"></div></div>
    </header>

    <section class="page">
      <div class="stage">
        <figure class="figure">
          <img :src="story.pages[pageIndex].img" :alt="story.pages[pageIndex].text" loading="eager" />
        </figure>

        <!-- 吉祥物（可朗读 Tip） -->
        <button
  class="mascot-float ocean-card"
  :style="{ '--accent': story.accent || '#0aa3c2' }"
  @click="(showMascotBubble = !showMascotBubble, showMascotBubble ? speakSpeech() : cancelSpeech())"
>
          <img class="mascot-img" :src="story.cover" :alt="`${story.mascot} mascot`" />
          <span class="bubble" v-show="showMascotBubble">
  {{ story.pages[pageIndex].speech
     || story.pages[pageIndex].tip
     || `Hi! I'm ${story.mascot}. Let's learn together!` }}
</span>

        </button>
      </div>

      <!-- 漫画下方 caption -->
      <div class="caption">
       <p class="text" v-html="highlightedHTML"></p>

        <div class="controls">
          <button class="play" @click="playText">
            {{ isPaused ? '▶ Resume' : '▶ Play' }}
          </button>
          <button class="pause" @click="pauseText">⏸ Pause</button>
          <button class="replay" v-if="isFinished" @click="replayText">🔁 Replay</button>
        </div>

        <button
          v-if="story.pages[pageIndex].tip"
          class="tip"
          @click="toggleTip($event)"
        >
          💡 Tip
          <span class="bubble">{{ story.pages[pageIndex].tip }}</span>
        </button>
      </div>

<div class="dots">
  <button
    v-for="(p, i) in story.pages"
    :key="i"
    class="dot"
    :class="{ active: i === pageIndex }"
    @click="goPage(i)"
  />
</div>
    </section>

    <nav class="nav">
      <button @click="prev" :disabled="pageIndex===0">◀ Prev</button>
      <span>{{ pageIndex + 1 }} / {{ story.pages.length }}</span>
      <button @click="next">{{ isLast ? 'Finish ▶' : 'Next ▶' }}</button>
    </nav>
    </div>

    <!-- Floating Animal Guide -->
    <FloatingAnimalGuide
      v-if="animals.length > 0"
      :available-animals="animals"
      :message="$t('floatingGuide.playGameMessage')"
      :button-text="$t('floatingGuide.playGameButton')"
      :aria-label="$t('floatingGuide.playGameAriaLabel')"
      @click="navigateToGame"
    />
  </div>
</template>

<style scoped>
.ocean-page{
  --accent: #9fe2ff;
  --mascot-offset: 26px;  /* 调整吉祥物偏移 */
  min-height:100vh;
  padding:16px;
  background:
    radial-gradient(circle at 20% 15%, rgba(255,255,255,.6) 0 30%, transparent 31%) 0 0/120px 120px,
    radial-gradient(circle at 80% 40%, rgba(255,255,255,.4) 0 25%, transparent 26%) 0 0/160px 160px,
    repeating-linear-gradient(180deg, rgba(255,255,255,.15) 0 6px, rgba(255,255,255,0) 7px 18px),
    linear-gradient(180deg,
      color-mix(in srgb, var(--accent) 75%, #ffffff) 0%,
      color-mix(in srgb, var(--accent) 45%, #ffffff) 60%,
      #ffffff 100%);
}
.top{display:flex;flex-direction:column;align-items:center;margin-bottom:12px}
.progress{height:8px;background:#eef5f7;border-radius:999px;overflow:hidden;width:100%;max-width:600px;margin-top:8px}
.bar{height:100%;background:linear-gradient(90deg,#10c2e3,#0aa3c2)}

.page{
  border:1px solid rgba(255,255,255,.6);
  border-radius:16px;
  padding:16px;
  background:rgba(255,255,255,0.55);
  box-shadow:0 4px 18px rgba(0,0,0,.08);
  backdrop-filter:blur(4px);
  position:relative;
  overflow:visible;
}
.stage{display:grid;justify-items:center}
.figure img{
  width:min(100%,900px);
  max-height:700px;
  object-fit:contain;
  border-radius:12px;
  background:#f9ffff;
}
/* ===== 侧边悬浮吉祥物 ===== */ .mascot-float{ position:absolute; top: 24px; left: calc(50% + min(410px, 50vw) + var(--mascot-offset)); /* ✅ 以漫画中心为基准，放到右侧“靠边一点” */ transform: translateX(-50%); /* 让卡片自身水平居中于该点 */ z-index:2; } .ocean-card{ overflow:visible; border:1px solid #d6ecf3; border-radius:16px; padding:8px; cursor:pointer; display:grid; place-items:center; background: radial-gradient(circle at 20% 20%, rgba(255,255,255,.4) 0 25%, transparent 26%) 0 0/120px 120px, linear-gradient(180deg, #d4f4ff, var(--accent)); box-shadow:0 10px 24px rgba(0,0,0,.10); z-index:3; } .mascot-img{ width:150px; height:auto; object-fit:contain; filter:drop-shadow(0 6px 10px rgba(0,0,0,.18)); user-select:none; pointer-events:none; }
.mascot-float .bubble{
  position:absolute;right:130%;top:10px;width:240px;
  background:#fffbe6;border:1px solid #f2d98b;padding:8px 12px;border-radius:10px;
}
.caption{text-align:center;margin-top:12px}
.text{font-size:18px;margin:8px auto;max-width:720px}
.controls{display:flex;gap:10px;justify-content:center;margin-bottom:10px}
.play,.pause,.replay{padding:8px 16px;border-radius:10px;border:1px solid #ccc;background:#fff;font-weight:600}
.play:hover,.pause:hover,.replay:hover{background:#f0fbff}
.tip{display:inline-flex;align-items:center;gap:6px;margin-top:6px;padding:8px 12px;
  border-radius:999px;background:#fff4c2;border:1px solid #f2d98b;font-weight:700;cursor:pointer;position:relative}
.tip .bubble{position:absolute;left:50%;transform:translateX(-50%);
  bottom:calc(100% + 10px);background:#fffbe6;border:1px solid #f2d98b;
  padding:10px 12px;border-radius:12px;width:min(90vw,560px);
  box-shadow:0 6px 18px rgba(0,0,0,.12);display:none;text-align:left}
.tip.show .bubble{display:block}
.dots{display:flex;justify-content:center;gap:8px;margin-top:12px}
.dot{width:10px;height:10px;border-radius:50%;background:#cfe7ee;border:0}
.dot.active{background:#0aa3c2}
.nav{margin-top:14px;display:flex;justify-content:center;gap:12px}
.nav button{padding:8px 14px;border-radius:10px;border:1px solid #dbe9ee;background:#fff}
.nav button:hover{background:#f0fbff}
.text :deep(.highlight) {
  background: linear-gradient(90deg, #fff5a0 0%, #ffe85f 100%);
  border-radius: 4px;
  padding: 2px 4px;
  transition: background .2s ease;
}
</style>
