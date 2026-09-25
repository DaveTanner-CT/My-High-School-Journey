import SwiftUI
import SwiftData

struct JourneyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JourneyMoment.momentDate, order: .reverse) private var moments: [JourneyMoment]
    @Query(sort: \PhotoAsset.sortOrder) private var photoAssets: [PhotoAsset]
    @State private var showingAddMoment = false

    var body: some View {
        Group {
            if moments.isEmpty {
                JourneyEmptyStateView {
                    showingAddMoment = true
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(moments) { moment in
                            NavigationLink {
                                JourneyMomentDetailView(moment: moment)
                            } label: {
                                JourneyMomentCard(
                                    moment: moment,
                                    photos: photos(for: moment)
                                )
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    deleteMoment(moment)
                                } label: {
                                    Label("Delete Moment", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
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

    private func photos(for moment: JourneyMoment) -> [PhotoAsset] {
        photoAssets
            .filter {
                $0.ownerType == PhotoOwnerType.journeyMoment && $0.ownerID == moment.id
            }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private func deleteMoment(_ moment: JourneyMoment) {
        for photo in photos(for: moment) {
            PhotoStorageService.deleteFiles(
                imageFilename: photo.imageFilename,
                thumbnailFilename: photo.thumbnailFilename
            )
            modelContext.delete(photo)
        }

        modelContext.delete(moment)
        try? modelContext.save()
    }
}

private struct JourneyMomentCard: View {
    let moment: JourneyMoment
    let photos: [PhotoAsset]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let firstPhoto = photos.first {
                StoredPhotoThumbnailView(
                    filename: firstPhoto.thumbnailFilename,
                    maxHeight: 400,
                    cornerRadius: 16
                )
            }

            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .firstTextBaseline) {
                    Text(moment.title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }

                HStack(spacing: 7) {
                    Label(moment.category, systemImage: "tag")
                    Text("•")
                    Text(moment.momentDate, format: .dateTime.month(.abbreviated).day().year())
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                if !moment.summary.isEmpty {
                    Text(moment.summary)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }

                if photos.count > 1 {
                    Label("\(photos.count) photos", systemImage: "photo.stack")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("Tap to open")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 2)
        }
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
    }
}
