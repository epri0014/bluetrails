<template>
  <main class="home-page">
    <section class="welcome-content">
      <h1>Welcome to BlueTrails</h1>
      <p>Let's protect Our Victorian Ocean Together and Be Ocean Heroes!</p>
      <button @click="showMessage">Start</button>
      <p v-if="message">{{ message }}</p>
    </section>
  </main>
</template>

<script setup>
import { ref } from 'vue'

const message = ref('')

const showMessage = () => {
  message.value = 'Hello Ocean Heroes!'
}
</script>

<style scoped>
.home-page {
  min-height: 100vh;
  padding-top: var(--nav-h);
  background: linear-gradient(135deg, #0ea5e9 0%, #06b6d4 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
}

.welcome-content {
  text-align: center;
  padding: 40px;
}

h1 {
  font-size: 48px;
  margin-bottom: 20px;
}

p {
  font-size: 20px;
  margin-bottom: 30px;
}

button {
  padding: 15px 30px;
  font-size: 18px;
  background: #10b981;
  color: white;
  border: none;
  border-radius: 10px;
  cursor: pointer;
}

button:hover {
  background: #059669;
}
</style>