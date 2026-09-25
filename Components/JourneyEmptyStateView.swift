import SwiftUI

struct JourneyEmptyStateView: View {
    let addAction: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Your Journey starts here", systemImage: "sparkles")
        } description: {
            Text("Save moments, experiences, accomplishments, photos and things you will want to remember later.")
        } actions: {
            Button("Add My First Moment", action: addAction)
                .buttonStyle(.borderedProminent)
        }
    }
}
