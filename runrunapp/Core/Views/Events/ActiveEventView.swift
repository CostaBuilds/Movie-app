import SwiftUI
import MapKit

// MARK: - Active Event View
/// Real-time tracking view during an active event
struct ActiveEventView: View {
    let event: RunEvent
    @ObservedObject var viewModel: RunEventViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showingLeaderboard = false
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        ZStack {
            // Map background
            mapView

            // Overlay UI
            VStack {
                // Top bar
                topBar

                Spacer()

                // Stats overlay
                statsOverlay

                // Control buttons
                controlButtons
            }
        }
        .sheet(isPresented: $showingLeaderboard) {
            LeaderboardView(
                event: event,
                participants: viewModel.participants
            )
        }
    }

    // MARK: - Map View
    private var mapView: some View {
        Map(position: $cameraPosition) {
            // User location
            UserAnnotation()

            // Event center
            Annotation(event.name, coordinate: event.coordinate) {
                Circle()
                    .fill(Color.cyan.opacity(0.8))
                    .frame(width: 30, height: 30)
                    .overlay {
                        Text(event.eventTypeEmoji)
                            .font(.system(size: 16))
                    }
            }

            // Event zone circle
            MapCircle(center: event.coordinate, radius: event.radius)
                .foregroundStyle(Color.cyan.opacity(0.15))
                .stroke(Color.cyan, lineWidth: 3)

            // Other participants
            ForEach(viewModel.participants.filter { $0.isActive && $0.id != viewModel.currentParticipant?.id }, id: \.id) { participant in
                if let lat = participant.lastKnownLatitude,
                   let lon = participant.lastKnownLongitude {
                    Annotation(participant.userName, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 20, height: 20)
                            .overlay {
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            }
                    }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .ignoresSafeArea()
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            // Event info
            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)

                Text(viewModel.timeRemaining(for: event))
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.9))
            }

            Spacer()

            // Zone indicator
            ZStack {
                Circle()
                    .fill(viewModel.isInsideZone ? Color.cyan : Color.red)
                    .frame(width: 40, height: 40)

                Image(systemName: viewModel.isInsideZone ? "checkmark" : "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.black.opacity(0.7), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Stats Overlay
    private var statsOverlay: some View {
        VStack(spacing: 16) {
            // Zone status
            if !viewModel.isInsideZone {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left.and.right")
                        .font(.system(size: 14))

                    Text("\(Int(viewModel.distanceToEvent))m até a zona")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.red)
                .cornerRadius(20)
            }

            // Stats cards
            HStack(spacing: 12) {
                if let participant = viewModel.currentParticipant {
                    ActiveStatCard(
                        title: "Distância",
                        value: participant.formattedDistance,
                        icon: "location.fill"
                    )

                    ActiveStatCard(
                        title: "Tempo",
                        value: participant.formattedDuration,
                        icon: "timer"
                    )

                    ActiveStatCard(
                        title: "Pace",
                        value: participant.formattedPace,
                        icon: "speedometer"
                    )

                    if let rank = participant.currentRank {
                        ActiveStatCard(
                            title: "Posição",
                            value: "#\(rank)",
                            icon: "trophy.fill",
                            color: .orange
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Control Buttons
    private var controlButtons: some View {
        HStack(spacing: 16) {
            // Leaderboard button
            Button {
                showingLeaderboard = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 18))

                    Text("Ranking")
                        .font(.system(size: 15, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }

            // Center on user
            Button {
                centerOnUser()
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 18))
                    .frame(width: 50, height: 50)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }

            // Leave event
            Button {
                viewModel.leaveEvent()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18))
                    .frame(width: 50, height: 50)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
    }

    // MARK: - Helper Methods
    private func centerOnUser() {
        if let location = viewModel.userLocation {
            withAnimation {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
            }
        }
    }
}

// MARK: - Active Stat Card
struct ActiveStatCard: View {
    let title: String
    let value: String
    let icon: String
    var color: Color = .cyan

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Leaderboard View
struct LeaderboardView: View {
    let event: RunEvent
    let participants: [EventParticipant]
    @Environment(\.dismiss) private var dismiss

    var sortedParticipants: [EventParticipant] {
        participants
            .filter { $0.isActive || $0.isCompleted }
            .sorted { $0.distance > $1.distance }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(sortedParticipants.enumerated()), id: \.element.id) { index, participant in
                    LeaderboardRow(
                        rank: index + 1,
                        participant: participant
                    )
                }
            }
            .navigationTitle("Ranking ao vivo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Leaderboard Row
struct LeaderboardRow: View {
    let rank: Int
    let participant: EventParticipant

    var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .secondary
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            ZStack {
                Circle()
                    .fill(rank <= 3 ? rankColor.opacity(0.2) : Color.clear)
                    .frame(width: 36, height: 36)

                Text("\(rank)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(rank <= 3 ? rankColor : .secondary)
            }

            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
                .overlay {
                    Text(participant.userName.prefix(1))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(participant.userName)
                    .font(.system(size: 15, weight: .semibold))

                HStack(spacing: 12) {
                    Label(participant.formattedDistance, systemImage: "location.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)

                    Label(participant.formattedPace, systemImage: "speedometer")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Zone indicator
            if participant.isInsideZone {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.cyan)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#Preview {
    let mockEvent = RunEvent(
        name: "Sprint Challenge",
        eventDescription: "Desafio de velocidade",
        latitude: -8.0522,
        longitude: -34.8821,
        radius: 150,
        locationName: "Orla de Boa Viagem",
        startTime: Date().addingTimeInterval(-600),
        endTime: Date().addingTimeInterval(1200),
        eventType: "sprint",
        difficultyLevel: "hard",
        targetDistance: 3000,
        minParticipants: 2,
        maxParticipants: 15,
        participantCount: 5,
        status: "active",
        pointsReward: 250,
        createdBy: "mock-user"
    )

    let viewModel = RunEventViewModel()
    viewModel.participants = EventParticipant.mockParticipants(for: mockEvent.id.uuidString)

    return ActiveEventView(event: mockEvent, viewModel: viewModel)
}
