
import SwiftUI



struct FeedbackRating: View {
    
    
    let feedback: Feedback
    
    
    init(_ feedback: Feedback) {
        self.feedback = feedback
    }
    
    
    var body: some View {
        
        Group {
            switch feedback.rating {
            case 0:
                Text("􀉿")
            case 2:
                Text("􀊁")
            default:
                Text("Neutral")
            }
        }
        .help(feedback.comment)
    }
}
