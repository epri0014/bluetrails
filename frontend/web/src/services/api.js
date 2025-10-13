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

// Get quiz questions with options in specified locale
export const getQuizQuestions = async (locale = 'en') => {
  try {
    const response = await api.get(`/api/quiz/questions`, {
      params: { locale }
    })
    return response.data.data || []
  } catch (error) {
    console.error('Error fetching quiz questions:', error)
    throw error
  }
}

// Get question categories in specified locale
export const getQuestionCategories = async (locale = 'en') => {
  try {
    const response = await api.get(`/api/quiz/categories`, {
      params: { locale }
    })
    return response.data.data || []
  } catch (error) {
    console.error('Error fetching question categories:', error)
    throw error
  }
}

export const getHabitatsByAnimal = async (slug, locale = 'en') => {
  try {
    const response = await api.get(`/api/animals/${slug}/sites`, {
      params: { locale }
    })
    return response.data.data || []
  } catch (error) {
    console.error('Error fetching habitats by animal:', error)
    throw error
  }
}

// Get EPA water quality prediction with traffic light status
export const getEpaPrediction = async (siteId, date) => {
  try {
    const response = await api.get(`/api/epa/prediction`, {
      params: { site_id: siteId, date }
    })
    return response.data.data || null
  } catch (error) {
    console.error('Error fetching EPA prediction:', error)
    throw error
  }
}