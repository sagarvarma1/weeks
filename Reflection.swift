import Foundation
import SwiftData

enum ReflectionType: String, Codable, CaseIterable {
    case meaningful = "Meaningful"
    case wasted = "Wasted"
}

@Model
final class Reflection {
    var date: Date
    var type: ReflectionType
    var explanation: String
    
    init(date: Date = Date(), type: ReflectionType = .meaningful, explanation: String = "") {
        self.date = date
        self.type = type
        self.explanation = explanation
    }
} 