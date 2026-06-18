import { badRequest, json, mapSupabaseError, serverError } from "@/lib/http";
import { getSupabaseAdmin } from "@/lib/supabase";
import { parseNumber, isUuid, validateLatLng } from "@/lib/validation";

export async function POST(request: Request) {
  const body = await request.json().catch(() => null);
  const userId = body?.userId;
  const lat = parseNumber(body?.lat);
  const lng = parseNumber(body?.lng);
  const accuracy = parseNumber(body?.accuracyMeters);
  const speed = parseNumber(body?.speedMps);
  const heading = parseNumber(body?.headingDegrees);

  if (!isUuid(userId)) return badRequest("A valid userId is required.");
  const coordinateError = validateLatLng(lat, lng);
  if (coordinateError) return badRequest(coordinateError);

  try {
    const supabase = getSupabaseAdmin();
    const user = await supabase.from("users").select("id").eq("id", userId).maybeSingle();
    if (user.error) return serverError(mapSupabaseError(user.error));
    if (!user.data) return badRequest("User not found.");

    const result = await supabase.rpc("record_player_location_update", {
      p_user_id: userId,
      p_lat: lat,
      p_lng: lng,
      p_accuracy_meters: Number.isFinite(accuracy) ? accuracy : null,
      p_speed_mps: Number.isFinite(speed) ? speed : null,
      p_heading_degrees: Number.isFinite(heading) ? heading : null
    });

    if (result.error) return serverError(mapSupabaseError(result.error));
    return json({ success: true });
  } catch (error) {
    return serverError(error instanceof Error ? error.message : "Unable to update location.");
  }
}

