
import SwiftUI
import Charts



struct ComptaDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    
    let selectedTransactions: Set<Transaction.ID>
    
    @State private var selectedMonth: String? = nil
    @State private var monthPositionRangesByMonth: [String: ClosedRange<CGFloat>] = [:]
    
    @State private var selectedTransaction: Transaction? = nil
    
    
    var body: some View {
        
        let allTransactions = appController.transactions.sorted { $0.date > $1.date }
        
        ScrollView {
            
            VStack(spacing: 36) {
                
                if !selectedTransactions.isEmpty {
                    
                    ComptaDetailDashboardItemView(
                        transactions: allTransactions.filter { selectedTransactions.contains($0.id) },
                        title: "Selection"
                    )
                    
                } else {
                    
                    let month = Date.currentMonth
                    let transactions = allTransactions.sorted { $0.date > $1.date } .grouppedByMonth
                        .first(where: { $0.month == month })?.transactions ?? []
                    
                    ComptaDetailDashboardItemView(
                        transactions: transactions,
                        title: month
                    )
                }
                
                Divider()
                
                let transactionsByMonth = allTransactions.sorted { $0.date < $1.date } .grouppedByMonth
                let months = transactionsByMonth.map { $0.month }
                
                Chart {
                    
                    ForEach(transactionsByMonth, id: \.month) { transactionsForMonth in
                        
                        let month = transactionsForMonth.month
                        
                        let incomeTransactionsForMonth = transactionsForMonth.transactions.filter { $0.type.isIncome }
                        
                        let totalIncomeByTypeForMonth: [(type: TransactionType, totalAmount: Float)] = TransactionType.incomeTypes.map { type in
                            (
                                type: type,
                                totalAmount: incomeTransactionsForMonth
                                    .filter { $0.type == type }
                                    .reduce(0, { $0 + $1.amount })
                            )
                        }
                        
                        ForEach(totalIncomeByTypeForMonth, id: \.type) { valueForType in
                            
                            let type = valueForType.type
                            
                            BarMark(
                                x: .value("Month", month),
                                y: .value(type.rawValue, valueForType.totalAmount),
                                width: 20
                            )
                            .foregroundStyle(by: .value("", type.rawValue))
                            .position(by: .value("Split", "Type"))
                        }
                        
                        let totalIncomeByPaymentMethod: [(method: PaymentMethod, totalAmount: Float)] = PaymentMethod.allCases.map { method in
                            (
                                method: method,
                                totalAmount: incomeTransactionsForMonth
                                    .filter { $0.paymentMethod == method }
                                    .reduce(0, { $0 + $1.amount })
                            )
                        }
                        
                        ForEach(totalIncomeByPaymentMethod, id: \.method) { valueForMethod in
                            
                            let method = valueForMethod.method
                            
                            BarMark(
                                x: .value("Month", month),
                                y: .value(method.rawValue, valueForMethod.totalAmount),
                                width: 20
                            )
                            .foregroundStyle(by: .value("", method.rawValue))
                            .position(by: .value("Split", "Method"))
                        }
                        
                        let expenseTransactionsForMonth = transactionsForMonth.transactions.filter { $0.type.isExpense }
                        
                        let totalExpenseByTypeForMonth: [(type: TransactionType, totalAmount: Float)] = TransactionType.expenseTypes.map { type in
                            (
                                type: type,
                                totalAmount: expenseTransactionsForMonth
                                    .filter { $0.type == type }
                                    .reduce(0, { $0 + $1.amount })
                            )
                        }
                        
                        ForEach(totalExpenseByTypeForMonth, id: \.type) { valueForType in
                            
                            let type = valueForType.type
                            
                            BarMark(
                                x: .value("Month", month),
                                y: .value(type.rawValue, valueForType.totalAmount),
                                width: 20
                            )
                            .foregroundStyle(by: .value("", type.rawValue))
                            .position(by: .value("Split", "Type"))
                        }
                        
                        let totalExpenseByPaymentMethod: [(method: PaymentMethod, totalAmount: Float)] = PaymentMethod.allCases.map { method in
                            (
                                method: method,
                                totalAmount: expenseTransactionsForMonth
                                    .filter { $0.paymentMethod == method }
                                    .reduce(0, { $0 + $1.amount })
                            )
                        }
                        
                        ForEach(totalExpenseByPaymentMethod, id: \.method) { valueForMethod in
                            
                            let method = valueForMethod.method
                            
                            BarMark(
                                x: .value("Month", month),
                                y: .value(method.rawValue, valueForMethod.totalAmount),
                                width: 20
                            )
                            .foregroundStyle(by: .value("", method.rawValue))
                            .position(by: .value("Split", "Method"))
                        }
                    }
                    
                    
                }
                .chartForegroundStyleScale { rawValue in
                    
                    if let type = TransactionType(rawValue: rawValue) {
                        return TransactionType.colorFor(type)
                        
                    } else if let method = PaymentMethod(rawValue: rawValue) {
                        return PaymentMethod.colorFor(method)
                    }
                    return Color.primary
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
                                
                                selectedTransaction = nil
                                
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
                
                Chart {
                    
                    let transactions = allTransactions.sorted { $0.date < $1.date }
                    
                    let accumulatedTotals: [(
                        transaction: Transaction?,
                        date: Date,
                        totalIncome: Float,
                        totalExpense: Float,
                        totalResult: Float
                    )] = {
                        
                        var values: [(
                            transaction: Transaction?,
                            date: Date,
                            totalIncome: Float,
                            totalExpense: Float,
                            totalResult: Float
                        )] = []
                        
                        var previousMonth: String = ""
                        
                        var totalIncome: Float = 0
                        var totalExpense: Float = 0
                        var totalResult: Float = 0
                        
                        for transaction in transactions {
                            
                            let cal = Calendar.current
                            
                            let comps = cal.dateComponents([.month, .year], from: transaction.date)
                            let month = "\(cal.monthSymbols[comps.month!-1]) \(comps.year!)"
                            
                            if month != previousMonth {
                                values.append((
                                    transaction: nil,
                                    date: transaction.date.firstDayOfMonth.previousDay.endOfDay,
                                    totalIncome: totalIncome,
                                    totalExpense: totalExpense,
                                    totalResult: totalResult
                                ))
                                values.append((
                                    transaction: nil,
                                    date: transaction.date.firstDayOfMonth.startOfDay,
                                    totalIncome: 0,
                                    totalExpense: 0,
                                    totalResult: totalResult
                                ))
                                totalIncome = 0
                                totalExpense = 0
                            }
                            
                            totalIncome += max(transaction.amount, 0)
                            totalExpense += min(transaction.amount, 0)
                            totalResult += transaction.amount
                            
                            values.append((
                                transaction: transaction,
                                date: transaction.date,
                                totalIncome: totalIncome,
                                totalExpense: totalExpense,
                                totalResult: totalResult
                            ))
                            
                            previousMonth = month
                        }
                        
                        return values
                    }()
                    
                    ForEach(accumulatedTotals, id: \.date) { item in
                        
                        AreaMark(x: .value("Date", item.date), y: .value("Income", item.totalIncome))
                            .foregroundStyle(by: .value("Type", "Income"))
                        
                        AreaMark(x: .value("Date", item.date), y: .value("Expense", item.totalExpense))
                            .foregroundStyle(by: .value("Type", "Expense"))
                        
                        LineMark(x: .value("Date", item.date), y: .value("Result", item.totalResult))
                            .foregroundStyle(by: .value("Type", "Result"))
                    }
                    
                    if let transaction = selectedTransaction {
                        
                        RuleMark(
                            x: .value("Date", transaction.date)
                        )
                        .foregroundStyle(Color.accentColor.opacity(0.4))
                        
                        if let totals = accumulatedTotals.first(where: { $0.transaction != nil && $0.date == transaction.date }) {
                            
                            PointMark(
                                x: .value("Date", transaction.date),
                                y: .value("Result", totals.totalResult)
                            )
                            .foregroundStyle(Color.accentColor.opacity(0.4))
                        }
                    }
                }
                .chartForegroundStyleScale { (value: String) in
                    
                    switch value {
                    case "Income": return Color.green
                    case "Expense": return Color.red
                    default: return Color.accentColor
                    }
                }
                .chartOverlay { chart in
                    
                    Color.clear
                        .onContinuousHover { phase in
                            
                            switch phase {
                            case .active(let mouse):
                                
                                if let date: Date = chart.value(atX: mouse.x),
                                   let transaction = allTransactions.closest(for: date) {
                                    selectedTransaction = transaction
                                }
                                
                                selectedMonth = nil
                                
                            case .ended:
                                break
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
                    
                } else if let transaction = selectedTransaction {
                    
                    HStack {
                        
                        let transactions = allTransactions.sorted { $0.date < $1.date }
                        
                        let activeIndex = transactions.firstIndex(where: { $0.id == transaction.id })!
                        
                        let previousIndex = transactions.index(before: activeIndex)
                        
                        Button {
                            guard previousIndex >= transactions.startIndex else { return }
                            selectedTransaction = transactions[previousIndex]
                        } label: {
                            Text("Previous")
                        }
                        .disabled(previousIndex < transactions.startIndex)
                        
                        Text(transaction.date, format: .dateTime)
                        
                        let nextIndex = transactions.index(after: activeIndex)
                        
                        Button {
                            guard nextIndex < transactions.endIndex else { return }
                            selectedTransaction = transactions[nextIndex]
                        } label: {
                            Text("Next")
                        }
                        .disabled(nextIndex >= transactions.endIndex)
                    }
                }
                
                let transactions = allTransactions.filter { transaction in
                    
                    if let selectedTransaction = selectedTransaction {
                        return transaction.id == selectedTransaction.id
                    }
                    
                    let cal = Calendar.current
                    
                    let comps = cal.dateComponents([.month, .year], from: transaction.date)
                    let month = "\(cal.monthSymbols[comps.month!-1]) \(comps.year!)"
                    
                    return month == selectedMonth
                }
                
                TransactionListView(
                    transactions: transactions,
                    grouppedByMonth: false,
                    selectedTransactions: .constant([])
                )
                    .frame(minHeight: 200)
            }
            .padding(24)
        }
    }
}
