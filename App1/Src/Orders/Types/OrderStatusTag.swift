
import Foundation
import SwiftUI



struct OrderStatusTag: Identifiable {
    
    let id = UUID()
    let text: String
    let status: TodoStatus
    let action: (() -> Void)?
    
    init(text: String, status: TodoStatus, action: (() -> Void)? = nil) {
        self.text = text
        self.status = status
        self.action = action
    }
}


enum TodoStatus {
    
    case actionRequired
    case waitingOnExternalAction
    case completed
    
    var color: Color {
        switch self {
        case .actionRequired: .red
        case .waitingOnExternalAction: .yellow
        case .completed: .green
        }
    }
}
