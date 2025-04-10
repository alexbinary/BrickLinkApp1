import SwiftUI
import Core



struct OrderChecklistView: View {

    
    @Environment(OrderStore.self)
    var orderStore 
    
    
    let order: Order
    
    init(_ order: Order) {
        self.order = order
    }
    
    
    @State
    var collapsedSections: Set<ChecklistData.SectionData.ID> = []
    
    
    var body: some View {

        let checklist = orderStore.checklistData(for: order)
        
        VStack(alignment: .leading, spacing: 12) {
            
            HeaderTitleView(label: "􀼏 Status").padding(.bottom, 6)
            
            ScrollView {
                
                VStack(alignment: .leading) {
                    
                    ForEach(checklist.sections) { section in
                        
                        let isExpandedBinding = Binding(
                            get: { !collapsedSections.contains(section.id) },
                            set: {
                                if $0 { collapsedSections.remove(section.id) }
                                else { collapsedSections.insert(section.id) }
                            }
                        )
                        
                        DisclosureGroup(
                            isExpanded: isExpandedBinding,
                            content: {
                                Grid(alignment: .leading) {
                                    ForEach(section.items) { item in
                                        GridRow {
                                            CheckView(state: item.state, mandatory: item.mandatory)
                                            Text(item.label)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                            },
                            label: {
                                Text(section.title).checklistTitle()
                            }
                        )
                        .fixedSize()
                    }
                }
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
