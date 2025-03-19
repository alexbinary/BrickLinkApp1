
import SwiftUI



struct OrderIdentityView: View {

    
    @Environment(OrderStore.self)
    var orderStore
    
    
    let order: OrderDetails
    var orderSummary: OrderSummary { orderStore.orderSummary(forOrderWithId: order.id)! }
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
    var body: some View {

        VStack(alignment: .leading, spacing: 12) {
            
            Grid(alignment: .leading, verticalSpacing: 0) {
                
                GridRow {
                    Text("order").captionStyle()
                    Text("placed").captionStyle()
                }
                GridRow {
                    OrderLink(orderSummary) { Text(order.id) }
                        .font(.title2)
                        .monospacedDigit()
                    Text(order.date, format: .dateTime)
                        .frame(width: 150, alignment: .leading)
                        .monospacedDigit()
                }
            
                GridRow {
                    Text("status").captionStyle()
                    Text("changed").captionStyle()
                }
                GridRow {
                    Text(order.status.rawValue).font(.title3)
                    Text(orderSummary.dateStatusChanged, format: .dateTime)
                        .monospacedDigit()
                }
            }
            
            Grid(alignment: .leading, verticalSpacing: 4) {
                
                GridRow {
                    Text("􀉩").foregroundStyle(.secondary).gridColumnAlignment(.center)
                    Text(order.buyer).gridCellColumns(3)
                }
                
                GridRow {
                    Text("􀍩").foregroundStyle(.secondary).gridColumnAlignment(.center)
                    Text("\(order.items) (\(order.lots))").frame(width: 75, alignment: .leading)
                    
                    Text("􀖧").foregroundStyle(.secondary)
                    Text(order.grandTotal, format: .currency(code: "EUR").presentation(.isoCode)).monospacedDigit()
                }
            }
        }
    }
}



#Preview {
    
    let controllers = AppController.createControllers()
    let orderStore = controllers.orderStore
    
    let order = orderStore.orderDetails.first!
    
    OrderIdentityView(order)
        .environment(orderStore)
}
