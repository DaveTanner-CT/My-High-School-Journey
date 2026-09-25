import SwiftUI
import SwiftData

struct AddJourneyMomentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var momentDate = Date()
    @State private var category = "General"
    @State private var summary = ""
    @State private var reflection = ""
    @State private var gradeLevel = ""
    @State private var includeInExports = true

    private let categories = ["General", "Academic", "Activity", "Athletics", "Award", "Experience", "Service", "Work", "Personal"]
    private let grades = ["", "9", "10", "11", "12"]

    var body: some View {
        Form {
            Section("Moment") {
                TextField("What happened?", text: $title)
                DatePicker("Date", selection: $momentDate, displayedComponents: .date)

                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { Text($0).tag($0) }
                }

                Picker("Grade", selection: $gradeLevel) {
                    Text("Not set").tag("")
                    ForEach(grades.filter { !$0.isEmpty }, id: \.self) { Text("Grade \($0)").tag($0) }
                }
            }

            Section("What do you want to remember?") {
                TextField("Short description", text: $summary, axis: .vertical)
                    .lineLimit(3...6)

                TextField("Optional reflection", text: $reflection, axis: .vertical)
                    .lineLimit(4...10)
            }

            Section {
                Toggle("Available for future exports", isOn: $includeInExports)
            } footer: {
                Text("You will still choose what to share each time you create an export.")
            }
        }
        .navigationTitle("New Moment")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .interactiveDismissDisabled(hasUnsavedChanges)
    }

    private var hasUnsavedChanges: Bool {
        !title.isEmpty || !summary.isEmpty || !reflection.isEmpty || category != "General" || gradeLevel != ""
    }

    private func save() {
        let moment = JourneyMoment(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            momentDate: momentDate,
            category: category,
            summary: summary.trimmingCharacters(in: .whitespacesAndNewlines),
            reflection: reflection.trimmingCharacters(in: .whitespacesAndNewlines),
            gradeLevel: gradeLevel,
            isFeatured: true,
            includeInExports: includeInExports
        )
        modelContext.insert(moment)
        try? modelContext.save()
        dismiss()
    }
}
