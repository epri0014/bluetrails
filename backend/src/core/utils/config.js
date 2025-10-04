/**
 * Application configuration object
 * Supports both Node.js (process.env) and Cloudflare Workers (globalThis) environments
 */

// Helper function to get environment variable from both Node.js and Cloudflare Workers
const getEnv = (key) => {
  // For Cloudflare Workers (set via globalThis in adapter)
  if (typeof globalThis[key] !== 'undefined' && globalThis[key] !== null && globalThis[key] !== '') {
    return globalThis[key];
  }
  // For Node.js (local development)
  if (typeof process !== 'undefined' && process.env && process.env[key]) {
    return process.env[key];
  }
  return undefined;
};

// Export config as an object with getters to ensure values are read at runtime
export const config = {
  supabase: {
    get url() {
      return getEnv('SUPABASE_URL');
    },
    get key() {
      return getEnv('SUPABASE_KEY');
    },
  },
  cors: {
    get allowedOrigins() {
      return getEnv('ALLOWED_ORIGINS')?.split(',');
    },
  },
  get environment() {
    return getEnv('NODE_ENV');
  },
};