# Build 4.1 - Quick Add follows Home

Quick Add now mirrors the student's enabled Home tiles in the same order.

- My Journey -> Add a Journey Moment
- Custom collection -> Add an item
- Built-in modules without an add workflow yet -> Open the module
- Custom shortcut -> Open its target module
- Custom resource -> Open its URL

As future modules gain add forms, QuickAddRegistry can change that module from Open to Add without redesigning Quick Add.

This update does not change the SwiftData schema, project.yml, codemagic.yaml, signing, or provisioning.
