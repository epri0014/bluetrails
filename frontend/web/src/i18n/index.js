import { createI18n } from 'vue-i18n'
import en from './locales/en.json'
import id from './locales/id.json'
import zh from './locales/zh.json'
import hi from './locales/hi.json'

const i18n = createI18n({
  legacy: false,
  locale: 'en',
  fallbackLocale: 'en',
  messages: { en, id, zh, hi }
})

export default i18n