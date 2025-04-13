import Foundation
import SwiftData

enum ReflectionType: String, Codable, CaseIterable {
    case meaningful = "Spent Well"
    case wasted = "Wasted"
    
    // Custom init for decoder to handle both old and new values
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "Meaningful", "Spent Well":
            self = .meaningful
        case "Wasted":
            self = .wasted
        default:
            // Default to meaningful if unknown value
            self = .meaningful
        }
    }
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