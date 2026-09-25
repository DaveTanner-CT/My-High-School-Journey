# Build 3 — Journey Photo & Editing Experience

This build focuses on making My Journey usable on a real iPhone before adding new modules.

## Fixes

- Journey photos now use aspect-fit display rather than a fixed-height crop.
- Portrait and landscape photos stay fully visible inside the card.
- Journey Moment cards are now tappable.

## New Journey experience

- Tap a Journey Moment to open a detail screen.
- Tap any saved photo to open a full-screen viewer.
- Swipe between multiple photos.
- Tap **Edit** to reopen the Journey Moment.
- Edit title, date, category, grade, summary, reflection, and export preference.
- Remove saved photos.
- Add replacement photos or additional photos, up to six total.
- Removed photos are not actually deleted until Save succeeds.
- Canceling an edit preserves the original photos and data.

## Architecture

No SwiftData schema change is required for Build 3. Existing JourneyMoment and PhotoAsset records remain compatible.

New views are automatically included by the existing XcodeGen project.yml because the entire `Views` folder is already a source path.
