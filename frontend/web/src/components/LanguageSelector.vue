<template>
  <div class="language-selector">
    <select v-model="$i18n.locale" @change="onLanguageChange" class="language-select">
      <option value="en">🇺🇸 English</option>
      <option value="id">🇮🇩 Bahasa Indonesia</option>
      <option value="zh">🇨🇳 中文</option>
      <option value="hi">🇮🇳 हिन्दी</option>
    </select>
  </div>
</template>

<script setup>
import { useI18n } from 'vue-i18n'

const { locale } = useI18n()

const onLanguageChange = () => {
  // Store language preference in localStorage
  localStorage.setItem('preferred-language', locale.value)
}

// Load saved language preference on component mount
if (typeof window !== 'undefined') {
  const savedLanguage = localStorage.getItem('preferred-language')
  if (savedLanguage && ['en', 'id', 'zh', 'hi'].includes(savedLanguage)) {
    locale.value = savedLanguage
  }
}
</script>

<style scoped>
.language-selector {
  position: relative;
}

.language-select {
  padding: 8px 12px;
  border-radius: 12px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  color: white;
  font-weight: 600;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 140px;
  outline: none;
}

.language-select:hover {
  background: rgba(255, 255, 255, 0.25);
  border-color: rgba(255, 255, 255, 0.5);
  transform: translateY(-1px);
}

.language-select:focus {
  background: rgba(255, 255, 255, 0.3);
  border-color: rgba(255, 255, 255, 0.6);
  box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.1);
}

.language-select option {
  background: #1e293b;
  color: white;
  padding: 8px;
}

/* Mobile responsive */
@media (max-width: 920px) {
  .language-select {
    min-width: 120px;
    font-size: 12px;
    padding: 6px 10px;
  }
}
</style>