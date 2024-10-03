
import SwiftUI
import Charts



struct ResultHistoryView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @Binding var selectedOrderIds: Set<OrderDetails.ID>
    
    @State var firstVisibleMonth: BusinessMonth = .current
    @State var lastVisibleMonth: BusinessMonth = .current
    
    @State var selectedMonth: String? = nil
    @State var monthClicked = false
    @State var monthPositionRangesByMonthName: [String: ClosedRange<CGFloat>] = [:]
    
    @State var animateGraph = false
    
    
    var orders: [OrderDetails] {
        
        !selectedOrderIds.isEmpty
            ? appController.orderDetails.filter { selectedOrderIds.contains($0.id) }
            : appController.orderDetails
    }
    
    
    var body: some View {
        
        let ordersByMonth = orders.grouppedByBusinessMonth
        
        let orderMonths = ordersByMonth.map { $0.month }
            .stableUniqueByFirstOccurence.sorted()
        
        let months: [BusinessMonth] = {
            if let first = orderMonths.first {
                return BusinessMonth.allMonths(
                    between: first, and: .current
                )
            } else {
                return [.current]
            }
        }()
        
        let visibleMonths = BusinessMonth.allMonths(
            between: firstVisibleMonth, and: lastVisibleMonth
        )
        
        let visibleOrders = orders
            .filter { visibleMonths.contains($0.date.businessMonth) }
        
        if !selectedOrderIds.isEmpty {
            
            HStack {
                
                Spacer()
                
                let n = selectedOrderIds.count
                Text("􀱢 View restricted to \(n) selected order\(n == 1 ? "" : "s")")
                
                Button {
                    self.selectedOrderIds.removeAll()
                } label: {
                    Text("􀁠")
                }
                .padding(.horizontal)
                .buttonStyle(.plain)
                
                Spacer()
            }
            .padding()
            .background(Color.accentColor.opacity(0.1))
        }
            
        VStack(spacing: 48) {
            
            HStack {
                
                let buttons: [(label: String, firstVisibleMonth: BusinessMonth, lastVisibleMonth: BusinessMonth)] = [
                    (label: "YTD", firstVisibleMonth: .firstOfYear, lastVisibleMonth: .current),
                    (label: "Last 6m", firstVisibleMonth: .current.offset(by: -5), lastVisibleMonth: .current),
                    (label: "12m", firstVisibleMonth: .current.offset(by: -11), lastVisibleMonth: .current),
                    (label: "24m", firstVisibleMonth: .current.offset(by: -23), lastVisibleMonth: .current),
                    (label: "36m", firstVisibleMonth: .current.offset(by: -35), lastVisibleMonth: .current),
                ]
                
                ForEach(buttons, id: \.label) { btn in
                    
                    Button {
                        self.setVisibleMonths(first: btn.firstVisibleMonth, last: btn.lastVisibleMonth)
                    } label: {
                        if firstVisibleMonth == btn.firstVisibleMonth && lastVisibleMonth == btn.lastVisibleMonth {
                            Text(btn.label).fontWeight(.bold)
                        } else {
                            Text(btn.label)
                        }
                    }
                }
                
                Text("-").opacity(0.1)
                
                Picker("From", selection: $lastVisibleMonth) {
                    ForEach(months.filter { $0 >= firstVisibleMonth } .reversed()) { month in
                        Text(month.name).tag(month)
                    }
                }
                
                Picker("back to", selection: $firstVisibleMonth) {
                    ForEach(months.filter { $0 <= lastVisibleMonth } .reversed()) { month in
                        Text(month.name).tag(month)
                    }
                }
            }
            
            Chart {
                
                ForEach(visibleMonths.sorted().reversed()) { month in
                    
                    let orders = ordersByMonth[month]
                    
                    let totalItems = orders.reduce(0) { $0 + $1.subTotal }
                    let totalShipping = orders.reduce(0) { $0 + $1.shippingCost }
                    
                    let totalIncome = totalItems + totalShipping
                    
                    BarMark(
                        x: .value("Month", month.name),
                        y: .value("Total items", totalIncome),
                        width: 20
                    )
                    .foregroundStyle(by: .value("Income type", "Income"))
                    .annotation(position: .top) {
                        if totalIncome != 0 {
                            Text(String(format:"%.2f €", abs(totalIncome)))
                                .signedAmountColor(.income)
                        }
                    }
                    
                    let totalItemCost: Float = 0
                    
                    let totalShippingCost = orders.reduce(0) { $0 + (appController.shippingCost(forOrderWithId: $1.id) ?? 0) }
                    
                    let totalFees = orders.reduce(0) { (total: Float, order) in
                        
                        var fees: Float = 0
                        
                        if let income = appController.transactions.first(where: { $0.type == .orderIncome && $0.orderRefIn == order.id })?.amount {
                        
                            fees = order.grandTotal - income
                        }
                        
                        return total + fees
                    }
                    
                    let totalExpense = totalItemCost + totalShippingCost + totalFees
                    
                    BarMark(
                        x: .value("Month", month.name),
                        y: .value("Total items cost", -totalExpense),
                        width: 20
                    )
                    .foregroundStyle(by: .value("Cost type", "Expense"))
                    .annotation(position: .bottom) {
                        if totalExpense != 0 {
                            Text(String(format:"%.2f €", abs(totalExpense)))
                                .signedAmountColor(.expense)
                        }
                    }
                }
            }
            .chartForegroundStyleScale { (value: String) in
                
                switch value {
                case "Income": return green
                case "Expense": return red
                default: return Color.accentColor
                }
            }
            .chartOverlay { chart in
                
                Color.clear
                    .onContinuousHover { phase in
                        
                        switch phase {
                        case .active(let mouse):
                            
                            selectedMonth = chart.value(atX: mouse.x)
                            
                            for month in visibleMonths {
                                monthPositionRangesByMonthName[month.name] = chart.positionRange(forX: month.name)!
                            }
                            
                        case .ended:
                            
                            if !monthClicked {
                                selectedMonth = nil
                            }
                        }
                    }
                    .onTapGesture {
                        
                        self.monthClicked.toggle()
                    }
            }
            .chartBackground { chart in
                
                GeometryReader { geometry in
                    
                    let plotFrame = geometry[chart.plotFrame!]

                    if let monthName = selectedMonth,
                       let range = monthPositionRangesByMonthName[monthName] {
                        
                        let size = CGSize(
                            width: range.upperBound - range.lowerBound,
                            height: plotFrame.maxY - plotFrame.minY
                        )
                        let offset = CGPoint(
                            x: range.lowerBound,
                            y: 0
                        )
                        ZStack {
                            Rectangle()
                                .size(size)
                                .offset(offset)
                                .fill(Color.accentColor)
                                .opacity(0.1)
                            Rectangle()
                                .size(size)
                                .offset(offset)
                                .stroke(Color.accentColor, lineWidth: 3)
                        }
                    }
                }
            }
            .frame(height: 200)
            .animation(.easeOut(duration: 0.2), value: animateGraph ? visibleMonths : nil)
            .onAppear {
                DispatchQueue.main.async {
                    self.animateGraph = true
                }
            }
            
            HStack {
                
                if let month = months.first(where: { $0.name == selectedMonth }) {
                    
                    let orders = ordersByMonth[month]
                    
                    let totalItems = orders.reduce(0) { $0 + $1.subTotal }
                    let totalShipping = orders.reduce(0) { $0 + $1.shippingCost }
                    
                    let totalItemCost: Float = 0
                    
                    let totalShippingCost = orders.reduce(0) { $0 + (appController.shippingCost(forOrderWithId: $1.id) ?? 0) }
                    
                    let totalFees = orders.reduce(0) { (total: Float, order) in
                        
                        var fees: Float = 0
                        
                        if let income = appController.transactions.first(where: { $0.type == .orderIncome && $0.orderRefIn == order.id })?.amount {
                            
                            fees = order.grandTotal - income
                        }
                        
                        return total + fees
                    }
                    
                    let totalResult = totalItems + totalShipping - totalItemCost - totalShippingCost - totalFees
                    
                    let totalIncome = totalItems + totalShipping
                    let totalExpense = totalItemCost + totalShippingCost + totalFees
                    
                    let profitMargin = (totalIncome - totalExpense) / totalIncome
                    
                    ResultCircleView(
                        title: month.name,
                        subtitle: "Selected",
                        totalItems: totalItems,
                        totalShipping: totalShipping,
                        totalItemCost: totalItemCost,
                        totalShippingCost: totalShippingCost,
                        totalFees: totalFees,
                        totalResult: totalResult,
                        profitMargin: profitMargin,
                        circleViewVisible: true
                    )
                    
                    Color.clear.frame(width: 120, height: 0)
                }
                
                if selectedMonth == nil || self.monthClicked {
                    
                    let orders = visibleOrders
                    
                    let totalItems = orders.reduce(0) { $0 + $1.subTotal }
                    let totalShipping = orders.reduce(0) { $0 + $1.shippingCost }
                    
                    let totalItemCost: Float = 0
                    
                    let totalShippingCost = orders.reduce(0) { $0 + (appController.shippingCost(forOrderWithId: $1.id) ?? 0) }
                    
                    let totalFees = orders.reduce(0) { (total: Float, order) in
                        
                        var fees: Float = 0
                        
                        if let income = appController.transactions.first(where: { $0.type == .orderIncome && $0.orderRefIn == order.id })?.amount {
                            
                            fees = order.grandTotal - income
                        }
                        
                        return total + fees
                    }
                    
                    let totalResult = totalItems + totalShipping - totalItemCost - totalShippingCost - totalFees
                    
                    let totalIncome = totalItems + totalShipping
                    let totalExpense = totalItemCost + totalShippingCost + totalFees
                    
                    let profitMargin = (totalIncome - totalExpense) / totalIncome
                    
                    let monthsSpan = {
                        if let first = visibleMonths.first,
                           let last = visibleMonths.last {
                            return BusinessMonth.allMonths(between: first, and: last)
                        } else {
                            return []
                        }
                    }().count
                    
                    let canAverage = monthsSpan > 0
                    if canAverage {
                        
                        let averageTotalItems = totalItems / Float(monthsSpan)
                        let averageTotalShipping = totalShipping / Float(monthsSpan)
                        let averageTotalItemCost = totalItemCost / Float(monthsSpan)
                        let averageTotalShippingCost = totalShippingCost / Float(monthsSpan)
                        let averageTotalFees = totalFees / Float(monthsSpan)
                        let averageTotalResult = totalResult / Float(monthsSpan)
                        
                        ResultCircleView(
                            title: "Average",
                            subtitle: "",
                            totalItems: averageTotalItems,
                            totalShipping: averageTotalShipping,
                            totalItemCost: averageTotalItemCost,
                            totalShippingCost: averageTotalShippingCost,
                            totalFees: averageTotalFees,
                            totalResult: averageTotalResult,
                            profitMargin: profitMargin,
                            circleViewVisible: false
                        )
                    }
                    
                    ResultCircleView(
                        title: "Total",
                        subtitle: "",
                        totalItems: totalItems,
                        totalShipping: totalShipping,
                        totalItemCost: totalItemCost,
                        totalShippingCost: totalShippingCost,
                        totalFees: totalFees,
                        totalResult: totalResult,
                        profitMargin: profitMargin,
                        circleViewVisible: true
                    )
                }
            }
            
            VStack(alignment: .leading) {
                
                let titleSuffix = {
                    if let month = months.first(where: { $0.name == selectedMonth }) {
                        return " for \(month.name)"
                    } else {
                        return ""
                    }
                }()
                
                Text("Most profitable orders"+titleSuffix).font(.title3)
                
                Table(of: OrderDetails.self) {
                    
                    TableColumn("ID", value: \.id)
                    
                    TableColumn("Date") { order in
                        Text(order.date, format: .dateTime)
                    }
                    
                    TableColumn("Buyer", value: \.buyer)
                    
                    TableColumn("Profit margin") { order in
                        
                        let profitMargin = appController.profitMargin(for: order)
                        
                        Text(
                            abs(profitMargin),
                            format: .percent.precision(.fractionLength(0))
                        ).signedAmountColor(profitMargin)
                    }
                    
                    TableColumn("Subtotal (items)") { order in
                        Text(
                            abs(order.subTotal),
                            format: .currency(code: "EUR").presentation(.isoCode)
                        ).signedAmountColor(.income)
                    }
                    
                    TableColumn("Total items cost") { order in
                        Text(
                            0,
                            format: .currency(code: "EUR").presentation(.isoCode)
                        ).signedAmountColor(.expense)
                    }
                    
                    TableColumn("Shipping") { order in
                        Text(
                            abs(order.shippingCost),
                            format: .currency(code: "EUR").presentation(.isoCode)
                        ).signedAmountColor(.income)
                    }
                    
                    TableColumn("Shipping cost") { order in
                        Text(
                            abs(appController.shippingCost(forOrderWithId: order.id) ?? 0),
                            format: .currency(code: "EUR").presentation(.isoCode)
                        ).signedAmountColor(.expense)
                    }
                    
                    TableColumn("Fees") { order in
                        
                        if let transactionAmount = appController.transactions.first(where: { $0.type == .orderIncome && $0.orderRefIn == order.id })?.amount {
                            
                            let fees = order.grandTotal - transactionAmount
                            
                            Text(
                                abs(fees),
                                format: .currency(code: "EUR").presentation(.isoCode)
                            ).signedAmountColor(.expense)
                        }
                    }
                    
                } rows: {
                    
                    let sourceOrders = {
                        if let month = months.first(where: { $0.name == selectedMonth }) {
                            return ordersByMonth[month]
                        } else {
                            return visibleOrders
                        }
                    }()
                    
                    let orders = sourceOrders.sorted {
                        (
                            (appController.profitMargin(for: $0)*100).rounded(),
                            $0.date
                        ) > (
                            (appController.profitMargin(for: $1)*100).rounded(),
                            $1.date
                        )
                    }
                    
                    let baseNumber = 5
                    let number = selectedMonth == nil
                        ? max(3 * visibleMonths.count, baseNumber)
                        : baseNumber
                    
                    ForEach(orders.limit(number)) { order in
                        TableRow(order)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            
            self.setVisibleMonths(first: .current.offset(by: -5), last: .current)
        }
        .onChange(of: selectedOrderIds) { oldValue, newValue in
            
            let allPossibleMonthsSorted = orders
                .grouppedByBusinessMonth.map { $0.month }
                .stableUniqueByFirstOccurence.sorted()
            
            let earliestPossibleMonth = allPossibleMonthsSorted.first ?? .current
            let latestPossibleMonth = allPossibleMonthsSorted.last ?? .current
            
            if selectedOrderIds.isEmpty {
                self.setVisibleMonths(first: .current.offset(by: -5), last: .current)
            } else {
                self.setVisibleMonths(first: earliestPossibleMonth, last: latestPossibleMonth)
            }
        }
    }
    
    
    func setVisibleMonths(first: BusinessMonth, last: BusinessMonth) {
        
        let allPossibleMonthsSorted = orders
            .grouppedByBusinessMonth.map { $0.month }
            .stableUniqueByFirstOccurence.sorted()
        
        let earliestPossibleMonth = allPossibleMonthsSorted.first ?? .current
        let latestPossibleMonth = allPossibleMonthsSorted.last ?? .current
        
        self.firstVisibleMonth = max(first, earliestPossibleMonth)
        self.lastVisibleMonth = min(last, latestPossibleMonth)
    }
}
