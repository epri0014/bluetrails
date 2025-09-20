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

/* Mobile responsive with ocean theme */
@media (max-width: 920px) {
  .language-select {
    min-width: auto !important;
    font-size: 16px !important;
    padding: 16px 20px !important;
    background: linear-gradient(135deg, #fff 0%, #f8fafc 100%) !important;
    color: #1e293b !important;
    border: 3px solid #40E0D0 !important;
    font-weight: 700 !important;
    box-shadow: 0 8px 25px rgba(64, 224, 208, 0.3) !important;
    border-radius: 16px !important;
    backdrop-filter: none !important;
    width: 100% !important;
  }

  .language-select:hover {
    background: linear-gradient(135deg, #7c3aed 0%, #5b21b6 100%) !important;
    color: #fff !important;
    border-color: #7c3aed !important;
    box-shadow: 0 12px 35px rgba(124, 58, 237, 0.4) !important;
    transform: translateY(-1px) !important;
  }

  .language-select:focus {
    background: linear-gradient(135deg, #7c3aed 0%, #5b21b6 100%) !important;
    color: #fff !important;
    border-color: #7c3aed !important;
    box-shadow: 0 12px 35px rgba(124, 58, 237, 0.4) !important;
  }

  .language-select option {
    background: #fff !important;
    color: #1e293b !important;
    padding: 8px 12px !important;
    font-weight: 600 !important;
  }
}
</style>