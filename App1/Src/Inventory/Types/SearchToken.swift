


enum SearchToken: Identifiable {
    
    var description: String {
        switch self {
        case .locationIs(let location):
            "locationIs:\(location.description)"
        case .locationContains(let str):
            "locationContains:\(str)"
        }
    }
    var id: String { description }
    
    case locationIs(_ loc: Location)
    case locationContains(_ str: String)
}
