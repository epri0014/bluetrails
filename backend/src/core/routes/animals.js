import { getAnimals, getAnimalBySlug, getHabitatsByAnimal } from '../services/database.js';
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

    const result = await getAnimals(locale);
    const { data, error } = result;

    if (error) {
      return createErrorResponse(
        'Failed to fetch animals',
        500,
        'DATABASE_ERROR'
      );
    }

    const message = result.fellBackToEn
      ? `Animals retrieved successfully (fallback to English, '${locale}' not available)`
      : `Animals retrieved successfully for locale: ${locale}`;

    return createSuccessResponse(data, message);
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

    const result = await getAnimalBySlug(slug, locale);
    const { data, error } = result;

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

    const message = result.fellBackToEn
      ? `Animal '${slug}' retrieved successfully (fallback to English, '${locale}' not available)`
      : `Animal '${slug}' retrieved successfully`;

    return createSuccessResponse(data, message);
  } catch (err) {
    return createErrorResponse(
      'Internal server error',
      500,
      'INTERNAL_ERROR'
    );
  }
};

// backend/src/core/routes/animals.js
export const handleGetHabitatsByAnimal = async (request, slug) => {
  try {
    const url = new URL(request.url)
    const locale = url.searchParams.get('locale') || 'en'

    console.log('[sites] hit:', { slug, locale })
    console.log('[env] SUPABASE_URL=', globalThis.SUPABASE_URL, 'key?', !!globalThis.SUPABASE_KEY)

    const result = await getHabitatsByAnimal(slug, locale)
    console.log('[sites] supabase result:', { error: result?.error, count: result?.data?.length })

    const { data, error } = result
    if (error) {
      console.error('[sites] supabase error:', error)
      // 把上游错误透明返回，便于你在 Network 里看到细节
      return createErrorResponse(error.message || 'Failed to fetch sites', 502, 'SUPABASE_ERROR')
    }

    // 可选：如果你不想 404，可以直接返回空数组
    if (!data || data.length === 0) {
      return createSuccessResponse([], `No sites found for '${slug}'`)
    }

    return createSuccessResponse(data, `Sites for '${slug}' ok`)
  } catch (err) {
    console.error('[sites] handler crashed:', err)
    return createErrorResponse('Internal server error', 500, 'INTERNAL_ERROR')
  }
}

