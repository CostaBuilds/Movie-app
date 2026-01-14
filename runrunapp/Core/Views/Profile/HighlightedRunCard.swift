import SwiftUI
import MapKit

struct HighlightedRunCard: View {
    let run: Run
    let onTap: () -> Void

    @State private var mapRegion: MKCoordinateRegion
    @State private var routeCoordinates: [CLLocationCoordinate2D] = []

    init(run: Run, onTap: @escaping () -> Void) {
        self.run = run
        self.onTap = onTap

        // Configurar região do mapa
        _mapRegion = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Thumbnail do mapa com glass border
                Map(position: .constant(.region(mapRegion))) {
                    if !routeCoordinates.isEmpty {
                        MapPolyline(coordinates: routeCoordinates)
                            .stroke(.cyan, lineWidth: 3)
                    }
                }
                .frame(width: 65, height: 65)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.3), lineWidth: 1.5)
                )
                .shadow(color: .cyan.opacity(0.2), radius: 5, x: 0, y: 2)
                .allowsHitTesting(false)

                // Info da corrida
                VStack(alignment: .leading, spacing: 4) {
                    Text(run.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(String(format: "%.2f km", run.distanceInKm))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    HStack(spacing: 12) {
                        Label(formatCalories(run.calories ?? 0), systemImage: "flame.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)

                        Label(run.paceFormatted + "/km", systemImage: "gauge.medium")
                            .font(.caption2)
                            .foregroundStyle(.cyan)
                    }
                }

                Spacer()

                // Seta de navegação
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .glassCard(
                gradient: [.white.opacity(0.2), .white.opacity(0.08)],
                borderColor: .white.opacity(0.35),
                cornerRadius: 16
            )
        }
        .buttonStyle(.plain)
        .onAppear {
            loadRouteData()
        }
    }

    private func loadRouteData() {
        guard let routeData = run.routeData,
              let coordinates = try? JSONDecoder().decode([Coordinate].self, from: routeData),
              !coordinates.isEmpty else {
            return
        }

        routeCoordinates = coordinates.map { $0.clLocation.coordinate }

        // Calcular região que contém toda a rota
        let latitudes = routeCoordinates.map { $0.latitude }
        let longitudes = routeCoordinates.map { $0.longitude }

        if let minLat = latitudes.min(),
           let maxLat = latitudes.max(),
           let minLon = longitudes.min(),
           let maxLon = longitudes.max() {

            let center = CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            )

            let span = MKCoordinateSpan(
                latitudeDelta: (maxLat - minLat) * 1.4,
                longitudeDelta: (maxLon - minLon) * 1.4
            )

            mapRegion = MKCoordinateRegion(center: center, span: span)
        }
    }

    private func formatCalories(_ calories: Int) -> String {
        if calories >= 1000 {
            return String(format: "%.1fk", Double(calories) / 1000.0)
        }
        return "\(calories)"
    }
}

#Preview {
    let mockRun = Run(
        userId: "test",
        date: Date(),
        distance: 10120,
        duration: 3600,
        averagePace: 5.5
    )
    mockRun.calories = 800

    return VStack {
        HighlightedRunCard(
            run: mockRun,
            onTap: {}
        )
        .padding()
    }
}
