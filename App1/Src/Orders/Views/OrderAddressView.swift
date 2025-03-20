
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
    
    let stores = AppController.createStores()
    
    let orderStore = stores.order
    
    let order = orderStore.orderDetails.first!
    
    OrderAddressView(order)
}
