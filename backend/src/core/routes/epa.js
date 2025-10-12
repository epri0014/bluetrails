import { getEpaPrediction } from '../services/database.js';
import { createSuccessResponse, createErrorResponse } from '../utils/response.js';
import { validateParams } from '../middleware/validation.js';

// Handle GET /api/epa/prediction - Get EPA prediction for a specific site and date
export const handleGetEpaPrediction = async (request) => {
  try {
    const url = new URL(request.url);
    const siteId = url.searchParams.get('site_id');
    const date = url.searchParams.get('date');

    // Validate required parameters
    if (!siteId) {
      return createErrorResponse(
        'Missing required parameter: site_id',
        400,
        'MISSING_PARAMETER'
      );
    }

    if (!date) {
      return createErrorResponse(
        'Missing required parameter: date',
        400,
        'MISSING_PARAMETER'
      );
    }

    // Validate date format (YYYY-MM-DD)
    const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
    if (!dateRegex.test(date)) {
      return createErrorResponse(
        'Invalid date format. Expected YYYY-MM-DD',
        400,
        'INVALID_DATE_FORMAT'
      );
    }

    const result = await getEpaPrediction(siteId, date);
    const { data, error } = result;

    if (error) {
      if (error.code === 'PGRST116') {
        return createErrorResponse(
          `No prediction data found for site '${siteId}' on date '${date}'`,
          404,
          'PREDICTION_NOT_FOUND'
        );
      }
      return createErrorResponse(
        'Failed to fetch EPA prediction data',
        500,
        'DATABASE_ERROR'
      );
    }

    return createSuccessResponse(
      data,
      `EPA prediction data retrieved successfully for site '${siteId}' on ${date}`
    );
  } catch (err) {
    console.error('EPA prediction endpoint error:', err);
    return createErrorResponse(
      `Internal server error: ${err.message}`,
      500,
      'INTERNAL_ERROR'
    );
  }
};
