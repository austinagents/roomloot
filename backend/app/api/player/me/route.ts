import { badRequest, json, mapSupabaseError, serverError } from "@/lib/http";
import { getSupabaseAdmin } from "@/lib/supabase";
import { isUuid } from "@/lib/validation";

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const userId = searchParams.get("userId");
  if (!isUuid(userId)) return badRequest("A valid userId is required.");

  try {
    const supabase = getSupabaseAdmin();
    const userResult = await supabase
      .from("users")
      .select("id, username, coins, gems, xp, level")
      .eq("id", userId)
      .maybeSingle();

    if (userResult.error) return serverError(mapSupabaseError(userResult.error));
    if (!userResult.data) return badRequest("User not found.");

    const collections = await supabase
      .from("treasure_collections")
      .select("id, treasure_id, artifact_name, rarity, coins_awarded, xp_awarded, collected_at")
      .eq("user_id", userId)
      .order("collected_at", { ascending: false })
      .limit(50);

    if (collections.error) return serverError(mapSupabaseError(collections.error));
    return json({ user: userResult.data, recentCollections: collections.data ?? [] });
  } catch (error) {
    return serverError(error instanceof Error ? error.message : "Unable to load player.");
  }
}

