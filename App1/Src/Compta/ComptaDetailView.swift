
import SwiftUI
import Charts



struct ComptaDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    
    let selectedTransactions: Set<Transaction.ID>
    
    
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
                
                Text("All time").font(.title)
                
                let transactionsByMonth = allTransactions.sorted { $0.date < $1.date } .grouppedByMonth
                
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
                .frame(minHeight: 200)
            }
            .padding(24)
        }
    }
}
