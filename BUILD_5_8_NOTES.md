# Build 5.8 — Resume Builder

This build turns the Resume tile into a working **Build From My Journey** experience.

## What changed

- The Resume tile now opens a real Resume Builder instead of a placeholder.
- Resume content is pulled from existing Journey records:
  - Experiences
  - Activities & Leadership
  - Athletics
  - Honors & Awards
- Students can choose which saved items appear by using the existing **Include in exports** flag.
- Contact fields are kept locally on the device:
  - full name
  - email
  - phone
  - city/state
- The optional profile headshot from Build 5.7 can be included or left off.
- The builder creates a clean PDF on the device and uses the iOS share sheet for whatever the student wants to do next.
- School name and graduation year come from My Profile.
- Private Reflections, People Who Know Me, Goals, College Visits, and Athletic Recruiting are intentionally excluded from the first resume layout.

## Privacy

Resume generation is local. No resume data is uploaded by this feature. The student decides when and where to share the exported PDF.

## Data model

No SwiftData schema migration is required. Resume contact fields and presentation preferences are stored as local app preferences, while selected Journey items continue using `ModuleRecord.includeInExports`.

## Files added

- `Views/Resume/ResumeBuilderView.swift`
- `Services/Resume/ResumeExportService.swift`

## File changed

- `Views/Navigation/AppRouteDestinationView.swift`
