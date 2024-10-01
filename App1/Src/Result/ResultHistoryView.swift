
import SwiftUI
import Charts



struct ResultHistoryView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let selectedOrderIds: Set<OrderDetails.ID>
    
    @State private var selectedMonth: String? = nil
    @State private var monthPositionRangesByMonth: [String: ClosedRange<CGFloat>] = [:]
    
    
    var body: some View {
        
        let allOrders = appController.orderSummaries.compactMap {
            appController.orderDetails(forOrderWithId: $0.id)
        }
        
        let allOrdersByMonth = allOrders.sorted { $0.date < $1.date } .grouppedByMonth
        
        ScrollView {
            
            VStack(spacing: 36) {
                
                if !selectedOrderIds.isEmpty {
                    
                    ResultHistoryNumbersView(
                        orders: allOrders.filter { selectedOrderIds.contains($0.id) },
                        title: "Selection"
                    )
                    
                } else {
                    
                    let month = selectedMonth ?? Date.currentMonth
                    let orders = allOrdersByMonth
                        .first(where: { $0.month == month })?.elements ?? []
                    
                    ResultHistoryNumbersView(
                        orders: orders,
                        title: month
                    )
                }
                
                Divider()
                
                let ordersByMonth = allOrdersByMonth
                let months = ordersByMonth.map { $0.month }
                
                Chart {
                    
                    ForEach(ordersByMonth, id: \.month) { ordersForMonth in
                        
                        let month = ordersForMonth.month
                        let orders = ordersForMonth.elements
                        
                        let totalItems = orders.reduce(0) { $0 + $1.subTotal }
                        
                        BarMark(
                            x: .value("Month", month),
                            y: .value("Total items", totalItems),
                            width: 20
                        )
                        .foregroundStyle(by: .value("Income type", "Items"))
                        .position(by: .value("Type", "Income"))
                        
                        let totalShipping = orders.reduce(0) { $0 + $1.shippingCost }
                        
                        BarMark(
                            x: .value("Month", month),
                            y: .value("Total shipping", totalShipping),
                            width: 20
                        )
                        .foregroundStyle(by: .value("Income type", "Shipping"))
                        .position(by: .value("Type", "Income"))
                        
                        let totalItemCost: Float = 0
                        
                        BarMark(
                            x: .value("Month", month),
                            y: .value("Total items cost", totalItemCost),
                            width: 20
                        )
                        .foregroundStyle(by: .value("Cost type", "Items"))
                        .position(by: .value("Type", "Cost"))
                        
                        let totalShippingCost = orders.reduce(0) { $0 + (appController.shippingCost(forOrderWithId: $1.id) ?? 0) }
                        
                        BarMark(
                            x: .value("Month", month),
                            y: .value("Total shipping cost", totalShippingCost),
                            width: 20
                        )
                        .foregroundStyle(by: .value("Cost type", "Shipping"))
                        .position(by: .value("Type", "Cost"))
                        
                        let totalFees = orders.reduce(0) { (total: Float, order) in
                            
                            var fees: Float = 0
                            
                            if let income = appController.transactions.first(where: { $0.type == .orderIncome && $0.orderRefIn == order.id })?.amount {
                            
                                fees = order.grandTotal - income
                            }
                            
                            return total + fees
                        }
                        
                        BarMark(
                            x: .value("Month", month),
                            y: .value("Total fees", totalFees),
                            width: 20
                        )
                        .foregroundStyle(by: .value("Cost type", "Fees"))
                        .position(by: .value("Type", "Cost"))
                        
                        let totalResult = totalItems + totalShipping - totalItemCost - totalShippingCost - totalFees
                        
                        LineMark(
                            x: .value("Month", month),
                            y: .value("Total result", totalResult)
                        )
                    }
                }
                .chartOverlay { chart in
                    
                    Color.clear
                        .onContinuousHover { phase in
                            
                            switch phase {
                            case .active(let mouse):
                                
                                selectedMonth = chart.value(atX: mouse.x)
                                
                                for month in months {
                                    monthPositionRangesByMonth[month] = chart.positionRange(forX: month)!
                                }
                                
                            case .ended:
                                break
                            }
                        }
                }
                .chartBackground { chart in
                    
                    GeometryReader { geometry in
                        
                        let plotFrame = geometry[chart.plotFrame!]

                        if let month = selectedMonth,
                           let range = monthPositionRangesByMonth[month] {
                            Rectangle()
                                .size(width: range.upperBound - range.lowerBound, height: plotFrame.maxY - plotFrame.minY)
                                .fill(Color.accentColor)
                                .offset(x: range.lowerBound, y: 0)
                                .opacity(0.1)
                        }
                    }
                }
                .frame(minHeight: 200)
                
                if let month = selectedMonth {
                    
                    HStack {
                        
                        let activeIndex = months.firstIndex(where: { $0 == month })!
                        
                        let previousIndex = months.index(before: activeIndex)
                        
                        Button {
                            guard previousIndex >= months.startIndex else { return }
                            selectedMonth = months[previousIndex]
                        } label: {
                            Text("Previous")
                        }
                        .disabled(previousIndex < months.startIndex)
                        
                        Text(month)
                        
                        let nextIndex = months.index(after: activeIndex)
                        
                        Button {
                            guard nextIndex < months.endIndex else { return }
                            selectedMonth = months[nextIndex]
                        } label: {
                            Text("Next")
                        }
                        .disabled(nextIndex >= months.endIndex)
                    }
                }
            }
            .padding(24)
        }
    }
}
