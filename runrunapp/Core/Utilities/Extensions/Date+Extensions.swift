import Foundation

extension Date {
    // Formata data pra display
    var asShortDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    var asFullDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    // Relativo: "Hoje", "Ontem", "há 2 dias"
    var asRelativeDate: String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            return "Hoje"
        } else if calendar.isDateInYesterday(self) {
            return "Ontem"
        } else {
            let components = calendar.dateComponents([.day], from: self, to: Date())
            if let days = components.day, days < 7 {
                return "há \(days) dias"
            } else {
                return asShortDate
            }
        }
    }
}
