import Foundation
import SwiftUI
import SwiftData
import CoreLocation
import Combine

// MARK: - Run Event ViewModel
@MainActor
class RunEventViewModel: ObservableObject {
    // MARK: - Published Properties

    // Events
    @Published var allEvents: [RunEvent] = []
    @Published var nearbyEvents: [RunEvent] = []
    @Published var activeEvents: [RunEvent] = []
    @Published var upcomingEvents: [RunEvent] = []

    // Current Event
    @Published var selectedEvent: RunEvent?
    @Published var activeEvent: RunEvent?
    @Published var participants: [EventParticipant] = []
    @Published var currentParticipant: EventParticipant?

    // Location & Status
    @Published var isInsideZone: Bool = false
    @Published var distanceToEvent: Double = 0
    @Published var userLocation: CLLocation?

    // UI State
    @Published var isLoading: Bool = false
    @Published var showingEventDetail: Bool = false
    @Published var showingActiveEvent: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private let eventService = RunEventService()
    private var modelContext: ModelContext?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init() {
        setupBindings()
    }

    // MARK: - Setup
    func setup(with context: ModelContext) {
        self.modelContext = context
        loadMockEvents() // For now, use mock data
        eventService.requestPermission()
        eventService.startMonitoring()
    }

    private func setupBindings() {
        // Observe service properties
        eventService.$nearbyEvents
            .assign(to: &$nearbyEvents)

        eventService.$activeEvent
            .assign(to: &$activeEvent)

        eventService.$isInsideEventZone
            .assign(to: &$isInsideZone)

        eventService.$distanceToEventCenter
            .assign(to: &$distanceToEvent)

        eventService.$currentLocation
            .assign(to: &$userLocation)

        // Update events when location changes
        eventService.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.updateEventLists()
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    /// Load all events (from database or Firebase)
    func loadEvents() {
        isLoading = true

        // TODO: Load from SwiftData/Firebase
        // For now, using mock data
        loadMockEvents()

        isLoading = false
    }

    /// Refresh nearby events based on current location
    func refreshNearbyEvents() {
        eventService.findNearbyEvents(allEvents: allEvents)
        updateEventLists()
    }

    /// Join an event
    func joinEvent(_ event: RunEvent) {
        guard let location = userLocation else {
            errorMessage = "Localização não disponível"
            return
        }

        // Check if event is full
        if event.isFull {
            errorMessage = "Evento lotado"
            return
        }

        // Check if too far
        let distance = event.distanceFrom(location)
        if distance > 1000 { // 1km limit to join
            errorMessage = "Você está muito longe do evento"
            return
        }

        // Create participant
        let participant = EventParticipant(
            eventId: event.firebaseId ?? event.id.uuidString,
            userId: "current-user-id", // TODO: Get from auth
            userName: "Você",
            status: "registered",
            isInsideZone: event.isLocationWithinRadius(location)
        )

        currentParticipant = participant
        participants.append(participant)

        // Update event
        event.participantCount += 1
        selectedEvent = event

        // Join in service
        eventService.joinEvent(event)

        // Show active event view
        showingActiveEvent = true
    }

    /// Leave current event
    func leaveEvent() {
        guard let event = activeEvent else { return }

        // Update participant status
        if let participant = currentParticipant {
            participant.status = "cancelled"
        }

        // Update event
        event.participantCount -= 1

        // Leave in service
        eventService.leaveEvent()

        currentParticipant = nil
        showingActiveEvent = false
    }

    /// Start running in an event
    func startRunning() {
        guard let participant = currentParticipant else { return }
        participant.status = "active"
        participant.enteredZoneAt = Date()
    }

    /// Stop running in an event
    func stopRunning() {
        guard let participant = currentParticipant else { return }
        participant.status = "completed"
        participant.exitedZoneAt = Date()
        participant.goalCompleted = checkIfGoalCompleted()

        // Calculate points
        calculatePoints()
    }

    /// Update participant metrics during run
    func updateMetrics(distance: Double, duration: TimeInterval, pace: Double) {
        guard let participant = currentParticipant,
              let location = userLocation else { return }

        eventService.updateParticipantLocation(
            participant: participant,
            location: location,
            distance: distance,
            pace: pace
        )

        participant.distance = distance
        participant.duration = duration
        participant.averagePace = pace
        participant.lastUpdate = Date()

        // Update rank
        updateLeaderboard()
    }

    /// Load participants for an event
    func loadParticipants(for event: RunEvent) {
        // TODO: Load from Firebase in real-time
        // For now, use mock data
        participants = EventParticipant.mockParticipants(for: event.firebaseId ?? event.id.uuidString)
    }

    /// Select an event to view details
    func selectEvent(_ event: RunEvent) {
        selectedEvent = event
        loadParticipants(for: event)
        showingEventDetail = true
    }

    /// Dismiss event detail
    func dismissEventDetail() {
        showingEventDetail = false
        selectedEvent = nil
    }

    // MARK: - Private Methods

    private func updateEventLists() {
        // Active events (happening now)
        activeEvents = allEvents.filter { $0.isActive }

        // Upcoming events (scheduled)
        upcomingEvents = allEvents.filter { $0.isScheduled }
            .sorted { $0.startTime < $1.startTime }
    }

    private func checkIfGoalCompleted() -> Bool {
        guard let event = activeEvent,
              let participant = currentParticipant,
              let targetDistance = event.targetDistance else {
            return false
        }

        return participant.distance >= targetDistance
    }

    private func calculatePoints() {
        guard let event = activeEvent,
              let participant = currentParticipant else { return }

        var points = event.pointsReward

        // Bonus for completing goal
        if participant.goalCompleted {
            points += 50
        }

        // Bonus for time in zone
        if let timeInZone = participant.timeInZone {
            let minutes = Int(timeInZone / 60)
            points += minutes * 2 // 2 points per minute in zone
        }

        // Bonus for rank
        if let rank = participant.currentRank {
            switch rank {
            case 1: points += 100
            case 2: points += 75
            case 3: points += 50
            default: break
            }
        }

        participant.pointsEarned = points
    }

    private func updateLeaderboard() {
        // Sort participants by distance
        let sortedParticipants = participants
            .filter { $0.isActive || $0.isCompleted }
            .sorted { $0.distance > $1.distance }

        // Update ranks
        for (index, participant) in sortedParticipants.enumerated() {
            participant.currentRank = index + 1
        }
    }

    private func loadMockEvents() {
        // Create mock events near user location
        let defaultLocation = CLLocation(latitude: -8.0522, longitude: -34.8821) // Recife
        let location = userLocation ?? defaultLocation

        allEvents = RunEventService.mockEvents(near: location)
        updateEventLists()
        eventService.findNearbyEvents(allEvents: allEvents)
    }

    /// Request notification permissions
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                print("Notification permission granted")
            }
        }
    }

    // MARK: - Formatting Helpers

    func formattedDistance(to event: RunEvent) -> String {
        guard let location = userLocation else { return "---" }
        return event.formattedDistanceFrom(location)
    }

    func timeUntilStart(for event: RunEvent) -> String {
        let interval = event.timeUntilStart

        if interval < 0 {
            return "Acontecendo agora"
        }

        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 24 {
            let days = hours / 24
            return "Em \(days)d"
        } else if hours > 0 {
            return "Em \(hours)h \(minutes)m"
        } else {
            return "Em \(minutes)m"
        }
    }

    func timeRemaining(for event: RunEvent) -> String {
        let interval = event.timeRemaining

        if interval < 0 {
            return "Finalizado"
        }

        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m restantes"
        } else {
            return "\(minutes)m restantes"
        }
    }
}
