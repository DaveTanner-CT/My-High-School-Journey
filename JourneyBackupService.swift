import Foundation

struct JourneyBackupPackage: Codable {
    let formatVersion: Int
    let createdAt: Date
    let appVersion: String
    let profile: BackupProfile?
    let tilePreferences: [BackupTilePreference]
    let journeyMoments: [BackupJourneyMoment]
    let customTiles: [BackupCustomTile]
    let customTileItems: [BackupCustomTileItem]
    let moduleRecords: [BackupModuleRecord]
    let photoAssets: [BackupPhotoAsset]
    let fileAttachments: [BackupFileAttachment]
    let headshot: BackupHeadshot?
    let preferences: BackupPreferences
}

struct BackupProfile: Codable {
    let id: UUID
    let preferredName: String
    let graduationYear: Int
    let schoolName: String
    let createdAt: Date
    let updatedAt: Date
}

struct BackupTilePreference: Codable {
    let id: UUID
    let moduleID: String
    let isEnabled: Bool
    let sortOrder: Int
    let createdAt: Date
    let updatedAt: Date
}

struct BackupJourneyMoment: Codable {
    let id: UUID
    let title: String
    let momentDate: Date
    let category: String
    let summary: String
    let reflection: String
    let gradeLevel: String
    let isFeatured: Bool
    let includeInExports: Bool
    let createdAt: Date
    let updatedAt: Date
}

struct BackupCustomTile: Codable {
    let id: UUID
    let title: String
    let systemImage: String
    let tileType: String
    let resourceURL: String
    let targetModuleID: String
    let isEnabled: Bool
    let isWide: Bool
    let sortOrder: Int
    let createdAt: Date
    let updatedAt: Date
}

struct BackupCustomTileItem: Codable {
    let id: UUID
    let tileID: UUID
    let title: String
    let itemDate: Date
    let notes: String
    let linkURL: String
    let createdAt: Date
    let updatedAt: Date
}

struct BackupModuleRecord: Codable {
    let id: UUID
    let moduleID: String
    let title: String
    let recordDate: Date
    let category: String
    let organization: String
    let role: String
    let details: String
    let reflection: String
    let status: String
    let includeInExports: Bool
    let createdAt: Date
    let updatedAt: Date
}

struct BackupPhotoAsset: Codable {
    let id: UUID
    let ownerType: String
    let ownerID: UUID
    let imageFilename: String
    let thumbnailFilename: String
    let caption: String
    let sortOrder: Int
    let createdAt: Date
    let updatedAt: Date
    let imageData: Data?
    let thumbnailData: Data?
}

struct BackupFileAttachment: Codable {
    let id: UUID
    let ownerType: String
    let ownerID: UUID
    let displayName: String
    let storedFilename: String
    let createdAt: Date
    let byteCount: Int64
    let fileData: Data?
}

struct BackupHeadshot: Codable {
    let imageFilename: String
    let thumbnailFilename: String
    let imageData: Data?
    let thumbnailData: Data?
}

struct BackupPreferences: Codable {
    let homeTileDisplayMode: String
    let resumeFullName: String
    let resumeEmail: String
    let resumePhone: String
    let resumeLocation: String
    let resumeIncludeHeadshot: Bool
}

enum JourneyBackupError: LocalizedError {
    case unableToCreateBackup

    var errorDescription: String? {
        "My High School Journey could not create the backup file."
    }
}

enum JourneyBackupService {
    static func createBackup(
        profiles: [StudentProfile],
        tilePreferences: [TilePreference],
        journeyMoments: [JourneyMoment],
        customTiles: [CustomTile],
        customTileItems: [CustomTileItem],
        moduleRecords: [ModuleRecord],
        photoAssets: [PhotoAsset],
        headshotImageFilename: String,
        headshotThumbnailFilename: String
    ) throws -> URL {
        let defaults = UserDefaults.standard

        let package = JourneyBackupPackage(
            formatVersion: 1,
            createdAt: Date(),
            appVersion: appVersion,
            profile: profiles.first.map {
                BackupProfile(
                    id: $0.id,
                    preferredName: $0.preferredName,
                    graduationYear: $0.graduationYear,
                    schoolName: $0.schoolName,
                    createdAt: $0.createdAt,
                    updatedAt: $0.updatedAt
                )
            },
            tilePreferences: tilePreferences.map {
                BackupTilePreference(
                    id: $0.id,
                    moduleID: $0.moduleID,
                    isEnabled: $0.isEnabled,
                    sortOrder: $0.sortOrder,
                    createdAt: $0.createdAt,
                    updatedAt: $0.updatedAt
                )
            },
            journeyMoments: journeyMoments.map {
                BackupJourneyMoment(
                    id: $0.id,
                    title: $0.title,
                    momentDate: $0.momentDate,
                    category: $0.category,
                    summary: $0.summary,
                    reflection: $0.reflection,
                    gradeLevel: $0.gradeLevel,
                    isFeatured: $0.isFeatured,
                    includeInExports: $0.includeInExports,
                    createdAt: $0.createdAt,
                    updatedAt: $0.updatedAt
                )
            },
            customTiles: customTiles.map {
                BackupCustomTile(
                    id: $0.id,
                    title: $0.title,
                    systemImage: $0.systemImage,
                    tileType: $0.tileType,
                    resourceURL: $0.resourceURL,
                    targetModuleID: $0.targetModuleID,
                    isEnabled: $0.isEnabled,
                    isWide: $0.isWide,
                    sortOrder: $0.sortOrder,
                    createdAt: $0.createdAt,
                    updatedAt: $0.updatedAt
                )
            },
            customTileItems: customTileItems.map {
                BackupCustomTileItem(
                    id: $0.id,
                    tileID: $0.tileID,
                    title: $0.title,
                    itemDate: $0.itemDate,
                    notes: $0.notes,
                    linkURL: $0.linkURL,
                    createdAt: $0.createdAt,
                    updatedAt: $0.updatedAt
                )
            },
            moduleRecords: moduleRecords.map {
                BackupModuleRecord(
                    id: $0.id,
                    moduleID: $0.moduleID,
                    title: $0.title,
                    recordDate: $0.recordDate,
                    category: $0.category,
                    organization: $0.organization,
                    role: $0.role,
                    details: $0.details,
                    reflection: $0.reflection,
                    status: $0.status,
                    includeInExports: $0.includeInExports,
                    createdAt: $0.createdAt,
                    updatedAt: $0.updatedAt
                )
            },
            photoAssets: photoAssets.map { asset in
                BackupPhotoAsset(
                    id: asset.id,
                    ownerType: asset.ownerType,
                    ownerID: asset.ownerID,
                    imageFilename: asset.imageFilename,
                    thumbnailFilename: asset.thumbnailFilename,
                    caption: asset.caption,
                    sortOrder: asset.sortOrder,
                    createdAt: asset.createdAt,
                    updatedAt: asset.updatedAt,
                    imageData: dataForPhoto(filename: asset.imageFilename),
                    thumbnailData: dataForPhoto(filename: asset.thumbnailFilename)
                )
            },
            fileAttachments: allFileAttachments(
                journeyMoments: journeyMoments,
                moduleRecords: moduleRecords,
                customTileItems: customTileItems
            ),
            headshot: makeHeadshot(
                imageFilename: headshotImageFilename,
                thumbnailFilename: headshotThumbnailFilename
            ),
            preferences: BackupPreferences(
                homeTileDisplayMode: defaults.string(forKey: "homeTileDisplayMode") ?? "compact",
                resumeFullName: defaults.string(forKey: "resumeFullName") ?? "",
                resumeEmail: defaults.string(forKey: "resumeEmail") ?? "",
                resumePhone: defaults.string(forKey: "resumePhone") ?? "",
                resumeLocation: defaults.string(forKey: "resumeLocation") ?? "",
                resumeIncludeHeadshot: defaults.object(forKey: "resumeIncludeHeadshot") as? Bool ?? true
            )
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(package)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let filename = "My-High-School-Journey-Backup-\(formatter.string(from: Date())).hsjbackup"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            throw JourneyBackupError.unableToCreateBackup
        }
    }

    private static var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }

    private static func dataForPhoto(filename: String) -> Data? {
        guard let url = PhotoStorageService.imageURL(filename: filename) else { return nil }
        return try? Data(contentsOf: url)
    }

    private static func makeHeadshot(imageFilename: String, thumbnailFilename: String) -> BackupHeadshot? {
        guard !imageFilename.isEmpty || !thumbnailFilename.isEmpty else { return nil }
        return BackupHeadshot(
            imageFilename: imageFilename,
            thumbnailFilename: thumbnailFilename,
            imageData: dataForPhoto(filename: imageFilename),
            thumbnailData: dataForPhoto(filename: thumbnailFilename)
        )
    }

    private static func allFileAttachments(
        journeyMoments: [JourneyMoment],
        moduleRecords: [ModuleRecord],
        customTileItems: [CustomTileItem]
    ) -> [BackupFileAttachment] {
        var values: [BackupFileAttachment] = []

        let owners: [(String, UUID)] =
            journeyMoments.map { (AttachmentOwnerType.journeyMoment, $0.id) } +
            moduleRecords.map { (AttachmentOwnerType.moduleRecord, $0.id) } +
            customTileItems.map { (AttachmentOwnerType.customTileItem, $0.id) }

        for (ownerType, ownerID) in owners {
            for attachment in FileAttachmentStorageService.attachments(ownerType: ownerType, ownerID: ownerID) {
                let fileData = FileAttachmentStorageService.fileURL(for: attachment).flatMap { try? Data(contentsOf: $0) }
                values.append(
                    BackupFileAttachment(
                        id: attachment.id,
                        ownerType: attachment.ownerType,
                        ownerID: attachment.ownerID,
                        displayName: attachment.displayName,
                        storedFilename: attachment.storedFilename,
                        createdAt: attachment.createdAt,
                        byteCount: attachment.byteCount,
                        fileData: fileData
                    )
                )
            }
        }

        return values
    }
}
