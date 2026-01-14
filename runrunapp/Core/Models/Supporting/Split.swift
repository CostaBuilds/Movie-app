import Foundation

struct Split: Codable, Identifiable {
    let id: UUID
    let km: Int // Qual quilômetro (1, 2, 3...)
    let time: TimeInterval // Tempo DESSE km específico em segundos
    let pace: Double // Pace DESSE km em min/km
    let timestamp: Date // Quando completou esse km
    
    init(km: Int, time: TimeInterval, pace: Double, timestamp: Date = Date()) {
        self.id = UUID()
        self.km = km
        self.time = time
        self.pace = pace
        self.timestamp = timestamp
    }
    
    var timeFormatted: String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var paceFormatted: String {
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d'%02d\"", minutes, seconds)
    }
}
