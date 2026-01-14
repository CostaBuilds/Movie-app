import SwiftUI

// MARK: - Mock Run Post Model
struct MockRunPost: Identifiable {
    let id = UUID()
    let userName: String
    let userPhoto: String?
    let subtitle: String
    let activityDays: String
    let duration: String
    let distance: String
    let pace: String
    let elevationGain: Int
    let route: String
    let likes: Int
    let comments: Int
    let isLiked: Bool
    let caption: String?
    let commenters: [String]
}

// MARK: - Run Post Card Component
struct RunPostCard: View {
    let post: MockRunPost
    @State private var isLiked: Bool
    @State private var likeCount: Int

    init(post: MockRunPost) {
        self.post = post
        _isLiked = State(initialValue: post.isLiked)
        _likeCount = State(initialValue: post.likes)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            postHeader

            // Stats Grid
            statsGrid

            // Map Preview
            mapPreview

            // Actions (Like, Comment, Share)
            actionsBar

            // Comments Preview
            if let caption = post.caption {
                commentsPreview(caption: caption)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    // MARK: - Post Header
    private var postHeader: some View {
        HStack(spacing: 12) {
            // User Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
                .overlay(
                    Text(post.userName.prefix(1))
                        .font(.headline)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(post.userName)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(post.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }

    // MARK: - Stats Grid
    private var statsGrid: some View {
        VStack(spacing: 0) {
            // Main Stats Row
            HStack(spacing: 0) {
                StatColumn(
                    label: "Atividade",
                    value: post.activityDays,
                    icon: "calendar",
                    iconColor: .secondary
                )

                StatColumn(
                    label: "Tempo",
                    value: post.duration,
                    icon: "clock",
                    iconColor: .secondary
                )

                StatColumn(
                    label: "Distância",
                    value: post.distance,
                    icon: "figure.run",
                    iconColor: .secondary
                )
            }

            Divider()
                .padding(.vertical, 8)

            // Secondary Stats Row
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "speedometer")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(post.pace)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "arrow.up")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(post.elevationGain)m")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    // MARK: - Map Preview
    private var mapPreview: some View {
        // Map Placeholder
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 200)

            VStack {
                Image(systemName: "map")
                    .font(.system(size: 50))
                    .foregroundColor(.gray.opacity(0.5))
                Text("Mapa da rota")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Actions Bar
    private var actionsBar: some View {
        HStack(spacing: 24) {
            // Like Button
            Button(action: toggleLike) {
                HStack(spacing: 6) {
                    Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .font(.title3)
                        .foregroundColor(isLiked ? .cyan : .secondary)

                    Text("\(likeCount)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }

            // Comment Button
            Button(action: {}) {
                HStack(spacing: 6) {
                    Image(systemName: "message")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Text("\(post.comments)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }

            Spacer()

            // Share Button
            Button(action: {}) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: - Comments Preview
    private func commentsPreview(caption: String) -> some View {
        HStack(spacing: -6) {
            // Avatares sobrepostos
            ForEach(0..<min(post.commenters.count, 3), id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .strokeBorder(Color(.systemBackground), lineWidth: 2)
                    )
                    .overlay(
                        Text(post.commenters[index].prefix(1))
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
            }

            Text(caption)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 10)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    // MARK: - Actions
    private func toggleLike() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isLiked.toggle()
            likeCount += isLiked ? 1 : -1
        }
    }
}

// MARK: - Stat Column Component
struct StatColumn: View {
    let label: String
    let value: String
    let icon: String
    let iconColor: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview {
    RunPostCard(post: MockRunPost(
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
    ))
    .padding()
}
