import Foundation
import SwiftData

@Model
class Run {
    @Attribute(.unique) var id: UUID
    var userId: String // Firebase UID do usuário
    var date: Date
    
    // Métricas básicas
    var distance: Double // em metros
    var duration: TimeInterval // em segundos
    var averagePace: Double // minutos por km
    var maxPace: Double? // melhor pace durante a corrida
    var calories: Int?
    var elevationGain: Double? // ganho de elevação em metros
    
    // Rota (salva como Data - JSON serializado)
    var routeData: Data? // [Coordinate]
    
    // Splits (tempo por km - salva como Data)
    var splitsData: Data? // [Split]
    
    // Grupos onde foi compartilhada
    var sharedInGroupIds: [String]
    
    // Mídia
    var photoData: Data? // Foto local (antes de sincronizar)
    var photoURL: String? // URL no Firebase Storage (depois de sincronizar)
    var caption: String? // Texto do post
    
    // Destacar corrida
    var isHighlighted: Bool // Se está destacada no perfil

    // Sincronização
    var synced: Bool // Se já foi enviada pro servidor
    var syncedAt: Date?
    var firebaseId: String? // ID do documento no Firestore
    
    init(
        id: UUID = UUID(),
        userId: String,
        date: Date,
        distance: Double,
        duration: TimeInterval,
        averagePace: Double,
        routeData: Data? = nil,
        splitsData: Data? = nil
    ) {
        self.id = id
        self.userId = userId
        self.date = date
        self.distance = distance
        self.duration = duration
        self.averagePace = averagePace
        self.maxPace = nil
        self.calories = nil
        self.elevationGain = nil
        self.routeData = routeData
        self.splitsData = splitsData
        self.sharedInGroupIds = []
        self.photoData = nil
        self.photoURL = nil
        self.caption = nil
        self.isHighlighted = false
        self.synced = false
        self.syncedAt = nil
        self.firebaseId = nil
    }
    
    // Computed properties úteis
    var distanceInKm: Double {
        distance / 1000.0
    }
    
    var paceFormatted: String {
        let minutes = Int(averagePace)
        let seconds = Int((averagePace - Double(minutes)) * 60)
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%dh %02dm %02ds", hours, minutes, seconds)
        } else {
            return String(format: "%dm %02ds", minutes, seconds)
        }
    }
}
