import Foundation
import SwiftData
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var allRuns: [Run] = []
    @Published var highlightedRuns: [Run] = []

    // Estatísticas calculadas
    @Published var totalKilometers: Double = 0
    @Published var averagePace: Double = 0
    @Published var totalCalories: Int = 0
    @Published var averageDistance: Double = 0
    @Published var percentileRank: Int = 12 // Percentil de performance

    private var modelContext: ModelContext?

    init() {}

    func setup(with context: ModelContext) {
        self.modelContext = context
        loadData()
    }

    func loadData() {
        guard let context = modelContext else { return }

        // Carregar usuário (mock por enquanto - até ter auth)
        let userDescriptor = FetchDescriptor<User>()
        currentUser = try? context.fetch(userDescriptor).first

        // Se não houver usuário, criar um mock
        if currentUser == nil {
            let mockUser = User(
                firebaseUID: "mock-uid",
                name: "Edson Honey",
                email: "edmel@gmail.com",
                username: "edmelrun"
            )
            context.insert(mockUser)
            currentUser = mockUser
        }

        // Carregar todas as corridas do usuário
        if let userId = currentUser?.firebaseUID {
            let runsDescriptor = FetchDescriptor<Run>(
                predicate: #Predicate { $0.userId == userId },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            allRuns = (try? context.fetch(runsDescriptor)) ?? []

            // Se não houver corridas, criar dados mock
            if allRuns.isEmpty {
                createMockRuns(for: userId, in: context)
                allRuns = (try? context.fetch(runsDescriptor)) ?? []
            }
        }

        // Filtrar corridas destacadas
        highlightedRuns = allRuns.filter { $0.isHighlighted }

        // Calcular estatísticas
        calculateStatistics()
    }

    private func calculateStatistics() {
        guard !allRuns.isEmpty else {
            totalKilometers = 0
            averagePace = 0
            totalCalories = 0
            averageDistance = 0
            return
        }

        // Total de km
        let totalMeters = allRuns.reduce(0) { $0 + $1.distance }
        totalKilometers = totalMeters / 1000.0

        // Pace médio (média ponderada pela distância)
        let totalPaceWeighted = allRuns.reduce(0.0) { $0 + ($1.averagePace * $1.distance) }
        averagePace = totalPaceWeighted / totalMeters

        // Total de calorias
        totalCalories = allRuns.reduce(0) { $0 + ($1.calories ?? 0) }

        // Distância média por corrida
        averageDistance = totalMeters / Double(allRuns.count) / 1000.0

        // Calcular percentil (mock baseado em total de km)
        // Quanto mais km, melhor o percentil
        percentileRank = calculatePercentile(totalKm: totalKilometers)
    }

    private func calculatePercentile(totalKm: Double) -> Int {
        // Simulação de percentil baseado em benchmarks
        // < 50km = bottom 50%
        // 50-100km = top 30%
        // 100-200km = top 20%
        // 200-500km = top 10%
        // > 500km = top 5%

        if totalKm < 50 {
            return 50
        } else if totalKm < 100 {
            return 30
        } else if totalKm < 200 {
            return 20
        } else if totalKm < 500 {
            return 10
        } else {
            return 5
        }
    }

    func toggleHighlight(for run: Run) {
        run.isHighlighted.toggle()

        // Limitar a 5 corridas destacadas
        let highlighted = allRuns.filter { $0.isHighlighted }
        if highlighted.count > 5 {
            // Remover a mais antiga
            if let oldest = highlighted.sorted(by: { $0.date < $1.date }).first {
                oldest.isHighlighted = false
            }
        }

        // Atualizar lista
        highlightedRuns = allRuns.filter { $0.isHighlighted }

        // Salvar contexto
        try? modelContext?.save()
    }

    // Formatar para exibição
    var totalKmFormatted: String {
        String(format: "%.0f", totalKilometers)
    }

    var averagePaceFormatted: String {
        let minutes = Int(averagePace)
        let seconds = Int((averagePace - Double(minutes)) * 60)
        return String(format: "%d:%02d", minutes, seconds)
    }

    var totalCaloriesFormatted: String {
        String(format: "%d", totalCalories)
    }

    var averageDistanceFormatted: String {
        String(format: "%.1f", averageDistance)
    }

    var percentileLabel: String {
        "Top \(percentileRank)%"
    }

    // MARK: - Mock Data

    private func createMockRuns(for userId: String, in context: ModelContext) {
        let calendar = Calendar.current
        let now = Date()

        // Criar 10 corridas mock dos últimos 30 dias
        let mockRunsData: [(daysAgo: Int, distance: Double, duration: TimeInterval, pace: Double, highlighted: Bool)] = [
            (1, 10120, 3420, 5.6, true),   // Ontem - 10.12km - Destacada
            (3, 8500, 2890, 5.7, false),   // 3 dias - 8.5km
            (5, 12340, 4120, 5.55, true),  // 5 dias - 12.34km - Destacada
            (7, 7890, 2670, 5.65, false),  // 7 dias - 7.89km
            (10, 15670, 5234, 5.58, true), // 10 dias - 15.67km - Destacada
            (12, 9123, 3078, 5.62, false), // 12 dias - 9.12km
            (15, 11234, 3789, 5.62, false), // 15 dias - 11.23km
            (18, 8765, 2956, 5.63, false), // 18 dias - 8.76km
            (21, 13456, 4512, 5.59, false), // 21 dias - 13.45km
            (25, 10987, 3698, 5.61, false)  // 25 dias - 10.98km
        ]

        for (index, mockData) in mockRunsData.enumerated() {
            guard let runDate = calendar.date(byAdding: .day, value: -mockData.daysAgo, to: now) else { continue }

            let run = Run(
                userId: userId,
                date: runDate,
                distance: mockData.distance,
                duration: mockData.duration,
                averagePace: mockData.pace
            )

            // Adicionar calorias estimadas
            run.calories = Int(mockData.distance / 1000.0 * 65) // ~65 kcal por km

            // Adicionar elevação variada
            run.elevationGain = Double.random(in: 20...150)

            // Marcar algumas como destacadas
            run.isHighlighted = mockData.highlighted

            // Criar rota mock (linha reta simulada)
            let mockRoute = createMockRoute(distance: mockData.distance, date: runDate)
            run.routeData = try? JSONEncoder().encode(mockRoute)

            // Criar splits mock
            let mockSplits = createMockSplits(distance: mockData.distance, pace: mockData.pace)
            run.splitsData = try? JSONEncoder().encode(mockSplits)

            context.insert(run)
        }

        // Atualizar estatísticas do usuário
        if let user = currentUser {
            user.totalRuns = mockRunsData.count
            user.totalDistance = mockRunsData.reduce(0) { $0 + $1.distance }
            user.totalDuration = mockRunsData.reduce(0) { $0 + $1.duration }
        }

        try? context.save()
    }

    private func createMockRoute(distance: Double, date: Date) -> [MockCoordinate] {
        // Criar uma rota mock (linha com algumas variações)
        let numberOfPoints = Int(distance / 100) // 1 ponto a cada 100m
        var coordinates: [MockCoordinate] = []

        // Ponto inicial (coordenadas de São Paulo, Brasil)
        let startLat = -23.550520
        let startLon = -46.633308

        for i in 0..<numberOfPoints {
            let progress = Double(i) / Double(numberOfPoints)

            // Variar latitude e longitude para criar uma rota
            let lat = startLat + (progress * 0.01) + Double.random(in: -0.0005...0.0005)
            let lon = startLon + (progress * 0.01) + Double.random(in: -0.0005...0.0005)

            let coordinate = MockCoordinate(
                latitude: lat,
                longitude: lon,
                timestamp: date.addingTimeInterval(progress * distance * 12), // ~12 seg por 100m
                altitude: Double.random(in: 700...750),
                speed: Double.random(in: 2.5...3.5) // m/s
            )

            coordinates.append(coordinate)
        }

        return coordinates
    }

    private func createMockSplits(distance: Double, pace: Double) -> [MockSplit] {
        let totalKm = Int(distance / 1000)
        var splits: [MockSplit] = []

        for km in 1...totalKm {
            // Variar o pace um pouco em cada km
            let kmPace = pace + Double.random(in: -0.15...0.15)
            let kmTime = kmPace * 60 // converter para segundos

            let split = MockSplit(
                km: km,
                time: kmTime,
                pace: kmPace,
                timestamp: Date()
            )

            splits.append(split)
        }

        return splits
    }
}

// MARK: - Mock Data Helpers

private struct MockCoordinate: Codable {
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let altitude: Double?
    let speed: Double?
}

private struct MockSplit: Codable {
    let km: Int
    let time: TimeInterval
    let pace: Double
    let timestamp: Date
}
