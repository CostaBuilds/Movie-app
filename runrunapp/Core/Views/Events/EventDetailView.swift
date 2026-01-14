import SwiftUI
import MapKit

// MARK: - Event Detail View
struct EventDetailView: View {
    let event: RunEvent
    @ObservedObject var viewModel: RunEventViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero section with map
                    heroSection

                    // Event info
                    eventInfoSection

                    // Participants
                    participantsSection

                    // Rewards
                    rewardsSection

                    // Join button
                    if !event.isCompleted {
                        joinButton
                    }
                }
                .padding(.bottom, 30)
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Map preview
            Map(initialPosition: .region(
                MKCoordinateRegion(
                    center: event.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )) {
                Annotation(event.name, coordinate: event.coordinate) {
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: 40, height: 40)
                        .overlay {
                            Text(event.eventTypeEmoji)
                                .font(.system(size: 20))
                        }
                }

                MapCircle(center: event.coordinate, radius: event.radius)
                    .foregroundStyle(Color.cyan.opacity(0.2))
                    .stroke(Color.cyan, lineWidth: 2)
            }
            .frame(height: 250)
            .disabled(true)

            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 250)

            // Title
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(event.eventTypeEmoji)
                        .font(.system(size: 32))

                    Text(event.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text(event.locationName)
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.9))

                // Status badge
                if event.isActive {
                    Label("Acontecendo agora", systemImage: "dot.radiowaves.left.and.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.cyan)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }

    // MARK: - Event Info Section
    private var eventInfoSection: some View {
        VStack(spacing: 16) {
            // Description
            Text(event.description)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            // Stats grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                InfoCard(
                    icon: "clock.fill",
                    title: "Horário",
                    value: event.formattedTimeRange
                )

                InfoCard(
                    icon: "timer",
                    title: "Duração",
                    value: event.formattedDuration
                )

                InfoCard(
                    icon: "figure.run",
                    title: "Participantes",
                    value: "\(event.participantCount)/\(event.maxParticipants ?? 99)"
                )

                if let targetDistance = event.targetDistance {
                    InfoCard(
                        icon: "location.fill",
                        title: "Meta",
                        value: String(format: "%.1f km", targetDistance / 1000)
                    )
                }

                InfoCard(
                    icon: "chart.bar.fill",
                    title: "Dificuldade",
                    value: event.difficultyLevel.capitalized,
                    color: Color(event.difficultyColor)
                )

                InfoCard(
                    icon: "flame.fill",
                    title: "Pontos",
                    value: "\(event.pointsReward)",
                    color: Color(hex: "C8FF00")
                )
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Participants Section
    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Participantes")
                    .font(.system(size: 18, weight: .bold))

                Spacer()

                Text("\(viewModel.participants.count)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            if viewModel.participants.isEmpty {
                Text("Seja o primeiro a participar!")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.participants, id: \.id) { participant in
                            ParticipantCard(participant: participant)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Rewards Section
    private var rewardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recompensas")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal)

            VStack(spacing: 12) {
                RewardRow(
                    icon: "star.fill",
                    title: "Participação",
                    value: "+\(event.pointsReward) pontos",
                    color: Color(hex: "C8FF00")
                )

                RewardRow(
                    icon: "target",
                    title: "Completar meta",
                    value: "+50 pontos bônus",
                    color: .green
                )

                RewardRow(
                    icon: "trophy.fill",
                    title: "Top 3",
                    value: "+100 pontos extras",
                    color: .orange
                )
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Join Button
    private var joinButton: some View {
        VStack(spacing: 12) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
            }

            Button {
                viewModel.joinEvent(event)
            } label: {
                HStack {
                    Image(systemName: "figure.run.circle.fill")
                        .font(.system(size: 20))

                    Text(event.isActive ? "Entrar agora" : "Participar")
                        .font(.system(size: 17, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(event.isFull ? Color.gray : Color.cyan)
                .foregroundStyle(.black)
                .cornerRadius(12)
            }
            .disabled(event.isFull)
            .padding(.horizontal)

            if event.isFull {
                Text("Evento lotado")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    var color: Color = .cyan

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 14, weight: .bold))
                .lineLimit(1)

            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Participant Card
struct ParticipantCard: View {
    let participant: EventParticipant

    var body: some View {
        VStack(spacing: 8) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .overlay {
                    Text(participant.userName.prefix(1))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }

            // Name
            Text(participant.userName)
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(1)

            // Status/Stats
            if participant.isActive {
                VStack(spacing: 2) {
                    Text(participant.formattedDistance)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.cyan)

                    if let rank = participant.currentRank {
                        Text("#\(rank)")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text("Aguardando")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 80)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Reward Row
struct RewardRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))

                Text(value)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview
#Preview {
    let mockEvent = RunEvent(
        name: "Corrida do Amanhecer",
        description: "Corrida matinal no parque. Venha correr com a gente!",
        latitude: -8.0522,
        longitude: -34.8821,
        radius: 150,
        locationName: "Parque da Boa Vista",
        startTime: Date(),
        endTime: Date().addingTimeInterval(3600),
        eventType: "social",
        difficultyLevel: "medium",
        targetDistance: 5000,
        minParticipants: 3,
        maxParticipants: 20,
        participantCount: 8,
        status: "active",
        pointsReward: 150,
        createdBy: "mock-user"
    )

    EventDetailView(event: mockEvent, viewModel: RunEventViewModel())
}
