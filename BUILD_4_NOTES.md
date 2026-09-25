# Build 4 — Home, Quick Add & Search Foundation

Build 4 focuses on making the app easier to use repeatedly while preserving the architecture needed for future modules.

## Home experience

- Home now uses a mixed-size tile layout instead of one full-width vertical list.
- Compact tiles appear two across when space allows.
- Wide tiles continue to span the screen.
- The latest Journey Moment appears as a more visual feed-style card and includes its photo when available.
- The header shows graduation year and Journey Moment count when available.
- Custom collection tiles show their saved-item count.
- A prominent Quick Add card is available near the top of Home.

## Quick Add

- Adds a dedicated center Add tab, similar to familiar mobile/social app patterns.
- Quick Add currently supports Journey Moments and enabled custom collection tiles.
- `QuickAddRegistry` provides the extension point for Activities, Honors, Experiences, College Visits, Recruiting and other future modules.
- Custom collection item creation was moved into a reusable `AddCustomTileItemView` so Home, Quick Add and collection screens can share one form.

## Search

- Adds a global Search tab.
- Search currently covers Journey Moments, enabled custom collections, custom collection items and enabled app modules.
- Search result routing uses the same central AppRoute destination logic as Home.

## Navigation architecture

- Adds `AppRouteDestinationView` so module/custom-tile routing is no longer duplicated inside Home.
- Future modules should add their real destination to this central router when their workflows are implemented.

## Data compatibility

Build 4 requires no SwiftData schema change. Existing Build 1–3 data remains compatible.

## Tab structure

The primary tabs are now:

1. Home
2. Journey
3. Add
4. Search
5. Settings

Trusted Resources remains an enabled Home module tile and will become a full feature in a future build. Keeping it out of the primary tab bar leaves room for the more frequently used Add and Search actions.
