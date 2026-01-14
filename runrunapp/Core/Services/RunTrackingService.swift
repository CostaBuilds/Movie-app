import Foundation
import CoreLocation
import Combine

class RunTrackingService: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var distance: Double = 0 // metros
    @Published var duration: TimeInterval = 0 // segundos
    @Published var currentPace: Double = 0 // min/km
    @Published var averagePace: Double = 0 // min/km
    @Published var currentSpeed: Double = 0 // m/s
    @Published var route: [CLLocation] = []
    @Published var splits: [Split] = []
    @Published var elevationGain: Double = 0 // metros
    
    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var timer: Timer?
    private var startTime: Date?
    private var pausedTime: TimeInterval = 0
    private var lastPauseTime: Date?
    
    // Controle de splits
    private var lastSplitDistance: Double = 0
    private var lastSplitTime: Date?
    
    // Auto-pause
    private var isAutoPaused = false
    private let autoPauseSpeedThreshold: Double = 1.0 // m/s (~3.6 km/h)
    private var stoppedDuration: TimeInterval = 0
    
    // Elevação
    private var lowestAltitude: Double?
    private var highestAltitude: Double?
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10 // Atualiza a cada 10 metros
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    // MARK: - Public Methods
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startRun() {
        // Reset tudo
        distance = 0
        duration = 0
        currentPace = 0
        averagePace = 0
        route = []
        splits = []
        elevationGain = 0
        pausedTime = 0
        lastSplitDistance = 0
        lowestAltitude = nil
        highestAltitude = nil
        lastLocation = nil
        
        // Inicia
        isRunning = true
        isPaused = false
        startTime = Date()
        lastSplitTime = Date()
        
        locationManager.startUpdatingLocation()
        startTimer()
        
        print("🏃 Corrida iniciada")
    }
    
    func pauseRun() {
        guard isRunning && !isPaused else { return }
        
        isPaused = true
        lastPauseTime = Date()
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
        
        print("⏸️ Corrida pausada")
    }
    
    func resumeRun() {
        guard isRunning && isPaused else { return }
        
        isPaused = false
        
        // Adiciona tempo pausado
        if let pauseTime = lastPauseTime {
            pausedTime += Date().timeIntervalSince(pauseTime)
        }
        
        locationManager.startUpdatingLocation()
        startTimer()
        
        print("▶️ Corrida retomada")
    }
    
    func stopRun() -> RunData {
        isRunning = false
        isPaused = false
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
        
        // Prepara dados finais
        let finalDistance = distance
        let finalDuration = duration
        let finalPace = averagePace
        let finalRoute = route
        let finalSplits = splits
        let finalElevation = elevationGain
        
        print("🏁 Corrida finalizada: \(finalDistance/1000)km em \(finalDuration/60) min")
        
        return RunData(
            distance: finalDistance,
            duration: finalDuration,
            averagePace: finalPace,
            route: finalRoute,
            splits: finalSplits,
            elevationGain: finalElevation
        )
    }
    
    // MARK: - Private Methods
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startTime else { return }
            
            // Calcula duração total menos tempo pausado
            let totalElapsed = Date().timeIntervalSince(start)
            self.duration = totalElapsed - self.pausedTime
            
            // Atualiza pace médio
            if self.distance > 0 {
                let km = self.distance / 1000.0
                let minutes = self.duration / 60.0
                self.averagePace = minutes / km
            }
        }
    }
    
    private func calculatePace(distance: Double, time: TimeInterval) -> Double {
        guard distance > 0, time > 0 else { return 0 }
        let km = distance / 1000.0
        let minutes = time / 60.0
        return minutes / km
    }
    
    private func checkForSplit() {
        let currentKm = Int(distance / 1000)
        let lastKm = Int(lastSplitDistance / 1000)
        
        if currentKm > lastKm && currentKm > 0 {
            // Completou um novo km!
            let splitDistance = distance - lastSplitDistance
            let splitTime = Date().timeIntervalSince(lastSplitTime ?? startTime ?? Date())
            let splitPace = calculatePace(distance: splitDistance, time: splitTime)
            
            let split = Split(
                km: currentKm,
                time: splitTime,
                pace: splitPace,
                timestamp: Date()
            )
            
            splits.append(split)
            
            print("🎯 Split \(currentKm)km: \(split.timeFormatted) (\(split.paceFormatted)/km)")
            
            // Reset para próximo split
            lastSplitDistance = distance
            lastSplitTime = Date()
        }
    }
    
    private func updateElevation(_ location: CLLocation) {
        guard location.verticalAccuracy >= 0 && location.verticalAccuracy < 50 else {
            return // Ignora leituras imprecisas
        }
        
        let altitude = location.altitude
        
        if lowestAltitude == nil {
            lowestAltitude = altitude
            highestAltitude = altitude
        } else {
            if altitude < lowestAltitude! {
                lowestAltitude = altitude
            }
            if altitude > highestAltitude! {
                highestAltitude = altitude
            }
        }
        
        if let lowest = lowestAltitude, let highest = highestAltitude {
            elevationGain = highest - lowest
        }
    }
    
    private func shouldSaveLocation(_ location: CLLocation) -> Bool {
        guard let last = lastLocation else { return true }
        
        // Critérios pra salvar:
        // 1. Moveu mais de 10 metros
        let moved = location.distance(from: last) > 10
        
        // 2. Passou mais de 5 segundos
        let timePassed = location.timestamp.timeIntervalSince(last.timestamp) > 5
        
        // 3. Mudou muito a direção (>15 graus) - indica curva
        let courseChanged = abs(location.course - last.course) > 15
        
        return moved || timePassed || courseChanged
    }
}

// MARK: - CLLocationManagerDelegate
extension RunTrackingService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, isRunning, !isPaused else { return }
        
        // Ignora leituras imprecisas
        guard location.horizontalAccuracy >= 0 && location.horizontalAccuracy < 50 else {
            print("⚠️ Localização imprecisa ignorada: \(location.horizontalAccuracy)m")
            return
        }
        
        // Auto-pause
        if location.speed >= 0 && location.speed < autoPauseSpeedThreshold {
            if !isAutoPaused {
                print("⏸️ Auto-pause ativado")
                isAutoPaused = true
            }
            return
        } else if isAutoPaused {
            print("▶️ Auto-pause desativado")
            isAutoPaused = false
        }
        
        // Salva localização (otimizado)
        if shouldSaveLocation(location) {
            route.append(location)
        }
        
        // Calcula distância
        if let last = lastLocation {
            let distanceIncrement = location.distance(from: last)
            distance += distanceIncrement
            
            // Verifica splits
            checkForSplit()
        }
        
        // Atualiza velocidade e pace atual
        if location.speed >= 0 {
            currentSpeed = location.speed
            
            if currentSpeed > 0 {
                // Pace = min/km
                // speed em m/s → km/h = speed * 3.6
                // pace = 60 / km/h
                let kmh = currentSpeed * 3.6
                currentPace = kmh > 0 ? 60.0 / kmh : 0
            }
        }
        
        // Atualiza elevação
        updateElevation(location)
        
        lastLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Erro de localização: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Permissão de localização concedida")
        case .denied, .restricted:
            print("❌ Permissão de localização negada")
        case .notDetermined:
            print("⏳ Permissão de localização pendente")
        @unknown default:
            break
        }
    }
}

// MARK: - RunData
struct RunData {
    let distance: Double
    let duration: TimeInterval
    let averagePace: Double
    let route: [CLLocation]
    let splits: [Split]
    let elevationGain: Double
}
