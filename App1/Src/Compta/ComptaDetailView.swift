
import SwiftUI
import Charts



struct ComptaDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @State var value: Float = 180
    
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                let transactions = appController.transactions
                
                let incomeTransactions = transactions.filter { $0.type.isIncome }
                let totalIncome = incomeTransactions.reduce(0, { $0 + $1.amount })
                
                let totalIncomeByType: [(type: TransactionType, totalAmount: Float)] = TransactionType.incomeTypes.map { type in
                    (
                        type: type,
                        totalAmount: incomeTransactions
                            .filter { $0.type == type }
                            .reduce(0, { $0 + $1.amount })
                    )
                }
                
                let expenseTransactions = transactions.filter { $0.type.isExpense }
                let totalExpense = expenseTransactions.reduce(0, { $0 + $1.amount })
                
                let totalExpenseByType: [(type: TransactionType, totalAmount: Float)] = TransactionType.expenseTypes.map { type in
                    (
                        type: type,
                        totalAmount: expenseTransactions
                            .filter { $0.type == type }
                            .reduce(0, { $0 + $1.amount })
                    )
                }
                
                let totalResult = totalIncome + totalExpense
                
                Grid(verticalSpacing: 36) {
                    
                    GridRow {
                        
                        VStack {
                            
                            Text("Total income").font(.title2)
                            
                            ZStack {
                                
                                Chart {
                                    ForEach(totalIncomeByType, id: \.type) { item in
                                        SectorMark(
                                            angle: .value(item.type.rawValue, abs(item.totalAmount)),
                                            innerRadius: .ratio(0.9)
                                        )
                                    }
                                }
                                .frame(minHeight: 150)
                                
                                Text(totalIncome, format: .currency(code: "EUR").presentation(.isoCode))
                                    .font(.title)
                                    .signedAmountColor(totalIncome)
                            }
                        }
                        
                        VStack {
                            ForEach(totalIncomeByType, id: \.type) { item in
                                HStack {
                                    Color.primary
                                        .frame(width: 8, height: 8)
                                        .clipShape(.circle)
                                    Text(item.type.rawValue)
                                    Text(item.totalAmount, format: .currency(code: "EUR").presentation(.isoCode))
                                        .signedAmountColor(item.totalAmount)
                                }
                            }
                        }
                        
                        VStack {
                            
                            Text("Total expense").font(.title2)
                            
                            ZStack {
                                
                                Chart {
                                    ForEach(totalExpenseByType, id: \.type) { item in
                                        SectorMark(
                                            angle: .value(item.type.rawValue, abs(item.totalAmount)),
                                            innerRadius: .ratio(0.9)
                                        )
                                    }
                                }
                                .frame(minHeight: 150)
                                
                                Text(abs(totalExpense), format: .currency(code: "EUR").presentation(.isoCode))
                                    .font(.title)
                                    .signedAmountColor(totalExpense)
                            }
                        }
                        
                        VStack {
                            ForEach(totalExpenseByType, id: \.type) { item in
                                HStack {
                                    Color.primary
                                        .frame(width: 8, height: 8)
                                        .clipShape(.circle)
                                    Text(item.type.rawValue)
                                    Text(abs(item.totalAmount), format: .currency(code: "EUR").presentation(.isoCode))
                                        .signedAmountColor(item.totalAmount)
                                }
                            }
                        }
                    }
                    
                    GridRow {
                        
                        VStack(alignment: .center) {
                            
                            Text("Total result").font(.title2)
                            
                            ZStack(alignment: .center) {
                                
                                let targetResult: Float = 360
                             
                                ProgressView(targetValue: targetResult, value: totalResult)
                                    .frame(minHeight: 150, maxHeight: 150)
                                    
                                VStack {
                                    Text(totalResult, format: .currency(code: "EUR").presentation(.isoCode))
                                        .font(.title)
                                        .signedAmountColor(totalResult)
                                    HStack(spacing: 0) {
                                        Text("Target: ")
                                            .font(.caption)
                                        Text(targetResult, format: .currency(code: "EUR").presentation(.isoCode))
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
    }
}
