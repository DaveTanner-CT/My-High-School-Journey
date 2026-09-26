# Build 5.7 — App Lock, Version Display, and Reliable Home Reordering

## Added

- Settings now shows the installed app version and build number at the bottom of the page.
- Optional four-digit App Lock in Settings.
- PIN information is stored in the iOS Keychain and is never stored in SwiftData.
- Recovery email setup with a generated recovery code that the student can email to themselves.
- Forgot-PIN flow that accepts the recovery code, lets the student choose a new four-digit PIN, and replaces the old recovery code.
- Change PIN, create a new recovery code, and turn off App Lock controls.

## Home tile reordering

Direct drag/drop was removed from the Home cards. Dragging square NavigationLink cards was unreliable because the same gesture was competing with opening the tile and with the two-column layout.

Home now has a dedicated **Reorder Tiles** control. It opens a simple list with native drag handles. The same reorder screen is used regardless of whether Home is in Compact or Wide layout. Settings > Home Screen still supports native list reordering too.

## Build reliability

HomeView.swift is included in this update and intentionally renders tile rows with an indexed range:

```swift
let rows = tileRows
ForEach(0..<rows.count, id: \.self) { index in
    tileRowView(rows[index])
}
```

This avoids the `ForEach(tileRows)` overload ambiguity that has caused Xcode archive failures in earlier source snapshots.

## Data model

No SwiftData schema change is required for Build 5.7. App Lock secrets live in Keychain; the on/off flag is stored in app preferences.

## Revised Build 5.7 additions

- Home tiles now use subtle module-specific color accents: tinted icons, light color wash, and colored outlines. This keeps the existing clean card layout while avoiding the all-grey appearance.
- Quick Add and Journey highlight cards also receive restrained accent outlines.
- Settings > My Profile now includes an optional student headshot.
- A saved headshot appears beside the Home greeting and is stored locally using the existing photo-storage system.
- Headshots can be added, replaced, or removed at any time.
- The stored headshot is intentionally available as a reusable profile asset for the future Resume / Build From My Journey features.
- No SwiftData schema change is required for these additions.
