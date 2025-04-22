
import SwiftUI



class PreviewNavigationController: NavigationControllerProtocol {
    
    
    init(sidebar: SidebarItem? = nil) {
        
        self.sidebar = sidebar ?? .orders
    }
    
    
    var sidebar: SidebarItem
    
    var orderStack: [Order.ID] = []
    
    func push(_ order: Order) {
        
    }
    
    var orderDetailTab: OrderDetailTab? = nil
    
    var resultSelectedOrderIds: Set<Order.ID> = []
    
    var selectedTransactions: Set<Transaction.ID> = []
    
    func resultClearSelectedOrder() {
        
    }
}
