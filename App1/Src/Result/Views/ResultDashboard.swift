
import SwiftUI
import Charts



struct ResultDashboard: View {
    
    
    @Environment(ResultUserStore.self)
    var resultStore
    
    
    @State var selectedMostProfitableOrder: OrderDetails.ID? = nil
    @State var selectedLeastProfitableOrder: OrderDetails.ID? = nil
    
    
    var body: some View {
        
        VSplitView {
            
            let model = resultStore.resultDashboardModel
            
            let periodNLastDays = model.periodNLastDays
            let orders = model.orders
            
            let totalItems = model.totalItems
            let totalShipping = model.totalShipping
            
            let totalItemCost = model.totalItemCost
            let totalShippingCost = model.totalShippingCost
            
            let totalFees = model.totalFees
            let totalRefund = model.totalRefund
            
            let totalResult = model.totalResult
            let profitMargin = model.profitMargin
            
            VStack(spacing: 24) {
                
                Color.clear.frame(height: 1).padding()
                
                Spacer()
                
                VStack {
                    Text(Date.now, style: .date).font(.title3)
                    Text("Last \(periodNLastDays) days").font(.title)
                }
                
                HStack(spacing: 48) {
                    
                    ResultGridView(
                        totalItems: totalItems,
                        totalShipping: totalShipping,
                        totalItemCost: totalItemCost,
                        totalShippingCost: totalShippingCost,
                        totalFees: totalFees,
                        totalRefund: totalRefund,
                        totalResult: totalResult
                    )
                    
                    let innerCircleSize: CGFloat = 100
                    let outerCircleSize: CGFloat = 140
                    
                    ResultCircleView(
                        income: totalItems + totalShipping,
                        expense: totalItemCost + totalShippingCost + totalFees + totalRefund,
                        profitMargin: profitMargin,
                        innerCircleSize: innerCircleSize,
                        outerCircleSize: outerCircleSize
                    )
                    .frame(width: outerCircleSize, height: outerCircleSize)
                }
                
                Text("Counting only orders with complete data").font(.caption)
                
                Color.clear.frame(height: 1).padding()
                
                Spacer()
            }
            
            VStack {
                
                Color.clear.frame(height: 1).padding()
                
                HStack {
                    ResultOrderList(orders.limit(5),
                                    title: "Most profitable orders", selection: $selectedMostProfitableOrder)
                    ResultOrderList(orders.reversed().limit(5),
                                    title: "Least profitable orders", selection: $selectedLeastProfitableOrder)
                }
            }
        }
        .padding()
    }
}
