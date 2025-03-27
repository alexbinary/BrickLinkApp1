
import SwiftUI
import Core



struct OrderLink<Label>: View where Label: View {
    
    
    @Environment(OrderStore.self)
    var orderStore
    
    
    let order: OrderSummary
    let label: () -> Label
    
    
    init(_ order: OrderSummary, label: @escaping () -> Label) {
        self.order = order
        self.label = label
    }
    
    
    var body: some View {

        Link(destination: orderStore.url(forDetailsOfOrderWithId: order.id)!, label: label)
    }
}



#Preview {
    
    let env = createEnv()
    let order = env.stores.order.orderSummaries.first!
    
    OrderLink(order) { Text(order.id) }
}
