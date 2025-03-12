
import SwiftUI



struct OrderLink<Label>: View where Label: View {
    
    
    @EnvironmentObject
    var app: AppController

    let order: OrderSummary
    let label: () -> Label
    
    
    init(_ order: OrderSummary, label: @escaping () -> Label) {
        self.order = order
        self.label = label
    }
    
    
    var body: some View {

        Link(destination: app.url(forDetailsOfOrderWithId: order.id)!, label: label)
    }
}



#Preview {
    let appController = AppController()
    let order = appController.orderSummaries.first!
    OrderLink(order) { Text(order.id) }
}
