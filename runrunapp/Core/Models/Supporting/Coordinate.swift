import Foundation
import CoreLocation

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let altitude: Double?
    let speed: Double? // m/s
    
    init(from location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.timestamp = location.timestamp
        self.altitude = location.altitude
        self.speed = location.speed >= 0 ? location.speed : nil
    }
    
    // Converte de volta pra CLLocation
    func toCLLocation() -> CLLocation {
        CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            altitude: altitude ?? 0,
            horizontalAccuracy: 10,
            verticalAccuracy: 10,
            timestamp: timestamp
        )
    }

    // Computed property para obter CLLocation
    var clLocation: CLLocation {
        toCLLocation()
    }
}
