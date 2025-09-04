<template>
  <main class="detail">
    <div class="wrap" v-if="a">
      <RouterLink to="/animals" class="back">← Back</RouterLink>

      <h1 class="title">{{ a.name }}</h1>
      <p class="intro">{{ a.intro }}</p>

      <section class="facts">
        <div class="facts-inner">
          <ul class="kv">
            <li><span>COMMON NAME:</span> {{ a.name }}</li>
            <li v-if="a.scientific"><span>SCIENTIFIC NAME:</span> {{ a.scientific }}</li>
            <li v-if="a.group"><span>GROUP:</span> {{ a.group }}</li>
            <li v-if="a.type"><span>TYPE:</span> {{ a.type }}</li>
            <li v-if="a.size"><span>SIZE:</span> {{ a.size }}</li>
            <li v-if="a.diet"><span>DIET:</span> {{ a.diet }}</li>
            <li v-if="a.status"><span>STATUS:</span> {{ a.status }}</li>
          </ul>
          <div class="circle">
            <img :src="a.src" :alt="a.name" />
          </div>
        </div>
      </section>

      <section class="body">
        <h2>Meet the {{ a.name }}</h2>
        <p>{{ a.story }}</p>

        <h2>Why they matter</h2>
        <p>{{ a.why }}</p>

        <h2>How pollution hurts them</h2>
        <ul class="bullets">
          <li v-for="t in a.threats" :key="t">{{ t }}</li>
        </ul>

        <h2>How you can help</h2>
        <ul class="bullets">
          <li v-for="h in a.help" :key="h">{{ h }}</li>
        </ul>
      </section>
    </div>

    <div class="wrap" v-else>
      <RouterLink to="/animals" class="back">← Back</RouterLink>
      <p>Sorry, we couldn't find that animal.</p>
    </div>
  </main>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const base = 'https://gvwrmcyksmswvduehrtd.supabase.co/storage/v1/object/public/bluetrails/animal-page'
const DATA = [
  {
    slug:'sea-turtle',
    name:'Sea Turtles',
    scientific:'Cheloniidae',
    group:'Reptiles',
    type:'Ocean animal',
    size:'Up to 2 meters (shell length)',
    diet:'Jellyfish, seagrass, algae (varies by species)',
    status:'Many species are threatened',
    src:`${base}/sea-turtle.jpg`,
    intro:'Sea turtles are ancient swimmers that glide across warm oceans.',
    story:`Imagine wearing a backpack your whole life, that's a turtle's shell! It keeps them safe while they explore coral gardens and open seas.`,
    why:'Sea turtles keep seagrass healthy and help coral reefs by eating jellyfish. Healthy turtles mean balanced ocean food webs.',
    threats:[
      'Plastic bags look like jellyfish and can choke turtles.',
      'Ghost nets and fishing lines can wrap around flippers and necks.',
      'Beach lights and trash make it harder for babies to reach the sea.'
    ],
    help:[
      'Use a reusable bag and bottle, skip single-use plastic.',
      'Clean up a beach or river for 15 minutes with an adult.',
      'Keep beaches dark and clear, no holes, no lights near nests.'
    ]
  },
  {
    slug:'sea-birds',
    name:'Seabirds',
    scientific:'Procellariiformes (many species)',
    group:'Birds',
    type:'Ocean bird',
    size:'From small petrels to huge albatross',
    diet:'Fish, squid, krill',
    status:'Many species are declining',
    src:`${base}/sea-birds.jpg`,
    intro:'Seabirds are champions of long-distance flight.',
    story:'Some albatross can circle the globe! They skim the waves, then soar on strong winds like tiny airplanes.',
    why:'Seabirds move nutrients from sea to land and help scientists find healthy fish populations.',
    threats:[
      'Chicks are fed plastic pieces that look like food.',
      'Oil and chemicals make feathers lose waterproofing.',
      'Hooks and longlines can catch birds by mistake.'
    ],
    help:[
      'Cut rings and loops before throwing anything away.',
      'Choose tuna with "bird-safe" or pole-and-line labels if possible.',
      'Join a local cleanup, every tiny piece helps.'
    ]
  },
  {
    slug:'seals',
    name:'Seals & Sea Lions',
    scientific:'Phocidae & Otariidae',
    group:'Mammals',
    type:'Marine mammal',
    size:'1-3 meters, species vary',
    diet:'Fish and squid',
    status:'Some stable, some at risk',
    src:`${base}/seals.jpg`,
    intro:'Curious, whiskered swimmers who love rocky shores.',
    story:'Puppies practice diving like kids learning to swim, short dips first, then deeper and longer!',
    why:'They are top predators that keep fish populations balanced.',
    threats:[
      'Lost fishing nets (ghost gear) can trap their necks and flippers.',
      'Plastic rings and straps can tighten as they grow.',
      'Noise and pollution can scare mothers from pups.'
    ],
    help:[
      `Throw trash in closed bins, wind can't take what it can't reach.`,
      'Support projects that remove ghost nets.',
      'Watch wildlife from a distance, give them space.'
    ]
  },
  {
    slug:'dolphins',
    name:'Dolphins',
    scientific:'Delphinidae',
    group:'Mammals',
    type:'Marine mammal',
    size:'2-4 meters, species vary',
    diet:'Fish and squid',
    status:'Some species threatened',
    src:`${base}/dolphins.jpg`,
    intro:'Dolphins are fast, playful, and super smart.',
    story:`Pods work as a team, some herd the fish, others take turns to eat. It's like an underwater sport!`,
    why:'Dolphins show when oceans are healthy, if dolphins are well, many other animals are too.',
    threats:[
      'Plastic and tiny microplastics enter the food they eat.',
      'Chemicals build up in their bodies over time.',
      'Loud noise from ships can confuse their echo-location.'
    ],
    help:[
      'Reduce, reuse, recycle, especially plastic.',
      'Choose products with less packaging.',
      'Learn and share: quiet oceans help dolphins talk.'
    ]
  },
  {
    slug:'whale',
    name:'Whales',
    scientific:'Balaenopteridae & others',
    group:'Mammals',
    type:'Marine mammal',
    size:'Up to 30 meters (blue whale!)',
    diet:'Krill or fish (species vary)',
    status:'Some recovering, some endangered',
    src:`${base}/whale.jpg`,
    intro:'The giants of the sea are gentle and powerful.',
    story:'Baleen whales eat with a giant comb, scooping water in and pushing it out while tasty krill stay trapped.',
    why:'Whales help fertilize the ocean with "whale pump," boosting tiny plants that make oxygen for our planet.',
    threats:[
      'Ropes and nets can wrap around tails and mouths.',
      'Plastic and balloons may be swallowed by mistake.',
      'Noise makes it hard to communicate and find food.'
    ],
    help:[
      'Never release balloons, tie them down or skip them.',
      'Support rescue groups that free entangled whales.',
      'Learn about "quiet ships" and share with friends.'
    ]
  },
  {
    slug:'sea-otters',
    name:'Sea Otters',
    scientific:'Enhydra lutris',
    group:'Mammals',
    type:'Marine mammal',
    size:'About 1-1.5 meters',
    diet:'Sea urchins, crabs, clams',
    status:'Threatened in some areas',
    src:`${base}/sea-otters.jpg`,
    intro:'Sea otters are fluffy kelp-forest heroes.',
    story:'They float on their backs and use a rock as a hammer, crack!, dinner is served.',
    why:'Otters eat sea urchins that munch kelp; with otters, kelp forests grow tall and shelter many fish.',
    threats:[
      'Oil and chemicals ruin their super-warm fur.',
      'Plastic straps or lines can entangle them.',
      'Sick prey from pollution can make pups weak.'
    ],
    help:[
      'Use less oil, walk, bike, or share rides when you can.',
      'Choose reef-safe sunscreen for beach days.',
      'Pick up litter near rivers, it all flows to the sea.'
    ]
  },
  {
    slug:'coral',
    name:'Coral Reefs',
    scientific:'Class Anthozoa',
    group:'Animals (cnidarians)',
    type:'Reef-building animal',
    size:'Tiny polyps build giant reefs',
    diet:'Microscopic plankton + algae partners',
    status:'Many reefs are stressed',
    src:`${base}/Coral.jpg`,
    intro:'Corals are animals that build colorful underwater cities.',
    story:'Each coral is a tiny polyp with tentacles. Millions together make a reef where fish find homes, like apartments under the sea.',
    why:'Reefs protect coasts, feed people, and hold amazing sea life.',
    threats:[
      'Sunscreen chemicals and plastic harm coral polyps.',
      'Warmer water makes corals "bleach" and lose color.',
      'Sediment and sewage block the sunlight they need.'
    ],
    help:[
      'Use reef-safe sunscreen and a hat or shirt for shade.',
      'Keep drains clean, never pour oil or chemicals.',
      'Support groups that restore reefs with coral gardening.'
    ]
  },
  {
    slug:'shark',
    name:'Sharks',
    scientific:'Selachimorpha',
    group:'Fish',
    type:'Top predator',
    size:'From 20 cm to 12 m (whale shark)',
    diet:'Fish, squid, varies widely',
    status:'Many species declining',
    src:`${base}/shark.jpg`,
    intro:`Sharks are not monsters, they're important ocean guardians.`,
    story:'Like referees in a game, sharks keep the rules: they eat the sick and the weak so fish schools stay strong.',
    why:'Without sharks, food webs wobble and some animals overgrow.',
    threats:[
      'Plastic and fishing gear can injure gills and fins.',
      'Chemical pollution builds up in top predators.',
      'Overfishing removes too many sharks from the sea.'
    ],
    help:[
      'Say no to souvenirs made from shark parts.',
      'Learn about sustainable seafood with an adult.',
      'Share the truth: most sharks avoid people!'
    ]
  }
]

const a = computed(() => DATA.find(x => x.slug === useRoute().params.id))
</script>

<style scoped>
.detail{
  min-height:100vh;
  padding-top:var(--nav-h);
  padding-bottom:48px;
  background-image:
    linear-gradient(180deg, rgba(0,0,0,.45), rgba(0,0,0,.25)),
    url('/hero/background.jpg');
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
}

.wrap{
  max-width:980px;
  margin:0 auto;
  padding:0 20px;
  color:#fff;              
}

.back{
  display:inline-block; margin:18px 0 6px;
  color:#fff; text-decoration:none; font-weight:600;
  background: rgba(255,255,255,.18);
  padding:6px 10px; border-radius:10px;
  backdrop-filter: blur(2px);
}

.title{
  font-size: clamp(28px, 6vw, 42px);
  line-height:1.1; margin:.2em 0 .4em;
  text-shadow: 0 6px 22px rgba(0,0,0,.45), 0 2px 10px rgba(0,0,0,.35);
}
.intro{
  max-width:800px; font-size:18px; line-height:1.6;
  text-shadow: 0 2px 8px rgba(0,0,0,.35);
}

.facts{ margin:22px 0 28px; }
.facts-inner{
  position:relative;
  background:#3f8f2e; border-radius:6px; padding:18px 18px; color:#fff;
  box-shadow:0 8px 20px rgba(0,0,0,.22);
}
.kv{ list-style:none; padding:0; margin:0; }
.kv li{ padding:8px 0; border-bottom:1px solid rgba(255,255,255,.18); font-size:15px; }
.kv li:last-child{ border-bottom:none; }
.kv span{ color:#ffe066; font-weight:700; letter-spacing:.02em; margin-right:8px; }

.circle{
  position:absolute; right:16px; top:16px;
  width:120px; height:120px; border-radius:50%;
  overflow:hidden; border:4px solid #fff;
  box-shadow:0 6px 14px rgba(0,0,0,.28);
}
.circle img{ width:100%; height:100%; object-fit:cover; }

.body h2{ margin:22px 0 10px; font-size:22px; text-shadow: 0 2px 8px rgba(0,0,0,.35); }
.body p{ line-height:1.7; text-shadow: 0 2px 8px rgba(0,0,0,.30); }
.bullets{ margin:0; padding-left:1.1em; line-height:1.7; }

@media (max-width: 720px){
  .circle{ position:static; margin:12px auto 0; }
  .facts-inner{ padding-bottom:12px; }
}
</style>
