
import SwiftUI



struct OrderDetailGeneralView: View {
    
    
    @EnvironmentObject
    var app: AppController
    
    
    let order: OrderDetails
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(alignment: .top, spacing: 96) {
                
                VStack(alignment: .leading) {
                    
                    Text("􂙡 Address").font(.caption).foregroundStyle(.secondary)
                    OrderAddressView(order)
                }
                .font(.title3)
                
                VStack(alignment: .leading) {
                    
                    OrderCostView(order)
                        .padding(.leading)
                    
                    OrderIncomeTransactionView(order)
                        .padding()
                        .roundedContainer(style: .secondary)
                }
            }
            
            Divider()
            
            let statuses: [OrderStatus] = [.paid, .packed, .shipped, .completed]
            
            HStack {
                ForEach(statuses, id: \.self) { status in
                    Button {
                        Task { await app.updateOrderStatus(orderId: order.id, status: status) }
                    } label: {
                        Text(status.rawValue).fontWeight(order.status == status ? .bold : .regular)
                    }
                }
            }
        }
    }
}
