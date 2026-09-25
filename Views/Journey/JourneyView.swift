import SwiftUI
import SwiftData

struct JourneyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JourneyMoment.momentDate, order: .reverse) private var moments: [JourneyMoment]
    @State private var showingAddMoment = false

    var body: some View {
        Group {
            if moments.isEmpty {
                JourneyEmptyStateView {
                    showingAddMoment = true
                }
            } else {
                List {
                    ForEach(moments) { moment in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(moment.title)
                                .font(.headline)

                            HStack(spacing: 8) {
                                Text(moment.category)
                                Text("•")
                                Text(moment.momentDate, format: .dateTime.month(.abbreviated).day().year())
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)

                            if !moment.summary.isEmpty {
                                Text(moment.summary)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 2)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .onDelete(perform: deleteMoments)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("My Journey")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddMoment = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Journey Moment")
            }
        }
        .sheet(isPresented: $showingAddMoment) {
            NavigationStack {
                AddJourneyMomentView()
            }
        }
    }

    private func deleteMoments(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(moments[index])
        }
        try? modelContext.save()
    }
}
