
import SwiftUI



struct OrderChecklistView: View {

    
    @Environment(OrderChecklistController.self)
    var orderChecklistController
    
    
    let order: OrderDetails
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
    var body: some View {

        let checklistData = orderChecklistController.checklistData(forOrderWithId: order.id)
        
        VStack(alignment: .leading, spacing: 12) {
            
            HeaderTitleView(label: "􀼏 Status").padding(.bottom, 6)
            
            ScrollView {
                
                Grid(alignment: .leading) {
                    
                    ForEach(checklistData.sections, id: \.title) { section in
                        
                        Text(section.title).checklistTitle()
                            .padding(.vertical, 6)
                        
                        ForEach(section.items, id: \.label) { item in
                            
                            GridRow {
                                CheckStatusView(status: item.checked, mandatory: item.mandatory)
                                Text(item.label)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .scrollIndicators(.hidden)
        }
    }
}



extension View {
    
    
    @ViewBuilder func checklistTitle() -> some View {
        
        self.font(.title3).opacity(0.5)
    }
}



#Preview {
    
    let controllers = AppController.createControllers()
    let orderStore = controllers.orderStore
    let pickingController = controllers.pickingController
    let trackingController = controllers.trackingController
    let orderChecklistController = controllers.orderChecklistController
    
    let order = orderStore.orderDetails.first!
    
    OrderChecklistView(order)
        .environment(orderStore)
        .environment(pickingController)
        .environment(trackingController)
        .environment(orderChecklistController)
}
