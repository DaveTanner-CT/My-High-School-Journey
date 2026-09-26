# Build 5.9.6 — Google Sign-In SDK OAuth Fix

This build replaces the hand-written OAuth browser/token flow with Google's official Google Sign-In for iOS SDK.

Why: Google currently recommends the Google Sign-In iOS SDK for iOS OAuth. The prior custom OAuth implementation could reach Google's authorization endpoint but returned `invalid_client / OAuth client was not found` even though the iOS client existed.

Changes:
- Adds GoogleSignIn-iOS 9.2.0 via Swift Package Manager/XcodeGen.
- Keeps the existing iOS OAuth client ID and reversed URL scheme.
- Adds `GIDClientID` to Info.plist generation.
- Requests only `https://www.googleapis.com/auth/drive.file` as the additional Google Drive scope.
- Restores prior Google sign-in when available.
- Refreshes access tokens through the official SDK.
- Routes callback URLs to Google Sign-In.
- Disconnect remains available in Settings and signs the local user out.

No SwiftData migration.
