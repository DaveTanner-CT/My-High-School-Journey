import SwiftUI

struct AppLockView: View {
    @AppStorage("biometricUnlockEnabled") private var biometricUnlockEnabled = false

    @State private var pin = ""
    @State private var errorMessage: String?
    @State private var showingRecovery = false
    @State private var attemptedBiometricUnlock = false
    @State private var isAuthenticating = false

    let onUnlocked: () -> Void

    private var biometricKind: BiometricKind { BiometricAuthService.kind }
    private var canUseBiometrics: Bool { biometricUnlockEnabled && BiometricAuthService.isAvailable }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: canUseBiometrics ? biometricKind.systemImage : "lock.shield.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.secondary)

                VStack(spacing: 8) {
                    Text("My High School Journey is locked")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)

                    Text(canUseBiometrics ? "Use \(biometricKind.displayName) or enter your four-digit PIN." : "Enter your four-digit PIN to continue.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                if canUseBiometrics {
                    Button {
                        Task { await unlockWithBiometrics() }
                    } label: {
                        Label("Unlock with \(biometricKind.displayName)", systemImage: biometricKind.systemImage)
                            .frame(maxWidth: 240)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isAuthenticating)
                }

                SecureField("4-digit PIN", text: $pin)
                    .keyboardType(.numberPad)
                    .textContentType(.password)
                    .multilineTextAlignment(.center)
                    .font(.title2.monospacedDigit())
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .frame(maxWidth: 220)
                    .onChange(of: pin) { _, newValue in
                        let cleaned = String(newValue.filter(\.isNumber).prefix(4))
                        if cleaned != newValue { pin = cleaned }
                        if cleaned.count == 4 { unlockWithPIN() }
                    }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button("Unlock with PIN") { unlockWithPIN() }
                    .buttonStyle(.bordered)
                    .disabled(pin.count != 4)

                Button("Forgot PIN?") { showingRecovery = true }
                    .font(.subheadline.weight(.semibold))

                Spacer()
            }
            .padding(24)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingRecovery) {
                RecoveryResetView {
                    showingRecovery = false
                    onUnlocked()
                }
            }
            .task {
                guard canUseBiometrics, !attemptedBiometricUnlock else { return }
                attemptedBiometricUnlock = true
                await unlockWithBiometrics()
            }
        }
    }

    private func unlockWithPIN() {
        guard AppLockService.shared.verify(pin: pin) else {
            pin = ""
            errorMessage = "That PIN is not correct."
            return
        }
        errorMessage = nil
        onUnlocked()
    }

    @MainActor
    private func unlockWithBiometrics() async {
        guard canUseBiometrics else { return }
        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            try await BiometricAuthService.authenticate()
            errorMessage = nil
            onUnlocked()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
