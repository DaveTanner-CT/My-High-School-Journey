import SwiftUI
import MessageUI

struct BackupMailView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss

    let recipient: String
    let backupURL: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = context.coordinator
        controller.setToRecipients(recipient.isEmpty ? nil : [recipient])
        controller.setSubject("My High School Journey backup")
        controller.setMessageBody(
            "Attached is a backup of my My High School Journey data. Keep this file in a safe place.",
            isHTML: false
        )

        if let data = try? Data(contentsOf: backupURL) {
            controller.addAttachmentData(
                data,
                mimeType: "application/json",
                fileName: backupURL.lastPathComponent
            )
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        private let dismiss: DismissAction

        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            dismiss()
        }
    }
}
