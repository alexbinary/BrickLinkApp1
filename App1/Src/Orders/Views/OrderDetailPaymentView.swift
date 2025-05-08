
import SwiftUI



struct OrderDetailPaymentView: View {
    
    
    @Environment(\.orderStore)
    var orderStore: OrderStoreProtocol!
    
    
    let order: Order
    
    init(_ order: Order) {
        self.order = order
    }
    
    
    var body: some View {
        
        VStack(alignment: .leading) {
           
           OrderCostView(order)
               .padding(.leading)
           
           OrderIncomeTransactionView(order)
               .padding()
               .roundedContainer(style: .secondary)
       }
    }
}



#Preview {
    
    let order = Order.previewOrderWith(
        subTotal: 42,
        grandTotal: 12
    )
    let details = OrderDetails.previewOrderDetailsWith(
        shippingCost: 34
    )
    
    OrderDetailPaymentView(order)
        .padding()
        .frame(width: 1200, height: 200)
        .previewEnv(
            orderStore: PreviewOrderStore(
                detailsForOrder: details
            )
        )
}
