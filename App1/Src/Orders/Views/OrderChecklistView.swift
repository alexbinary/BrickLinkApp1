import SwiftUI
import Core



struct OrderChecklistView: View {

    
    @Environment(OrderStore.self)
    var orderStore 
    
    
    let order: Order
    
    init(_ order: Order) {
        self.order = order
    }
    
    
    var body: some View {

        let checklist = orderStore.checklistData(for: order)
        
        VStack(alignment: .leading, spacing: 12) {
            
            HeaderTitleView(label: "􀼏 Status").padding(.bottom, 6)
            
            ScrollView {
                
                Grid(alignment: .leading) {
                    
                    ForEach(checklist.sections) { section in
                        
                        Text(section.title).checklistTitle().padding(.vertical, 6)
                        
                        ForEach(section.items) { item in
                            
                            GridRow {
                                CheckView(state: item.state, mandatory: item.mandatory)
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
    let order = env.stores.order.orders.first!
    
    OrderChecklistView(order)
        .inject(env)
}
