
import SwiftUI
import Core



struct OrderLink<Label>: View where Label: View {
    
    
    @Environment(OrderStore.self)
    var orderStore
    
    
    let order: Order
    let label: () -> Label
    
    
    init(_ order: Order, label: @escaping () -> Label) {
        self.order = order
        self.label = label
    }
    
    
    var body: some View {

        Link(destination: orderStore.url(forDetailsOf: order)!, label: label)
    }
}



#Preview {
    
    let env = createEnv()
    let order = env.stores.order.orders.first!
    
    OrderLink(order) { Text(order.id) }
}
