
import SwiftUI



class PreviewNavigationController: NavigationControllerProtocol {
    
    
    init(defaultSelectedSidebarItem: SidebarItem? = nil) {
        
        self.sidebar = defaultSelectedSidebarItem ?? .orders
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
