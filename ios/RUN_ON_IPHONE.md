# Run RoomLoot On iPhone

1. Open `ios/RoomLoot.xcodeproj` in Xcode.
2. Select the `RoomLoot` target.
3. In Signing & Capabilities, choose your Apple Developer Team.
4. If Xcode reports that `com.roomloot.app` is unavailable, change the bundle identifier to a unique value, for example `com.yourname.roomloot`.
5. Confirm `ios/RoomLoot/Config/AppConfig.swift` contains:

   ```swift
   static let apiBaseURL = "https://roomloot.vercel.app"
   ```

6. Connect an iPhone running iOS 17 or newer.
7. Trust the Mac from the iPhone if prompted.
8. Select the connected iPhone as the run destination.
9. Press Run.
10. On first launch, allow When In Use location access.
11. Tap Start Hunt.
12. Seed treasures near your current GPS location with the production backend `/api/spawn/nearby` endpoint if none are nearby.
13. Walk within 25 meters of a treasure marker.
14. Tap Start AR Hunt.
15. Allow camera access.
16. Point the camera at a surface, find the treasure, and tap it to collect.
17. Confirm coins, XP, and recent inventory update after collection.

ARKit must be tested on a physical device. The iOS Simulator cannot validate the camera-based AR collection scene.

