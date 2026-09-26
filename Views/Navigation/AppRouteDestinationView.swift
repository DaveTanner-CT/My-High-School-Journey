import SwiftUI

struct AppRouteDestinationView: View {
    let route: AppRoute

    var body: some View {
        switch route {
        case .module(let id):
            if id == "journey" {
                JourneyView()
            } else if id == "resources" {
                TrustedResourcesView()
            } else if id == "resume" {
                ResumeBuilderView()
            } else if ModuleRecordConfig.supportsRecords(id) {
                ModuleRecordsView(moduleID: id)
            } else if let module = ModuleRegistry.module(id: id) {
                ModulePlaceholderView(
                    title: module.title,
                    message: "The architecture for this module is connected. Its full workflow will be added in a later build.",
                    systemImage: module.systemImage
                )
            } else {
                ContentUnavailableView(
                    "Module not found",
                    systemImage: "questionmark.folder"
                )
            }

        case .customTile(let id):
            CustomCollectionView(tileID: id)
        }
    }
}
