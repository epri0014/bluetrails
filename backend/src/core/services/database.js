import { supabase } from './supabase.js';

// Get all animals with basic translated information
export const getAnimals = async (locale = 'en') => {
  // Try to get data in requested locale
  let result = await supabase
    .from('v_animals')
    .select('*')
    .eq('locale', locale)
    .order('display_order');

  // If no data found and locale is not 'en', fallback to English
  if ((!result.data || result.data.length === 0) && locale !== 'en') {
    result = await supabase
      .from('v_animals')
      .select('*')
      .eq('locale', 'en')
      .order('display_order');

    // Add fallback indicator to result
    if (result.data && result.data.length > 0) {
      result.fellBackToEn = true;
    }
  }

  return result;
};

// Get specific animal by slug with complete data
export const getAnimalBySlug = async (slug, locale = 'en') => {
  // Try to get data in requested locale
  let result = await supabase
    .from('v_animal_complete')
    .select('*')
    .eq('slug', slug)
    .eq('locale', locale)
    .single();

  // If no data found and locale is not 'en', fallback to English
  if (result.error && result.error.code === 'PGRST116' && locale !== 'en') {
    result = await supabase
      .from('v_animal_complete')
      .select('*')
      .eq('slug', slug)
      .eq('locale', 'en')
      .single();

    // Add fallback indicator to result
    if (result.data && !result.error) {
      result.fellBackToEn = true;
    }
  }

  return result;
};

// Get home page speeches in specified locale
export const getHomeSpeeches = async (locale = 'en') => {
  // Try to get data in requested locale
  let result = await supabase
    .from('v_home_speeches')
    .select('*')
    .eq('locale', locale)
    .order('speech_order');

  // If no data found and locale is not 'en', fallback to English
  if ((!result.data || result.data.length === 0) && locale !== 'en') {
    result = await supabase
      .from('v_home_speeches')
      .select('*')
      .eq('locale', 'en')
      .order('speech_order');

    // Add fallback indicator to result
    if (result.data && result.data.length > 0) {
      result.fellBackToEn = true;
    }
  }

  return result;
};

// Get available locales from the database
export const getAvailableLocales = async () => {
  return await supabase
    .from('t_animal')
    .select('locale')
    .limit(1000);
};

// Get all quiz questions with options in specified locale
export const getQuizQuestions = async (locale = 'en') => {
  // Try to get data in requested locale
  let result = await supabase
    .from('v_quiz_questions')
    .select('*')
    .eq('locale', locale)
    .order('question_order');

  // If no data found and locale is not 'en', fallback to English
  if ((!result.data || result.data.length === 0) && locale !== 'en') {
    result = await supabase
      .from('v_quiz_questions')
      .select('*')
      .eq('locale', 'en')
      .order('question_order');

    // Add fallback indicator to result
    if (result.data && result.data.length > 0) {
      result.fellBackToEn = true;
    }
  }

  return result;
};

// Get question categories with translations
export const getQuestionCategories = async (locale = 'en') => {
  // Try to get data in requested locale
  let result = await supabase
    .from('v_question_categories')
    .select('*')
    .eq('locale', locale)
    .order('code');

  // If no data found and locale is not 'en', fallback to English
  if ((!result.data || result.data.length === 0) && locale !== 'en') {
    result = await supabase
      .from('v_question_categories')
      .select('*')
      .eq('locale', 'en')
      .order('code');

    // Add fallback indicator to result
    if (result.data && result.data.length > 0) {
      result.fellBackToEn = true;
    }
  }

  return result;
};

// Get habitats/sites by animal slug
export const getHabitatsByAnimal = async (slug, locale = 'en') => {
  // Try to get data in requested locale from v_animal_site
  let result = await supabase
    .from('v_animal_site')
    .select('*')
    .eq('animal_slug', slug)
    .eq('locale', locale)
    .order('site_id');

  // If no data found and locale is not 'en', fallback to English
  if ((!result.data || result.data.length === 0) && locale !== 'en') {
    result = await supabase
      .from('v_animal_site')
      .select('*')
      .eq('animal_slug', slug)
      .eq('locale', 'en')
      .order('site_id');

    if (result.data && result.data.length > 0) {
      result.fellBackToEn = true;
    }
  }

  return result;
};

// Get EPA water quality prediction with traffic light status
export const getEpaPrediction = async (siteId, date) => {
  const result = await supabase
    .from('v_epa_measurements_wide_prediction_tl')
    .select('*')
    .eq('site_id', siteId)
    .eq('date', date)
    .single();

  return result;
};
