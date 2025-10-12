<template>
  <component :is="currentComponent" @navigate="handleNavigate" />
</template>

<script setup>
import { ref, provide, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import ChooseHero from './ChooseHero.vue'
import TestHabitatChoose from './TestHabitatChoose.vue'
import MyOceanHome from './MyOceanHome.vue'

const router = useRouter()
const route = useRoute()

// Challenge state
const step = ref(1) // 1: choose animal, 2: choose habitat, 3: view prediction
const selectedAnimal = ref(null)
const selectedSite = ref(null)

// Current component based on step
const currentComponent = computed(() => {
  switch (step.value) {
    case 1: return ChooseHero
    case 2: return TestHabitatChoose
    case 3: return MyOceanHome
    default: return ChooseHero
  }
})

// Navigation handler
const handleNavigate = (action) => {
  if (action.type === 'selectAnimal') {
    selectedAnimal.value = action.data
    step.value = 2
  } else if (action.type === 'selectSite') {
    selectedSite.value = action.data
    step.value = 3
  } else if (action.type === 'back') {
    if (step.value > 1) {
      step.value--
      if (step.value === 1) {
        selectedAnimal.value = null
        selectedSite.value = null
      }
    } else {
      router.push('/')
    }
  } else if (action.type === 'restart') {
    step.value = 1
    selectedAnimal.value = null
    selectedSite.value = null
  }
}

// Provide challenge state to child components
provide('challengeState', {
  step,
  selectedAnimal,
  selectedSite,
  navigate: handleNavigate
})
</script>
