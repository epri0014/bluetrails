import { createRouter } from '../core/routes/index.js';
import { handleCors } from '../core/middleware/cors.js';

/**
 * Cloudflare Worker entry point
 * Handles all incoming requests and routes them appropriately
 */

const router = createRouter();

// Main fetch handler for Cloudflare Worker
export default {
  async fetch(request, env, ctx) {
    try {
      // Set environment variables in globalThis for access in other modules
      // Works for both local development (.env) and production (Cloudflare dashboard)
      globalThis.SUPABASE_URL = env.SUPABASE_URL;
      globalThis.SUPABASE_KEY = env.SUPABASE_KEY;
      globalThis.ALLOWED_ORIGINS = env.ALLOWED_ORIGINS || 'http://localhost:5173,https://bluetrails.pages.dev';
      globalThis.NODE_ENV = env.NODE_ENV || 'production';

      // Validate required environment variables
      if (!globalThis.SUPABASE_URL || !globalThis.SUPABASE_KEY) {
        return new Response(JSON.stringify({
          error: {
            message: 'Missing required environment variables: SUPABASE_URL and SUPABASE_KEY',
            code: 'MISSING_ENV_VARS',
            status: 500,
          },
        }), {
          status: 500,
          headers: { 'Content-Type': 'application/json' },
        });
      }

      // Handle the request with the router
      const response = await router.handle(request);

      // Add CORS headers to all responses
      const corsHeaders = handleCors(request);
      if (response instanceof Response) {
        Object.entries(corsHeaders).forEach(([key, value]) => {
          response.headers.set(key, value);
        });
      }

      return response;
    } catch (error) {
      console.error('Worker error:', error);

      return new Response(JSON.stringify({
        error: {
          message: 'Internal server error',
          code: 'WORKER_ERROR',
          status: 500,
        },
      }), {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          ...handleCors(request),
        },
      });
    }
  },
};