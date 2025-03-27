
import Foundation
import Core



@Observable
class NavigationController {
    
    
    var sidebar: SidebarItem = Secrets.Defaults.selectedSidebarItem
    
    
    var orders: [Order.ID] = Secrets.Defaults.ordersActiveNavigationPath
    
    func push(_ order: Order) {
        orders.append(order.id)
    }
    
    
    var resultSelectedOrderIds: Set<Order.ID> = Secrets.Defaults.resultSelectedOrderIds
    var selectedTransactions: Set<Transaction.ID> = []
    
    func resultClearSelectedOrder() {
        resultSelectedOrderIds.removeAll()
    }
}
