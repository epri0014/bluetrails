import { createErrorResponse } from '../utils/response.js';

// Validate locale parameter
export const isValidLocale = (locale) => {
  const validLocales = ['en', 'id', 'hi', 'zh'];
  return validLocales.includes(locale);
};

// Validate animal slug parameter
export const isValidSlug = (slug) => {
  return /^[a-z0-9-]+$/.test(slug) && slug.length > 0 && slug.length <= 100;
};

// Middleware to validate query parameters
export const validateParams = (request, params = {}) => {
  const url = new URL(request.url);
  const locale = url.searchParams.get('locale') || 'en';

  if (!isValidLocale(locale)) {
    return createErrorResponse(
      `Invalid locale. Supported locales: en, id, hi, zh`,
      400,
      'INVALID_LOCALE'
    );
  }

  if (params.slug && !isValidSlug(params.slug)) {
    return createErrorResponse(
      'Invalid slug format. Use lowercase letters, numbers, and hyphens only.',
      400,
      'INVALID_SLUG'
    );
  }

  return null;
};