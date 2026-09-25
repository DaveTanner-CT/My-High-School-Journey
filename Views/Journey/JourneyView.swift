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
                            JourneyMomentCard(
                                moment: moment,
                                photos: photos(for: moment)
                            )
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
        photoAssets.filter {
            $0.ownerType == PhotoOwnerType.journeyMoment && $0.ownerID == moment.id
        }
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
                StoredPhotoThumbnailView(filename: firstPhoto.thumbnailFilename)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text(moment.title)
                    .font(.title3.weight(.semibold))

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
                }

                if photos.count > 1 {
                    Label("\(photos.count) photos", systemImage: "photo.stack")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
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
