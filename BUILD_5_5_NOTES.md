# Build 5.5 — Add Keepsakes While Creating an Item

## What changed

Keepsakes are now available inside the creation form instead of only after an item has already been saved.

This applies to:
- Journey Moments
- Activities, Honors, Experiences, Goals, Athletics, People Who Know Me, College Visits, Athletic Recruiting, and any other module that uses the shared ModuleRecord form
- Custom Collection items

Students can add both photos and files before tapping the main Save button.

## How it works

A new item gets a draft attachment ID as soon as its add form opens. Any photos or files selected in the Keepsakes section are saved against that draft ID. When the student saves the item, the new record uses that same ID, so the attachments are already connected to it.

If the student cancels instead, draft photos and files are deleted so abandoned items do not leave orphaned attachments behind.

## Data model

No SwiftData schema migration is required.

## Files changed

- `Views/Modules/AddEditModuleRecordView.swift`
- `Views/Journey/AddJourneyMomentView.swift`
- `Views/QuickAdd/AddCustomTileItemView.swift`

## Validation

A Swift syntax parse was run across the full source successfully.
