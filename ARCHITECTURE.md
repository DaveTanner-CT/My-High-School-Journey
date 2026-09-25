# Architecture Notes — Build 1

## Why built-in modules and custom tiles are different models

Built-in modules are application capabilities. Their identity, title, icon and default behavior live in `ModuleRegistry` so adding a future feature is predictable and testable.

A student's choices about those modules live in `TilePreference`. That means a future code update can add a module without rewriting the student's home layout.

Custom tiles are user-created content, so they are persisted as `CustomTile` records.

Both built-in and custom tiles are converted to the shared `HomeTileEntry` type for display and ordering. This keeps the home screen unaware of how a tile was created.

## Module navigation

Tiles navigate using stable module IDs through `AppRoute`. The home screen does not directly instantiate future module data models.

This allows a placeholder module to later become a complete feature without changing its tile preference record or its place on the home screen.

## Custom tile types

- `collection`: stores simple student-created entries in `CustomTileItem`
- `shortcut`: points to a registered built-in module
- `resource`: opens a student-selected URL

Custom collection entries use a stable `tileID`. Build 1 manually deletes dependent items when a custom tile is deleted. Before CloudKit is enabled, decide whether this should become an explicit SwiftData relationship with a cascade rule.

## Journey

`JourneyMoment` is intentionally a real persisted model in Build 1. This proves that the app shell is not just a navigation prototype.

Later feature models should link back to Journey Moments rather than copy Journey text into multiple tables whenever possible.

## Photos

Do not add large image blobs directly to the current models. Add a dedicated `PhotoAsset` model and storage service next.

## CloudKit

CloudKit is deliberately deferred. Apple's current SwiftData guidance requires iCloud/CloudKit plus Background Modes/remote notifications for automatic synchronization. We should establish the first stable schema and migration plan before creating a production CloudKit schema.
