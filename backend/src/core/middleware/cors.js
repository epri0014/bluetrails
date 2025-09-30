import { config } from '../utils/config.js';

// Generates CORS headers based on the request origin
export const corsHeaders = (origin) => {
  const isAllowedOrigin = config.cors.allowedOrigins.includes(origin) ||
                         config.cors.allowedOrigins.includes('*');

  return {
    'Access-Control-Allow-Origin': isAllowedOrigin ? origin : config.cors.allowedOrigins[0],
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Max-Age': '86400',
  };
};

// Handles CORS preflight requests and returns appropriate headers
export const handleCors = (request) => {
  const origin = request.headers.get('Origin');

  if (request.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: corsHeaders(origin),
    });
  }

  return corsHeaders(origin);
};