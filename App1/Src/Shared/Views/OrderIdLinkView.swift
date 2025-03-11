
import SwiftUI



struct OrderIdLinkView: View {
    
    
    @EnvironmentObject
    var app: AppController

    let orderId: String
    
    
    var body: some View {

        Link(destination: app.url(forDetailsOfOrderWithId: orderId)!) {
            Text(orderId)
        }
    }
}



#Preview {
    OrderIdLinkView(orderId: "123456789")
}
