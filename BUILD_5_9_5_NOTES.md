# Build 5.9.5 — Google OAuth Connected

## What changed

- Added the production Google iOS OAuth client ID for My High School Journey.
- Added the reversed Google OAuth client ID as the app URL callback scheme.
- The Google Docs resume button can now begin Google sign-in instead of reporting that OAuth is not configured.
- The OAuth request continues to use only the narrow `drive.file` scope.

## Google Cloud prerequisites already completed

- Google Drive API enabled.
- Google Docs API enabled.
- `drive.file` scope added to Data Access.
- OAuth app is External / Testing.
- davetanner@scriptingforschools.org added as a test user.

## Current testing limitation

While the Google OAuth app remains in Testing, only Google accounts added as test users can complete authorization. Before broader release, complete Google OAuth publishing/verification requirements as applicable.

## No data migration

This build does not change the SwiftData schema.
