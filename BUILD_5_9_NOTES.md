# Build 5.9 — Face ID, Email Backup, and Google Docs Resume

## What changed

### App Lock
- Adds Face ID or Touch ID as an optional unlock method when the device supports it.
- The existing four-digit PIN remains available as the backup unlock method.
- Biometric preference is stored locally. The PIN and recovery information remain in Keychain.
- Adds the required Face ID usage description to `project.yml`.

### Email Backup
- Adds a Backup section in Settings.
- Students can enter a backup email and tap **Email Backup to Me**.
- The backup contains profile information, Journey Moments, module records, custom tiles/items, tile preferences, photos, keepsake files, headshot, and resume preferences.
- App Lock PINs, recovery codes, and Google OAuth tokens are deliberately excluded.
- If Apple Mail is not configured, the app still creates the backup and exposes **Save or Share Latest Backup** so another mail app or storage destination can be used.
- Backup file extension: `.hsjbackup`. The current package is JSON with embedded binary data so a later Restore feature can rebuild the records and local files.

### Resume → Editable Google Doc
- Makes **Create Editable Google Doc** the primary resume output.
- Uses the student's selected Journey records and creates the document in the student's Google Drive.
- Opens the new document in Google Docs for editing.
- Keeps PDF as a secondary option for a final, printable copy.
- Uses OAuth with PKCE and stores Google tokens in Keychain on the device.
- Requests the narrow `drive.file` scope rather than full Drive access.

## One-time Google setup required
See `GOOGLE_DOCS_SETUP.md`.

Until the Google OAuth client ID is added, the Google Docs button stays disabled and shows a setup message. The rest of Build 5.9 works without Google setup.

## Data model
No SwiftData schema change. Build 5.9 continues to use `JourneySchemaV2`.

## Validation
- Swift syntax parse run across all Swift files.
- `project.yml` updated for Face ID and Google OAuth callback settings.
