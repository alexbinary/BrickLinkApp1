
import SwiftUI



struct OrderChecklistView: View {

    
    @Environment(\.orderStore)
    var orderStore: OrderStoreProtocol!
    
    
    let order: Order
    
    init(_ order: Order) {
        self.order = order
    }
    
    
    @State
    var collapsedSections: Set<ChecklistData.SectionData.ID> = []
    @State
    var animated = false
    
    
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
                                                .transition(.scale)
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
                                    Text(section.title).checklistTitle()
                                        .strikethrough(section.state != .pending)
                                    if !isExpandedBinding.wrappedValue {
                                        CheckView(state: section.state, mandatory: section.mandatory)
                                            .transition(.scale)
                                    }
                                }
                            }
                        )
                        .fixedSize()
                    }
                    
                    let closed = orderStore.macroStatus(for: order).isOneOf([.recentlyClosed, .closed])

                    HStack {
                        Color.clear.frame(width: 3, height: 0)
                        Text(OrderMacroStatus.closed.descriptionWithPicto).checklistTitle()
                            .strikethrough(closed)
                        if closed {
                            CheckView(state: .validated)
                                .transition(.scale)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            updateCollapsedSections(from: checklist, animated: false)
        }
        .onChange(of: checklist, initial: false) {
            updateCollapsedSections(from: checklist, animated: true)
        }
        .animation(.default, value: checklist)
        .animation(.default, value: collapsedSections)
    }
    
    
    func updateCollapsedSections(from checklist: ChecklistData, animated: Bool) {
        
        var transaction = SwiftUI.Transaction()
        transaction.disablesAnimations = !animated
        withTransaction(transaction) {
            
            let completedSections = checklist.sections.filter { $0.state != .pending }
            collapsedSections = Set(completedSections.map(\.id))
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
