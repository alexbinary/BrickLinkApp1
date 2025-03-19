
import SwiftUI



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
    
    let appController = AppController()
    let orderStore = appController.orderStore
    
    let order = orderStore.orderDetails.first!
    
    OrderAddressView(order)
}
