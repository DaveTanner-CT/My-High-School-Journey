# High School Journey — First Architecture Build

This is the first native SwiftUI/SwiftData architecture build for High School Journey.

## What this build proves

- Native SwiftUI app shell
- SwiftData persistence
- A central module registry separate from home-screen preferences
- Built-in tiles can be enabled/disabled and reordered
- Custom tiles are persisted independently from built-in modules
- Custom tiles support collection, shortcut and resource behaviors
- A working My Journey data model and add/delete flow
- Profile settings
- Navigation destinations are routed by module ID rather than hard-coded into each tile
- Placeholder screens let future modules connect without changing the home-screen architecture

## Recommended Xcode setup

1. In Xcode, create a new **iOS App** project named `HighSchoolJourney`.
2. Interface: **SwiftUI**.
3. Language: **Swift**.
4. Storage: you can choose SwiftData, but replace the generated model/app files with the files in this package.
5. Set the deployment target to **iOS 17.0 or later**. SwiftData requires iOS 17+.
6. Delete the generated `ContentView.swift` and any generated sample model such as `Item.swift`.
7. Add the folders/files in this package to the Xcode project, preserving the folder groups if desired.
8. Build and run.

## Important: iCloud is intentionally NOT enabled in Build 1

The model has been kept simple so we can make it CloudKit-compatible, but this first build uses the local SwiftData store only.

Before enabling iCloud sync we should:

- finalize the first model relationships
- add an explicit SwiftData schema/version plan
- test migrations locally
- enable the iCloud + CloudKit capability
- enable Background Modes > Remote notifications
- configure the private CloudKit container
- test on two real devices signed into the same Apple ID

This avoids creating a production CloudKit schema before the model foundation is ready.

## Photo architecture

Photos are intentionally not stored in SwiftData as large binary blobs in this first build.

Recommended next architecture:

- SwiftData `PhotoAsset` metadata record
- image files stored in the app's Application Support directory
- generated thumbnails stored separately
- PhotosPicker for user-selected images
- filenames/IDs in SwiftData rather than image bytes
- later verify how file storage and CloudKit synchronization should work before committing to the sync approach

## Next build recommendation

Build 2 should add:

1. explicit SwiftData schema/versioning
2. PhotoAsset model + photo storage service
3. add/edit Journey Moment detail screen
4. photo attachment to Journey Moments
5. a unified quick-add button
6. friendly save/error state instead of `try?`
7. initial Trusted Resource model/data file
8. then validate CloudKit compatibility before enabling iCloud

## Known limitation

This source package was generated outside Xcode, so it has not been compiled against Apple's SDK in this environment. Xcode should be treated as the compilation authority. If Xcode identifies a compile issue, use the exact error and filename to correct it before adding more features.
