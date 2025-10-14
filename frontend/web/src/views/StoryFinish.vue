<script setup>
import { ref, onMounted } from 'vue';
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

function again(){ router.push(`/stories/${story.id}`); }

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
</script>

<template>
  <div class="story-finish-view">
    <div class="finish">
      <div class="confetti" aria-hidden="true"><i v-for="n in 60" :key="n"></i></div>

      <h2>🎉 You finished <em>{{ story.title }}</em>!</h2>

      <div class="card">
        <div class="badge">🌊 Ocean Helper</div>
        <h3>🌱 Takeaway</h3>
        <p>{{ story.takeaway }}</p>
      </div>

      <div class="actions">
        <button @click="again">🔁 Read Again</button>
        <router-link to="/stories" class="link">📚 Back to Library</router-link>
        <router-link to="/play" class="link">🎮 Try a Mini-Game</router-link>
      </div>
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
.finish{padding:18px;text-align:center}
h2{font-size:24px;margin:6px 0 12px}
.card{
  background:#f0fff0;border:1px solid #b7eb8f;padding:16px;border-radius:14px;
  margin:12px auto;max-width:720px
}
.badge{
  display:inline-block;background:#ffe9a6;border:1px solid #f1d17a;
  padding:6px 12px;border-radius:999px;font-weight:800;margin-bottom:8px
}
.actions{display:flex;gap:12px;justify-content:center;margin-top:14px;flex-wrap:wrap}
.actions .link, .actions button{
  padding:8px 14px;border-radius:10px;border:1px solid #dbe9ee;background:#fff;text-decoration:none;color:#024
}
.actions .link:hover, .actions button:hover{background:#f7fdff}

/* confetti */
.confetti{position:relative;height:0}
.confetti i{
  --x: 0; --delay: 0s; --rot: 0deg;
  position:absolute; left:calc(50% + var(--x));
  width:8px;height:12px;background: hsl(calc(10*var(--i,1)),90%,60%);
  transform:rotate(var(--rot)); top:-8px; animation:drop 1.6s ease-in var(--delay) 1;
  border-radius:2px
}
.confetti i:nth-child(n){ --i: 1; --x: -220px; --delay:.0s; --rot:8deg }
.confetti i:nth-child(3n+1){ --i: 16; --x:-140px; --delay:.15s; --rot:-8deg }
.confetti i:nth-child(4n+2){ --i: 22; --x:  20px; --delay:.25s; --rot:5deg }
.confetti i:nth-child(5n+3){ --i: 28; --x: 140px; --delay:.35s; --rot:-12deg }
.confetti i:nth-child(6n+4){ --i: 34; --x: 220px; --delay:.45s; --rot:14deg }
@keyframes drop{
  0%{ transform:translateY(-10px) rotate(0); opacity:0 }
  10%{ opacity:1 }
  100%{ transform:translateY(220px) rotate(220deg); opacity:0 }
}
</style>
