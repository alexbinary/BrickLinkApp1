
import SwiftUI



struct PreviewResultStore: ResultStoreProtocol {


    func fees(for order: Order) -> Float? {
        
        return nil
    }
    
    func profitMargin(for order: Order) -> Float? {
        
        return nil
    }
    
    var resultDashboardModel: ResultDashboardModel {
        
        return ResultDashboardModel(
            periodNLastDays: 30,
            orders: [],
            totalItems: 0,
            totalShipping: 0,
            totalItemCost: 0,
            totalShippingCost: 0,
            totalFees: 0,
            totalRefund: 0,
            totalResult: 0,
            profitMargin: 0
        )
    }
}
