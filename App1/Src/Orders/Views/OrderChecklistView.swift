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
                                HStack {
                                    let state = sectionState(for: section)
                                    Text(section.title).checklistTitle()
                                        .strikethrough(state.state != .pending)
                                    if !isExpandedBinding.wrappedValue {                                        
                                        CheckView(state: state.state, mandatory: state.mandatory)
                                    }
                                }
                            }
                        )
                        .fixedSize()
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .onChange(of: checklist, initial: true) {
            let completedSections = checklist.sections.filter { sectionState(for: $0).state != .pending }
            collapsedSections = Set(completedSections.map(\.id))
        }
    }
    
    
    private func sectionState(for section: ChecklistData.SectionData) -> (state: ChecklistState, mandatory: Bool) {
        
        let states = section.items.map(\.state)
        let mandatory = section.items.map(\.mandatory).contains(true)
        
        if states.contains(.pending) {
            return (state: .pending, mandatory: mandatory)
        }
        
        if states.contains(.validated) {
            return (state: .validated, mandatory: mandatory)
        }
        
        return (state: .notApplicable, mandatory: mandatory)
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
