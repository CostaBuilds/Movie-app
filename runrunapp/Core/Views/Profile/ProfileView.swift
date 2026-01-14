import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ProfileViewModel()

    @State private var showingRunHistory = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background simples e clean
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // Header com foto e informações básicas
                        profileHeader

                        // Stats principais em destaque
                        mainStatsSection

                        // Grid de estatísticas secundárias
                        secondaryStatsGrid

                        // Corridas recentes
                        recentRunsSection

                        // Próximos desafios (opcional)
                        upcomingChallengesSection

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // Voltar ou menu
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                }
            }
            .sheet(isPresented: $showingRunHistory) {
                RunHistoryView(runs: viewModel.allRuns, viewModel: viewModel)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .onAppear {
                viewModel.setup(with: modelContext)
            }
        }
    }

    // MARK: - Components

    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar com borda ciano
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 120, height: 120)

                Circle()
                    .stroke(
                        Color.cyan,
                        lineWidth: 4
                    )
                    .frame(width: 120, height: 120)

                // Placeholder para foto do perfil
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.secondary)
            }

            // Nome e localização
            VStack(spacing: 4) {
                Text(viewModel.currentUser?.name ?? "Costa")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Recife | PE")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 12)
    }

    private var mainStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Badge professional
            HStack {
                Text("JANEIRO")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)

                Spacer()
            }

            // KM total com percentil
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(viewModel.totalKmFormatted)
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(.primary)

                Text("KM")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                    .offset(y: -4)

                // Badge percentil
                ZStack {
                    Circle()
                        .fill(Color(hex: "00A8E8"))
                        .frame(width: 32, height: 32)

                    Text("\(viewModel.percentileRank)%")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                }
                .offset(y: -4)

                Spacer()
            }

            // Subtítulo
            Text("Acima da média")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 4)
    }

    private var secondaryStatsGrid: some View {
        HStack(spacing: 0) {
            StatGridItem(
                title: "Calorias queimadas",
                value: viewModel.totalCaloriesFormatted,
                unit: "Kcal"
            )

            Divider()
                .frame(height: 60)
                .background(Color(.separator))

            StatGridItem(
                title: "Tempo de corrida",
                value: formatTotalTime(),
                unit: "Horas"
            )

            Divider()
                .frame(height: 60)
                .background(Color(.separator))

            StatGridItem(
                title: "Frequência cardíaca",
                value: "100",
                unit: "bpm"
            )
        }
        .padding(.vertical, 20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private var recentRunsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Corridas recentes")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)

                Spacer()
            }

            if viewModel.allRuns.isEmpty {
                emptyRunsState
            } else {
                ForEach(viewModel.allRuns.prefix(3), id: \.id) { run in
                    CleanRunCard(run: run) {
                        // Navegar para detalhe
                    }
                }

                // Ver todas
                Button {
                    showingRunHistory = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Ver todas as corridas")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.primary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                }
            }
        }
    }

    private var upcomingChallengesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Próximos desafios")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"], id: \.self) { day in
                        ChallengeDayCard(day: day, isCompleted: false)
                    }
                }
            }
        }
    }

    private var emptyRunsState: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Nenhuma corrida registrada")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    // MARK: - Helpers

    private func formatTotalTime() -> String {
        guard let user = viewModel.currentUser else { return "0" }
        let hours = Int(user.totalDuration) / 3600
        return "\(hours)"
    }
}

// MARK: - Supporting Views

struct StatGridItem: View {
    let title: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)

                Text(unit)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
    }
}

struct CleanRunCard: View {
    let run: Run
    let onTap: () -> Void

    @State private var routeImage: UIImage?

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Thumbnail do mapa
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .frame(width: 60, height: 60)

                    if let image = routeImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Image(systemName: "map")
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary)
                    }
                }

                // Info da corrida
                VStack(alignment: .leading, spacing: 4) {
                    Text(run.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)

                    Text(String(format: "%.2f km", run.distanceInKm))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)

                    HStack(spacing: 8) {
                        Text("\(formatCalories(run.calories ?? 0)) kcal")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)

                        Text("•")
                            .foregroundStyle(.secondary)

                        Text("\(run.paceFormatted)/km")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .onAppear {
            loadMockRouteImage()
        }
    }

    private func loadMockRouteImage() {
        // Aqui você pode implementar a lógica para gerar uma imagem da rota
        // Por enquanto, deixamos vazio para mostrar o ícone de mapa
    }

    private func formatCalories(_ calories: Int) -> String {
        if calories >= 1000 {
            return String(format: "%.0f", Double(calories))
        }
        return "\(calories)"
    }
}

struct ChallengeDayCard: View {
    let day: String
    let isCompleted: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(day)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(isCompleted ? .primary : .secondary)

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isCompleted ? Color(hex: "C8FF00") : Color(.separator),
                        lineWidth: 2
                    )
                    .frame(width: 44, height: 44)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(hex: "C8FF00"))
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [User.self, Run.self, RunEvent.self, EventParticipant.self], inMemory: true)
}
