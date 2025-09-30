// src/services/api.js
import axios from 'axios'
import qs from 'qs'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE || 'http://localhost:8787',
  paramsSerializer: params => qs.stringify(params, { arrayFormat: 'repeat' })
})

// Get all animals with basic translated information
export const getAnimals = async (locale = 'en') => {
  try {
    const response = await api.get(`/api/animals`, {
      params: { locale }
    })
    return response.data.data || []
  } catch (error) {
    console.error('Error fetching animals:', error)
    throw error
  }
}

// Get specific animal by slug with complete data
export const getAnimalBySlug = async (slug, locale = 'en') => {
  try {
    const response = await api.get(`/api/animals/${slug}`, {
      params: { locale }
    })
    return response.data.data || null
  } catch (error) {
    console.error('Error fetching animal:', error)
    throw error
  }
}

// Get home page speeches in specified locale
export const getHomeSpeeches = async (locale = 'en') => {
  try {
    const response = await api.get(`/api/speeches`, {
      params: { locale }
    })
    return response.data.data || []
  } catch (error) {
    console.error('Error fetching speeches:', error)
    throw error
  }
}

