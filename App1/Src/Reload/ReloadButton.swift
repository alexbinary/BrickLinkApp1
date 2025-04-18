
import SwiftUI



struct ReloadButton: View {

    
    @Environment(\.navigationController)
    var nav: NavigationControllerProtocol!
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    @Environment(\.orderStore)
    var orderStore: OrderStoreProtocol!
    
    @Environment(\.feedbackStore)
    var feedbackStore: FeedbackStoreProtocol!
    
    @Environment(\.updateStore)
    var updateStore: UpdateStoreProtocol!
    
    
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
    
    
    @State
    var currentOperationTag: OperationTag? = nil
    
    
    var isLoading: Bool {
        
        if let tag = currentOperationTag {
            return updateStore.isLoadingOperations(withTag: tag)
        }
        return false
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
        
        currentOperationTag = .new
        
        switch item {
        
        case .inventoryAndColors:
            
            Task { await inventoryStore.hardRefreshInventories(currentOperationTag) }
            Task { await catalog.loadColors(currentOperationTag) }
        
        case .orders:
            
            Task { await orderStore.hardRefreshOrders(currentOperationTag) }
        
        case .order(let orderId, let includeDetails):
            
            Task { await orderStore.hardRefresh(orderWithId: orderId, currentOperationTag) }
            if includeDetails {
                Task {await orderStore.hardRefreshDetails(forOrderWithId: orderId, currentOperationTag) }
            }
            
        case .items(let orderId):

            Task { await orderStore.hardRefreshItems(forOrderWithId: orderId, currentOperationTag) }
            
        case .feedbacks(let orderId):
            
            Task { await feedbackStore.hardRefreshFeedbacks(forOrderWithId: orderId, currentOperationTag) }
        }
    }
}



#Preview {
    ReloadButton()
}
