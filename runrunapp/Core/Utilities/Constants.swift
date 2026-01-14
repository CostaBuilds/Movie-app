import Foundation
import SwiftUI

enum AppConstants {
    // Tracking
    static let minAccuracy: Double = 50 // metros
    static let distanceFilter: Double = 10 // metros
    static let autoPauseThreshold: Double = 1.0 // m/s
    static let splitDistance: Double = 1000 // metros (1km)
    
    // UI
    static let defaultPadding: CGFloat = 16
    static let cornerRadius: CGFloat = 12
    static let buttonHeight: CGFloat = 56
    
    // Limits
    static let maxPhotoSize: Int = 1_048_576 // 1MB
    static let maxRoutePoints: Int = 1000
}

enum AppColors {
    static let primary = Color("Primary") // Criar no Assets
    static let secondary = Color("Secondary")
    static let accent = Color.cyan
    static let background = Color(.systemBackground)
    static let cardBackground = Color(.secondarySystemBackground)
}
