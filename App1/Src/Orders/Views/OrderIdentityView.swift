
import SwiftUI



struct OrderIdentityView: View {

    
    let order: Order
    
    init(_ order: Order) {
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
                    OrderLink(order) { Text(order.id) }
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
                    Text(order.dateStatusChanged, format: .dateTime)
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
    
    let env = createEnv()
    let order = env.stores.order.orders.first!
    
    OrderIdentityView(order)
        .inject(env)
}
