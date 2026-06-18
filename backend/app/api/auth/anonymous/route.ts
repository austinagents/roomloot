import { badRequest, json, mapSupabaseError, serverError } from "@/lib/http";
import { getSupabaseAdmin } from "@/lib/supabase";

const names = ["Explorer", "Hunter", "Scout"];

function randomUsername() {
  const prefix = names[Math.floor(Math.random() * names.length)];
  return `${prefix}${Math.floor(1000 + Math.random() * 9000)}`;
}

export async function POST(request: Request) {
  const body = await request.json().catch(() => null);
  const deviceId = body?.deviceId;
  if (typeof deviceId !== "string" || deviceId.trim().length < 8) {
    return badRequest("deviceId is required.");
  }

  try {
    const supabase = getSupabaseAdmin();
    const existing = await supabase
      .from("users")
      .select("id, username, coins, gems, xp, level")
      .eq("device_id", deviceId)
      .maybeSingle();

    if (existing.error) return serverError(mapSupabaseError(existing.error));
    if (existing.data) return json({ user: existing.data });

    const created = await supabase
      .from("users")
      .insert({ device_id: deviceId, username: randomUsername() })
      .select("id, username, coins, gems, xp, level")
      .single();

    if (created.error) return serverError(mapSupabaseError(created.error));
    return json({ user: created.data });
  } catch (error) {
    return serverError(error instanceof Error ? error.message : "Unable to authenticate anonymously.");
  }
}

