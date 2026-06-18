import { badRequest, json, mapSupabaseError, serverError } from "@/lib/http";
import { calculateLevel } from "@/lib/leveling";
import { getSupabaseAdmin } from "@/lib/supabase";
import { isUuid, parseNumber, validateLatLng } from "@/lib/validation";

export async function POST(request: Request) {
  const body = await request.json().catch(() => null);
  const userId = body?.userId;
  const treasureId = body?.treasureId;
  const lat = parseNumber(body?.lat);
  const lng = parseNumber(body?.lng);
  const accuracy = parseNumber(body?.accuracyMeters);

  if (!isUuid(userId)) return badRequest("A valid userId is required.");
  if (!isUuid(treasureId)) return badRequest("A valid treasureId is required.");
  const coordinateError = validateLatLng(lat, lng);
  if (coordinateError) return badRequest(coordinateError);
  if (!Number.isFinite(accuracy)) return badRequest("GPS accuracy is required.");
  if (accuracy > 100) return json({ success: false, error: "GPS accuracy is too low to collect this treasure. Move to a clearer area and try again." }, 400);

  try {
    const supabase = getSupabaseAdmin();
    const user = await supabase
      .from("users")
      .select("id, coins, xp")
      .eq("id", userId)
      .maybeSingle();
    if (user.error) return serverError(mapSupabaseError(user.error));
    if (!user.data) return badRequest("User not found.");

    const treasure = await supabase
      .from("treasures")
      .select("id, collected_at, expires_at")
      .eq("id", treasureId)
      .maybeSingle();
    if (treasure.error) return serverError(mapSupabaseError(treasure.error));
    if (!treasure.data) return badRequest("Treasure not found.");
    if (treasure.data.collected_at) return json({ success: false, error: "This treasure has already been collected." }, 409);
    if (new Date(treasure.data.expires_at).getTime() <= Date.now()) return json({ success: false, error: "This treasure has expired." }, 410);

    const collected = await supabase.rpc("collect_treasure_atomic", {
      p_user_id: userId,
      p_treasure_id: treasureId,
      p_lat: lat,
      p_lng: lng
    });
    if (collected.error) return serverError(mapSupabaseError(collected.error));
    const row = collected.data?.[0];
    if (!row) return json({ success: false, error: "You need to be closer to collect this treasure." }, 400);

    const newCoins = user.data.coins + row.coin_value;
    const newXp = user.data.xp + row.xp_value;
    const newLevel = calculateLevel(newXp);

    const collection = await supabase
      .from("treasure_collections")
      .insert({
        user_id: userId,
        treasure_id: treasureId,
        artifact_name: row.artifact_name,
        rarity: row.rarity,
        coins_awarded: row.coin_value,
        xp_awarded: row.xp_value,
        collection_location: `SRID=4326;POINT(${lng} ${lat})`
      })
      .select("id")
      .single();
    if (collection.error) return serverError(mapSupabaseError(collection.error));

    const updated = await supabase
      .from("users")
      .update({ coins: newCoins, xp: newXp, level: newLevel, updated_at: new Date().toISOString() })
      .eq("id", userId)
      .select("coins, xp, level")
      .single();
    if (updated.error) return serverError(mapSupabaseError(updated.error));

    return json({
      success: true,
      collection: {
        artifactName: row.artifact_name,
        rarity: row.rarity,
        coinsAwarded: row.coin_value,
        xpAwarded: row.xp_value,
        artifactDescription: row.artifact_description
      },
      user: updated.data
    });
  } catch (error) {
    return serverError(error instanceof Error ? error.message : "Unable to collect treasure.");
  }
}

