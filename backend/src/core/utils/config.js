/**
 * Application configuration object
 * Supports Cloudflare Workers environment variables
 */
export const config = {
  supabase: {
    url: globalThis.SUPABASE_URL,
    key: globalThis.SUPABASE_KEY,
  },
  cors: {
    allowedOrigins: (globalThis.ALLOWED_ORIGINS || 'http://localhost:5173,https://bluetrails.pages.dev').split(','),
  },
  environment: globalThis.NODE_ENV || 'development',
};