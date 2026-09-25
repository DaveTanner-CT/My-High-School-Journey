import SwiftUI
import UIKit

struct StoredPhotoThumbnailView: View {
    let filename: String
    var maxHeight: CGFloat = 440
    var cornerRadius: CGFloat = 14

    var body: some View {
        Group {
            if let image = StoredPhotoImageLoader.load(filename: filename) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: maxHeight)
            } else {
                ZStack {
                    Rectangle()
                        .fill(.quaternary)
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .accessibilityHidden(true)
    }
}

struct StoredPhotoFullView: View {
    let filename: String

    var body: some View {
        Group {
            if let image = StoredPhotoImageLoader.load(filename: filename) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                ContentUnavailableView(
                    "Photo unavailable",
                    systemImage: "photo.badge.exclamationmark",
                    description: Text("This photo could not be loaded from this device.")
                )
            }
        }
    }
}

enum StoredPhotoImageLoader {
    static func load(filename: String) -> UIImage? {
        guard let url = PhotoStorageService.imageURL(filename: filename) else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }
}
