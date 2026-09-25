import SwiftUI
import SwiftData

struct JourneyMomentDetailView: View {
    let moment: JourneyMoment

    @Query(sort: \PhotoAsset.sortOrder) private var allPhotoAssets: [PhotoAsset]
    @State private var showingEdit = false
    @State private var selectedPhotoID: UUID?

    private var photos: [PhotoAsset] {
        allPhotoAssets
            .filter {
                $0.ownerType == PhotoOwnerType.journeyMoment &&
                $0.ownerID == moment.id
            }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if !photos.isEmpty {
                    photoSection
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(moment.title)
                        .font(.largeTitle.bold())

                    HStack(spacing: 8) {
                        Label(moment.category, systemImage: "tag")
                        Text("•")
                        Text(moment.momentDate, format: .dateTime.month(.abbreviated).day().year())
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    if !moment.gradeLevel.isEmpty {
                        Label("Grade \(moment.gradeLevel)", systemImage: "graduationcap")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if !moment.summary.isEmpty {
                    detailBlock(title: "What happened", text: moment.summary)
                }

                if !moment.reflection.isEmpty {
                    detailBlock(title: "What I want to remember", text: moment.reflection)
                }

                HStack(spacing: 8) {
                    Image(systemName: moment.includeInExports ? "checkmark.circle.fill" : "minus.circle")
                    Text(moment.includeInExports ? "Available for future exports" : "Not included in future exports by default")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .padding(.bottom, 24)
        }
        .navigationTitle("Journey Moment")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            NavigationStack {
                EditJourneyMomentView(moment: moment)
            }
        }
        .fullScreenCover(
            isPresented: Binding(
                get: { selectedPhotoID != nil },
                set: { if !$0 { selectedPhotoID = nil } }
            )
        ) {
            if let selectedPhotoID {
                JourneyPhotoViewer(photos: photos, selectedPhotoID: selectedPhotoID)
            }
        }
    }

    private var photoSection: some View {
        VStack(spacing: 10) {
            ForEach(photos) { photo in
                Button {
                    selectedPhotoID = photo.id
                } label: {
                    StoredPhotoThumbnailView(
                        filename: photo.thumbnailFilename,
                        maxHeight: 520,
                        cornerRadius: 18
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open photo")
            }
        }
    }

    private func detailBlock(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.headline)
            Text(text)
                .font(.body)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.quaternary.opacity(0.28), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
