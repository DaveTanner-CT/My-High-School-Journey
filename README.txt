My High School Journey - Build 4 compile fix

Replace these two files in GitHub:
1. Views/Home/HomeView.swift
   - Fixes the SwiftUI ForEach compile error by explicitly identifying HomeTileRow values with id: \.id.
2. Views/Settings/SettingsView.swift
   - Keeps the Class of year displayed without a thousands separator (2030, not 2,030).

No changes are required to project.yml, codemagic.yaml, signing, or provisioning.
