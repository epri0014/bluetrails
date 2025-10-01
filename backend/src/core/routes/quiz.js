import { getQuizQuestions, getQuestionCategories } from '../services/database.js';
import { createSuccessResponse, createErrorResponse } from '../utils/response.js';
import { validateParams } from '../middleware/validation.js';

// Handle GET /api/quiz/questions - Get all quiz questions with options
export const handleGetQuestions = async (request) => {
  const validationError = validateParams(request);
  if (validationError) return validationError;

  try {
    const url = new URL(request.url);
    const locale = url.searchParams.get('locale') || 'en';

    const result = await getQuizQuestions(locale);
    const { data, error } = result;

    if (error) {
      return createErrorResponse(
        'Failed to fetch quiz questions',
        500,
        'DATABASE_ERROR'
      );
    }

    const message = result.fellBackToEn
      ? `Quiz questions retrieved successfully (fallback to English, '${locale}' not available)`
      : `Quiz questions retrieved successfully for locale: ${locale}`;

    return createSuccessResponse(data, message);
  } catch (err) {
    console.error('Quiz questions endpoint error:', err);
    return createErrorResponse(
      `Internal server error: ${err.message}`,
      500,
      'INTERNAL_ERROR'
    );
  }
};

// Handle GET /api/quiz/categories - Get question categories
export const handleGetCategories = async (request) => {
  const validationError = validateParams(request);
  if (validationError) return validationError;

  try {
    const url = new URL(request.url);
    const locale = url.searchParams.get('locale') || 'en';

    const result = await getQuestionCategories(locale);
    const { data, error } = result;

    if (error) {
      return createErrorResponse(
        'Failed to fetch question categories',
        500,
        'DATABASE_ERROR'
      );
    }

    const message = result.fellBackToEn
      ? `Question categories retrieved successfully (fallback to English, '${locale}' not available)`
      : `Question categories retrieved successfully for locale: ${locale}`;

    return createSuccessResponse(data, message);
  } catch (err) {
    console.error('Quiz categories endpoint error:', err);
    return createErrorResponse(
      `Internal server error: ${err.message}`,
      500,
      'INTERNAL_ERROR'
    );
  }
};
