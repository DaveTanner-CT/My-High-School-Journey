import SwiftUI

struct RecoveryResetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var recoveryCode = ""
    @State private var newPIN = ""
    @State private var confirmPIN = ""
    @State private var newRecoveryCode: String?
    @State private var errorMessage: String?

    let onReset: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                if let newRecoveryCode {
                    Section("PIN Reset") {
                        Label("Your PIN has been changed.", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)

                        Text("For security, your old recovery code has been replaced. Email this new recovery code to yourself before leaving this screen.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Text(newRecoveryCode)
                            .font(.title3.monospaced().bold())
                            .textSelection(.enabled)

                        Button {
                            emailRecoveryCode(newRecoveryCode)
                        } label: {
                            Label("Email New Recovery Code", systemImage: "envelope.fill")
                        }

                        Button("Done") {
                            dismiss()
                            onReset()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    Section("Recovery") {
                        if let maskedEmail = AppLockService.shared.maskedRecoveryEmail {
                            Text("Use the recovery code you saved in email for \(maskedEmail).")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        TextField("Recovery code", text: $recoveryCode)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()

                        SecureField("New 4-digit PIN", text: $newPIN)
                            .keyboardType(.numberPad)
                            .onChange(of: newPIN) { _, value in
                                newPIN = String(value.filter(\.isNumber).prefix(4))
                            }

                        SecureField("Confirm new PIN", text: $confirmPIN)
                            .keyboardType(.numberPad)
                            .onChange(of: confirmPIN) { _, value in
                                confirmPIN = String(value.filter(\.isNumber).prefix(4))
                            }
                    }

                    if let errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                        }
                    }

                    Section {
                        Button("Reset PIN") {
                            resetPIN()
                        }
                        .disabled(recoveryCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || newPIN.count != 4 || confirmPIN.count != 4)
                    }
                }
            }
            .navigationTitle("Reset PIN")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if newRecoveryCode == nil {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
        }
    }

    private func resetPIN() {
        guard newPIN == confirmPIN else {
            errorMessage = "The two PIN entries do not match."
            return
        }

        do {
            newRecoveryCode = try AppLockService.shared.resetPIN(
                recoveryCode: recoveryCode,
                newPIN: newPIN
            )
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func emailRecoveryCode(_ code: String) {
        guard let email = AppLockService.shared.recoveryEmail else { return }
        openURL(recoveryEmailURL(email: email, code: code))
    }
}
