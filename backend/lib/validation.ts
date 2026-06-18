export function parseNumber(value: unknown) {
  if (typeof value === "number") return value;
  if (typeof value === "string" && value.trim() !== "") return Number(value);
  return Number.NaN;
}

export function isUuid(value: unknown) {
  return (
    typeof value === "string" &&
    /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value)
  );
}

export function validateLatLng(lat: number, lng: number) {
  if (!Number.isFinite(lat) || lat < -90 || lat > 90) return "Latitude must be between -90 and 90.";
  if (!Number.isFinite(lng) || lng < -180 || lng > 180) return "Longitude must be between -180 and 180.";
  return null;
}

export function validateRadius(radius: number, max: number) {
  if (!Number.isFinite(radius) || radius <= 0) return "Radius must be a positive number.";
  if (radius > max) return `Radius must be ${max} meters or less.`;
  return null;
}

