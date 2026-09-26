# Build 5.9.1 Compile Fix

This patch fixes the two Swift compiler issues reported by the Codemagic archive step in `ResumeBuilderView.swift`.

- Uses explicit `Section { } header: { } footer: { }` syntax for the Create Your Resume section.
- Awaits the iOS application URL open call after a Google Doc is created.

No data model or SwiftData migration changes are included.
