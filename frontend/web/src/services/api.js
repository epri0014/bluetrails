// src/services/api.js
import axios from 'axios'
import qs from 'qs'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE || 'http://localhost:8000',
  paramsSerializer: params => qs.stringify(params, { arrayFormat: 'repeat' })
})

// --- Avatars ---
export async function fetchAvatars() {
  const { data } = await api.get('/api/ws/avatars')
  return data
}

// --- Health ---
export async function fetchHealth(avatarId, siteId) {
  const { data } = await api.get('/api/ws/health', {
    params: { avatar_id: avatarId, site_id: siteId }
  })
  return data
}

// --- Pollution Causes ---
export async function fetchPollutionCauses(statusIds) {
  const { data } = await api.get('/api/ws/pollution_causes', {
    params: { status_id: statusIds }
  })
  return data
}

// --- Fun Facts ---
export async function fetchFunFacts(avatarId) {
  const { data } = await api.get('/api/ws/fun_facts', {
    params: { avatar_id: avatarId }
  })
  return data
}

// --- Eco Actions ---
export async function fetchEcoActions() {
  const { data } = await api.get('/api/ws/eco_actions')
  return data
}
