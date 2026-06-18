import { badRequest, json, mapSupabaseError, serverError } from "@/lib/http";
import { getSupabaseAdmin } from "@/lib/supabase";
import { isUuid, parseNumber, validateLatLng, validateRadius } from "@/lib/validation";

function mapTreasure(row: any) {
  return {
    id: row.id,
    artifactName: row.artifact_name,
    artifactDescription: row.artifact_description,
    rarity: row.rarity,
    coinValue: row.coin_value,
    xpValue: row.xp_value,
    lat: Number(row.lat),
    lng: Number(row.lng),
    distanceMeters: Math.round(Number(row.distance_meters))
  };
}

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const userId = searchParams.get("userId");
  const lat = parseNumber(searchParams.get("lat"));
  const lng = parseNumber(searchParams.get("lng"));
  const radius = parseNumber(searchParams.get("radius") ?? "500");

  if (!isUuid(userId)) return badRequest("A valid userId is required.");
  const coordinateError = validateLatLng(lat, lng);
  if (coordinateError) return badRequest(coordinateError);
  const radiusError = validateRadius(radius, 1000);
  if (radiusError) return badRequest(radiusError);

  try {
    const supabase = getSupabaseAdmin();
    const user = await supabase.from("users").select("id").eq("id", userId).maybeSingle();
    if (user.error) return serverError(mapSupabaseError(user.error));
    if (!user.data) return badRequest("User not found.");

    const result = await supabase.rpc("nearby_treasures", {
      p_lat: lat,
      p_lng: lng,
      p_radius_meters: radius
    });

    if (result.error) return serverError(mapSupabaseError(result.error));
    return json({ treasures: (result.data ?? []).map(mapTreasure) });
  } catch (error) {
    return serverError(error instanceof Error ? error.message : "Unable to load nearby treasures.");
  }
}

