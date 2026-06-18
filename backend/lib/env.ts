export type BackendEnv = {
  supabaseUrl: string;
  supabaseAnonKey: string;
  supabaseServiceRoleKey: string;
};

const requiredKeys = [
  "SUPABASE_URL",
  "SUPABASE_ANON_KEY",
  "SUPABASE_SERVICE_ROLE_KEY"
] as const;

export function getEnvStatus() {
  const missing = requiredKeys.filter((key) => !process.env[key]);
  return {
    configured: missing.length === 0,
    missing,
    message:
      missing.length === 0
        ? "Supabase environment is configured."
        : `Missing Supabase env vars: ${missing.join(", ")}. Copy backend/.env.local.example to backend/.env.local and fill the values.`
  };
}

export function getBackendEnv(): BackendEnv {
  const status = getEnvStatus();
  if (!status.configured) {
    if (process.env.NODE_ENV === "production") {
      throw new Error(status.message);
    }
    throw new Error(status.message);
  }

  return {
    supabaseUrl: process.env.SUPABASE_URL!,
    supabaseAnonKey: process.env.SUPABASE_ANON_KEY!,
    supabaseServiceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY!
  };
}

