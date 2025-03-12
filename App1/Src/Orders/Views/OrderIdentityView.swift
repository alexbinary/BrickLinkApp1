
import SwiftUI



struct OrderIdentityView: View {

    
    @EnvironmentObject
    var app: AppController
    
    
    let order: OrderDetails
    var orderSummary: OrderSummary { app.orderSummary(forOrderWithId: order.id)! }
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
    var body: some View {

        VStack(alignment: .leading, spacing: 12) {
            
            Grid(alignment: .leading, verticalSpacing: 0) {
                
                GridRow {
                    Text("order").captionSyle()
                    Text("placed").captionSyle()
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
                    Text("status").captionSyle()
                    Text("changed").captionSyle()
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
    let appController = AppController()
    let order = appController.orderDetails.first!
    OrderIdentityView(order)
        .environmentObject(appController)
}
