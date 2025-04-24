


enum SearchSuggestion {
    
    var description: String {
        switch self {
        case .token(let token):
            "token:\(token.description)"
        }
    }
    
    case token(_ token: SearchToken)
}
