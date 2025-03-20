
import SwiftUI



struct OrderLink<Label>: View where Label: View {
    
    
    let order: OrderSummary
    let label: () -> Label
    
    
    init(_ order: OrderSummary, label: @escaping () -> Label) {
        self.order = order
        self.label = label
    }
    
    
    var body: some View {

        Link(destination: BrickLinkUtility.url(forDetailsOfOrderWithId: order.id)!, label: label)
    }
}



#Preview {
    
    let controllers = AppController.createControllers()
    
    let orderController = controllers.orderController
    let order = orderController.orderSummaries.first!
    
    OrderLink(order) { Text(order.id) }
}
