# Build 5.6 — Trusted Resources

Build 5.6 turns the Trusted Resources Home tile into a working resource library.

## What changed

- Added a curated catalog of official/national resources for:
  - College Planning
  - Financial Aid
  - Athletics
  - Testing
  - Careers
  - Apprenticeships
  - Service
- Added category filters and resource search.
- Added an Official source badge and verification date to each resource.
- Trusted Resources now opens a real module instead of the placeholder screen.
- Global Search now searches the Trusted Resources catalog whenever the module is enabled.
- Resource links open the source website directly.

## Data model

No SwiftData schema change is required. Trusted Resources is code-backed static reference data, which keeps this build low risk and lets links be updated without changing student records.

## Included resource fields

Each resource includes organization, title, description, URL, category, resource type, audience, official-source status, and last-verified date.

## Testing

1. Open Trusted Resources from Home.
2. Test All plus each category chip.
3. Search for terms such as FAFSA, NCAA, SAT, career, and apprenticeship.
4. Open several resource links and confirm they launch correctly.
5. Use global Search and confirm matching Trusted Resources appear.
6. Disable Trusted Resources in Home Screen settings and confirm resource results no longer appear in global Search.
