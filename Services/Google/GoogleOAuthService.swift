import Foundation
import GoogleSignIn
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
}

enum GoogleOAuthError: LocalizedError {
    case notConfigured
    case noPresentingViewController
    case signInFailed(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Google Docs has not been connected to this app build yet."
        case .noPresentingViewController:
            return "Google sign-in could not open. Please try again."
        case .signInFailed(let message):
            return message.isEmpty ? "Google sign-in could not be completed." : message
        }
    }
}

@MainActor
final class GoogleOAuthService {
    static let shared = GoogleOAuthService()

    private let driveFileScope = "https://www.googleapis.com/auth/drive.file"

    private init() {
        configureSDKIfPossible()
    }

    var isConfigured: Bool {
        GoogleOAuthConfiguration.current != nil
    }

    var isConnected: Bool {
        GIDSignIn.sharedInstance.currentUser != nil || GIDSignIn.sharedInstance.hasPreviousSignIn()
    }

    func accessToken() async throws -> String {
        guard GoogleOAuthConfiguration.current != nil else {
            throw GoogleOAuthError.notConfigured
        }

        configureSDKIfPossible()

        if let currentUser = GIDSignIn.sharedInstance.currentUser {
            return try await validAccessToken(for: currentUser)
        }

        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            do {
                let restoredUser = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
                return try await validAccessToken(for: restoredUser)
            } catch {
                GIDSignIn.sharedInstance.signOut()
            }
        }

        guard let presenter = presentingViewController() else {
            throw GoogleOAuthError.noPresentingViewController
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: presenter,
                hint: nil,
                additionalScopes: [driveFileScope]
            )
            let refreshedUser = try await result.user.refreshTokensIfNeeded()
            return refreshedUser.accessToken.tokenString
        } catch {
            throw GoogleOAuthError.signInFailed(error.localizedDescription)
        }
    }

    func disconnect() {
        GIDSignIn.sharedInstance.signOut()
    }

    func handleOpenURL(_ url: URL) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }

    private func configureSDKIfPossible() {
        guard let config = GoogleOAuthConfiguration.current else { return }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: config.clientID)
    }

    private func validAccessToken(for user: GIDGoogleUser) async throws -> String {
        do {
            let userWithScopes: GIDGoogleUser
            if !(user.grantedScopes ?? []).contains(driveFileScope) {
                guard let presenter = presentingViewController() else {
                    throw GoogleOAuthError.noPresentingViewController
                }
                let scopeResult = try await user.addScopes([driveFileScope], presenting: presenter)
                userWithScopes = scopeResult.user
            } else {
                userWithScopes = user
            }

            let refreshedUser = try await userWithScopes.refreshTokensIfNeeded()
            return refreshedUser.accessToken.tokenString
        } catch let error as GoogleOAuthError {
            throw error
        } catch {
            throw GoogleOAuthError.signInFailed(error.localizedDescription)
        }
    }

    private func presentingViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first
        let root = scene?.windows.first(where: \.isKeyWindow)?.rootViewController
            ?? scene?.windows.first?.rootViewController
        return topViewController(from: root)
    }

    private func topViewController(from root: UIViewController?) -> UIViewController? {
        if let navigation = root as? UINavigationController {
            return topViewController(from: navigation.visibleViewController)
        }
        if let tab = root as? UITabBarController {
            return topViewController(from: tab.selectedViewController)
        }
        if let presented = root?.presentedViewController {
            return topViewController(from: presented)
        }
        return root
    }
}
