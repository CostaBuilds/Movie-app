import Foundation
import SwiftData

// MARK: - Event Participant Model
/// Represents a user's participation in a RunEvent
@Model
class EventParticipant {
    @Attribute(.unique) var id: UUID
    var firebaseId: String?

    // References
    var eventId: String // RunEvent firebaseId or id
    var userId: String // User firebaseId
    var userName: String
    var userPhotoURL: String?

    // Participation Status
    var status: String // "registered", "active", "completed", "cancelled"
    var joinedAt: Date
    var lastUpdate: Date

    // Performance Metrics (updated in real-time during event)
    var distance: Double // meters
    var duration: TimeInterval // seconds
    var averagePace: Double // min/km
    var calories: Int?
    var elevationGain: Double?

    // Position & Ranking
    var currentRank: Int?
    var isInsideZone: Bool
    var enteredZoneAt: Date?
    var exitedZoneAt: Date?

    // Achievements
    var goalCompleted: Bool
    var pointsEarned: Int
    var badgeEarned: String?

    // Real-time Data
    var currentSpeed: Double? // m/s
    var currentPace: Double? // min/km
    var lastKnownLatitude: Double?
    var lastKnownLongitude: Double?

    init(
        id: UUID = UUID(),
        firebaseId: String? = nil,
        eventId: String,
        userId: String,
        userName: String,
        userPhotoURL: String? = nil,
        status: String = "registered",
        joinedAt: Date = Date(),
        lastUpdate: Date = Date(),
        distance: Double = 0,
        duration: TimeInterval = 0,
        averagePace: Double = 0,
        calories: Int? = nil,
        elevationGain: Double? = nil,
        currentRank: Int? = nil,
        isInsideZone: Bool = false,
        enteredZoneAt: Date? = nil,
        exitedZoneAt: Date? = nil,
        goalCompleted: Bool = false,
        pointsEarned: Int = 0,
        badgeEarned: String? = nil,
        currentSpeed: Double? = nil,
        currentPace: Double? = nil,
        lastKnownLatitude: Double? = nil,
        lastKnownLongitude: Double? = nil
    ) {
        self.id = id
        self.firebaseId = firebaseId
        self.eventId = eventId
        self.userId = userId
        self.userName = userName
        self.userPhotoURL = userPhotoURL
        self.status = status
        self.joinedAt = joinedAt
        self.lastUpdate = lastUpdate
        self.distance = distance
        self.duration = duration
        self.averagePace = averagePace
        self.calories = calories
        self.elevationGain = elevationGain
        self.currentRank = currentRank
        self.isInsideZone = isInsideZone
        self.enteredZoneAt = enteredZoneAt
        self.exitedZoneAt = exitedZoneAt
        self.goalCompleted = goalCompleted
        self.pointsEarned = pointsEarned
        self.badgeEarned = badgeEarned
        self.currentSpeed = currentSpeed
        self.currentPace = currentPace
        self.lastKnownLatitude = lastKnownLatitude
        self.lastKnownLongitude = lastKnownLongitude
    }
}

// MARK: - Computed Properties
extension EventParticipant {
    var isActive: Bool {
        status == "active"
    }

    var isCompleted: Bool {
        status == "completed"
    }

    var distanceInKm: Double {
        distance / 1000.0
    }

    var formattedDistance: String {
        String(format: "%.2f km", distanceInKm)
    }

    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%dh %02dm %02ds", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%dm %02ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }

    var formattedPace: String {
        guard averagePace > 0 else { return "--'--\"" }
        let minutes = Int(averagePace)
        let seconds = Int((averagePace - Double(minutes)) * 60)
        return String(format: "%d'%02d\"/km", minutes, seconds)
    }

    var formattedCurrentPace: String? {
        guard let pace = currentPace, pace > 0 else { return nil }
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d'%02d\"/km", minutes, seconds)
    }

    var timeInZone: TimeInterval? {
        guard let entered = enteredZoneAt else { return nil }
        if let exited = exitedZoneAt {
            return exited.timeIntervalSince(entered)
        } else if isInsideZone {
            return Date().timeIntervalSince(entered)
        }
        return nil
    }

    var formattedTimeInZone: String? {
        guard let time = timeInZone else { return nil }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%dm %02ds", minutes, seconds)
    }
}

// MARK: - Mock Data
extension EventParticipant {
    static func mockParticipants(for eventId: String) -> [EventParticipant] {
        [
            EventParticipant(
                eventId: eventId,
                userId: "user1",
                userName: "Marcelo Costa",
                status: "active",
                distance: 3200,
                duration: 960, // 16 min
                averagePace: 5.0,
                currentRank: 1,
                isInsideZone: true,
                pointsEarned: 150
            ),
            EventParticipant(
                eventId: eventId,
                userId: "user2",
                userName: "Vitor Brito",
                status: "active",
                distance: 2800,
                duration: 840, // 14 min
                averagePace: 5.5,
                currentRank: 2,
                isInsideZone: true,
                pointsEarned: 120
            ),
            EventParticipant(
                eventId: eventId,
                userId: "user3",
                userName: "Juão Z",
                status: "active",
                distance: 2500,
                duration: 750, // 12.5 min
                averagePace: 6.0,
                currentRank: 3,
                isInsideZone: false,
                pointsEarned: 100
            ),
            EventParticipant(
                eventId: eventId,
                userId: "user4",
                userName: "Edson Mel",
                status: "active",
                distance: 2200,
                duration: 660, // 11 min
                averagePace: 6.5,
                currentRank: 4,
                isInsideZone: true,
                pointsEarned: 80
            ),
            EventParticipant(
                eventId: eventId,
                userId: "user5",
                userName: "Ana Silva",
                status: "registered",
                distance: 0,
                duration: 0,
                averagePace: 0,
                isInsideZone: false,
                pointsEarned: 0
            )
        ]
    }
}
