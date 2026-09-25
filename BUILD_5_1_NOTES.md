# Build 5.1 — Home Tile Reordering + Tagline

## Changes

- Home tagline shortened to **Keep telling your story!**
- Enabled Home tiles can now be reordered directly from the Home screen.
- Direct reordering works in both **Compact** and **Wide** Home layouts.
- Press and drag a tile onto another tile to move it before that tile.
- Reordering updates the existing `sortOrder` values used by Home, Quick Add, and Home Screen settings.
- Disabled tiles keep their relative place in the full tile order so turning them back on remains predictable.
- Home Screen settings still supports list-style drag reordering and now explains that tiles can also be moved directly on Home.

## Data model

No SwiftData schema change is required for Build 5.1.
