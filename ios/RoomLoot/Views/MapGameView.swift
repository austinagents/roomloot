import SwiftUI
import MapKit
import CoreLocation

struct MapGameView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var locationManager: LocationManager
    @State private var position: MapCameraPosition = .automatic
    @State private var showAR = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position) {
                UserAnnotation()
                ForEach(appState.treasures) { treasure in
                    Annotation(treasure.artifactName, coordinate: treasure.coordinate) {
                        Button {
                            appState.selectedTreasure = treasure
                        } label: {
                            TreasureMarkerView(treasure: treasure, selected: appState.selectedTreasure?.id == treasure.id)
                        }
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .ignoresSafeArea(edges: .bottom)

            VStack(spacing: 10) {
                if let user = appState.user {
                    HStack {
                        StatPill(title: "Coins", value: "\(user.coins)")
                        StatPill(title: "Level", value: "\(user.level)")
                        Spacer()
                        Button {
                            Task { await refresh(force: true) }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(Color.charcoal)
                                .padding(10)
                                .background(Color.agedGold)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                }

                if let treasure = appState.selectedTreasure {
                    TreasureBottomCard(treasure: treasure, currentLocation: locationManager.currentLocation) {
                        showAR = true
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 16)
        }
        .navigationTitle("Hunt")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            locationManager.requestWhenInUse()
            locationManager.start()
        }
        .onChange(of: locationManager.currentLocation) { _, location in
            guard let location else { return }
            position = .region(MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 650, longitudinalMeters: 650))
            Task {
                await appState.updateLocation(location)
                await appState.refreshTreasuresIfNeeded(location: location)
            }
        }
        .task {
            if let location = locationManager.currentLocation {
                await appState.refreshTreasures(location: location)
            }
        }
        .fullScreenCover(isPresented: $showAR) {
            if let treasure = appState.selectedTreasure {
                ARHuntView(treasure: treasure)
            }
        }
    }

    private func refresh(force: Bool) async {
        guard let location = locationManager.currentLocation else { return }
        await appState.refreshTreasuresIfNeeded(location: location, force: force)
    }
}

private struct TreasureBottomCard: View {
    let treasure: Treasure
    let currentLocation: CLLocation?
    let onStart: () -> Void

    private var liveDistance: Double {
        guard let currentLocation else { return treasure.distanceMeters }
        return currentLocation.distance(from: CLLocation(latitude: treasure.lat, longitude: treasure.lng))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: "shippingbox.fill")
                    .font(.title2)
                    .foregroundStyle(Color.agedGold)
                    .frame(width: 46, height: 46)
                    .background(Color.charcoal)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 5) {
                    Text(treasure.artifactName)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.parchment)
                    RarityBadge(rarity: treasure.rarity)
                }
                Spacer()
                Text("\(Int(liveDistance)) m")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.agedGold)
            }

            Text("+\(treasure.coinValue) coins  +\(treasure.xpValue) XP")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.parchment.opacity(0.9))

            Button(action: onStart) {
                Text(liveDistance <= 25 ? "Start AR Hunt" : "Move closer to collect")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryAdventureButton())
            .disabled(liveDistance > 25)
            .opacity(liveDistance > 25 ? 0.65 : 1)
        }
        .padding(16)
        .background(Color.leather.opacity(0.94))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.brass.opacity(0.8)))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

