import Foundation
import LocalAuthentication

enum BiometricKind: String {
    case faceID
    case touchID
    case none

    var displayName: String {
        switch self {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .none: return "Biometrics"
        }
    }

    var systemImage: String {
        switch self {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .none: return "person.badge.key.fill"
        }
    }
}

enum BiometricAuthError: LocalizedError {
    case unavailable
    case failed

    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Biometric unlock is not available on this device."
        case .failed:
            return "Biometric unlock was not completed. You can still use your four-digit PIN."
        }
    }
}

enum BiometricAuthService {
    static var kind: BiometricKind {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .faceID: return .faceID
        case .touchID: return .touchID
        default: return .none
        }
    }

    static var isAvailable: Bool {
        kind != .none
    }

    @MainActor
    static func authenticate() async throws {
        let context = LAContext()
        context.localizedCancelTitle = "Use PIN"
        context.localizedFallbackTitle = "Use PIN"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw BiometricAuthError.unavailable
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Unlock My High School Journey"
            )
            guard success else { throw BiometricAuthError.failed }
        } catch {
            throw BiometricAuthError.failed
        }
    }
}
