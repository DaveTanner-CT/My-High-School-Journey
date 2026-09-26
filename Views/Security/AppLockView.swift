import SwiftUI

struct AppLockView: View {
    @State private var pin = ""
    @State private var errorMessage: String?
    @State private var showingRecovery = false

    let onUnlocked: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.secondary)

                VStack(spacing: 8) {
                    Text("My High School Journey is locked")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)

                    Text("Enter your four-digit PIN to continue.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
                        if cleaned != newValue {
                            pin = cleaned
                        }
                        if cleaned.count == 4 {
                            unlock()
                        }
                    }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Button("Unlock") {
                    unlock()
                }
                .buttonStyle(.borderedProminent)
                .disabled(pin.count != 4)

                Button("Forgot PIN?") {
                    showingRecovery = true
                }
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
        }
    }

    private func unlock() {
        guard AppLockService.shared.verify(pin: pin) else {
            pin = ""
            errorMessage = "That PIN is not correct."
            return
        }

        errorMessage = nil
        onUnlocked()
    }
}
