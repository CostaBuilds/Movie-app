import Foundation
import SwiftData
import CoreLocation

// MARK: - Run Event Model
/// Represents a timed running event at a specific location (similar to Pokémon GO Raids)
@Model
class RunEvent {
    @Attribute(.unique) var id: UUID
    var firebaseId: String?

    // Event Info
    var name: String
    var eventDescription: String
    var imageURL: String?

    // Location
    var latitude: Double
    var longitude: Double
    var radius: Double // in meters (e.g., 100m circle)
    var locationName: String // e.g., "Parque da Boa Vista"

    // Timing
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval // in seconds

    // Event Details
    var eventType: String // "sprint", "endurance", "social", "challenge"
    var difficultyLevel: String // "easy", "medium", "hard"
    var targetDistance: Double? // optional goal distance in meters
    var minParticipants: Int
    var maxParticipants: Int?

    // Stats
    var participantCount: Int
    var totalDistanceRun: Double // sum of all participants
    var averagePace: Double?

    // Status
    var status: String // "scheduled", "active", "completed", "cancelled"
    var isRecurring: Bool
    var recurringPattern: String? // "daily", "weekly", "monthly"

    // Rewards
    var badgeId: String?
    var pointsReward: Int

    // Meta
    var createdBy: String // Firebase UID
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        firebaseId: String? = nil,
        name: String,
        eventDescription: String,
        imageURL: String? = nil,
        latitude: Double,
        longitude: Double,
        radius: Double = 100,
        locationName: String,
        startTime: Date,
        endTime: Date,
        eventType: String = "social",
        difficultyLevel: String = "medium",
        targetDistance: Double? = nil,
        minParticipants: Int = 2,
        maxParticipants: Int? = nil,
        participantCount: Int = 0,
        totalDistanceRun: Double = 0,
        averagePace: Double? = nil,
        status: String = "scheduled",
        isRecurring: Bool = false,
        recurringPattern: String? = nil,
        badgeId: String? = nil,
        pointsReward: Int = 100,
        createdBy: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.firebaseId = firebaseId
        self.name = name
        self.eventDescription = eventDescription
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.locationName = locationName
        self.startTime = startTime
        self.endTime = endTime
        self.duration = endTime.timeIntervalSince(startTime)
        self.eventType = eventType
        self.difficultyLevel = difficultyLevel
        self.targetDistance = targetDistance
        self.minParticipants = minParticipants
        self.maxParticipants = maxParticipants
        self.participantCount = participantCount
        self.totalDistanceRun = totalDistanceRun
        self.averagePace = averagePace
        self.status = status
        self.isRecurring = isRecurring
        self.recurringPattern = recurringPattern
        self.badgeId = badgeId
        self.pointsReward = pointsReward
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Computed Properties
extension RunEvent {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var isActive: Bool {
        status == "active" && Date() >= startTime && Date() <= endTime
    }

    var isScheduled: Bool {
        status == "scheduled" && Date() < startTime
    }

    var isCompleted: Bool {
        status == "completed" || Date() > endTime
    }

    var timeUntilStart: TimeInterval {
        startTime.timeIntervalSinceNow
    }

    var timeRemaining: TimeInterval {
        endTime.timeIntervalSinceNow
    }

    var progress: Double {
        guard Date() >= startTime else { return 0 }
        guard Date() <= endTime else { return 1 }
        let elapsed = Date().timeIntervalSince(startTime)
        return elapsed / duration
    }

    var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startTime)
    }

    var formattedEndTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: endTime)
    }

    var formattedTimeRange: String {
        "\(formattedStartTime) - \(formattedEndTime)"
    }

    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var isFull: Bool {
        guard let max = maxParticipants else { return false }
        return participantCount >= max
    }

    var spotsRemaining: Int? {
        guard let max = maxParticipants else { return nil }
        return max - participantCount
    }

    var eventTypeEmoji: String {
        switch eventType {
        case "sprint": return "⚡️"
        case "endurance": return "🔥"
        case "social": return "🎉"
        case "challenge": return "🏆"
        default: return "🏃"
        }
    }

    var difficultyColor: String {
        switch difficultyLevel {
        case "easy": return "green"
        case "medium": return "orange"
        case "hard": return "red"
        default: return "gray"
        }
    }
}

// MARK: - Helper Methods
extension RunEvent {
    /// Check if a given location is within the event's radius
    func isLocationWithinRadius(_ location: CLLocation) -> Bool {
        let eventLocation = CLLocation(latitude: latitude, longitude: longitude)
        let distance = location.distance(from: eventLocation)
        return distance <= radius
    }

    /// Calculate distance from a given location to the event center
    func distanceFrom(_ location: CLLocation) -> Double {
        let eventLocation = CLLocation(latitude: latitude, longitude: longitude)
        return location.distance(from: eventLocation)
    }

    /// Get formatted distance from location
    func formattedDistanceFrom(_ location: CLLocation) -> String {
        let distance = distanceFrom(location)
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
}
