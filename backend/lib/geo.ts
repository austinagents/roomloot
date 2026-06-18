import { cellToBoundary, cellToLatLng, gridDisk, latLngToCell } from "h3-js";
import { validateLatLng, validateRadius } from "./validation";

export { cellToBoundary, cellToLatLng, gridDisk, latLngToCell };

export function validateCoordinateInput(lat: number, lng: number) {
  return validateLatLng(lat, lng);
}

export function validateRadiusInput(radius: number, max: number) {
  return validateRadius(radius, max);
}

export function pointWkt(lat: number, lng: number) {
  return `SRID=4326;POINT(${lng} ${lat})`;
}

export function randomPointAround(lat: number, lng: number, radiusMeters: number) {
  const earthRadiusMeters = 6371000;
  const distance = radiusMeters * Math.sqrt(Math.random());
  const bearing = Math.random() * Math.PI * 2;
  const lat1 = (lat * Math.PI) / 180;
  const lng1 = (lng * Math.PI) / 180;
  const angularDistance = distance / earthRadiusMeters;

  const lat2 = Math.asin(
    Math.sin(lat1) * Math.cos(angularDistance) +
      Math.cos(lat1) * Math.sin(angularDistance) * Math.cos(bearing)
  );
  const lng2 =
    lng1 +
    Math.atan2(
      Math.sin(bearing) * Math.sin(angularDistance) * Math.cos(lat1),
      Math.cos(angularDistance) - Math.sin(lat1) * Math.sin(lat2)
    );

  return {
    lat: (lat2 * 180) / Math.PI,
    lng: ((((lng2 * 180) / Math.PI + 540) % 360) - 180)
  };
}

