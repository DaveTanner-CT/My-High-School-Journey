import Foundation
import UIKit

struct ResumeExportRecord {
    let moduleID: String
    let title: String
    let date: Date
    let category: String
    let organization: String
    let role: String
    let details: String
}

struct ResumeExportRequest {
    let fullName: String
    let email: String
    let phone: String
    let location: String
    let schoolName: String
    let graduationYear: Int?
    let includeHeadshot: Bool
    let headshotImageFilename: String
    let records: [ResumeExportRecord]
}

enum ResumeExportError: LocalizedError {
    case unableToCreateFile

    var errorDescription: String? {
        "High School Journey couldn’t create the resume PDF."
    }
}

enum ResumeExportService {
    private static let pageSize = CGSize(width: 612, height: 792)
    private static let margin: CGFloat = 48
    private static let sectionOrder = ["experiences", "activities", "athletics", "honors"]

    static func createPDF(request: ResumeExportRequest) throws -> URL {
        let fileManager = FileManager.default
        let directory = fileManager.temporaryDirectory
            .appendingPathComponent("HighSchoolJourneyExports", isDirectory: true)

        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)

        let safeName = request.fullName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "-")
        let filename = safeName.isEmpty ? "My-Resume.pdf" : "\(safeName)-Resume.pdf"
        let outputURL = directory.appendingPathComponent(filename)

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))

        do {
            try renderer.writePDF(to: outputURL) { context in
                var y = margin
                context.beginPage()

                y = drawHeader(request: request, atY: y)

                for moduleID in sectionOrder {
                    let records = request.records.filter { $0.moduleID == moduleID }
                    guard !records.isEmpty else { continue }

                    let estimatedSectionHeight = 42 + CGFloat(records.count) * 92
                    if y + min(estimatedSectionHeight, 180) > pageSize.height - margin {
                        context.beginPage()
                        y = margin
                    }

                    y = drawSectionTitle(sectionTitle(for: moduleID), atY: y)

                    for record in records {
                        let estimatedHeight = estimateRecordHeight(record)
                        if y + estimatedHeight > pageSize.height - margin {
                            context.beginPage()
                            y = margin
                            y = drawSectionTitle(sectionTitle(for: moduleID), atY: y)
                        }
                        y = drawRecord(record, atY: y)
                    }
                }
            }
        } catch {
            throw ResumeExportError.unableToCreateFile
        }

        return outputURL
    }

    private static func drawHeader(request: ResumeExportRequest, atY startY: CGFloat) -> CGFloat {
        var y = startY
        var textWidth = pageSize.width - margin * 2

        if request.includeHeadshot,
           !request.headshotImageFilename.isEmpty,
           let url = PhotoStorageService.imageURL(filename: request.headshotImageFilename),
           let image = UIImage(contentsOfFile: url.path) {
            let imageSize: CGFloat = 74
            let rect = CGRect(
                x: pageSize.width - margin - imageSize,
                y: y,
                width: imageSize,
                height: imageSize
            )
            let path = UIBezierPath(ovalIn: rect)
            path.addClip()
            image.draw(in: aspectFillRect(for: image.size, in: rect))
            textWidth -= imageSize + 18
        }

        y += drawText(
            request.fullName,
            frame: CGRect(x: margin, y: y, width: textWidth, height: 40),
            font: .boldSystemFont(ofSize: 24),
            color: .label
        )

        let schoolLine: String = {
            var parts: [String] = []
            if !request.schoolName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                parts.append(request.schoolName)
            }
            if let year = request.graduationYear {
                parts.append("Class of \(year)")
            }
            return parts.joined(separator: " • ")
        }()

        if !schoolLine.isEmpty {
            y += drawText(
                schoolLine,
                frame: CGRect(x: margin, y: y + 2, width: textWidth, height: 24),
                font: .systemFont(ofSize: 12),
                color: .secondaryLabel
            )
        }

        let contact = [request.email, request.phone, request.location]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " • ")

        if !contact.isEmpty {
            y += drawText(
                contact,
                frame: CGRect(x: margin, y: y + 2, width: textWidth, height: 32),
                font: .systemFont(ofSize: 11),
                color: .secondaryLabel
            )
        }

        let lineY = max(y + 10, startY + 82)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: lineY))
        path.addLine(to: CGPoint(x: pageSize.width - margin, y: lineY))
        UIColor.separator.setStroke()
        path.lineWidth = 1
        path.stroke()

        return lineY + 18
    }

    private static func drawSectionTitle(_ title: String, atY y: CGFloat) -> CGFloat {
        let height = drawText(
            title.uppercased(),
            frame: CGRect(x: margin, y: y, width: pageSize.width - margin * 2, height: 26),
            font: .boldSystemFont(ofSize: 12),
            color: .label
        )
        return y + height + 8
    }

    private static func drawRecord(_ record: ResumeExportRecord, atY startY: CGFloat) -> CGFloat {
        var y = startY
        let width = pageSize.width - margin * 2

        y += drawText(
            record.title,
            frame: CGRect(x: margin, y: y, width: width * 0.72, height: 32),
            font: .boldSystemFont(ofSize: 12.5),
            color: .label
        )

        let dateText = record.date.formatted(.dateTime.year())
        drawText(
            dateText,
            frame: CGRect(x: margin + width * 0.72, y: startY, width: width * 0.28, height: 24),
            font: .systemFont(ofSize: 10.5),
            color: .secondaryLabel,
            alignment: .right
        )

        let contextLine = [record.organization, record.role, record.category]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " • ")

        if !contextLine.isEmpty {
            y += drawText(
                contextLine,
                frame: CGRect(x: margin, y: y + 1, width: width, height: 30),
                font: .italicSystemFont(ofSize: 10.5),
                color: .secondaryLabel
            )
        }

        let details = record.details.trimmingCharacters(in: .whitespacesAndNewlines)
        if !details.isEmpty {
            y += drawText(
                details,
                frame: CGRect(x: margin, y: y + 3, width: width, height: 76),
                font: .systemFont(ofSize: 10.5),
                color: .label
            )
        }

        return y + 13
    }

    private static func estimateRecordHeight(_ record: ResumeExportRecord) -> CGFloat {
        let detailCount = max(record.details.count, 1)
        let detailLines = CGFloat((detailCount / 85) + 1)
        return 48 + min(detailLines, 5) * 15
    }

    @discardableResult
    private static func drawText(
        _ text: String,
        frame: CGRect,
        font: UIFont,
        color: UIColor,
        alignment: NSTextAlignment = .left
    ) -> CGFloat {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        paragraph.lineBreakMode = .byWordWrapping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]

        let bounding = (text as NSString).boundingRect(
            with: CGSize(width: frame.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        let height = max(ceil(bounding.height), font.lineHeight)
        let drawFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: height)
        (text as NSString).draw(in: drawFrame, withAttributes: attributes)
        return height
    }

    private static func aspectFillRect(for imageSize: CGSize, in rect: CGRect) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else { return rect }
        let scale = max(rect.width / imageSize.width, rect.height / imageSize.height)
        let size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        return CGRect(
            x: rect.midX - size.width / 2,
            y: rect.midY - size.height / 2,
            width: size.width,
            height: size.height
        )
    }

    private static func sectionTitle(for moduleID: String) -> String {
        switch moduleID {
        case "experiences": return "Experience"
        case "activities": return "Activities & Leadership"
        case "athletics": return "Athletics"
        case "honors": return "Honors & Awards"
        default: return "Journey"
        }
    }
}
