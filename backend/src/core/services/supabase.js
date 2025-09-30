import { createClient } from '@supabase/supabase-js';

let supabaseInstance = null;

// Get or create Supabase client instance (lazy initialization)
export const getSupabase = () => {
  if (!supabaseInstance) {
    // Get environment variables directly from globalThis (set by Cloudflare adapter)
    const supabaseUrl = globalThis.SUPABASE_URL;
    const supabaseKey = globalThis.SUPABASE_KEY;

    if (!supabaseUrl || !supabaseKey) {
      throw new Error(`Missing Supabase credentials: url=${!!supabaseUrl}, key=${!!supabaseKey}`);
    }

    supabaseInstance = createClient(supabaseUrl, supabaseKey);
  }
  return supabaseInstance;
};

// Export for backward compatibility
export const supabase = new Proxy({}, {
  get(target, prop) {
    return getSupabase()[prop];
  }
});

// Test database connection
export const testConnection = async () => {
  try {
    const client = getSupabase();
    const { data, error } = await client
      .from('animal')
      .select('id')
      .limit(1);

    return !error;
  } catch (err) {
    return false;
  }
};