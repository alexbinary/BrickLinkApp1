
import SwiftUI



struct PreviewOrderStore: OrderStoreProtocol {
    
    
    func url(forDetailsOf order: Order) -> URL? {
        
        return URL(string: "http://example.com")
    }
    
    var orders: [Order] {
        
        return []
    }
    
    func order(withId orderId: Order.ID) -> Order? {
        
        return .previewOrder1
    }
    
    func details(for order: Order) -> OrderDetails? {
        
        return nil
    }
    
    func isLoadingDetails(for order: Order) -> Bool {
        
        return false
    }
    
    func updateStatus(of order: Order, to status: OrderStatus) async {
        
    }
    
    func isUpdatingStatus(of order: Order, to status: OrderStatus) -> Bool {
        
        return false
    }
    
    func updateTrackingNo(of order: Order, to trackingNo: TrackingNo) async {
        
    }
    
    func sendDriveThru(for order: Order) async {
        
    }
    
    func isSendingDriveThru(for order: Order) -> Bool {
        
        return false
    }
    
    func state(of item: ChecklistItem, for order: Order) -> ChecklistState {
        
        return .pending
    }
    
    func order(_ order: Order, validates item: ChecklistItem) -> Bool {
        
        return false
    }
    
    func checklistData(for order: Order) -> ChecklistData {
        
        return ChecklistData(sections: [])
    }
    
    func macroStatus(for order: Order) -> OrderMacroStatus {
        
        return .validatePayment
    }
    
    func ordersMainListSections(restrictingToOrdersMatching searchText: String) -> [OrdersMainListSection] {
        
        return []
    }
    
    func softRefreshOrders() async {
        
    }
    
    func hardRefreshOrders(_ operationTag: OperationTag?) async {
        
    }
    
    func hardRefresh(orderWithId orderId: Order.ID, _ operationTag: OperationTag?) async {
        
    }
    
    func hardRefreshDetails(forOrderWithId orderId: Order.ID, _ operationTag: OperationTag?) async {
        
    }
    
    func softRefreshItems(for order: Order) async {
        
    }
    
    func hardRefreshItems(forOrderWithId orderId: Order.ID, _ operationTag: OperationTag?) async {
        
    }

    func ordersThatNeedCompletedAndGiveFeedback(_ orders: [Order]) -> [Order] {
        
        return []
    }
    
    func ordersThatNeedGiveFeedback(_ orders: [Order]) -> [Order] {
        
        return []
    }
    
    func ordersToShipAndSendDriveThru(_ orders: [Order]) -> [Order] {
        
        return []
    }
    
    func ordersThatNeedAction(_ orders: [Order]) -> [Order] {
        
        return []
    }
    
    func performActions(for orders: [Order]) async {
        
    }
    
    var numberForSidebarBadge: Int {
        
        return 42
    }
}
