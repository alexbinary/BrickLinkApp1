
import Foundation



public struct ResultDashboardModel {
    
    
    public let periodNLastDays: Int
    public let orders: [Order]
    
    public let totalItems: Float
    public let totalShipping: Float
    
    public let totalItemCost: Float
    public let totalShippingCost: Float
    
    public let totalFees: Float
    public let totalRefund: Float
    
    public let totalResult: Float
    public let profitMargin: Float
}
