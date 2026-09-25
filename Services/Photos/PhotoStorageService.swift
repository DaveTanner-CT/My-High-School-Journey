import Foundation
import PhotosUI
import UIKit

enum PhotoStorageError: LocalizedError {
    case unableToLoadSelection
    case invalidImageData
    case unableToCreateDirectory
    case unableToWriteImage

    var errorDescription: String? {
        switch self {
        case .unableToLoadSelection:
            return "The selected photo could not be loaded."
        case .invalidImageData:
            return "The selected item is not a supported image."
        case .unableToCreateDirectory:
            return "High School Journey could not prepare photo storage."
        case .unableToWriteImage:
            return "High School Journey could not save the photo."
        }
    }
}

struct StoredPhotoFiles: Sendable {
    let imageFilename: String
    let thumbnailFilename: String
}

enum PhotoStorageService {
    private static let photosFolderName = "JourneyPhotos"
    private static let fullImageMaximumDimension: CGFloat = 2200
    private static let thumbnailMaximumDimension: CGFloat = 640

    static func savePickerItem(_ item: PhotosPickerItem, id: UUID) async throws -> StoredPhotoFiles {
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw PhotoStorageError.unableToLoadSelection
        }

        return try await Task.detached(priority: .userInitiated) {
            try writeJPEGFiles(from: data, id: id)
        }.value
    }

    static func imageURL(filename: String) -> URL? {
        guard !filename.isEmpty else { return nil }
        return try? photosDirectory().appendingPathComponent(filename, isDirectory: false)
    }

    static func deleteFiles(imageFilename: String, thumbnailFilename: String) {
        guard let directory = try? photosDirectory() else { return }
        let fileManager = FileManager.default

        for filename in [imageFilename, thumbnailFilename] where !filename.isEmpty {
            let url = directory.appendingPathComponent(filename, isDirectory: false)
            try? fileManager.removeItem(at: url)
        }
    }

    private static func writeJPEGFiles(from data: Data, id: UUID) throws -> StoredPhotoFiles {
        guard let image = UIImage(data: data) else {
            throw PhotoStorageError.invalidImageData
        }

        let directory = try photosDirectory()
        let imageFilename = "\(id.uuidString).jpg"
        let thumbnailFilename = "\(id.uuidString)_thumb.jpg"

        let fullImage = image.resizedToFit(maxDimension: fullImageMaximumDimension)
        let thumbnail = image.resizedToFit(maxDimension: thumbnailMaximumDimension)

        guard
            let fullData = fullImage.jpegData(compressionQuality: 0.84),
            let thumbnailData = thumbnail.jpegData(compressionQuality: 0.72)
        else {
            throw PhotoStorageError.unableToWriteImage
        }

        do {
            try fullData.write(
                to: directory.appendingPathComponent(imageFilename),
                options: .atomic
            )
            try thumbnailData.write(
                to: directory.appendingPathComponent(thumbnailFilename),
                options: .atomic
            )
        } catch {
            deleteFiles(imageFilename: imageFilename, thumbnailFilename: thumbnailFilename)
            throw PhotoStorageError.unableToWriteImage
        }

        return StoredPhotoFiles(
            imageFilename: imageFilename,
            thumbnailFilename: thumbnailFilename
        )
    }

    private static func photosDirectory() throws -> URL {
        let fileManager = FileManager.default
        guard let applicationSupport = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw PhotoStorageError.unableToCreateDirectory
        }

        let directory = applicationSupport
            .appendingPathComponent("HighSchoolJourney", isDirectory: true)
            .appendingPathComponent(photosFolderName, isDirectory: true)

        if !fileManager.fileExists(atPath: directory.path) {
            do {
                try fileManager.createDirectory(
                    at: directory,
                    withIntermediateDirectories: true
                )
            } catch {
                throw PhotoStorageError.unableToCreateDirectory
            }
        }

        return directory
    }
}

private extension UIImage {
    func resizedToFit(maxDimension: CGFloat) -> UIImage {
        let largestDimension = max(size.width, size.height)
        guard largestDimension > maxDimension, largestDimension > 0 else {
            return self
        }

        let scale = maxDimension / largestDimension
        let targetSize = CGSize(
            width: floor(size.width * scale),
            height: floor(size.height * scale)
        )

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
