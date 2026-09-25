# Build 5 — Core Student Records

Build 5 turns four Home tiles into real data-entry modules:

- Activities
- Honors
- Experiences
- Goals

## What changed

### Real records instead of placeholders
Each module now supports adding, viewing, editing, and deleting records.

The forms use language specific to the module. For example:

- Activities: activity name, organization/group, role, what you did, what you learned or contributed
- Honors: honor/award, date received, presented by, why you received it
- Experiences: jobs, volunteer service, internships, summer programs, independent projects, role, details, reflection
- Goals: goal, target date, category, status, steps/notes

Each record also has an **Include in future exports** setting so later resume, activities-list, brag-sheet, and portfolio builders can use the same student-owned data.

### Quick Add gets more useful
Activities, Honors, Experiences, and Goals now show **Add** in Quick Add and open directly to their entry form.

### Home status
These four tiles now show how many records have been saved (or **Start here** when empty).

### Search
Global Search now searches these records in addition to Journey Moments and custom collections.

## Data model
Build 5 introduces `JourneySchemaV2` and a new `ModuleRecord` SwiftData model.

`JourneySchemaV1` remains frozen. The migration plan uses a lightweight V1 → V2 migration so existing Journey Moments, photos, settings, and custom tiles can remain in place.

## No Apple/Codemagic changes
No changes are required to signing, provisioning, App Store Connect, `project.yml`, or `codemagic.yaml`.
