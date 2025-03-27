
import SwiftUI
import Core



struct OrderCostView: View {

    
    @Environment(OrderStore.self)
    var orderStore
    
    
    let order: Order
    var orderDetails: OrderDetails { orderStore.details(for: order)! }
    
    init(_ order: Order) {
        self.order = order
    }
    
    
    var body: some View {

        HStack(spacing: 48) {
            
            VStack(alignment: .leading) {
                
                Text("􀖧 Grand total").captionStyle()
                
                Text(order.grandTotal, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                    .font(.title2)
                
                if order.dispCostCurrencyCode != order.costCurrencyCode {
                    Text(order.dispGrandTotal, format: .currency(code: order.dispCostCurrencyCode).presentation(.isoCode))
                        .font(.title2)
                }
            }
            
            HStack {
                
                VStack(alignment: .leading) {
                    
                    Text("􀖧 Subtotal").captionStyle()
                    
                    Text(order.subTotal, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                        .font(.title3)
                    
                    if order.dispCostCurrencyCode != order.costCurrencyCode {
                        Text(order.dispSubTotal, format: .currency(code: order.dispCostCurrencyCode).presentation(.isoCode))
                            .font(.title3)
                    }
                }
                
                VStack(alignment: .leading) {
                    
                    Text("􀖧 Shipping").captionStyle()
                    
                    Text(orderDetails.shippingCost, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                        .font(.title3)
                    
                    if order.dispCostCurrencyCode != order.costCurrencyCode {
                        Text(orderDetails.dispShippingCost, format: .currency(code: order.dispCostCurrencyCode).presentation(.isoCode))
                            .font(.title3)
                    }
                }
            }
        }
    }
}

#Preview {
    
    let env = createEnv()
    let order = env.stores.order.orders.first!
    
    OrderCostView(order)
        .inject(env)
}
