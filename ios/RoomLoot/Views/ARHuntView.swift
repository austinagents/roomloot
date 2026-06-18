import SwiftUI

struct ARHuntView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var locationManager: LocationManager
    let treasure: Treasure

    @State private var isCollecting = false
    @State private var result: CollectedTreasure?
    @State private var errorMessage: String?

    var body: some View {
        ZStack(alignment: .top) {
            TreasureARView {
                Task { await collect() }
            }
            .ignoresSafeArea()

            VStack(spacing: 8) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.parchment)
                            .padding(10)
                            .background(Color.charcoal.opacity(0.8))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                Text(isCollecting ? "Collecting..." : "Find the treasure")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.parchment)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.charcoal.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding()
        }
        .sheet(item: Binding(
            get: { result.map { CollectionResultItem(collection: $0) } },
            set: { _ in }
        )) { item in
            CollectionResultView(collection: item.collection) {
                result = nil
                dismiss()
            }
        }
        .alert("RoomLoot", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("Return to Map") { dismiss() }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func collect() async {
        guard !isCollecting else { return }
        guard let location = locationManager.currentLocation else {
            errorMessage = "Location is required to collect this treasure."
            return
        }
        isCollecting = true
        defer { isCollecting = false }
        let response = await appState.collect(treasure, at: location)
        if response?.success == true, let collection = response?.collection {
            result = collection
        } else {
            errorMessage = response?.error ?? appState.errorMessage ?? "Collection failed."
        }
    }
}

private struct CollectionResultItem: Identifiable {
    let id = UUID()
    let collection: CollectedTreasure
}

