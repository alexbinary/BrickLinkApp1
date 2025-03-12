
import SwiftUI



struct OrderIdLink: View {
    
    
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
    OrderIdLink(orderId: "123456789")
}
