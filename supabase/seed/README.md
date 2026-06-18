Use the backend dev/admin endpoints after migrations are applied:

1. Run the backend locally or deploy it.
2. Create or authenticate a player through `/api/auth/anonymous`.
3. Seed a test area with `POST /api/spawn/nearby`.

Example body:

```json
{
  "lat": 26.6165,
  "lng": -80.0728,
  "radiusMeters": 750,
  "count": 50
}
```

