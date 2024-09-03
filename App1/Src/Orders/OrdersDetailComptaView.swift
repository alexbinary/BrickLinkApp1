
import SwiftUI



struct OrdersDetailComptaView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let order: Order
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            HeaderTitleView(label: "􀗧 Income")
            
            TransactionListView(transactions: appController.transactions
                .filter { $0.type == .orderIncome && $0.orderRefIn == order.id })
            .frame(minHeight: 75)
            
            Divider()
            
            HeaderTitleView(label: "􀐚 Shipping")
            
            TransactionListView(transactions: appController.transactions
                .filter { $0.type == .orderShipping && $0.orderRefIn == order.id })
            .frame(minHeight: 75)
            
            Divider()
        }
    }
}
