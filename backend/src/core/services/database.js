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