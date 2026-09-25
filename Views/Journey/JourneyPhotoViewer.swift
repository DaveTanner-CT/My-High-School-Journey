import SwiftUI

struct JourneyPhotoViewer: View {
    @Environment(\.dismiss) private var dismiss

    let photos: [PhotoAsset]
    @State private var selectedPhotoID: UUID

    init(photos: [PhotoAsset], selectedPhotoID: UUID) {
        self.photos = photos.sorted { $0.sortOrder < $1.sortOrder }
        _selectedPhotoID = State(initialValue: selectedPhotoID)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black
                .ignoresSafeArea()

            TabView(selection: $selectedPhotoID) {
                ForEach(photos) { photo in
                    StoredPhotoFullView(filename: photo.imageFilename)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 50)
                        .tag(photo.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: photos.count > 1 ? .automatic : .never))

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
                    .padding(18)
            }
            .accessibilityLabel("Close photo")
        }
        .statusBarHidden()
    }
}
