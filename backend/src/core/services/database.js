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

// 追加在文件末尾 —— services/database.js
export const getHabitatsByAnimal = async (slug, locale = 'en') => {
  // 先按请求的 locale 查
  let result = await supabase
    .from('v_animal_sites')         // ← 换成你的真实视图/表名
    .select('*')
    .eq('slug', slug)
    .eq('locale', locale)
    .order('site_order');           // ← 如无该字段可去掉

  // 若没数据且 locale 不是 en，则回退到英文
  if ((!result.data || result.data.length === 0) && locale !== 'en') {
    result = await supabase
      .from('v_animal_sites')       // ← 同上
      .select('*')
      .eq('slug', slug)
      .eq('locale', 'en')
      .order('site_order');         // ← 同上

    if (result.data && result.data.length > 0) {
      result.fellBackToEn = true;
    }
  }

  return result;
};
