import SwiftUI

/// Screen 5 (bonus) — cached location picker. Matches the wireframe: a plain
/// list of location names, one per row.
struct CachedLocationsScreenView: View {
    @ObservedObject var viewModel: CachedLocationsViewModel
    let slot: SlotIdentifier
    let onSelect: () -> Void

    var body: some View {
        Group {
            if viewModel.cachedLocations.isEmpty {
                Text("No cached locations yet.")
                    .foregroundColor(DesignTokens.secondaryText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(Array(viewModel.cachedLocations.enumerated()), id: \.offset) { _, cached in
                    Button {
                        viewModel.select(cached, for: slot)
                        onSelect()
                    } label: {
                        Text(cached.location.displayName)
                            .foregroundColor(.black)
                            .font(.system(size: 15))
                            .padding(.vertical, 8)
                    }
                }
                .listStyle(.plain)
            }
        }
        .onAppear { viewModel.load() }
    }
}
