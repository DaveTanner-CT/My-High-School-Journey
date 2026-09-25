import SwiftUI
import SwiftData

struct AddCustomTileItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let tileID: UUID
    let tileTitle: String

    @State private var title = ""
    @State private var notes = ""
    @State private var itemDate = Date()
    @State private var linkURL = ""

    var body: some View {
        Form {
            Section("Item") {
                TextField("Title", text: $title)
                DatePicker("Date", selection: $itemDate, displayedComponents: .date)
            }

            Section("Notes") {
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(3...8)
            }

            Section("Link") {
                TextField("Optional web link", text: $linkURL)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
            }
        }
        .navigationTitle("Add to \(tileTitle)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { saveItem() }
                    .disabled(cleanTitle.isEmpty)
            }
        }
    }

    private var cleanTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func saveItem() {
        let item = CustomTileItem(
            tileID: tileID,
            title: cleanTitle,
            itemDate: itemDate,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            linkURL: linkURL.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        modelContext.insert(item)
        try? modelContext.save()
        dismiss()
    }
}
