
import SwiftUI



struct OrderAddressView: View {

    
    @Environment(\.orderStore)
    var orderStore: OrderStoreProtocol!
    
    
    let order: Order
    var orderDetails: OrderDetails? { orderStore.details(for: order) }
    
    init(_ order: Order) {
        self.order = order
    }
    
    
    var body: some View {
        
        if let orderDetails = orderDetails {
            
            VStack(alignment: .leading) {
                
                Text(orderDetails.shippingAddressName)
                Text(orderDetails.shippingAddress).fixedSize(horizontal: false, vertical: true)
                Text(orderDetails.shippingAddressCountryCode)
            }
        }
    }
}



#Preview {
    
    let env = createEnv()
    let order = env.stores.order.orders.first!
    
    OrderAddressView(order)
        .inject(env)
}
