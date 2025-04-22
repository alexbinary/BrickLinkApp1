
import SwiftUI



class PreviewNavigationController: NavigationControllerProtocol {
    
    
    var sidebar: SidebarItem = .upload
    
    var orderStack: [Order.ID] = []
    
    func push(_ order: Order) {
        
    }
    
    var orderDetailTab: OrderDetailTab? = nil
    
    var resultSelectedOrderIds: Set<Order.ID> = []
    
    var selectedTransactions: Set<Transaction.ID> = []
    
    func resultClearSelectedOrder() {
        
    }
}
