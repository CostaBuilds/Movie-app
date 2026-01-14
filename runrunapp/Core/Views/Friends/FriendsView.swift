import SwiftUI

struct FriendsView: View {
    @State private var selectedTab: FriendsTab = .activity
    @State private var showingStory = false
    @State private var selectedFriendStory: FriendStory?

    // Mock data para posts de amigos (usando RunPostCard)
    private let mockFriendsPosts = [
        MockRunPost(
            userName: "Edson Mel",
            userPhoto: nil,
            subtitle: "Corredor do maior dos salários",
            activityDays: "2h",
            duration: "45m",
            distance: "8.2km",
            pace: "5'28\"",
            elevationGain: 25,
            route: "Parque da Jaqueira",
            likes: 8,
            comments: 2,
            isLiked: false,
            caption: "Treino leve pela manhã!",
            commenters: ["João", "Maria"]
        ),
        MockRunPost(
            userName: "Juão Z",
            userPhoto: nil,
            subtitle: "Membro há 3 meses",
            activityDays: "5h",
            duration: "38m",
            distance: "5.5km",
            pace: "6'54\"",
            elevationGain: 15,
            route: "Orla de Boa Viagem",
            likes: 12,
            comments: 3,
            isLiked: true,
            caption: "Corrida ao pôr do sol 🌅",
            commenters: ["Ana", "Pedro", "Lucas"]
        ),
        MockRunPost(
            userName: "Vitor Brito",
            userPhoto: nil,
            subtitle: "Corredor profissional",
            activityDays: "1d",
            duration: "1h 5m",
            distance: "12.1km",
            pace: "5'22\"",
            elevationGain: 45,
            route: "Alto da Sé",
            likes: 24,
            comments: 5,
            isLiked: false,
            caption: "Preparação para a maratona!",
            commenters: ["Carlos", "Beatriz", "Felipe", "Marina"]
        ),
        MockRunPost(
            userName: "Marcelo Costa",
            userPhoto: nil,
            subtitle: "Runner entusiasta",
            activityDays: "3h",
            duration: "42m",
            distance: "6.8km",
            pace: "6'10\"",
            elevationGain: 20,
            route: "Ponte do Limoeiro",
            likes: 15,
            comments: 4,
            isLiked: false,
            caption: "Voltando ao ritmo depois do feriado",
            commenters: ["Juliana", "Roberto", "Sofia"]
        ),
    ]

    // Mock data para stories de amigos
    private let mockStories = [
        FriendStory(
            id: "1",
            friendName: "Edson Mel",
            hasNewActivity: true,
            activities: [
                StoryActivity(distance: "8.2 km", time: "45m", photoName: nil, timestamp: "2h atrás"),
                StoryActivity(distance: "5.1 km", time: "32m", photoName: nil, timestamp: "1d atrás")
            ]
        ),
        FriendStory(
            id: "2",
            friendName: "Juão Z",
            hasNewActivity: true,
            activities: [
                StoryActivity(distance: "5.5 km", time: "38m", photoName: nil, timestamp: "5h atrás")
            ]
        ),
        FriendStory(
            id: "3",
            friendName: "Vitor Brito",
            hasNewActivity: true,
            activities: [
                StoryActivity(distance: "12.1 km", time: "1h 5m", photoName: nil, timestamp: "1d atrás"),
                StoryActivity(distance: "10.5 km", time: "58m", photoName: nil, timestamp: "2d atrás")
            ]
        ),
        FriendStory(
            id: "4",
            friendName: "Marcelo Costa",
            hasNewActivity: false,
            activities: [
                StoryActivity(distance: "6.8 km", time: "42m", photoName: nil, timestamp: "3h atrás")
            ]
        ),
        FriendStory(
            id: "5",
            friendName: "Ana Silva",
            hasNewActivity: true,
            activities: [
                StoryActivity(distance: "7.3 km", time: "48m", photoName: nil, timestamp: "4h atrás")
            ]
        ),
    ]

    // Mock data para ranking de amigos
    private let mockFriends = [
        MockFriend(
            id: "1",
            name: "Vitor Brito",
            username: "@vitorbrito",
            photoURL: nil,
            totalKm: 312.6,
            weeklyKm: 42.8
        ),
        MockFriend(
            id: "2",
            name: "Edson Mel",
            username: "@edmelrun",
            photoURL: nil,
            totalKm: 245.8,
            weeklyKm: 32.5
        ),
        MockFriend(
            id: "3",
            name: "Juão Z",
            username: "@juaoz",
            photoURL: nil,
            totalKm: 198.3,
            weeklyKm: 28.1
        ),
        MockFriend(
            id: "4",
            name: "Marcelo Costa",
            username: "@marcelorun",
            photoURL: nil,
            totalKm: 187.2,
            weeklyKm: 25.3
        ),
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Stories Section no topo
                    storiesSection
                        .padding(.top, 8)

                    // Challenge Card
                    challengeCard
                        .padding(.horizontal)
                        .padding(.vertical, 12)

                    // Tab Selector
                    tabSelector

                    // Content
                    ScrollView {
                        VStack(spacing: 16) {
                            if selectedTab == .activity {
                                activityContent
                            } else {
                                rankingContent
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.bottom, 20)
                    }
                }
                .background(Color(.systemBackground))

                // Floating Action Button
                Button {
                    // Adicionar amigos
                } label: {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: .cyan.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingStory) {
                if let story = selectedFriendStory {
                    StoryViewer(story: story)
                }
            }
        }
    }

    // MARK: - Stories Section

    private var storiesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(mockStories) { story in
                    StoryCircle(story: story) {
                        selectedFriendStory = story
                        showingStory = true
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Challenge Card

    private var challengeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Desafio Semanal")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)

                    Text("Correr 50 km esta semana")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.85))
                }

                Spacer()

                // Amigos no desafio (avatares sobrepostos)
                HStack(spacing: -8) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)
                        .overlay {
                            Text("J")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .overlay {
                            Circle()
                                .stroke(Color.cyan, lineWidth: 2)
                        }

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)
                        .overlay {
                            Text("M")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .overlay {
                            Circle()
                                .stroke(Color.cyan, lineWidth: 2)
                        }

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)
                        .overlay {
                            Text("V")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .overlay {
                            Circle()
                                .stroke(Color.cyan, lineWidth: 2)
                        }

                    // Contador de mais amigos
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 28, height: 28)
                        .overlay {
                            Text("+5")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .overlay {
                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        }
                }

                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 4)
                        .frame(width: 44, height: 44)

                    Circle()
                        .trim(from: 0, to: 0.68) // 68% progress (34km/50km)
                        .stroke(
                            Color.white,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))

                    Text("68%")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                }
            }

            // Progress Bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("34 km")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)

                    Spacer()

                    Text("16 km restantes")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.85))
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 8)

                        // Progress
                        Capsule()
                            .fill(Color.white)
                            .frame(width: geometry.size.width * 0.68, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [.cyan, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(FriendsTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.snappy) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 8) {
                        Text(tab.title)
                            .font(.system(size: 15, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundStyle(selectedTab == tab ? .primary : .secondary)

                        if selectedTab == tab {
                            Capsule()
                                .fill(Color.cyan)
                                .frame(height: 3)
                                .matchedGeometryEffect(id: "friendsTab", in: tabNamespace)
                        } else {
                            Capsule()
                                .fill(Color.clear)
                                .frame(height: 3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .background(Color(.systemBackground))
    }

    @Namespace private var tabNamespace

    // MARK: - Activity Content

    private var activityContent: some View {
        VStack(spacing: 16) {
            ForEach(mockFriendsPosts) { post in
                RunPostCard(post: post)
                    .padding(.horizontal)
            }
        }
    }

    // MARK: - Ranking Content

    private var rankingContent: some View {
        VStack(spacing: 0) {
            // Período do ranking
            HStack {
                Text("Ranking Semanal")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)

                Spacer()

                Button {
                    // Alterar período
                } label: {
                    HStack(spacing: 4) {
                        Text("Esta semana")
                            .font(.system(size: 14))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(.cyan)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)

            // Ranking List
            VStack(spacing: 12) {
                ForEach(Array(mockFriends.sorted(by: { $0.weeklyKm > $1.weeklyKm }).enumerated()), id: \.element.id) { index, friend in
                    FriendRankingRow(
                        position: index + 1,
                        friend: friend,
                        isCurrentUser: false
                    ) {
                        // Navegar para perfil do amigo
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Friends Tab Enum

enum FriendsTab: CaseIterable {
    case activity
    case ranking

    var title: String {
        switch self {
        case .activity: return "Atividade"
        case .ranking: return "Ranking"
        }
    }
}

// MARK: - Mock Friend Model

struct MockFriend: Identifiable {
    let id: String
    let name: String
    let username: String
    let photoURL: String?
    let totalKm: Double
    let weeklyKm: Double
}

// MARK: - Friend Ranking Row

struct FriendRankingRow: View {
    let position: Int
    let friend: MockFriend
    let isCurrentUser: Bool
    let onTap: () -> Void

    var medalColor: Color? {
        switch position {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return nil
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Position/Medal
                ZStack {
                    if let color = medalColor {
                        Circle()
                            .fill(color)
                            .frame(width: 40, height: 40)

                        Text("\(position)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Text(String(format: "%02d.", position))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 40, alignment: .leading)
                    }
                }

                // Avatar
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isCurrentUser ? [.cyan, .blue] : [.orange, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(friend.name.prefix(1))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    )

                // Name and username
                VStack(alignment: .leading, spacing: 2) {
                    Text(friend.name)
                        .font(.system(size: 15, weight: isCurrentUser ? .semibold : .regular))
                        .foregroundStyle(.primary)

                    Text(friend.username)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Distance
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.1f km", friend.weeklyKm))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text("\(String(format: "%.0f", friend.totalKm)) km total")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isCurrentUser ? Color.cyan.opacity(0.1) : Color.clear)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Story Models

struct FriendStory: Identifiable {
    let id: String
    let friendName: String
    let hasNewActivity: Bool
    let activities: [StoryActivity]
}

struct StoryActivity: Identifiable {
    let id = UUID()
    let distance: String
    let time: String
    let photoName: String?
    let timestamp: String
}

// MARK: - Story Circle Component

struct StoryCircle: View {
    let story: FriendStory
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    // Gradient border para indicar nova atividade
                    if story.hasNewActivity {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 74, height: 74)
                    } else {
                        Circle()
                            .stroke(Color(.systemGray4), lineWidth: 2)
                            .frame(width: 74, height: 74)
                    }

                    // Avatar
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 68, height: 68)
                        .overlay(
                            Text(story.friendName.prefix(1))
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(.white)
                        )
                }

                Text(story.friendName.split(separator: " ").first ?? "")
                    .font(.caption2)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .frame(width: 80)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Story Viewer

struct StoryViewer: View {
    let story: FriendStory
    @Environment(\.dismiss) private var dismiss
    @State private var currentActivityIndex = 0
    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack(alignment: .top) {
            // Background
            Color.black
                .ignoresSafeArea()

            if !story.activities.isEmpty {
                VStack(spacing: 0) {
                    // Progress bars
                    HStack(spacing: 4) {
                        ForEach(0..<story.activities.count, id: \.self) { index in
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.3))

                                    Capsule()
                                        .fill(Color.white)
                                        .frame(width: index == currentActivityIndex ? progress * geometry.size.width : (index < currentActivityIndex ? geometry.size.width : 0))
                                }
                            }
                            .frame(height: 3)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 60)

                    // Header
                    HStack(spacing: 12) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(story.friendName.prefix(1))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(story.friendName)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)

                            Text(story.activities[currentActivityIndex].timestamp)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)

                    Spacer()

                    // Activity Content
                    VStack(spacing: 20) {
                        // Photo placeholder or map
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 400)

                            VStack(spacing: 12) {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.white.opacity(0.5))

                                Text("Foto da corrida")
                                    .font(.title3)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                        .padding(.horizontal, 20)

                        // Stats
                        HStack(spacing: 40) {
                            VStack(spacing: 4) {
                                Text(story.activities[currentActivityIndex].distance)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(.white)

                                Text("Distância")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                            }

                            VStack(spacing: 4) {
                                Text(story.activities[currentActivityIndex].time)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(.white)

                                Text("Tempo")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
            }

            // Tap areas for navigation
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if currentActivityIndex > 0 {
                            currentActivityIndex -= 1
                            progress = 0
                        } else {
                            dismiss()
                        }
                    }

                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if currentActivityIndex < story.activities.count - 1 {
                            currentActivityIndex += 1
                            progress = 0
                        } else {
                            dismiss()
                        }
                    }
            }
        }
        .onAppear {
            startProgress()
        }
    }

    private func startProgress() {
        progress = 0
        withAnimation(.linear(duration: 3)) {
            progress = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if currentActivityIndex < story.activities.count - 1 {
                currentActivityIndex += 1
                startProgress()
            } else {
                dismiss()
            }
        }
    }
}

#Preview {
    FriendsView()
}
