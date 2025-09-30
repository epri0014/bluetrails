/**
 * Test suite for animal routes
 */

import { handleGetAnimals, handleGetAnimalBySlug } from '../../src/core/routes/animals.js';

// Mock database service
jest.mock('../../src/core/services/database.js', () => ({
  getAnimals: jest.fn(),
  getAnimalBySlug: jest.fn(),
}));

import { getAnimals, getAnimalBySlug } from '../../src/core/services/database.js';

describe('Animal Routes', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  /**
   * Test GET /api/animals endpoint
   */
  describe('handleGetAnimals', () => {
    it('should return animals successfully', async () => {
      const mockAnimals = [
        { id: 1, slug: 'burrunan-dolphin', name: 'Burrunan Dolphin' },
        { id: 2, slug: 'little-penguin', name: 'Little Penguin' },
      ];

      getAnimals.mockResolvedValue({ data: mockAnimals, error: null });

      const request = new Request('http://localhost/api/animals?locale=en');
      const response = await handleGetAnimals(request);
      const result = await response.json();

      expect(response.status).toBe(200);
      expect(result.success).toBe(true);
      expect(result.data).toEqual(mockAnimals);
      expect(getAnimals).toHaveBeenCalledWith('en');
    });

    it('should handle database errors', async () => {
      getAnimals.mockResolvedValue({ data: null, error: { message: 'Database error' } });

      const request = new Request('http://localhost/api/animals?locale=en');
      const response = await handleGetAnimals(request);
      const result = await response.json();

      expect(response.status).toBe(500);
      expect(result.error.code).toBe('DATABASE_ERROR');
    });

    it('should validate locale parameter', async () => {
      const request = new Request('http://localhost/api/animals?locale=invalid');
      const response = await handleGetAnimals(request);
      const result = await response.json();

      expect(response.status).toBe(400);
      expect(result.error.code).toBe('INVALID_LOCALE');
    });
  });

  /**
   * Test GET /api/animals/:slug endpoint
   */
  describe('handleGetAnimalBySlug', () => {
    it('should return specific animal successfully', async () => {
      const mockAnimal = {
        id: 1,
        slug: 'burrunan-dolphin',
        name: 'Burrunan Dolphin',
        lines: [],
        threats: [],
        help_actions: [],
        fun_facts: [],
      };

      getAnimalBySlug.mockResolvedValue({ data: mockAnimal, error: null });

      const request = new Request('http://localhost/api/animals/burrunan-dolphin?locale=en');
      const response = await handleGetAnimalBySlug(request, 'burrunan-dolphin');
      const result = await response.json();

      expect(response.status).toBe(200);
      expect(result.success).toBe(true);
      expect(result.data).toEqual(mockAnimal);
      expect(getAnimalBySlug).toHaveBeenCalledWith('burrunan-dolphin', 'en');
    });

    it('should handle animal not found', async () => {
      getAnimalBySlug.mockResolvedValue({
        data: null,
        error: { code: 'PGRST116', message: 'No rows found' }
      });

      const request = new Request('http://localhost/api/animals/nonexistent?locale=en');
      const response = await handleGetAnimalBySlug(request, 'nonexistent');
      const result = await response.json();

      expect(response.status).toBe(404);
      expect(result.error.code).toBe('ANIMAL_NOT_FOUND');
    });

    it('should validate slug format', async () => {
      const request = new Request('http://localhost/api/animals/INVALID_SLUG?locale=en');
      const response = await handleGetAnimalBySlug(request, 'INVALID_SLUG');
      const result = await response.json();

      expect(response.status).toBe(400);
      expect(result.error.code).toBe('INVALID_SLUG');
    });
  });
});