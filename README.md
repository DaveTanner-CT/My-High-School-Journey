# My High School Journey

Native iOS architecture for **High School Journey** — a private, student-owned app for capturing experiences, accomplishments, photos, reflections and future plans throughout high school.

> The student owns and controls their High School Journey data. The app is designed as a personal student tool, not as a school student-information system.

## Current milestone

**Build 2 — Versioned data architecture + reusable photos**

Build 2 includes everything from Build 1 plus:

- explicit SwiftData schema versioning
- a migration-plan foundation
- frozen V1 model definitions
- a reusable `PhotoAsset` model
- one shared photo-storage service
- PhotosPicker support in My Journey
- optimized full images + thumbnails
- photo-aware Journey cards
- cleanup of photo files when a Journey Moment is deleted
- safer save behavior so a photo failure does not create duplicate Journey Moments

See `BUILD_2_NOTES.md` and `ARCHITECTURE.md` for the architectural reasoning.

## Repository

GitHub repository:

`DaveTanner-CT/My-High-School-Journey`

## Recommended Xcode setup

1. Create/open the iOS project `HighSchoolJourney` in Xcode.
2. Interface: **SwiftUI**.
3. Language: **Swift**.
4. Deployment target: **iOS 17.0 or later**.
5. Remove generated sample files such as `ContentView.swift` and `Item.swift` if they are still present.
6. Add the files and folders from this package to the app target.
7. Preserve the folder structure where practical.
8. Build and run first in an iPhone simulator.

## Build 2 test checklist

Test these before starting the next module:

- launch with a clean install
- create a Journey Moment without a photo
- create one with one photo
- create one with multiple photos
- quit/reopen and confirm the moments and thumbnails persist
- delete a Journey Moment that contains photos
- enable/disable built-in tiles
- reorder tiles
- create a custom Collection tile
- create a custom Shortcut tile
- create a custom Resource tile
- delete a custom tile
- change profile settings

## iCloud is still intentionally off

Do **not** enable CloudKit yet.

Build 2 establishes the versioned schema and local photo-file lifecycle first. We should validate those on-device before deciding how photo files and SwiftData metadata synchronize between a student's devices.

## Permissions

The current photo flow uses Apple's system PhotosPicker. Do not add broad Photo Library access merely to allow students to select photos.

Camera capture has not been added yet.

## Important Build 1 note

Build 1 used an experimental unversioned SwiftData store. If you have meaningful test data created with Build 1, save anything you care about before switching to Build 2. Build 2 is the first explicit versioned schema baseline.

## Suggested Git commit

`Build 2 - Add versioned SwiftData schema and reusable photo storage`

## Next architecture milestone

After Build 2 compiles and passes the test checklist, the recommended next work is:

1. Journey Moment detail/editing
2. photo gallery/detail view and captions
3. global Quick Add
4. Trusted Resources model + bundled data source
5. friendly app-wide error/save states
6. CloudKit compatibility review

Do not start large College, Recruiting or Resume features until these shared foundations are stable.


## Build 5
Activities, Honors, Experiences, and Goals now support real student-owned records through SwiftData schema V2. See `BUILD_5_NOTES.md`.
