import SwiftUI

struct FeedView: View {
    // Mock data
    private let mockPosts = [
        MockRunPost(
            userName: "Edson Mel",
            userPhoto: nil,
            subtitle: "Corredor do maior dos salários",
            activityDays: "3d",
            duration: "2h 23m",
            distance: "10.2km",
            pace: "6'30\"",
            elevationGain: 30,
            route: "Percurso anterior",
            likes: 12,
            comments: 3,
            isLiked: false,
            caption: "Tá correndo muito Ed!",
            commenters: ["João", "Maria", "Pedro"]
        ),
        MockRunPost(
            userName: "Juão",
            userPhoto: nil,
            subtitle: "Membro há 2 semanas",
            activityDays: "1d",
            duration: "45m",
            distance: "8.5km",
            pace: "5'18\"",
            elevationGain: 15,
            route: "Orla de Boa Viagem",
            likes: 8,
            comments: 2,
            isLiked: true,
            caption: "Treino leve hoje 🏃",
            commenters: ["Ana", "Carlos"]
        ),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats Card (Aumento de distância)
                    statsCard

                    // Featured Group
                    featuredGroupSection

                    // Nearby Groups
                    nearbyGroupsSection

                    // Weekly Leaderboard
                    weeklyLeaderboardSection

                    // Feed Posts
                    feedPostsSection
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image("moovin_logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 28)

                        Text("Moovin'")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Notificações
                    } label: {
                        Image(systemName: "bell")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
        }
    }

    // MARK: - Stats Card

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.black)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("Aumento de distância:")
                            .font(.system(size: 15))
                            .foregroundStyle(.black)

                        Text("22%")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color.black)
                    }

                    Text("Ontem você correu: 12km")
                        .font(.system(size: 13))
                        .foregroundStyle(.black.opacity(0.7))
                }

                Spacer()
            }

            // Mini stats
            HStack(spacing: 0) {
                MiniStatBox(title: "Calorias", value: "2087", unit: "Kcal", isDark: false)

                Divider()
                    .background(Color.black.opacity(0.2))
                    .frame(height: 50)

                MiniStatBox(title: "Tempo", value: "70", unit: "Horas", isDark: false)

                Divider()
                    .background(Color.black.opacity(0.2))
                    .frame(height: 50)

                MiniStatBox(title: "Freq. cardíaca", value: "100", unit: "bpm", isDark: false)
            }
        }
        .padding()
        .background(Color.cyan)
        .cornerRadius(16)
        .padding(.horizontal)
    }

    // MARK: - Featured Group

    private var featuredGroupSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Corrida em destaque")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)

                Spacer()

                Button("Veja mais") {
                    // Ação
                }
                .font(.system(size: 14))
                .foregroundStyle(.cyan)
            }
            .padding(.horizontal)

            FeaturedGroupCard(
                groupName: "Recife Sunset Runners",
                members: "8 KM",
                imageName: "group_sunset"
            )
        }
    }

    // MARK: - Nearby Groups

    private var nearbyGroupsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Próximas de você")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    NearbyGroupCard(
                        groupName: "Corredores do Cais",
                        distance: "8 KM",
                        imageName: "group_porto"
                    )

                    NearbyGroupCard(
                        groupName: "São Lourenço da Mata",
                        distance: "5 KM",
                        imageName: "group_leme"
                    )
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Weekly Leaderboard

    private var weeklyLeaderboardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Classificação semanal")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal)

            VStack(spacing: 12) {
                FeedLeaderboardRow(
                    position: 1,
                    userName: "Vitor Brito",
                    distance: "105,15 km"
                )

                FeedLeaderboardRow(
                    position: 2,
                    userName: "Juão Z",
                    distance: "103,5 km"
                )

                FeedLeaderboardRow(
                    position: 3,
                    userName: "Marcelo Costa",
                    distance: "100,2 km"
                )
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Feed Posts

    private var feedPostsSection: some View {
        VStack(spacing: 16) {
            ForEach(mockPosts) { post in
                RunPostCard(post: post)
                    .padding(.horizontal)
            }
        }
    }
}

// MARK: - Mini Stat Box

struct MiniStatBox: View {
    let title: String
    let value: String
    let unit: String
    var isDark: Bool = true

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(isDark ? .secondary : Color.black.opacity(0.7))
                .lineLimit(1)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(isDark ? .primary : Color.black)

                Text(unit)
                    .font(.system(size: 10))
                    .foregroundStyle(isDark ? .secondary : Color.black.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Featured Group Card

struct FeaturedGroupCard: View {
    let groupName: String
    let members: String
    let imageName: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image placeholder
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 180)
                .overlay {
                    Image(systemName: "figure.run")
                        .font(.system(size: 60))
                        .foregroundStyle(.white.opacity(0.3))
                }

            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "figure.run.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)

                        Text(groupName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color(hex: "C8FF00"))
                }

                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 12))
                        Text(members)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.3))
                    .cornerRadius(8)

                    Spacer()

                    Button {} label: {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(width: 36, height: 36)
                            .background(Color(hex: "C8FF00"))
                            .clipShape(Circle())
                    }
                }
            }
            .padding()
        }
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Nearby Group Card

struct NearbyGroupCard: View {
    let groupName: String
    let distance: String
    let imageName: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.cyan.opacity(0.3), .blue.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 160)
                .overlay {
                    Image(systemName: "figure.run")
                        .font(.system(size: 50))
                        .foregroundStyle(.white.opacity(0.3))
                }

            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "figure.run.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)

                    Text(groupName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }

                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 11))
                        Text(distance)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.3))
                    .cornerRadius(6)

                    Spacer()

                    Button {} label: {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(width: 30, height: 30)
                            .background(Color(hex: "C8FF00"))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(12)
        }
        .frame(width: 200)
        .cornerRadius(16)
    }
}

// MARK: - Feed Leaderboard Row

struct FeedLeaderboardRow: View {
    let position: Int
    let userName: String
    let distance: String

    var body: some View {
        HStack(spacing: 12) {
            // Position
            Text(String(format: "%02d.", position))
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .leading)

            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.orange, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
                .overlay {
                    Text(userName.prefix(1))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }

            // Name
            Text(userName)
                .font(.system(size: 15))
                .foregroundStyle(.primary)

            Spacer()

            // Distance
            Text(distance)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    FeedView()
}
