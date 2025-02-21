
import SwiftUI



struct FeedbackRatingView: View {
    
    
    let feedback: Feedback
    
    
    var body: some View {
        
        let rating = feedback.rating
        if rating == 0 {
            Text("􀉿")
        } else if rating == 2 {
            Text("􀊁")
        } else {
            Text("Neutral")
        }
    }
}
