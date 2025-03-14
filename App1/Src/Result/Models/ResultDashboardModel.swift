
import Foundation



struct ResultDashboardModel {
    
    
    let periodNLastDays: Int
    let orders: [OrderDetails]
    
    let totalItems: Float
    let totalShipping: Float
    
    let totalItemCost: Float
    let totalShippingCost: Float
    
    let totalFees: Float
    let totalRefund: Float
    
    let totalResult: Float
    let profitMargin: Float
}
