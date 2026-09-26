import Foundation
import AuthenticationServices
import CryptoKit
import Security
import UIKit

struct GoogleOAuthConfiguration {
    let clientID: String
    let redirectScheme: String

    static var current: GoogleOAuthConfiguration? {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GoogleOAuthClientID") as? String,
              let redirectScheme = Bundle.main.object(forInfoDictionaryKey: "GoogleOAuthRedirectScheme") as? String
        else { return nil }

        let cleanClientID = clientID.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanScheme = redirectScheme.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanClientID.isEmpty,
              !cleanScheme.isEmpty,
              !cleanClientID.contains("replace-me"),
              !cleanScheme.contains("replace-me")
        else { return nil }

        return GoogleOAuthConfiguration(clientID: cleanClientID, redirectScheme: cleanScheme)
    }

    var redirectURI: String {
        "\(redirectScheme):/oauth2redirect"
    }
}

enum GoogleOAuthError: LocalizedError {
    case notConfigured
    case cancelled
    case invalidCallback
    case stateMismatch
    case tokenExchangeFailed(String)
    case noRefreshToken

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Google Docs has not been connected to this app build yet. The Google iOS OAuth client ID still needs to be added to project.yml."
        case .cancelled:
            return "Google sign-in was cancelled."
        case .invalidCallback:
            return "Google sign-in did not return the information needed to continue."
        case .stateMismatch:
            return "Google sign-in could not be verified. Please try again."
        case .tokenExchangeFailed(let message):
            return message.isEmpty ? "Google sign-in could not be completed." : message
        case .noRefreshToken:
            return "Google did not return a reusable sign-in token. Disconnect Google and try again."
        }
    }
}

@MainActor
final class GoogleOAuthService: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = GoogleOAuthService()

    private let keychainService = "org.scriptingforschools.MyHighSchoolJourney.googleOAuth"
    private var webSession: ASWebAuthenticationSession?

    private enum Key: String {
        case accessToken
        case refreshToken
        case expirationDate
    }

    var isConfigured: Bool {
        GoogleOAuthConfiguration.current != nil
    }

    var isConnected: Bool {
        readString(.refreshToken) != nil
    }

    func accessToken() async throws -> String {
        if let token = readString(.accessToken),
           let expiration = readDate(.expirationDate),
           expiration.timeIntervalSinceNow > 60 {
            return token
        }

        if let refreshToken = readString(.refreshToken) {
            return try await refreshAccessToken(refreshToken)
        }

        return try await authorize()
    }

    func disconnect() {
        for key in [Key.accessToken, .refreshToken, .expirationDate] {
            delete(key)
        }
    }

    private func authorize() async throws -> String {
        guard let config = GoogleOAuthConfiguration.current else {
            throw GoogleOAuthError.notConfigured
        }

        let verifier = randomURLSafeString(byteCount: 48)
        let challenge = base64URL(Data(SHA256.hash(data: Data(verifier.utf8))))
        let state = randomURLSafeString(byteCount: 24)

        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: config.clientID),
            URLQueryItem(name: "redirect_uri", value: config.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "https://www.googleapis.com/auth/drive.file"),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "prompt", value: "consent")
        ]

        guard let authorizationURL = components.url else {
            throw GoogleOAuthError.notConfigured
        }

        let callbackURL: URL = try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authorizationURL,
                callbackURLScheme: config.redirectScheme
            ) { callbackURL, error in
                self.webSession = nil
                if let authError = error as? ASWebAuthenticationSessionError,
                   authError.code == .canceledLogin {
                    continuation.resume(throwing: GoogleOAuthError.cancelled)
                    return
                }
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let callbackURL else {
                    continuation.resume(throwing: GoogleOAuthError.invalidCallback)
                    return
                }
                continuation.resume(returning: callbackURL)
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            self.webSession = session
            if !session.start() {
                self.webSession = nil
                continuation.resume(throwing: GoogleOAuthError.invalidCallback)
            }
        }

        guard let callback = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
              callback.queryItems?.first(where: { $0.name == "state" })?.value == state
        else {
            throw GoogleOAuthError.stateMismatch
        }

        if let error = callback.queryItems?.first(where: { $0.name == "error" })?.value {
            throw GoogleOAuthError.tokenExchangeFailed(error)
        }

        guard let code = callback.queryItems?.first(where: { $0.name == "code" })?.value else {
            throw GoogleOAuthError.invalidCallback
        }

        let tokenResponse = try await exchangeCode(code, verifier: verifier, config: config)
        try store(tokenResponse)
        return tokenResponse.accessToken
    }

    private func exchangeCode(
        _ code: String,
        verifier: String,
        config: GoogleOAuthConfiguration
    ) async throws -> TokenResponse {
        let body = formBody([
            "client_id": config.clientID,
            "code": code,
            "code_verifier": verifier,
            "grant_type": "authorization_code",
            "redirect_uri": config.redirectURI
        ])
        return try await tokenRequest(body: body)
    }

    private func refreshAccessToken(_ refreshToken: String) async throws -> String {
        guard let config = GoogleOAuthConfiguration.current else {
            throw GoogleOAuthError.notConfigured
        }

        let body = formBody([
            "client_id": config.clientID,
            "refresh_token": refreshToken,
            "grant_type": "refresh_token"
        ])
        let response = try await tokenRequest(body: body)
        try saveString(response.accessToken, .accessToken)
        try saveDate(Date().addingTimeInterval(TimeInterval(response.expiresIn)), .expirationDate)
        if let newRefresh = response.refreshToken {
            try saveString(newRefresh, .refreshToken)
        }
        return response.accessToken
    }

    private func tokenRequest(body: Data) async throws -> TokenResponse {
        var request = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? ""
            throw GoogleOAuthError.tokenExchangeFailed(message)
        }

        return try JSONDecoder().decode(TokenResponse.self, from: data)
    }

    private func store(_ response: TokenResponse) throws {
        try saveString(response.accessToken, .accessToken)
        try saveDate(Date().addingTimeInterval(TimeInterval(response.expiresIn)), .expirationDate)
        if let refreshToken = response.refreshToken {
            try saveString(refreshToken, .refreshToken)
        } else if readString(.refreshToken) == nil {
            throw GoogleOAuthError.noRefreshToken
        }
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first
        return scene?.windows.first(where: \.isKeyWindow) ?? scene?.windows.first ?? ASPresentationAnchor()
    }

    private func randomURLSafeString(byteCount: Int) -> String {
        var data = Data(count: byteCount)
        data.withUnsafeMutableBytes { buffer in
            guard let baseAddress = buffer.baseAddress else { return }
            _ = SecRandomCopyBytes(kSecRandomDefault, byteCount, baseAddress)
        }
        return base64URL(data)
    }

    private func base64URL(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private func formBody(_ values: [String: String]) -> Data {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~"))
        let string = values.map { key, value in
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key
            let escapedValue = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
            return "\(escapedKey)=\(escapedValue)"
        }
        .sorted()
        .joined(separator: "&")
        return Data(string.utf8)
    }

    private struct TokenResponse: Decodable {
        let accessToken: String
        let expiresIn: Int
        let refreshToken: String?

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case expiresIn = "expires_in"
            case refreshToken = "refresh_token"
        }
    }

    private func saveString(_ value: String, _ key: Key) throws {
        try save(Data(value.utf8), key)
    }

    private func readString(_ key: Key) -> String? {
        read(key).flatMap { String(data: $0, encoding: .utf8) }
    }

    private func saveDate(_ value: Date, _ key: Key) throws {
        var interval = value.timeIntervalSince1970
        try save(Data(bytes: &interval, count: MemoryLayout<TimeInterval>.size), key)
    }

    private func readDate(_ key: Key) -> Date? {
        guard let data = read(key), data.count == MemoryLayout<TimeInterval>.size else { return nil }
        let interval = data.withUnsafeBytes { $0.load(as: TimeInterval.self) }
        return Date(timeIntervalSince1970: interval)
    }

    private func save(_ data: Data, _ key: Key) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key.rawValue
        ]
        SecItemDelete(query as CFDictionary)

        var addQuery = query
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw GoogleOAuthError.tokenExchangeFailed("Google sign-in could not be saved securely on this device.")
        }
    }

    private func read(_ key: Key) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess else { return nil }
        return item as? Data
    }

    private func delete(_ key: Key) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key.rawValue
        ]
        SecItemDelete(query as CFDictionary)
    }
}
