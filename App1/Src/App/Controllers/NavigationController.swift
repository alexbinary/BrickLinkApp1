
import Foundation



protocol NavigationControllerProtocol {
    
    var sidebar: SidebarItem { get }
    
    var orderStack: [Order.ID] { get }
    func push(_ order: Order)
    
    var orderDetailTab: OrderDetailTab? { get }
    
    var resultSelectedOrderIds: Set<Order.ID> { get }
    var selectedTransactions: Set<Transaction.ID> { get }
    func resultClearSelectedOrder()
}



@Observable
class NavigationController: NavigationControllerProtocol {
    
    
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
