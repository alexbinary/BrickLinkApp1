
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



#Preview {
    FeedbackRating(Feedback(id: 1, orderId: "", from: "", to: "", dateRated: .now, rating: 0, author: .buyer, comment: ""))
}
