import Foundation
import SwiftUI
import SwiftData
import CoreLocation
import Combine

@MainActor
class RunTrackingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var showingPostRunView = false
    @Published var currentRun: Run?
    
    // Formatados para UI
    @Published var distanceText = "0.00"
    @Published var durationText = "00:00"
    @Published var paceText = "--:--"
    @Published var currentPaceText = "--:--"
    
    // MARK: - Services
    private let trackingService = RunTrackingService()
    private var modelContext: ModelContext?
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    private func setupBindings() {
        // Observa mudanças no tracking service
        trackingService.$isRunning
            .assign(to: &$isRunning)
        
        trackingService.$isPaused
            .assign(to: &$isPaused)
        
        // Formata valores para display
        trackingService.$distance
            .map { distance in
                String(format: "%.2f", distance / 1000.0) // km
            }
            .assign(to: &$distanceText)
        
        trackingService.$duration
            .map { duration in
                Self.formatDuration(duration)
            }
            .assign(to: &$durationText)
        
        trackingService.$averagePace
            .map { pace in
                Self.formatPace(pace)
            }
            .assign(to: &$paceText)
        
        trackingService.$currentPace
            .map { pace in
                Self.formatPace(pace)
            }
            .assign(to: &$currentPaceText)
    }
    
    // MARK: - Public Methods
    func requestPermission() {
        trackingService.requestPermission()
    }
    
    func startRun() {
        trackingService.startRun()
    }
    
    func pauseRun() {
        trackingService.pauseRun()
    }
    
    func resumeRun() {
        trackingService.resumeRun()
    }
    
    func stopRun(userId: String) {
        let runData = trackingService.stopRun()
        
        // Converte route pra Data
        let coordinates = runData.route.map { Coordinate(from: $0) }
        let routeData = try? JSONEncoder().encode(coordinates)
        
        // Converte splits pra Data
        let splitsData = try? JSONEncoder().encode(runData.splits)
        
        // Cria objeto Run
        let run = Run(
            userId: userId,
            date: Date(),
            distance: runData.distance,
            duration: runData.duration,
            averagePace: runData.averagePace,
            routeData: routeData,
            splitsData: splitsData
        )
        
        // Adiciona elevação se tiver
        if runData.elevationGain > 0 {
            run.elevationGain = runData.elevationGain
        }
        
        // Estima calorias (aproximação: 1 cal por kg por km)
        // Pode melhorar depois pegando peso do usuário
        let estimatedCalories = Int((runData.distance / 1000) * 70) // Assumindo 70kg
        run.calories = estimatedCalories
        
        // Salva no SwiftData
        saveRun(run)
        
        // Guarda pra mostrar na tela de post-run
        currentRun = run
        
        // Mostra tela de post-run
        showingPostRunView = true
    }
    
    private func saveRun(_ run: Run) {
        guard let context = modelContext else {
            print("❌ ModelContext não configurado")
            return
        }
        
        context.insert(run)
        
        do {
            try context.save()
            print("✅ Corrida salva localmente: \(run.id)")
        } catch {
            print("❌ Erro ao salvar corrida: \(error)")
        }
    }
    
    // MARK: - Computed Properties
    var splits: [Split] {
        trackingService.splits
    }
    
    var route: [CLLocation] {
        trackingService.route
    }
    
    var elevationGain: Double {
        trackingService.elevationGain
    }
    
    // MARK: - Formatters
    static func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    static func formatPace(_ pace: Double) -> String {
        guard pace > 0 && pace < 100 else { return "--:--" }
        
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    static func formatDistance(_ distance: Double) -> String {
        String(format: "%.2f km", distance / 1000.0)
    }
}
