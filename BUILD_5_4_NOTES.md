# Build 5.4 - College Visits + Athletic Recruiting

Build 5.4 turns two more optional Home tiles into working record modules without changing the SwiftData schema.

## College Visits
Students can save:
- college or university
- visit date
- visit type
- campus/location
- people they met
- what stood out
- how the school felt
- current interest/application status
- photos and file Keepsakes

## Athletic Recruiting
Students can save:
- school or program
- contact/event date
- update type
- coach/contact
- sport, position, or event
- what happened or was discussed
- next-step notes
- recruiting status
- photos and file Keepsakes

## Integration
Both modules now automatically participate in:
- Home record counts
- Quick Add as an Add action
- global Search
- edit/delete workflows
- Keepsakes attachments

## Data model
No SwiftData schema change is required. Both modules reuse the existing ModuleRecord model introduced in Build 5.

## Testing
1. Enable College Visits and Athletic Recruiting in Home Screen settings if they are off.
2. Add one record from each tile.
3. Add a photo and a file to each record.
4. Edit the status and notes.
5. Search for the school name or coach name.
6. Close and reopen the app and confirm both records remain.
