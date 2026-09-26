import SwiftUI

struct AppLockSettingsView: View {
    @Environment(\.openURL) private var openURL

    @AppStorage("appLockEnabled") private var appLockEnabled = false
    @AppStorage("biometricUnlockEnabled") private var biometricUnlockEnabled = false

    @State private var pin = ""
    @State private var confirmPIN = ""
    @State private var recoveryEmail = ""
    @State private var currentPIN = ""
    @State private var newPIN = ""
    @State private var confirmNewPIN = ""
    @State private var generatedRecoveryCode: String?
    @State private var errorMessage: String?
    @State private var showingChangePIN = false
    @State private var showingDisable = false
    @State private var showingRecoveryRefresh = false

    var body: some View {
        Form {
            if appLockEnabled && AppLockService.shared.isEnabled {
                enabledContent
            } else {
                setupContent
            }
        }
        .navigationTitle("App Lock")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: Binding(
            get: { generatedRecoveryCode != nil },
            set: { if !$0 { generatedRecoveryCode = nil } }
        )) {
            if let code = generatedRecoveryCode {
                RecoveryCodeSheet(code: code)
            }
        }
        .sheet(isPresented: $showingChangePIN) {
            changePINSheet
        }
        .sheet(isPresented: $showingDisable) {
            disableSheet
        }
        .sheet(isPresented: $showingRecoveryRefresh) {
            refreshRecoverySheet
        }
        .onAppear {
            if recoveryEmail.isEmpty {
                recoveryEmail = AppLockService.shared.recoveryEmail ?? ""
            }
        }
    }

    private var setupContent: some View {
        Group {
            Section {
                Text("App Lock is optional. When it is on, My High School Journey asks for a four-digit PIN when the app is reopened after leaving it.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Create PIN") {
                SecureField("4-digit PIN", text: $pin)
                    .keyboardType(.numberPad)
                    .onChange(of: pin) { _, value in
                        pin = String(value.filter(\.isNumber).prefix(4))
                    }

                SecureField("Confirm PIN", text: $confirmPIN)
                    .keyboardType(.numberPad)
                    .onChange(of: confirmPIN) { _, value in
                        confirmPIN = String(value.filter(\.isNumber).prefix(4))
                    }
            }

            Section("Recovery Email") {
                TextField("Email address", text: $recoveryEmail)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                Text("The app will create a recovery code for you to email to yourself. The recovery code can reset the PIN if you forget it.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button("Turn On App Lock") {
                    enableLock()
                }
                .disabled(pin.count != 4 || confirmPIN.count != 4 || recoveryEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private var enabledContent: some View {
        Group {
            Section {
                Label("App Lock is on", systemImage: "lock.fill")
                    .foregroundStyle(.green)

                if let email = AppLockService.shared.recoveryEmail {
                    LabeledContent("Recovery email", value: email)
                }
            }

            Section("Security") {
                if BiometricAuthService.isAvailable {
                    Toggle(isOn: $biometricUnlockEnabled) {
                        Label("Unlock with \(BiometricAuthService.kind.displayName)", systemImage: BiometricAuthService.kind.systemImage)
                    }

                    Text("Your four-digit PIN remains available as a backup way to unlock the app.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    LabeledContent("Biometric unlock", value: "Not available")
                        .foregroundStyle(.secondary)
                }

                Button("Change PIN") {
                    resetSheetFields()
                    showingChangePIN = true
                }

                Button("Create New Recovery Code") {
                    resetSheetFields()
                    showingRecoveryRefresh = true
                }

                Button("Turn Off App Lock", role: .destructive) {
                    resetSheetFields()
                    showingDisable = true
                }
            }

            Section {
                Text("Your PIN and recovery code are stored securely on this device. My High School Journey does not send them to a school or to Scripting for Schools.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var changePINSheet: some View {
        NavigationStack {
            Form {
                Section("Current PIN") {
                    SecureField("Current 4-digit PIN", text: $currentPIN)
                        .keyboardType(.numberPad)
                        .onChange(of: currentPIN) { _, value in
                            currentPIN = String(value.filter(\.isNumber).prefix(4))
                        }
                }

                Section("New PIN") {
                    SecureField("New 4-digit PIN", text: $newPIN)
                        .keyboardType(.numberPad)
                        .onChange(of: newPIN) { _, value in
                            newPIN = String(value.filter(\.isNumber).prefix(4))
                        }
                    SecureField("Confirm new PIN", text: $confirmNewPIN)
                        .keyboardType(.numberPad)
                        .onChange(of: confirmNewPIN) { _, value in
                            confirmNewPIN = String(value.filter(\.isNumber).prefix(4))
                        }
                }

                sheetErrorSection
            }
            .navigationTitle("Change PIN")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingChangePIN = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { changePIN() }
                        .disabled(currentPIN.count != 4 || newPIN.count != 4 || confirmNewPIN.count != 4)
                }
            }
        }
    }

    private var disableSheet: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Enter your current PIN to turn off App Lock.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    SecureField("Current 4-digit PIN", text: $currentPIN)
                        .keyboardType(.numberPad)
                        .onChange(of: currentPIN) { _, value in
                            currentPIN = String(value.filter(\.isNumber).prefix(4))
                        }
                }
                sheetErrorSection
            }
            .navigationTitle("Turn Off App Lock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingDisable = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Turn Off", role: .destructive) { disableLock() }
                        .disabled(currentPIN.count != 4)
                }
            }
        }
    }

    private var refreshRecoverySheet: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Enter your current PIN. A new recovery code will replace the old one.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    SecureField("Current 4-digit PIN", text: $currentPIN)
                        .keyboardType(.numberPad)
                        .onChange(of: currentPIN) { _, value in
                            currentPIN = String(value.filter(\.isNumber).prefix(4))
                        }
                }
                sheetErrorSection
            }
            .navigationTitle("New Recovery Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingRecoveryRefresh = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { refreshRecoveryCode() }
                        .disabled(currentPIN.count != 4)
                }
            }
        }
    }

    @ViewBuilder
    private var sheetErrorSection: some View {
        if let errorMessage {
            Section {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
    }

    private func enableLock() {
        guard pin == confirmPIN else {
            errorMessage = "The two PIN entries do not match."
            return
        }

        do {
            let code = try AppLockService.shared.enable(pin: pin, recoveryEmail: recoveryEmail)
            appLockEnabled = true
            errorMessage = nil
            generatedRecoveryCode = code
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func changePIN() {
        guard newPIN == confirmNewPIN else {
            errorMessage = "The two new PIN entries do not match."
            return
        }

        do {
            try AppLockService.shared.changePIN(currentPIN: currentPIN, newPIN: newPIN)
            errorMessage = nil
            showingChangePIN = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func disableLock() {
        do {
            try AppLockService.shared.disable(currentPIN: currentPIN)
            appLockEnabled = false
            biometricUnlockEnabled = false
            errorMessage = nil
            showingDisable = false
            pin = ""
            confirmPIN = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshRecoveryCode() {
        do {
            let code = try AppLockService.shared.replaceRecoveryCode(currentPIN: currentPIN)
            errorMessage = nil
            showingRecoveryRefresh = false
            generatedRecoveryCode = code
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func resetSheetFields() {
        currentPIN = ""
        newPIN = ""
        confirmNewPIN = ""
        errorMessage = nil
    }
}

private struct RecoveryCodeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    let code: String

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Label("Save your recovery code", systemImage: "envelope.badge.shield.half.filled")
                    .font(.title2.bold())

                Text("If you forget your PIN, this code is the way back into the app. Email it to yourself and keep that message.")
                    .foregroundStyle(.secondary)

                Text(code)
                    .font(.title2.monospaced().bold())
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button {
                    if let email = AppLockService.shared.recoveryEmail {
                        openURL(recoveryEmailURL(email: email, code: code))
                    }
                } label: {
                    Label("Email Recovery Code", systemImage: "envelope.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Text("The email is created in your mail app so you can review and send it yourself.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(24)
            .navigationTitle("Recovery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

func recoveryEmailURL(email: String, code: String) -> URL {
    var components = URLComponents()
    components.scheme = "mailto"
    components.path = email
    components.queryItems = [
        URLQueryItem(name: "subject", value: "My High School Journey recovery code"),
        URLQueryItem(
            name: "body",
            value: "Keep this message in a safe place.\n\nMy High School Journey recovery code: \(code)\n\nThis code can be used to reset the four-digit App Lock PIN."
        )
    ]
    return components.url ?? URL(string: "mailto:\(email)")!
}

