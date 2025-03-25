
import SwiftUI
import Core



struct OrderAddressView: View {

    
    let order: OrderDetails
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
    var body: some View {

        VStack(alignment: .leading) {
            
            Text(order.shippingAddressName)
            Text(order.shippingAddress).fixedSize(horizontal: false, vertical: true)
            Text(order.shippingAddressCountryCode)
        }
    }
}



#Preview {
    
    let env = createEnv()
    let order = env.stores.order.orderDetails.first!
    
    OrderAddressView(order)
        .inject(env)
}
