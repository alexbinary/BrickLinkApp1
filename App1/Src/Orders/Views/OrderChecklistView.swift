
import SwiftUI
import Core



struct OrderChecklistView: View {

    
    @Environment(OrderUserStore.self)
    var orderStore 
    
    
    let order: OrderDetails
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
    var body: some View {

        let checklist = orderStore.checklist(forOrderWithId: order.id)
        
        VStack(alignment: .leading, spacing: 12) {
            
            HeaderTitleView(label: "􀼏 Status").padding(.bottom, 6)
            
            ScrollView {
                
                Grid(alignment: .leading) {
                    
                    ForEach(checklist.sections) { section in
                        
                        Text(section.title).checklistTitle().padding(.vertical, 6)
                        
                        ForEach(section.items) { item in
                            
                            GridRow {
                                CheckView(checked: item.checked, mandatory: item.mandatory)
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
    
    let env = createEnv()
    let order = env.stores.order.orderDetails.first!
    
    OrderChecklistView(order)
        .inject(env)
}
