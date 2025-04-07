
import SwiftUI
import Core



struct ReloadButton: View {

    
    @Environment(NavigationController.self)
    var nav
    
    @Environment(Catalog.self)
    var catalog
    
    @Environment(InventoryStore.self)
    var inventoryStore
    
    @Environment(OrderStore.self)
    var orderStore
    
    @Environment(FeedbackStore.self)
    var feedbackStore
    
    
    var items: [ReloadItem] {
        
        var items: [ReloadItem] = []
        switch nav.sidebar {
            
        case .orders:
            if let orderId = nav.orderStack.last {
        
                switch nav.orderDetailTab {
                
                case .picking:
                    items.append(contentsOf: [.order(orderId: orderId, includeDetails: false), .items(orderId: orderId), .inventoryAndColors])
                
                case .shipping:
                    items.append(contentsOf: [.order(orderId: orderId, includeDetails: true)])
                    
                case .feedback:
                    items.append(contentsOf: [.order(orderId: orderId, includeDetails: false), .feedbacks(orderId: orderId)])
                    
                default:
                    items.append(contentsOf: [.order(orderId: orderId, includeDetails: false)])
                }
                
            } else {
                items.append(contentsOf: [.orders])
            }
            
        case .upload:
            items.append(contentsOf: [.inventoryAndColors])
            
        default:
            break
        }
        
        return items
    }
    
    
    var body: some View {

        Menu {
            
            ForEach(items) { item in
                Button(label(for: item)) { performAction(for: item) }
            }
            
        } label: {
            Text("􀅈").padding(.horizontal)
        }

        primaryAction: {
            items.forEach { performAction(for: $0) }
        }
    }
    
    
    func label(for item: ReloadItem) -> String {
        
        switch item {
        
        case .inventoryAndColors:
            "Reload inventory"
        
        case .orders:
            "Reload orders"
        
        case .order:
            "Reload order"
        
        case .items:
            "Reload items"
        
        case .feedbacks:
            "Reload feedbacks"
        }
    }
    
    
    func performAction(for item: ReloadItem) {
        
        switch item {
        
        case .inventoryAndColors:
            
            Task { await inventoryStore.softRefreshInventories() }
            Task { await catalog.loadColors() }
        
        case .orders:
            
            Task { await orderStore.hardRefreshOrders() }
        
        case .order(let orderId, let includeDetails):
            
            Task { await orderStore.hardRefresh(orderWithId: orderId) }
            if includeDetails {
                Task {await orderStore.hardRefreshDetails(forOrderWithId: orderId) }
            }
            
        case .items(let orderId):

            Task { await orderStore.hardRefreshItems(forOrderWithId: orderId) }
            
        case .feedbacks(let orderId):
            
            Task { await feedbackStore.hardRefreshFeedbacks(forOrderWithId: orderId) }
        }
    }
}



#Preview {
    ReloadButton()
}
