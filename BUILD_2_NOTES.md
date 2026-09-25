# Build 2 — Schema Versioning + Photo Architecture

Repository: `DaveTanner-CT/My-High-School-Journey`

## Purpose

Build 2 adds two foundation pieces before additional modules are developed:

1. Explicit SwiftData schema versioning and a migration plan.
2. One reusable photo architecture for My Journey and future modules.

## New files

- `Architecture/Schema/JourneySchemaV1.swift`
- `Architecture/Schema/JourneyMigrationPlan.swift`
- `Models/PhotoAsset.swift`
- `Services/Photos/PhotoStorageService.swift`
- `Components/Photos/StoredPhotoThumbnailView.swift`

## Replaced files

- `HighSchoolJourneyApp.swift`
- `Views/Journey/AddJourneyMomentView.swift`
- `Views/Journey/JourneyView.swift`

## Architecture decisions

### Versioned schema

All persistent models are now registered through `JourneySchemaV1`.

Future model changes should create a new schema version instead of silently changing V1. Do not edit a released version's intended historical shape after a newer schema ships.

`JourneyMigrationPlan` is intentionally empty today because there is only one explicit schema version. Add migration stages when V2 is created.

### Reusable photo ownership

`PhotoAsset` does not belong only to `JourneyMoment`.

It identifies its parent using:

- `ownerType`
- `ownerID`

This lets College Visits, Athletics, Awards, Activities, Projects and custom collections reuse the same photo service later.

### Image bytes do not live in SwiftData

SwiftData stores photo metadata only. JPEG files are written under the app's Application Support directory.

The service creates:

- an optimized display image, max dimension 2200px
- a thumbnail, max dimension 640px

This keeps large image data out of common SwiftData fetches.

### PhotosPicker

The app uses Apple's system PhotosPicker. This is preferable to asking for broad photo-library access merely to select images.

## Important Build 1 note

Build 1 used an unversioned SwiftData container. If you have already created irreplaceable test data in a simulator/device using Build 1, export or note that test data before switching builds. At this stage we are treating Build 2 as the first explicit schema baseline rather than preserving experimental Build 1 stores.

## Test checklist

1. Launch with an empty store.
2. Add a Journey Moment without a photo.
3. Quit/relaunch and confirm it persists.
4. Add a Journey Moment with one photo.
5. Add a Journey Moment with several photos.
6. Quit/relaunch and confirm thumbnails still display.
7. Delete a Journey Moment with photos.
8. Confirm the moment disappears and the app does not crash.
9. Confirm tile settings/custom tiles still work exactly as in Build 1.
10. Test on iPhone simulator and, when convenient, a physical iPhone.

## Suggested Git commit

`Build 2 - Add versioned SwiftData schema and reusable photo storage`

## Frozen V1 model definitions

V1 models are nested under `JourneySchemaV1`. `Models/CurrentModelAliases.swift` exposes simple model names to the rest of the app. This is intentional: when V2 is created, V1 stays frozen and the aliases move to V2.
