import { createClient } from "@supabase/supabase-js";
import { getBackendEnv } from "./env";

export function getSupabaseAdmin() {
  const env = getBackendEnv();
  return createClient(env.supabaseUrl, env.supabaseServiceRoleKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false
    }
  });
}

