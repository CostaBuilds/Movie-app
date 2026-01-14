import SwiftUI

struct GroupDetailView: View {
    let group: Group
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Header
            groupHeader

            // Tab Picker
            tabPicker

            // Tab Content
            TabView(selection: $selectedTab) {
                ScrollView {
                    InfoTabView(group: group)
                }
                .tag(0)

                ScrollView {
                    MembersTabView(group: group)
                }
                .tag(1)

                ScrollView {
                    FeedTabView(group: group)
                }
                .tag(2)

                ScrollView {
                    LeaderboardTabView(group: group)
                }
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Group Header
    private var groupHeader: some View {
        VStack(spacing: 16) {
            // Group Photo
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "figure.run")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                )

            // Group Info
            VStack(spacing: 8) {
                Text(group.name)
                    .font(.title2)
                    .fontWeight(.bold)

                HStack(spacing: 16) {
                    Label("\(group.memberCount)", systemImage: "person.2.fill")
                    Label("\(group.city), \(group.state)", systemImage: "location.fill")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                // Public/Private Badge
                HStack(spacing: 4) {
                    Image(systemName: group.isPublic ? "globe" : "lock.fill")
                    Text(group.isPublic ? "Público" : "Privado")
                }
                .font(.caption)
                .foregroundColor(group.isPublic ? .cyan : .orange)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(group.isPublic ? Color.cyan.opacity(0.1) : Color.orange.opacity(0.1))
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }

    // MARK: - Tab Picker
    private var tabPicker: some View {
        HStack(spacing: 0) {
            TabButton(title: "Info", isSelected: selectedTab == 0) {
                withAnimation { selectedTab = 0 }
            }

            TabButton(title: "Membros", isSelected: selectedTab == 1) {
                withAnimation { selectedTab = 1 }
            }

            TabButton(title: "Feed", isSelected: selectedTab == 2) {
                withAnimation { selectedTab = 2 }
            }

            TabButton(title: "Ranking", isSelected: selectedTab == 3) {
                withAnimation { selectedTab = 3 }
            }
        }
        .background(Color(.secondarySystemBackground))
    }
}

// MARK: - Tab Button Component
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .cyan : .secondary)

                Rectangle()
                    .fill(isSelected ? Color.cyan : Color.clear)
                    .frame(height: 3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

// MARK: - Info Tab
struct InfoTabView: View {
    let group: Group
    @State private var showAllMembers = false

    // Mock members (same as MembersTabView)
    private let mockMembers = [
        GroupMember(userId: "1", userName: "Juão", userPhotoURL: nil, joinedAt: Date(), role: .admin),
        GroupMember(userId: "2", userName: "Edson Mel", userPhotoURL: nil, joinedAt: Date().addingTimeInterval(-86400), role: .member),
        GroupMember(userId: "3", userName: "Vitor Brito", userPhotoURL: nil, joinedAt: Date().addingTimeInterval(-172800), role: .member),
        GroupMember(userId: "4", userName: "AK Trovão", userPhotoURL: nil, joinedAt: Date().addingTimeInterval(-259200), role: .member),
        GroupMember(userId: "5", userName: "Marcelo Costa", userPhotoURL: nil, joinedAt: Date().addingTimeInterval(-345600), role: .member),
        GroupMember(userId: "6", userName: "Ana Silva", userPhotoURL: nil, joinedAt: Date().addingTimeInterval(-432000), role: .member),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Members Preview
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    // Overlapping avatars
                    HStack(spacing: -10) {
                        ForEach(mockMembers.prefix(5)) { member in
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text(member.userName.prefix(1))
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color(.systemBackground), lineWidth: 2)
                                )
                        }
                    }

                    // Member count
                    Text("\(mockMembers.count) membros")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    Spacer()

                    // Ver todos button
                    Button {
                        showAllMembers = true
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.cyan)
                    }
                }
                .padding(.vertical, 16)

                Divider()
            }

            // Description
            VStack(alignment: .leading, spacing: 12) {
                Text("Sobre")
                    .font(.headline)

                Text(group.description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // Stats
            VStack(alignment: .leading, spacing: 12) {
                Text("Estatísticas")
                    .font(.headline)

                HStack(spacing: 20) {
                    StatBox(
                        icon: "person.2.fill",
                        value: "\(group.memberCount)",
                        label: "Membros"
                    )

                    StatBox(
                        icon: "figure.run",
                        value: "0",
                        label: "Corridas"
                    )

                    StatBox(
                        icon: "calendar",
                        value: group.createdAt.asRelativeDate,
                        label: "Criado"
                    )
                }
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // Admin Info
            VStack(alignment: .leading, spacing: 12) {
                Text("Administração")
                    .font(.headline)

                HStack {
                    Image(systemName: "star.circle.fill")
                        .foregroundColor(.yellow)
                    Text("Criado por: User #\(group.createdBy.prefix(8))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // Activities Feed
            VStack(alignment: .leading, spacing: 16) {
                Text("Atividades Recentes")
                    .font(.headline)
                    .padding(.top, 8)

                ForEach(mockActivities) { activity in
                    GroupActivityCard(activity: activity)
                }
            }
            .padding(.vertical, 16)

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showAllMembers) {
            AllMembersSheet(members: mockMembers)
        }
    }

    // Mock activities
    private let mockActivities = [
        GroupActivity(
            id: "1",
            type: .run,
            title: "Corrida Matinal no Parque",
            date: Date().addingTimeInterval(-86400 * 2),
            participants: 8,
            distance: 10.5,
            duration: 3600,
            photoName: nil,
            description: "Treino coletivo com foco em ritmo"
        ),
        GroupActivity(
            id: "2",
            type: .event,
            title: "Maratona Recife 2025",
            date: Date().addingTimeInterval(-86400 * 7),
            participants: 15,
            distance: 42.2,
            duration: nil,
            photoName: nil,
            description: "Participação oficial do grupo na maratona"
        ),
        GroupActivity(
            id: "3",
            type: .run,
            title: "Treino de Velocidade",
            date: Date().addingTimeInterval(-86400 * 14),
            participants: 6,
            distance: 8.0,
            duration: 2700,
            photoName: nil,
            description: "Intervalados na pista de atletismo"
        )
    ]
}

// MARK: - Group Activity Model
struct GroupActivity: Identifiable {
    let id: String
    let type: ActivityType
    let title: String
    let date: Date
    let participants: Int
    let distance: Double?
    let duration: TimeInterval?
    let photoName: String?
    let description: String

    enum ActivityType {
        case run
        case event
    }
}

// MARK: - Group Activity Card
struct GroupActivityCard: View {
    let activity: GroupActivity

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image placeholder
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: activity.type == .run ? [.cyan.opacity(0.3), .blue.opacity(0.5)] : [.orange.opacity(0.3), .pink.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)

                Image(systemName: activity.type == .run ? "figure.run" : "calendar.badge.clock")
                    .font(.system(size: 60))
                    .foregroundStyle(.white.opacity(0.4))
            }

            // Content
            VStack(alignment: .leading, spacing: 12) {
                // Title and date
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text(activity.date.formatted(date: .long, time: .omitted))
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                // Description
                Text(activity.description)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                // Stats
                HStack(spacing: 16) {
                    // Participants
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 13))
                        Text("\(activity.participants)")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(.cyan)

                    if let distance = activity.distance {
                        HStack(spacing: 6) {
                            Image(systemName: "figure.run")
                                .font(.system(size: 13))
                            Text(String(format: "%.1f km", distance))
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundStyle(.secondary)
                    }

                    if let duration = activity.duration {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 13))
                            Text(formatDuration(duration))
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
            }
            .padding(16)
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    }

// MARK: - All Members Sheet
struct AllMembersSheet: View {
    let members: [GroupMember]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(members) { member in
                        MemberRow(member: member)
                    }
                }
                .padding()
            }
            .navigationTitle("Membros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                    }
                }
            }
        }
    }
}

// MARK: - Members Tab
struct MembersTabView: View {
    let group: Group

    // Mock members
    private let mockMembers = [
        GroupMember(userId: "1", userName: "Juão", userPhotoURL: nil, joinedAt: Date(), role: .admin),
        GroupMember(userId: "2", userName: "Edson Mel", userPhotoURL: nil, joinedAt: Date().addingTimeInterval(-86400), role: .member),
        GroupMember(userId: "3", userName: "Vitor Brito", userPhotoURL: nil, joinedAt: Date().addingTimeInterval(-172800), role: .member),
        GroupMember(userId: "4", userName: "AK Trovão", userPhotoURL: nil, joinedAt: Date().addingTimeInterval(-259200), role: .member),
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Member Count Header
            HStack {
                Text("\(mockMembers.count) Membros")
                    .font(.headline)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.cyan)
                }
            }
            .padding(.horizontal)
            .padding(.top)

            // Members List
            VStack(spacing: 12) {
                ForEach(mockMembers) { member in
                    MemberRow(member: member)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
    }
}

// MARK: - Member Row Component
struct MemberRow: View {
    let member: GroupMember

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .overlay(
                    Text(member.userName.prefix(1))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(member.userName)
                        .font(.body)
                        .fontWeight(.medium)

                    if member.role == .admin {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }

                Text("Entrou \(member.joinedAt.asRelativeDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Feed Tab
struct FeedTabView: View {
    let group: Group

    var body: some View {
        VStack(spacing: 16) {
            // Empty State
            VStack(spacing: 16) {
                Image(systemName: "newspaper")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)

                Text("Nenhuma corrida compartilhada ainda")
                    .font(.headline)

                Text("Seja o primeiro a compartilhar uma corrida neste grupo!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(40)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
            .padding()

            Spacer()
        }
        .padding(.top)
    }
}

// MARK: - Leaderboard Tab
struct LeaderboardTabView: View {
    let group: Group

    // Mock leaderboard data
    private let mockLeaders = [
        LeaderboardEntry(rank: 1, userId: "1", userName: "João Silva", distance: 42500, runs: 8),
        LeaderboardEntry(rank: 2, userId: "2", userName: "Maria Santos", distance: 38200, runs: 7),
        LeaderboardEntry(rank: 3, userId: "3", userName: "Pedro Costa", distance: 35100, runs: 6),
        LeaderboardEntry(rank: 4, userId: "4", userName: "Ana Oliveira", distance: 28900, runs: 5),
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Period Selector
            HStack {
                Text("Esta Semana")
                    .font(.headline)

                Spacer()

                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Filtrar")
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .font(.subheadline)
                    .foregroundColor(.cyan)
                }
            }
            .padding(.horizontal)
            .padding(.top)

            // Leaderboard List
            VStack(spacing: 12) {
                ForEach(mockLeaders) { leader in
                    LeaderboardRow(entry: leader)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
    }
}

// MARK: - Leaderboard Entry Model
struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let rank: Int
    let userId: String
    let userName: String
    let distance: Double // em metros
    let runs: Int
}

// MARK: - Leaderboard Row Component
struct LeaderboardRow: View {
    let entry: LeaderboardEntry

    var medalColor: Color? {
        switch entry.rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return nil
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Rank Badge
            ZStack {
                if let color = medalColor {
                    Circle()
                        .fill(color)
                        .frame(width: 40, height: 40)

                    Image(systemName: "medal.fill")
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 40, height: 40)

                    Text("#\(entry.rank)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.userName)
                    .font(.body)
                    .fontWeight(.medium)

                HStack(spacing: 12) {
                    Label(String(format: "%.1f km", entry.distance / 1000), systemImage: "figure.run")
                    Label("\(entry.runs) corridas", systemImage: "number")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()

            if entry.rank <= 3 {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(entry.rank <= 3 ? Color.cyan.opacity(0.05) : Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Stat Box Component
struct StatBox: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.cyan)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        GroupDetailView(group: Group(
            id: "1",
            name: "Run Recife",
            description: "Corridas semanais em Recife toda quarta 19h na orla de Boa Viagem",
            city: "Recife",
            state: "PE",
            createdBy: "user123",
            isPublic: true
        ))
    }
}
