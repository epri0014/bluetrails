// src/store/storyStore.js
import { defineStore } from 'pinia'

export const useStoryStore = defineStore('story', {
  state: () => ({
    avatar: null,
    site: null,
    cause: null   // holds { status_id, justification }
  }),
  actions: {
    setAvatar(avatar) {
      this.avatar = avatar
    },
    setSite(site) {
      this.site = site
    },
    setCause(cause) {
      this.cause = cause
    },
    reset() {
      this.avatar = null
      this.site = null
      this.cause = null
    }
  }
})
