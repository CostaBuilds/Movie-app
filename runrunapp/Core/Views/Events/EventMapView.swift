import SwiftUI
import MapKit

// MARK: - Event Map View
struct EventMapView: View {
    @StateObject private var viewModel = RunEventViewModel()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedEventId: UUID?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Map with events
                mapView

                // Event list overlay
                if !viewModel.nearbyEvents.isEmpty {
                    eventListOverlay
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Eventos Próximos")
                        .font(.headline)
                        .fontWeight(.bold)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        centerOnUserLocation()
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingEventDetail) {
                if let event = viewModel.selectedEvent {
                    EventDetailView(event: event, viewModel: viewModel)
                }
            }
            .sheet(isPresented: $viewModel.showingActiveEvent) {
                if let event = viewModel.activeEvent {
                    ActiveEventView(event: event, viewModel: viewModel)
                }
            }
            .onAppear {
                viewModel.requestNotificationPermission()
                viewModel.loadEvents()
                viewModel.refreshNearbyEvents()
            }
        }
    }

    // MARK: - Map View
    private var mapView: some View {
        Map(position: $cameraPosition, selection: $selectedEventId) {
            // User location
            UserAnnotation()

            // Event markers
            ForEach(viewModel.nearbyEvents, id: \.id) { event in
                Annotation(event.name, coordinate: event.coordinate) {
                    EventMarker(event: event)
                        .onTapGesture {
                            selectedEventId = event.id
                            viewModel.selectEvent(event)
                        }
                }

                // Event radius circle
                MapCircle(center: event.coordinate, radius: event.radius)
                    .foregroundStyle(event.isActive ? Color.cyan.opacity(0.2) : Color.gray.opacity(0.1))
                    .stroke(event.isActive ? Color.cyan : Color.gray, lineWidth: 2)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
    }

    // MARK: - Event List Overlay
    private var eventListOverlay: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.nearbyEvents, id: \.id) { event in
                        EventCard(event: event, viewModel: viewModel)
                            .onTapGesture {
                                viewModel.selectEvent(event)
                            }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 180)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Helper Methods
    private func centerOnUserLocation() {
        if let location = viewModel.userLocation {
            withAnimation {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                )
            }
        }
    }
}

// MARK: - Event Marker
struct EventMarker: View {
    let event: RunEvent

    var body: some View {
        ZStack {
            // Outer pulse for active events
            if event.isActive {
                Circle()
                    .fill(Color.cyan.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .scaleEffect(1.0)
            }

            // Main marker
            Circle()
                .fill(event.isActive ? Color.cyan : Color.gray)
                .frame(width: 44, height: 44)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

            // Icon
            VStack(spacing: 2) {
                Text(event.eventTypeEmoji)
                    .font(.system(size: 18))

                if event.isActive {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 4, height: 4)
                }
            }
        }
    }
}

// MARK: - Event Card
struct EventCard: View {
    let event: RunEvent
    @ObservedObject var viewModel: RunEventViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(event.eventTypeEmoji)
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 2) {
                    Text(event.name)
                        .font(.system(size: 15, weight: .bold))
                        .lineLimit(1)

                    Text(event.locationName)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }

            // Stats
            HStack(spacing: 16) {
                EventStatBubble(
                    icon: "figure.run",
                    value: "\(event.participantCount)",
                    label: "pessoas"
                )

                if event.isActive {
                    EventStatBubble(
                        icon: "clock.fill",
                        value: viewModel.timeRemaining(for: event).components(separatedBy: " ").first ?? "",
                        label: "restante"
                    )
                } else {
                    EventStatBubble(
                        icon: "clock",
                        value: event.formattedStartTime,
                        label: "início"
                    )
                }

                EventStatBubble(
                    icon: "location.fill",
                    value: viewModel.formattedDistance(to: event),
                    label: "de você"
                )
            }

            // Status badge
            HStack {
                if event.isActive {
                    Label("Acontecendo agora", systemImage: "dot.radiowaves.left.and.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.cyan)
                        .cornerRadius(8)
                } else {
                    Text(viewModel.timeUntilStart(for: event))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }

                Spacer()

                Text("\(event.pointsReward) pts")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(hex: "C8FF00"))
            }
        }
        .padding()
        .frame(width: 280)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Event Stat Bubble
struct EventStatBubble: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(.cyan)

            Text(value)
                .font(.system(size: 13, weight: .bold))
                .lineLimit(1)

            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview {
    EventMapView()
}
