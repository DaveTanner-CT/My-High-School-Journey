import Foundation
import Security
import CryptoKit

final class AppLockService {
    static let shared = AppLockService()

    private let service = "org.scriptingforschools.MyHighSchoolJourney.appLock"
    private let defaultsKey = "appLockEnabled"

    private enum Key: String {
        case pinSalt
        case pinHash
        case recoveryHash
        case recoveryEmail
    }

    var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: defaultsKey) && hasStoredPIN
    }

    var recoveryEmail: String? {
        guard let data = read(key: .recoveryEmail) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    var maskedRecoveryEmail: String? {
        guard let email = recoveryEmail else { return nil }
        let parts = email.split(separator: "@", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return email }
        let name = parts[0]
        let domain = parts[1]
        let first = name.first.map(String.init) ?? ""
        return "\(first)•••@\(domain)"
    }

    @discardableResult
    func enable(pin: String, recoveryEmail: String) throws -> String {
        try validate(pin: pin, recoveryEmail: recoveryEmail)

        let salt = randomData(count: 16)
        let recoveryCode = generateRecoveryCode()

        try save(salt, key: .pinSalt)
        try save(hash(value: pin, salt: salt), key: .pinHash)
        try save(hash(value: normalizedRecoveryCode(recoveryCode), salt: salt), key: .recoveryHash)
        try save(Data(recoveryEmail.trimmingCharacters(in: .whitespacesAndNewlines).utf8), key: .recoveryEmail)

        UserDefaults.standard.set(true, forKey: defaultsKey)
        return recoveryCode
    }

    func verify(pin: String) -> Bool {
        guard let salt = read(key: .pinSalt),
              let storedHash = read(key: .pinHash) else { return false }
        return hash(value: pin, salt: salt) == storedHash
    }

    func verifyRecoveryCode(_ code: String) -> Bool {
        guard let salt = read(key: .pinSalt),
              let storedHash = read(key: .recoveryHash) else { return false }
        return hash(value: normalizedRecoveryCode(code), salt: salt) == storedHash
    }

    func changePIN(currentPIN: String, newPIN: String) throws {
        guard verify(pin: currentPIN) else { throw AppLockError.incorrectPIN }
        try validate(pin: newPIN, recoveryEmail: recoveryEmail ?? "")
        guard let salt = read(key: .pinSalt) else { throw AppLockError.notConfigured }
        try save(hash(value: newPIN, salt: salt), key: .pinHash)
    }

    @discardableResult
    func resetPIN(recoveryCode: String, newPIN: String) throws -> String {
        guard verifyRecoveryCode(recoveryCode) else { throw AppLockError.incorrectRecoveryCode }
        try validate(pin: newPIN, recoveryEmail: recoveryEmail ?? "")
        guard let salt = read(key: .pinSalt) else { throw AppLockError.notConfigured }

        let newRecoveryCode = generateRecoveryCode()
        try save(hash(value: newPIN, salt: salt), key: .pinHash)
        try save(hash(value: normalizedRecoveryCode(newRecoveryCode), salt: salt), key: .recoveryHash)
        return newRecoveryCode
    }

    @discardableResult
    func replaceRecoveryCode(currentPIN: String) throws -> String {
        guard verify(pin: currentPIN) else { throw AppLockError.incorrectPIN }
        guard let salt = read(key: .pinSalt) else { throw AppLockError.notConfigured }
        let code = generateRecoveryCode()
        try save(hash(value: normalizedRecoveryCode(code), salt: salt), key: .recoveryHash)
        return code
    }

    func updateRecoveryEmail(currentPIN: String, email: String) throws {
        guard verify(pin: currentPIN) else { throw AppLockError.incorrectPIN }
        try validate(pin: "0000", recoveryEmail: email)
        try save(Data(email.trimmingCharacters(in: .whitespacesAndNewlines).utf8), key: .recoveryEmail)
    }

    func disable(currentPIN: String) throws {
        guard verify(pin: currentPIN) else { throw AppLockError.incorrectPIN }
        deleteAll()
        UserDefaults.standard.set(false, forKey: defaultsKey)
    }

    private var hasStoredPIN: Bool {
        read(key: .pinSalt) != nil && read(key: .pinHash) != nil
    }

    private func validate(pin: String, recoveryEmail: String) throws {
        guard pin.count == 4, pin.allSatisfy(\.isNumber) else {
            throw AppLockError.invalidPIN
        }

        let email = recoveryEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard email.contains("@"), email.contains("."), !email.contains(" ") else {
            throw AppLockError.invalidEmail
        }
    }

    private func normalizedRecoveryCode(_ value: String) -> String {
        value.uppercased().filter { $0.isLetter || $0.isNumber }
    }

    private func generateRecoveryCode() -> String {
        let alphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        var generator = SystemRandomNumberGenerator()
        return String((0..<10).compactMap { _ in alphabet.randomElement(using: &generator) })
    }

    private func randomData(count: Int) -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        _ = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
        return Data(bytes)
    }

    private func hash(value: String, salt: Data) -> Data {
        var data = salt
        data.append(Data(value.utf8))
        return Data(SHA256.hash(data: data))
    }

    private func save(_ data: Data, key: Key) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]

        SecItemDelete(query as CFDictionary)

        var addQuery = query
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw AppLockError.keychain(status)
        }
    }

    private func read(key: Key) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        return item as? Data
    }

    private func deleteAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        SecItemDelete(query as CFDictionary)
    }
}

enum AppLockError: LocalizedError {
    case invalidPIN
    case invalidEmail
    case incorrectPIN
    case incorrectRecoveryCode
    case notConfigured
    case keychain(OSStatus)

    var errorDescription: String? {
        switch self {
        case .invalidPIN:
            return "Use exactly four numbers for your PIN."
        case .invalidEmail:
            return "Enter a valid recovery email address."
        case .incorrectPIN:
            return "That PIN is not correct."
        case .incorrectRecoveryCode:
            return "That recovery code is not correct."
        case .notConfigured:
            return "App Lock has not been set up yet."
        case .keychain:
            return "The app could not securely save your App Lock information."
        }
    }
}
