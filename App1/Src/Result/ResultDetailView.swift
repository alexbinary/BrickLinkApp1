
import SwiftUI
import Charts



struct ResultDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let selectedOrderIds: Set<OrderDetails.ID>
    
    
    var body: some View {
        
        let allOrders = appController.orderSummaries.compactMap {
            appController.orderDetails(forOrderWithId: $0.id)
        }
        
        let allOrdersByMonth = allOrders.grouppedByMonth
        
        ScrollView {
            
            VStack(spacing: 36) {
                
                if !selectedOrderIds.isEmpty {
                    
                    ResultDetailDashboardView(
                        orders: allOrders.filter { selectedOrderIds.contains($0.id) },
                        title: "Selection"
                    )
                    
                } else {
                    
                    let month = Date.currentMonth
                    let orders = allOrdersByMonth
                        .first(where: { $0.month == month })?.elements ?? []
                    
                    ResultDetailDashboardView(
                        orders: orders,
                        title: month
                    )
                }
                
                Divider()
            }
            .padding(24)
        }
    }
}
