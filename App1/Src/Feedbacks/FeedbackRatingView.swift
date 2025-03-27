
import SwiftUI
import Core



struct FeedbackRatingView: View {
    
    
    let feedback: Feedback
    
    
    init(_ feedback: Feedback) {
        self.feedback = feedback
    }
    
    
    var body: some View {
        
        Group {
            switch feedback.rating {
            case .praise:
                Text("􀉿")
            case .complaint:
                Text("􀊁")
            case .neutral:
                Text("Neutral")
            }
        }
        .help(feedback.comment)
    }
}



#Preview {
    FeedbackRatingView(Feedback(id: 1, orderId: "", from: "", to: "", dateRated: .now, rating: .praise, author: .buyer, comment: ""))
        .padding()
}
