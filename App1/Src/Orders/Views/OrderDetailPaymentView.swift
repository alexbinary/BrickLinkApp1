
import SwiftUI



struct OrderDetailPaymentView: View {
    
    
    @Environment(\.orderStore)
    var orderStore: OrderStoreProtocol!
    
    
    let order: Order
    
    init(_ order: Order) {
        self.order = order
    }
    
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 96) {
            
            VStack(alignment: .leading) {
                
                Text("􂙡 Address").font(.caption).foregroundStyle(.secondary)
                OrderAddressView(order)
            }
            .font(.title3)
            
            Spacer()
            
            VStack(alignment: .leading) {
                
                OrderCostView(order)
                    .padding(.leading)
                
                OrderIncomeTransactionView(order)
                    .padding()
                    .roundedContainer(style: .secondary)
            }
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
