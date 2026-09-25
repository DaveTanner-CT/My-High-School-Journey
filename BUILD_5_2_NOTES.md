# Build 5.2 - Keepsakes and Attachments

Build 5.2 adds a reusable keepsake system so students can preserve supporting material with their journey records.

## What changed

- Activities, Honors, Experiences, Goals, and future modules that use `ModuleRecord` can now store photos and files from the record detail screen.
- Journey Moments keep their existing photo workflow and now also support file attachments.
- Custom collection items now open to a detail screen where students can add photos and files.
- Files are copied into the app's Application Support storage so the app keeps its own copy rather than depending on the original Files location.
- Common file types can be reopened with the iOS Quick Look viewer.
- Deleting a module record or custom collection item also cleans up its saved photos and files.

## Architecture

Photos continue using the existing `PhotoAsset` SwiftData model. File attachments are intentionally stored as local file metadata plus copied files, so this build does not require another SwiftData schema migration.

This keeps the change lower risk while the local-first data architecture is still being stabilized. A later CloudKit/iCloud phase can move file attachment metadata into the synced model when cloud storage is intentionally enabled.

## No project configuration changes

The project already recursively includes `Views`, `Components`, and `Services`, so no `project.yml`, Codemagic, signing, or provisioning changes are required.
