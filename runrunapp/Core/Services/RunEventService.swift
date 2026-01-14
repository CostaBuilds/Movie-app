import Foundation
import CoreLocation
import Combine

// MARK: - Run Event Service
/// Manages event detection, location monitoring, and real-time participation
@MainActor
class RunEventService: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var nearbyEvents: [RunEvent] = []
    @Published var activeEvent: RunEvent?
    @Published var isInsideEventZone: Bool = false
    @Published var distanceToEventCenter: Double = 0
    @Published var currentLocation: CLLocation?

    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private var monitoredRegions: Set<String> = []
    private let notificationCenter = NotificationCenter.default

    // Constants
    private let searchRadius: Double = 5000 // 5km search radius for nearby events
    private let updateInterval: TimeInterval = 5.0 // Update every 5 seconds

    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
    }

    // MARK: - Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update every 10 meters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    // MARK: - Public Methods

    /// Request location permissions
    func requestPermission() {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        default:
            break
        }
    }

    /// Start monitoring for nearby events
    func startMonitoring() {
        locationManager.startUpdatingLocation()
    }

    /// Stop monitoring
    func stopMonitoring() {
        locationManager.stopUpdatingLocation()
        stopMonitoringAllRegions()
    }

    /// Find events near current location
    func findNearbyEvents(allEvents: [RunEvent]) {
        guard let location = currentLocation else { return }

        nearbyEvents = allEvents.filter { event in
            let distance = event.distanceFrom(location)
            return distance <= searchRadius && !event.isCompleted
        }.sorted { event1, event2 in
            // Sort by: active first, then by distance
            if event1.isActive && !event2.isActive {
                return true
            } else if !event1.isActive && event2.isActive {
                return false
            }
            return event1.distanceFrom(location) < event2.distanceFrom(location)
        }

        // Monitor nearby events as geofence regions
        updateMonitoredRegions(for: nearbyEvents)
    }

    /// Join an event (start tracking participation)
    func joinEvent(_ event: RunEvent) {
        activeEvent = event
        checkIfInsideZone()

        // Send notification
        sendLocalNotification(
            title: "Evento iniciado!",
            body: "Você entrou no evento \(event.name). Boa corrida!"
        )
    }

    /// Leave current event
    func leaveEvent() {
        if let event = activeEvent {
            sendLocalNotification(
                title: "Evento finalizado",
                body: "Você saiu do evento \(event.name)"
            )
        }
        activeEvent = nil
        isInsideEventZone = false
    }

    /// Check if user is inside the active event zone
    func checkIfInsideZone() {
        guard let event = activeEvent,
              let location = currentLocation else {
            isInsideEventZone = false
            return
        }

        let wasInside = isInsideEventZone
        isInsideEventZone = event.isLocationWithinRadius(location)
        distanceToEventCenter = event.distanceFrom(location)

        // Notify on zone entry/exit
        if !wasInside && isInsideEventZone {
            onZoneEntry()
        } else if wasInside && !isInsideEventZone {
            onZoneExit()
        }
    }

    /// Update participant location and metrics
    func updateParticipantLocation(
        participant: EventParticipant,
        location: CLLocation,
        distance: Double,
        pace: Double
    ) {
        participant.lastKnownLatitude = location.coordinate.latitude
        participant.lastKnownLongitude = location.coordinate.longitude
        participant.distance = distance
        participant.currentPace = pace
        participant.lastUpdate = Date()
        participant.isInsideZone = isInsideEventZone
    }

    // MARK: - Private Methods

    private func updateMonitoredRegions(for events: [RunEvent]) {
        // Remove old regions
        for regionId in monitoredRegions {
            if let region = locationManager.monitoredRegions.first(where: { $0.identifier == regionId }) {
                locationManager.stopMonitoring(for: region)
            }
        }
        monitoredRegions.removeAll()

        // Add new regions
        for event in events where event.isScheduled || event.isActive {
            let region = CLCircularRegion(
                center: event.coordinate,
                radius: event.radius,
                identifier: event.id.uuidString
            )
            region.notifyOnEntry = true
            region.notifyOnExit = true

            locationManager.startMonitoring(for: region)
            monitoredRegions.insert(region.identifier)
        }
    }

    private func stopMonitoringAllRegions() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        monitoredRegions.removeAll()
    }

    private func onZoneEntry() {
        guard let event = activeEvent else { return }

        sendLocalNotification(
            title: "Você entrou na zona! 🎯",
            body: "Continue correndo para somar pontos no \(event.name)"
        )

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func onZoneExit() {
        guard let event = activeEvent else { return }

        sendLocalNotification(
            title: "Você saiu da zona ⚠️",
            body: "Volte para a área do \(event.name) para continuar somando pontos"
        )

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    private func sendLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    /// Calculate distance between two locations
    func distance(from: CLLocation, to: CLLocation) -> Double {
        from.distance(from: to)
    }
}

// MARK: - CLLocationManagerDelegate
extension RunEventService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        Task { @MainActor in
            currentLocation = location
            checkIfInsideZone()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        Task { @MainActor in
            // User entered an event region
            if let event = nearbyEvents.first(where: { $0.id.uuidString == region.identifier }) {
                sendLocalNotification(
                    title: "Evento próximo! 📍",
                    body: "\(event.name) está acontecendo agora. Entre para participar!"
                )
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        Task { @MainActor in
            // User left an event region
            if let event = nearbyEvents.first(where: { $0.id.uuidString == region.identifier }),
               activeEvent?.id == event.id {
                isInsideEventZone = false
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            let status = manager.authorizationStatus
            if status == .authorizedAlways || status == .authorizedWhenInUse {
                startMonitoring()
            }
        }
    }
}

// MARK: - Mock Data Helper
extension RunEventService {
    /// Generate mock events for testing
    static func mockEvents(near location: CLLocation) -> [RunEvent] {
        let baseCoord = location.coordinate

        return [
            RunEvent(
                name: "Corrida do Amanhecer 🌅",
                eventDescription: "Corrida matinal no parque. Junte-se a nós!",
                latitude: baseCoord.latitude + 0.01,
                longitude: baseCoord.longitude + 0.01,
                radius: 150,
                locationName: "Parque da Boa Vista",
                startTime: Date().addingTimeInterval(600), // 10 min from now
                endTime: Date().addingTimeInterval(3600), // 1 hour from now
                eventType: "social",
                difficultyLevel: "easy",
                targetDistance: 5000,
                minParticipants: 3,
                maxParticipants: 20,
                participantCount: 8,
                status: "scheduled",
                pointsReward: 150,
                createdBy: "mock-user"
            ),
            RunEvent(
                name: "Sprint Challenge ⚡️",
                eventDescription: "Desafio de velocidade! Quem consegue o melhor pace?",
                latitude: baseCoord.latitude - 0.02,
                longitude: baseCoord.longitude + 0.015,
                radius: 100,
                locationName: "Orla de Boa Viagem",
                startTime: Date().addingTimeInterval(-300), // Started 5 min ago
                endTime: Date().addingTimeInterval(1200), // 20 min remaining
                eventType: "sprint",
                difficultyLevel: "hard",
                targetDistance: 3000,
                minParticipants: 2,
                maxParticipants: 15,
                participantCount: 12,
                status: "active",
                pointsReward: 250,
                createdBy: "mock-user"
            ),
            RunEvent(
                name: "Maratona Noturna 🌙",
                eventDescription: "Corrida de resistência à noite",
                latitude: baseCoord.latitude + 0.03,
                longitude: baseCoord.longitude - 0.02,
                radius: 200,
                locationName: "Parque Dona Lindu",
                startTime: Date().addingTimeInterval(7200), // 2 hours from now
                endTime: Date().addingTimeInterval(10800), // 3 hours from now
                eventType: "endurance",
                difficultyLevel: "hard",
                targetDistance: 10000,
                minParticipants: 5,
                maxParticipants: 30,
                participantCount: 4,
                status: "scheduled",
                pointsReward: 500,
                createdBy: "mock-user"
            )
        ]
    }
}
