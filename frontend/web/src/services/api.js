// src/services/api.js
import axios from 'axios'
import qs from 'qs'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE || 'http://localhost:8000',
  paramsSerializer: params => qs.stringify(params, { arrayFormat: 'repeat' })
})

