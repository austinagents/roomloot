import { randomArtifact } from "@/lib/artifacts";
import { cellToLatLng, gridDisk, latLngToCell, pointWkt, randomPointAround } from "@/lib/geo";
import { badRequest, json, mapSupabaseError, serverError } from "@/lib/http";
import { getSupabaseAdmin } from "@/lib/supabase";
import { parseNumber, validateLatLng } from "@/lib/validation";

const rarityTargets = {
  common: 20,
  uncommon: 10,
  rare: 5,
  epic: 2,
  legendary: 1
} as const;

export async function POST(request: Request) {
  const body = await request.json().catch(() => null);
  const lat = parseNumber(body?.lat);
  const lng = parseNumber(body?.lng);
  const resolution = Math.floor(parseNumber(body?.resolution ?? 9));
  const ringSize = Math.floor(parseNumber(body?.ringSize ?? 1));

  const coordinateError = validateLatLng(lat, lng);
  if (coordinateError) return badRequest(coordinateError);
  if (resolution < 6 || resolution > 11) return badRequest("Resolution must be between 6 and 11 for RoomLoot spawning.");
  if (ringSize < 0 || ringSize > 3) return badRequest("ringSize must be between 0 and 3.");

  try {
    const origin = latLngToCell(lat, lng, resolution);
    const cells = gridDisk(origin, ringSize);
    const supabase = getSupabaseAdmin();
    const summary = [];

    for (const cell of cells) {
      const [centerLat, centerLng] = cellToLatLng(cell);
      await supabase.from("h3_cells").upsert({
        h3_cell: cell,
        resolution,
        center_location: pointWkt(centerLat, centerLng),
        target_common_count: rarityTargets.common,
        target_uncommon_count: rarityTargets.uncommon,
        target_rare_count: rarityTargets.rare,
        target_epic_count: rarityTargets.epic,
        target_legendary_count: rarityTargets.legendary,
        updated_at: new Date().toISOString()
      });

      const active = await supabase
        .from("treasures")
        .select("rarity")
        .eq("h3_cell", cell)
        .is("collected_at", null)
        .gt("expires_at", new Date().toISOString());
      if (active.error) return serverError(mapSupabaseError(active.error));

      const counts = { common: 0, uncommon: 0, rare: 0, epic: 0, legendary: 0 };
      for (const item of active.data ?? []) counts[item.rarity as keyof typeof counts] += 1;

      const toSpawn = [];
      for (const rarity of Object.keys(rarityTargets) as Array<keyof typeof rarityTargets>) {
        const missing = Math.max(0, rarityTargets[rarity] - counts[rarity]);
        for (let i = 0; i < missing; i++) {
          const artifact = randomArtifact(rarity);
          const point = randomPointAround(centerLat, centerLng, 220);
          toSpawn.push({
            artifact_name: artifact.name,
            artifact_description: artifact.description,
            rarity: artifact.rarity,
            coin_value: artifact.coinValue,
            xp_value: artifact.xpValue,
            location: pointWkt(point.lat, point.lng),
            h3_cell: cell,
            expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
          });
        }
      }

      if (toSpawn.length > 0) {
        const inserted = await supabase.from("treasures").insert(toSpawn).select("id");
        if (inserted.error) return serverError(mapSupabaseError(inserted.error));
      }

      await supabase.from("spawn_jobs").insert({
        h3_cell: cell,
        status: "completed",
        spawned_count: toSpawn.length,
        completed_at: new Date().toISOString()
      });

      summary.push({ h3Cell: cell, spawnedCount: toSpawn.length, activeBefore: counts });
    }

    return json({ originCell: origin, cellCount: cells.length, summary });
  } catch (error) {
    return serverError(
      error instanceof Error
        ? `H3 spawn failed: ${error.message}. Verify h3-js v4 is installed and deployed.`
        : "H3 spawn failed. Verify h3-js v4 is installed and deployed."
    );
  }
}

