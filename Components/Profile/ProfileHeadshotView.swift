import SwiftUI

struct ProfileHeadshotView: View {
    let thumbnailFilename: String
    var size: CGFloat = 72

    var body: some View {
        Group {
            if !thumbnailFilename.isEmpty,
               let image = StoredPhotoImageLoader.load(filename: thumbnailFilename) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle()
                        .fill(.secondary.opacity(0.12))
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(size * 0.18)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay {
            Circle()
                .stroke(.primary.opacity(0.10), lineWidth: 1)
        }
        .accessibilityHidden(true)
    }
}
