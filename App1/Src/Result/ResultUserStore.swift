
import Foundation



@Observable
class ResultUserStore {
    
    
    private let resultStore: ResultStore
    
    
    init(resultStore: ResultStore) {
        self.resultStore = resultStore
    }
    
    
    public func fees(for order: OrderDetails) -> Float? {
        
        resultStore.fees(for: order)
    }
    
    
    public func profitMargin(for order: OrderDetails) -> Float? {
        
        resultStore.profitMargin(for: order)
    }
    
    
    public var resultDashboardModel: ResultDashboardModel {
        
        resultStore.resultDashboardModel
    }
}
