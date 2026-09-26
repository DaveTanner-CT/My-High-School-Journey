import Foundation

struct GoogleDocsResumeRequest {
    let fullName: String
    let email: String
    let phone: String
    let location: String
    let schoolName: String
    let graduationYear: Int?
    let records: [ResumeExportRecord]
}

enum GoogleDocsResumeError: LocalizedError {
    case invalidResponse
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Google Docs returned an unexpected response."
        case .requestFailed(let message): return message.isEmpty ? "The resume could not be created in Google Docs." : message
        }
    }
}

enum GoogleDocsResumeService {
    private struct CreatedDocument: Decodable { let documentId: String }
    private struct StyleRange { let startIndex: Int; let endIndex: Int; let fontSize: Int; let bold: Bool }

    static func createResume(request: GoogleDocsResumeRequest) async throws -> URL {
        let token = try await GoogleOAuthService.shared.accessToken()
        let title = request.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "My High School Journey Resume" : "\(request.fullName) - Resume"
        let document = try await createDocument(title: title, accessToken: token)
        let content = buildContent(request)
        try await populateDocument(documentID: document.documentId, text: content.text, styles: content.styles, accessToken: token)
        guard let url = URL(string: "https://docs.google.com/document/d/\(document.documentId)/edit") else { throw GoogleDocsResumeError.invalidResponse }
        return url
    }

    private static func createDocument(title: String, accessToken: String) async throws -> CreatedDocument {
        var request = URLRequest(url: URL(string: "https://docs.googleapis.com/v1/documents")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["title": title])
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)
        return try JSONDecoder().decode(CreatedDocument.self, from: data)
    }

    private static func populateDocument(documentID: String, text: String, styles: [StyleRange], accessToken: String) async throws {
        var updates: [[String: Any]] = [["insertText": ["location": ["index": 1], "text": text]]]
        for style in styles {
            updates.append(["updateTextStyle": [
                "range": ["startIndex": style.startIndex, "endIndex": style.endIndex],
                "textStyle": ["bold": style.bold, "fontSize": ["magnitude": style.fontSize, "unit": "PT"]],
                "fields": "bold,fontSize"
            ]])
        }
        var request = URLRequest(url: URL(string: "https://docs.googleapis.com/v1/documents/\(documentID):batchUpdate")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["requests": updates])
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)
    }

    private static func buildContent(_ request: GoogleDocsResumeRequest) -> (text: String, styles: [StyleRange]) {
        var text = ""
        var styles: [StyleRange] = []
        func appendStyledLine(_ value: String, size: Int, bold: Bool) {
            let start = (text as NSString).length + 1
            text += value + "\n"
            styles.append(StyleRange(startIndex: start, endIndex: start + (value as NSString).length, fontSize: size, bold: bold))
        }
        appendStyledLine(request.fullName, size: 20, bold: true)
        let contact = [request.email, request.phone, request.location].map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }.joined(separator: " • ")
        if !contact.isEmpty { text += contact + "\n" }
        var schoolBits: [String] = []
        if !request.schoolName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { schoolBits.append(request.schoolName) }
        if let year = request.graduationYear { schoolBits.append("Class of \(year)") }
        if !schoolBits.isEmpty { text += schoolBits.joined(separator: " • ") + "\n" }
        text += "\n"
        for moduleID in ["experiences", "activities", "athletics", "honors"] {
            let sectionRecords = request.records.filter { $0.moduleID == moduleID }
            guard !sectionRecords.isEmpty else { continue }
            appendStyledLine(sectionTitle(moduleID).uppercased(), size: 12, bold: true)
            for record in sectionRecords {
                appendStyledLine(record.title, size: 11, bold: true)
                let context = [record.organization, record.role].map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }.joined(separator: " • ")
                if !context.isEmpty { text += context + "\n" }
                let date = record.date.formatted(.dateTime.month(.abbreviated).year())
                let metadata = [record.category, date].map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }.joined(separator: " • ")
                if !metadata.isEmpty { text += metadata + "\n" }
                let details = record.details.trimmingCharacters(in: .whitespacesAndNewlines)
                if !details.isEmpty { text += details + "\n" }
                text += "\n"
            }
        }
        return (text, styles)
    }

    private static func sectionTitle(_ moduleID: String) -> String {
        switch moduleID {
        case "experiences": return "Experience"
        case "activities": return "Activities & Leadership"
        case "athletics": return "Athletics"
        case "honors": return "Honors & Awards"
        default: return "Journey"
        }
    }

    private static func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { throw GoogleDocsResumeError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            throw GoogleDocsResumeError.requestFailed(String(data: data, encoding: .utf8) ?? "")
        }
    }
}
