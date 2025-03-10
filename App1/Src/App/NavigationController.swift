
import Foundation



@Observable
class NavigationController {
    
    
    var sidebar: SidebarItem = Secrets.Defaults.selectedSidebarItem
    
    
    var orders: [OrderSummary.ID] = Secrets.Defaults.ordersActiveNavigationPath
    
    func pushOrder(_ orderId: OrderSummary.ID) {
        orders.append(orderId)
    }
    
    
    var resultSelectedOrderIds: Set<OrderSummary.ID> = Secrets.Defaults.resultSelectedOrderIds
    var selectedTransactions: Set<Transaction.ID> = []
    
    func resultClearSelectedOrder() {
        resultSelectedOrderIds.removeAll()
    }
}
