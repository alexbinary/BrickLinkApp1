
import Foundation



protocol NavigationControllerProtocol: AnyObject {
    
    var sidebar: SidebarItem { get set }
    
    var orderStack: [Order.ID] { get set }
    func push(_ order: Order)
    
    var orderDetailTab: OrderDetailTab? { get set }
    
    var resultSelectedOrderIds: Set<Order.ID> { get set }
    var selectedTransactions: Set<Transaction.ID> { get set }
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
