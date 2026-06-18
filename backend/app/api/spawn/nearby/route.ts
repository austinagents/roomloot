import { randomArtifact } from "@/lib/artifacts";
import { randomPointAround, pointWkt, latLngToCell } from "@/lib/geo";
import { badRequest, json, mapSupabaseError, serverError } from "@/lib/http";
import { getSupabaseAdmin } from "@/lib/supabase";
import { parseNumber, validateLatLng, validateRadius } from "@/lib/validation";

export async function POST(request: Request) {
  const body = await request.json().catch(() => null);
  const lat = parseNumber(body?.lat);
  const lng = parseNumber(body?.lng);
  const radiusMeters = parseNumber(body?.radiusMeters);
  const count = Math.floor(parseNumber(body?.count));

  const coordinateError = validateLatLng(lat, lng);
  if (coordinateError) return badRequest(coordinateError);
  const radiusError = validateRadius(radiusMeters, 5000);
  if (radiusError) return badRequest(radiusError);
  if (!Number.isFinite(count) || count < 1 || count > 500) return badRequest("Count must be between 1 and 500.");

  try {
    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
    const treasures = Array.from({ length: count }, () => {
      const point = randomPointAround(lat, lng, radiusMeters);
      const artifact = randomArtifact();
      let h3Cell: string | null = null;
      try {
        h3Cell = latLngToCell(point.lat, point.lng, 9);
      } catch {
        h3Cell = null;
      }
      return {
        artifact_name: artifact.name,
        artifact_description: artifact.description,
        rarity: artifact.rarity,
        coin_value: artifact.coinValue,
        xp_value: artifact.xpValue,
        location: pointWkt(point.lat, point.lng),
        h3_cell: h3Cell,
        expires_at: expiresAt
      };
    });

    const supabase = getSupabaseAdmin();
    const result = await supabase
      .from("treasures")
      .insert(treasures)
      .select("id, artifact_name, artifact_description, rarity, coin_value, xp_value, h3_cell, expires_at");
    if (result.error) return serverError(mapSupabaseError(result.error));

    return json({ spawned: result.data?.length ?? 0, treasures: result.data ?? [] });
  } catch (error) {
    return serverError(error instanceof Error ? error.message : "Unable to spawn nearby treasures.");
  }
}

