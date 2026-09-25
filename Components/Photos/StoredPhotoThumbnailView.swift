import SwiftUI
import UIKit

struct StoredPhotoThumbnailView: View {
    let filename: String
    var height: CGFloat = 180

    var body: some View {
        Group {
            if let image = loadImage() {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Rectangle()
                        .fill(.quaternary)
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityHidden(true)
    }

    private func loadImage() -> UIImage? {
        guard let url = PhotoStorageService.imageURL(filename: filename) else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }
}
