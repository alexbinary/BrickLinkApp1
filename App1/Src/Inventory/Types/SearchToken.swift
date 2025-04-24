


enum SearchToken: Identifiable {
    
    
    var description: String {
        
        switch self {
        
        case .locationIs(let location):
            "locationIs:\(location.description)"
        
        case .locationContains(let str):
            "locationContains:\(str)"
            
        case .refIs(let ref):
            "refIs:\(ref)"
        
        case .refContains(let str):
            "refContains:\(str)"
        }
    }
    
    var id: String { description }
    
    
    case locationIs(_ loc: Location)
    case locationContains(_ str: String)
    
    case refIs(_ ref: String)
    case refContains(_ str: String)
}
