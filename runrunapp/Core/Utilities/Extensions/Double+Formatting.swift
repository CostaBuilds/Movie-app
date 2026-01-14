import Foundation

extension Double {
    // Formata distância em metros pra km
    var asKilometers: String {
        String(format: "%.2f km", self / 1000.0)
    }
    
    // Formata pace (min/km)
    var asPace: String {
        guard self > 0 && self < 100 else { return "--:--" }
        
        let minutes = Int(self)
        let seconds = Int((self - Double(minutes)) * 60)
        return String(format: "%d:%02d /km", minutes, seconds)
    }
    
    // Formata elevação
    var asElevation: String {
        String(format: "%.0f m", self)
    }
}
