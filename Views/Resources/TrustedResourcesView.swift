import SwiftUI

struct TrustedResourcesView: View {
    @State private var searchText = ""
    @State private var selectedCategory: TrustedResourceCategory?

    private var filteredResources: [TrustedResource] {
        TrustedResourceCatalog.resources.filter { resource in
            let matchesCategory = selectedCategory == nil || resource.category == selectedCategory
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesSearch = query.isEmpty || [
                resource.organization,
                resource.title,
                resource.description,
                resource.category.rawValue,
                resource.resourceType,
                resource.audience,
                resource.accessNote ?? ""
            ].contains { $0.localizedCaseInsensitiveContains(query) }
            return matchesCategory && matchesSearch
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                introCard
                categoryPicker

                if filteredResources.isEmpty {
                    ContentUnavailableView {
                        Label("No Resources Found", systemImage: "magnifyingglass")
                    } description: {
                        Text("Try another search or choose a different category.")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 28)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredResources) { resource in
                            resourceCard(resource)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Trusted Resources")
        .searchable(text: $searchText, prompt: "Search resources")
        .background(Color(.systemGroupedBackground))
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Start with a trusted source", systemImage: "checkmark.seal.fill")
                .font(.headline)
            Text("These links point to official organizations and national resources. Always check a college, employer, program, or organization directly for requirements that apply to you.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryButton(title: "All", systemImage: "square.grid.2x2", category: nil)
                ForEach(TrustedResourceCategory.allCases) { category in
                    categoryButton(title: category.rawValue, systemImage: category.systemImage, category: category)
                }
            }
        }
    }

    private func categoryButton(
        title: String,
        systemImage: String,
        category: TrustedResourceCategory?
    ) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedCategory = category
            }
        } label: {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .background(
                    isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }

    private func resourceCard(_ resource: TrustedResource) -> some View {
        Link(destination: resource.url) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: resource.category.systemImage)
                        .font(.title3)
                        .frame(width: 28)
                        .foregroundStyle(.tint)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(resource.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(resource.organization)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Text(resource.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 8) {
                    if resource.officialSource {
                        Label("Official source", systemImage: "checkmark.seal.fill")
                    }
                    Text(resource.resourceType)
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                if let accessNote = resource.accessNote {
                    Label(accessNote, systemImage: "person.crop.circle.badge.checkmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("Verified \(resource.lastVerified)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
