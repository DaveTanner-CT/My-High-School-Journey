# Build 4.2 - Home Tile Size Preference

## What changed
- Home tiles no longer mix compact and wide sizes automatically.
- The default Home layout is Compact: two square tiles across.
- Settings > Home Screen now includes a Home Layout control with Compact and Wide choices.
- Wide mode shows every tile full-width, one per row.
- The preference is stored locally with AppStorage, so no SwiftData schema migration is required.
- Existing tile order and enabled/disabled choices are unchanged.

## Files changed
- Architecture/HomeTileDisplayMode.swift (new)
- Views/Home/HomeView.swift
- Views/Home/ModuleTileView.swift
- Views/Home/CustomTileCardView.swift
- Views/Settings/HomeScreenSettingsView.swift
