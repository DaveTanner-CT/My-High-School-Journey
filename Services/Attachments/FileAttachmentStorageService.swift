import Foundation

struct StoredFileAttachment: Codable, Identifiable, Hashable {
    let id: UUID
    let ownerType: String
    let ownerID: UUID
    let displayName: String
    let storedFilename: String
    let createdAt: Date
    let byteCount: Int64
}

enum FileAttachmentStorageError: LocalizedError {
    case unableToCreateDirectory
    case unableToAccessFile
    case unableToCopyFile
    case unableToSaveMetadata

    var errorDescription: String? {
        switch self {
        case .unableToCreateDirectory:
            return "High School Journey could not prepare file storage."
        case .unableToAccessFile:
            return "The selected file could not be accessed."
        case .unableToCopyFile:
            return "The selected file could not be saved."
        case .unableToSaveMetadata:
            return "The file was saved, but its attachment information could not be updated."
        }
    }
}

enum FileAttachmentStorageService {
    private static let rootFolderName = "Attachments"
    private static let metadataFilename = "attachments.json"

    static func attachments(ownerType: String, ownerID: UUID) -> [StoredFileAttachment] {
        guard let url = try? metadataURL(ownerType: ownerType, ownerID: ownerID),
              let data = try? Data(contentsOf: url),
              let values = try? JSONDecoder().decode([StoredFileAttachment].self, from: data)
        else {
            return []
        }

        return values.sorted { $0.createdAt < $1.createdAt }
    }

    static func importFiles(
        _ urls: [URL],
        ownerType: String,
        ownerID: UUID
    ) throws -> [StoredFileAttachment] {
        var current = attachments(ownerType: ownerType, ownerID: ownerID)
        var imported: [StoredFileAttachment] = []
        let directory = try ownerDirectory(ownerType: ownerType, ownerID: ownerID)
        let fileManager = FileManager.default

        for sourceURL in urls {
            let secured = sourceURL.startAccessingSecurityScopedResource()
            defer {
                if secured { sourceURL.stopAccessingSecurityScopedResource() }
            }

            guard fileManager.fileExists(atPath: sourceURL.path) else {
                throw FileAttachmentStorageError.unableToAccessFile
            }

            let id = UUID()
            let cleanName = sourceURL.lastPathComponent.isEmpty ? "File" : sourceURL.lastPathComponent
            let ext = sourceURL.pathExtension
            let storedFilename = ext.isEmpty ? id.uuidString : "\(id.uuidString).\(ext)"
            let destinationURL = directory.appendingPathComponent(storedFilename, isDirectory: false)

            do {
                try fileManager.copyItem(at: sourceURL, to: destinationURL)
            } catch {
                throw FileAttachmentStorageError.unableToCopyFile
            }

            let byteCount = (try? destinationURL.resourceValues(forKeys: [.fileSizeKey]).fileSize)
                .map(Int64.init) ?? 0

            let attachment = StoredFileAttachment(
                id: id,
                ownerType: ownerType,
                ownerID: ownerID,
                displayName: cleanName,
                storedFilename: storedFilename,
                createdAt: Date(),
                byteCount: byteCount
            )
            current.append(attachment)
            imported.append(attachment)
        }

        do {
            try saveMetadata(current, ownerType: ownerType, ownerID: ownerID)
        } catch {
            for attachment in imported {
                try? fileManager.removeItem(at: directory.appendingPathComponent(attachment.storedFilename))
            }
            throw FileAttachmentStorageError.unableToSaveMetadata
        }

        return imported
    }

    static func fileURL(for attachment: StoredFileAttachment) -> URL? {
        guard let directory = try? ownerDirectory(ownerType: attachment.ownerType, ownerID: attachment.ownerID) else {
            return nil
        }
        let url = directory.appendingPathComponent(attachment.storedFilename, isDirectory: false)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    static func delete(_ attachment: StoredFileAttachment) throws {
        var current = attachments(ownerType: attachment.ownerType, ownerID: attachment.ownerID)
        current.removeAll { $0.id == attachment.id }

        if let url = fileURL(for: attachment) {
            try? FileManager.default.removeItem(at: url)
        }

        try saveMetadata(current, ownerType: attachment.ownerType, ownerID: attachment.ownerID)
    }

    static func deleteAll(ownerType: String, ownerID: UUID) {
        guard let directory = try? ownerDirectory(ownerType: ownerType, ownerID: ownerID) else { return }
        try? FileManager.default.removeItem(at: directory)
    }

    private static func saveMetadata(
        _ attachments: [StoredFileAttachment],
        ownerType: String,
        ownerID: UUID
    ) throws {
        let data = try JSONEncoder().encode(attachments)
        try data.write(to: metadataURL(ownerType: ownerType, ownerID: ownerID), options: .atomic)
    }

    private static func metadataURL(ownerType: String, ownerID: UUID) throws -> URL {
        try ownerDirectory(ownerType: ownerType, ownerID: ownerID)
            .appendingPathComponent(metadataFilename, isDirectory: false)
    }

    private static func ownerDirectory(ownerType: String, ownerID: UUID) throws -> URL {
        let fileManager = FileManager.default
        guard let applicationSupport = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw FileAttachmentStorageError.unableToCreateDirectory
        }

        let safeOwnerType = ownerType.replacingOccurrences(of: "/", with: "-")
        let directory = applicationSupport
            .appendingPathComponent("HighSchoolJourney", isDirectory: true)
            .appendingPathComponent(rootFolderName, isDirectory: true)
            .appendingPathComponent(safeOwnerType, isDirectory: true)
            .appendingPathComponent(ownerID.uuidString, isDirectory: true)

        if !fileManager.fileExists(atPath: directory.path) {
            do {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            } catch {
                throw FileAttachmentStorageError.unableToCreateDirectory
            }
        }

        return directory
    }
}

enum AttachmentOwnerType {
    static let journeyMoment = "journeyMoment"
    static let moduleRecord = "moduleRecord"
    static let customTileItem = "customTileItem"
}
