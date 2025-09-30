import { getAnimals, getAnimalBySlug } from '../services/database.js';
import { createSuccessResponse, createErrorResponse } from '../utils/response.js';
import { validateParams } from '../middleware/validation.js';

// Handle GET /api/animals - Get all animals with basic info
export const handleGetAnimals = async (request) => {
  const validationError = validateParams(request);
  if (validationError) return validationError;

  try {
    // Debug logging
    console.log('Environment variables:', {
      SUPABASE_URL: globalThis.SUPABASE_URL,
      SUPABASE_KEY: globalThis.SUPABASE_KEY ? '[HIDDEN]' : 'undefined'
    });

    const url = new URL(request.url);
    const locale = url.searchParams.get('locale') || 'en';

    const { data, error } = await getAnimals(locale);

    if (error) {
      return createErrorResponse(
        'Failed to fetch animals',
        500,
        'DATABASE_ERROR'
      );
    }

    return createSuccessResponse(data, `Animals retrieved successfully for locale: ${locale}`);
  } catch (err) {
    console.error('Animals endpoint error:', err);
    return createErrorResponse(
      `Internal server error: ${err.message}`,
      500,
      'INTERNAL_ERROR'
    );
  }
};

// Handle GET /api/animals/:slug - Get specific animal by slug
export const handleGetAnimalBySlug = async (request, slug) => {
  const validationError = validateParams(request, { slug });
  if (validationError) return validationError;

  try {
    const url = new URL(request.url);
    const locale = url.searchParams.get('locale') || 'en';

    const { data, error } = await getAnimalBySlug(slug, locale);

    if (error) {
      if (error.code === 'PGRST116') {
        return createErrorResponse(
          `Animal with slug '${slug}' not found`,
          404,
          'ANIMAL_NOT_FOUND'
        );
      }
      return createErrorResponse(
        'Failed to fetch animal',
        500,
        'DATABASE_ERROR'
      );
    }

    return createSuccessResponse(data, `Animal '${slug}' retrieved successfully`);
  } catch (err) {
    return createErrorResponse(
      'Internal server error',
      500,
      'INTERNAL_ERROR'
    );
  }
};