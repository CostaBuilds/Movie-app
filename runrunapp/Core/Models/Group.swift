import Foundation

struct Group: Codable, Identifiable {
    var id: String // Firestore document ID
    var name: String
    var description: String
    var photoURL: String?
    
    // Localização
    var city: String
    var state: String
    
    // Metadados
    var createdBy: String // User ID do criador
    var createdAt: Date
    var memberCount: Int
    var isPublic: Bool // Público = qualquer um pode entrar
    
    // Admins
    var adminIds: [String]
    
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        city: String,
        state: String,
        createdBy: String,
        isPublic: Bool = true
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.photoURL = nil
        self.city = city
        self.state = state
        self.createdBy = createdBy
        self.createdAt = Date()
        self.memberCount = 1
        self.isPublic = isPublic
        self.adminIds = [createdBy]
    }
}

// Struct pra representar membro do grupo
struct GroupMember: Codable, Identifiable {
    var id: String { userId } // userId é o ID
    var userId: String
    var userName: String
    var userPhotoURL: String?
    var joinedAt: Date
    var role: MemberRole
    
    enum MemberRole: String, Codable {
        case admin
        case member
    }
}

// Struct pra posts de corrida no feed do grupo
struct RunPost: Codable, Identifiable {
    var id: String // Firestore document ID
    var runId: String // ID local da corrida
    var groupId: String
    var userId: String
    var userName: String
    var userPhotoURL: String?
    
    // Dados da corrida
    var date: Date
    var distance: Double // metros
    var duration: TimeInterval // segundos
    var averagePace: Double // min/km
    
    var photoURL: String?
    var caption: String?
    
    // Engagement
    var likes: Int
    var likedBy: [String] // Array de user IDs
    var commentCount: Int
    
    var createdAt: Date
    
    init(from run: Run, user: User, groupId: String) {
        self.id = UUID().uuidString
        self.runId = run.id.uuidString
        self.groupId = groupId
        self.userId = user.firebaseUID
        self.userName = user.name
        self.userPhotoURL = user.profilePhotoURL
        self.date = run.date
        self.distance = run.distance
        self.duration = run.duration
        self.averagePace = run.averagePace
        self.photoURL = run.photoURL
        self.caption = run.caption
        self.likes = 0
        self.likedBy = []
        self.commentCount = 0
        self.createdAt = Date()
    }
}
