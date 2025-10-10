import { Router } from 'itty-router';
import { handleGetAnimals, handleGetAnimalBySlug, handleGetHabitatsByAnimal} from './animals.js';
import { handleGetSpeeches } from './speeches.js';
import { handleGetQuestions, handleGetCategories } from './quiz.js';
import { handleCors } from '../middleware/cors.js';
import { createErrorResponse } from '../utils/response.js';


// Create and configure API router
export const createRouter = () => {
  const router = Router();

  // Handle CORS preflight requests
  router.options('*', (request) => handleCors(request));

  // Health check endpoint
  router.get('/health', () => {
    return new Response(JSON.stringify({ status: 'healthy', timestamp: new Date().toISOString() }), {
      headers: { 'Content-Type': 'application/json' }
    });
  });

  // API routes
  router.get('/api/animals/:slug', async (request) => {
    const { slug } = request.params;
    return await handleGetAnimalBySlug(request, slug);
  });

  router.get('/api/animals/:slug/sites', async (request) => {
    const { slug } = request.params
    return await handleGetHabitatsByAnimal(request, slug)
  })

  router.get('/api/animals', async (request) => {
    return await handleGetAnimals(request);
  });

  router.get('/api/speeches', async (request) => {
    return await handleGetSpeeches(request);
  });

  router.get('/api/quiz/questions', async (request) => {
    return await handleGetQuestions(request);
  });

  router.get('/api/quiz/categories', async (request) => {
    return await handleGetCategories(request);
  });

  
  
  // 404 handler
  router.all('*', () => {
    return createErrorResponse(
      'Endpoint not found',
      404,
      'NOT_FOUND'
    );
  });

  return router;
};