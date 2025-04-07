
import Foundation
import Core



@Observable
class NavigationController {
    
    
    var sidebar: SidebarItem = Secrets.Defaults.selectedSidebarItem
    
    
    var orderStack: [Order.ID] = Secrets.Defaults.ordersActiveNavigationPath {
        didSet {
            orderDetailTab = nil
        }
    }
    
    func push(_ order: Order) {
        orderStack.append(order.id)
    }
    
    
    var orderDetailTab: OrderDetailTab? = Secrets.Defaults.orderDetailActiveTab
    
    
    var resultSelectedOrderIds: Set<Order.ID> = Secrets.Defaults.resultSelectedOrderIds
    var selectedTransactions: Set<Transaction.ID> = []
    
    func resultClearSelectedOrder() {
        resultSelectedOrderIds.removeAll()
    }
}
