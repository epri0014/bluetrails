import { getHomeSpeeches } from '../services/database.js';
import { createSuccessResponse, createErrorResponse } from '../utils/response.js';
import { validateParams } from '../middleware/validation.js';

// Handle GET /api/speeches - Get home page speeches
export const handleGetSpeeches = async (request) => {
  const validationError = validateParams(request);
  if (validationError) return validationError;

  try {
    const url = new URL(request.url);
    const locale = url.searchParams.get('locale') || 'en';

    const { data, error } = await getHomeSpeeches(locale);

    if (error) {
      return createErrorResponse(
        'Failed to fetch speeches',
        500,
        'DATABASE_ERROR'
      );
    }

    return createSuccessResponse(data, `Speeches retrieved successfully for locale: ${locale}`);
  } catch (err) {
    return createErrorResponse(
      'Internal server error',
      500,
      'INTERNAL_ERROR'
    );
  }
};