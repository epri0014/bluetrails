import { supabase } from './supabase.js';

// Get all animals with basic translated information
export const getAnimals = async (locale = 'en') => {
  return await supabase
    .from('v_animals')
    .select('*')
    .eq('locale', locale)
    .order('display_order');
};

// Get specific animal by slug with complete data
export const getAnimalBySlug = async (slug, locale = 'en') => {
  return await supabase
    .from('v_animal_complete')
    .select('*')
    .eq('slug', slug)
    .eq('locale', locale)
    .single();
};

// Get home page speeches in specified locale
export const getHomeSpeeches = async (locale = 'en') => {
  return await supabase
    .from('v_home_speeches')
    .select('*')
    .eq('locale', locale)
    .order('speech_order');
};

// Get available locales from the database
export const getAvailableLocales = async () => {
  return await supabase
    .from('t_animal')
    .select('locale')
    .limit(1000);
};