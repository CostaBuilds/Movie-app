import Foundation
import SwiftData

@Model
class User {
    @Attribute(.unique) var id: UUID
    var firebaseUID: String
    var name: String
    var email: String
    var username: String
    var profilePhotoURL: String?
    
    // Estatísticas
    var totalDistance: Double // em metros
    var totalRuns: Int
    var totalDuration: TimeInterval // segundos
    
    // Grupos que participa (array de IDs do Firebase)
    var memberOfGroupIds: [String]
    
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        firebaseUID: String,
        name: String,
        email: String,
        username: String,
        profilePhotoURL: String? = nil
    ) {
        self.id = id
        self.firebaseUID = firebaseUID
        self.name = name
        self.email = email
        self.username = username
        self.profilePhotoURL = profilePhotoURL
        self.totalDistance = 0
        self.totalRuns = 0
        self.totalDuration = 0
        self.memberOfGroupIds = []
        self.createdAt = Date()
    }
}
