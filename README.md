# RoomLoot

RoomLoot is a production-shaped mobile AR treasure hunt MVP. Players explore the real world, see nearby treasures on a MapKit map, walk close to them, open an ARKit/RealityKit collection moment, and collect persisted rewards through a backend that validates location with PostGIS.

This repo is intentionally unified:

- `backend/` - Next.js App Router API deployed to Vercel.
- `ios/RoomLoot/` - SwiftUI iOS source using CoreLocation, MapKit, ARKit, RealityKit, and URLSession.
- `supabase/migrations/` - Supabase Postgres/PostGIS schema and SQL functions.
- `supabase/seed/` - Notes for early test seeding.

## Architecture

The iOS app only calls the backend API. It does not write directly to Supabase.

The backend is the only layer that talks to Supabase, using the service role key server-side only. PostGIS geography is the source of truth for nearby search, exact distance, and collection validation. H3 is used for scalable world partitioning and spawn density, not final collection validation.

## Setup Checklist

1. Create Supabase project.
2. Copy `SUPABASE_URL`.
3. Copy `SUPABASE_ANON_KEY`.
4. Copy `SUPABASE_SERVICE_ROLE_KEY`.
5. Add env vars to `backend/.env.local`.
6. Run migrations in Supabase SQL editor or via CLI.
7. Run backend locally.
8. Confirm `/api/health` works.
9. Deploy backend to Vercel.
10. Paste Vercel URL into `ios/RoomLoot/Config/AppConfig.swift`.
11. Open iOS app in Xcode.
12. Run on iPhone.
13. Use `/api/spawn/nearby` to seed treasures near current location.
14. Start hunt.

## Required Backend Env Vars

Create `backend/.env.local` from `backend/.env.local.example`:

```bash
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
```

The backend also includes `backend/.env.example` with the same keys. Secrets are not hardcoded.

Missing env vars produce setup errors in API responses where possible. In production, backend client creation fails with a clear missing-env message.

## Supabase Setup

Run this migration:

```text
supabase/migrations/001_initial_schema.sql
```

You can paste it into the Supabase SQL editor, or run it through the Supabase CLI from the repo root if your project is linked.

The migration creates:

- `users`
- `player_locations`
- `treasures`
- `treasure_collections`
- `h3_cells`
- `spawn_jobs`
- `anti_cheat_events`
- GIST geography indexes
- `nearby_treasures(...)`
- `collect_treasure_atomic(...)`
- `record_player_location_update(...)`

PostGIS logic uses `extensions.geography(Point, 4326)`, `extensions.ST_DWithin`, `extensions.ST_Distance`, `extensions.ST_SetSRID`, `extensions.ST_MakePoint`, `extensions.ST_X`, and `extensions.ST_Y`.

## Run Backend Locally

```bash
cd roomloot/backend
npm install
npm run dev
```

Then open:

```text
http://localhost:3000/api/health
```

Expected configured response:

```json
{
  "ok": true,
  "service": "roomloot-backend",
  "supabaseConfigured": true,
  "databaseReachable": true
}
```

## Backend API

Implemented routes:

- `GET /api/health`
- `POST /api/auth/anonymous`
- `GET /api/player/me?userId=uuid`
- `POST /api/location/update`
- `GET /api/treasures/nearby?userId=uuid&lat=26.6165&lng=-80.0728&radius=500`
- `POST /api/treasures/collect`
- `POST /api/spawn/nearby`
- `POST /api/spawn/cell`

Early test spawn:

```bash
curl -X POST http://localhost:3000/api/spawn/nearby \
  -H "Content-Type: application/json" \
  -d '{"lat":26.6165,"lng":-80.0728,"radiusMeters":750,"count":50}'
```

## Deploy Backend To Vercel

1. Create a Vercel project using `roomloot/backend` as the project root.
2. Add environment variables in Vercel:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY`
3. Deploy.
4. Visit `https://YOUR_PROJECT.vercel.app/api/health`.
5. Confirm `supabaseConfigured` and `databaseReachable` are true.

Vercel Hobby is fine for development and TestFlight. Expect Vercel Pro before a commercial public launch.

Supabase Free is fine for MVP and TestFlight. Expect Supabase Pro if real global usage grows.

## iOS Setup

This repo includes the Swift source files for a SwiftUI iOS app under:

```text
ios/RoomLoot/
```

To create the Xcode project:

1. Open Xcode.
2. Create a new iOS App project named `RoomLoot`.
3. Use SwiftUI and Swift.
4. Set the minimum deployment target to iOS 17.
5. Add the files from `ios/RoomLoot/` to the app target.
6. Use `ios/RoomLoot/Info.plist` values for permissions.
7. Paste your backend URL into:

```text
ios/RoomLoot/Config/AppConfig.swift
```

```swift
enum AppConfig {
    static let apiBaseURL = "https://YOUR_BACKEND_URL_HERE"
}
```

Run on a real iPhone for ARKit and location testing.

## Implemented

- Anonymous device-based player persistence.
- Player profile and recent collection loading.
- CoreLocation location updates.
- PostGIS-backed nearby treasure search.
- Server-side atomic collection validation within 25 meters.
- GPS accuracy rejection over 100 meters.
- Basic impossible travel anti-cheat logging.
- Persisted coins, XP, and level progression.
- Admin/dev nearby spawn endpoint.
- H3 cell spawn route using `h3-js` v4 functions.
- SwiftUI premium adventure UI.
- MapKit treasure markers and selected treasure card.
- ARKit/RealityKit treasure collection scene with simple primitive chest.
- Inventory, profile, and collection result screens.

## Intentionally Not Implemented In V1

- OAuth.
- Payments, subscriptions, ads, or in-app purchase.
- Push notifications.
- Background location.
- Direct iOS-to-Supabase writes.
- Redis or custom cache services.
- Analytics, crash reporting, email, SMS, AI, crypto, or NFT systems.
- Ban enforcement for anti-cheat events.
- Production admin authentication for spawn endpoints.
- Custom 3D art assets.

## What To Test First

1. Run the Supabase migration.
2. Start the backend and open `/api/health`.
3. Call `POST /api/auth/anonymous`.
4. Use `POST /api/spawn/nearby` with your current coordinates.
5. Call `GET /api/treasures/nearby`.
6. Deploy to Vercel and repeat `/api/health`.
7. Paste the Vercel URL into `ios/RoomLoot/Config/AppConfig.swift`.
8. Run the app on an iPhone.
9. Start Hunt, grant When In Use location, and verify nearby markers.
10. Walk within 25 meters, open AR Hunt, tap the chest, and verify coins/XP update.

