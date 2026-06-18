import { getEnvStatus } from "@/lib/env";
import { getSupabaseAdmin } from "@/lib/supabase";
import { json } from "@/lib/http";

export async function GET() {
  const env = getEnvStatus();
  if (!env.configured) {
    return json({
      ok: false,
      service: "roomloot-backend",
      supabaseConfigured: false,
      databaseReachable: false,
      setup: env.message
    });
  }

  try {
    const supabase = getSupabaseAdmin();
    const { error } = await supabase.from("users").select("id").limit(1);
    return json({
      ok: !error,
      service: "roomloot-backend",
      supabaseConfigured: true,
      databaseReachable: !error,
      error: error?.message
    });
  } catch (error) {
    return json({
      ok: false,
      service: "roomloot-backend",
      supabaseConfigured: true,
      databaseReachable: false,
      error: error instanceof Error ? error.message : "Unknown health check error."
    });
  }
}

