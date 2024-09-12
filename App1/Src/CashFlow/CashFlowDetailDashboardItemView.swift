
import SwiftUI
import Charts



struct CashFlowDetailDashboardItemView: View {
    
    
    let transactions: [Transaction]
    let title: String
    
    
    var body: some View {
        
        VStack(spacing: 48) {
            
            Text(title).font(.title)
            
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
            let totalIncomeByPaymentMethod: [(method: PaymentMethod, totalAmount: Float)] = PaymentMethod.allCases.map { method in
                (
                    method: method,
                    totalAmount: incomeTransactions
                        .filter { $0.paymentMethod == method }
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
            let totalExpenseByPaymentMethod: [(method: PaymentMethod, totalAmount: Float)] = PaymentMethod.allCases.map { method in
                (
                    method: method,
                    totalAmount: expenseTransactions
                        .filter { $0.paymentMethod == method }
                        .reduce(0, { $0 + $1.amount })
                )
            }
            
            let totalResult = totalIncome + totalExpense
            
            Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 24) {
                
                GridRow {
                    Text("Total income")
                    Text(totalIncome, format: .currency(code: "EUR").presentation(.isoCode))
                        .signedAmountColor(totalIncome)
                    
                    Text("")
                }
                .font(.title2)
                
                HStack {
                    
                    HStack {
                        
                        Chart {
                            ForEach(totalIncomeByType, id: \.type) { item in
                                SectorMark(
                                    angle: .value(item.type.rawValue, abs(item.totalAmount))
                                )
                                .foregroundStyle(by: .value("", item.type.rawValue))
                            }
                        }
                        .chartForegroundStyleScale { rawValue in
                            
                            TransactionType.colorFor(TransactionType(rawValue: rawValue)!)
                        }
                        .chartLegend(.hidden)
                        .frame(minHeight: 75)
                        
                        Grid(alignment: .leading) {
                            ForEach(totalIncomeByType, id: \.type) { item in
                                GridRow {
                                    TransactionType.colorFor(item.type)
                                        .frame(width: 8, height: 8)
                                        .clipShape(.circle)
                                    Text(item.type.rawValue)
                                    Text(item.totalAmount, format: .currency(code: "EUR").presentation(.isoCode))
                                        .signedAmountColor(.income)
                                }
                            }
                        }
                    }
                    
                    HStack {
                        
                        Chart {
                            ForEach(totalIncomeByPaymentMethod, id: \.method) { item in
                                SectorMark(
                                    angle: .value(item.method.rawValue, abs(item.totalAmount))
                                )
                                .foregroundStyle(by: .value("", item.method.rawValue))
                            }
                        }
                        .chartForegroundStyleScale { rawValue in
                            
                            PaymentMethod.colorFor(PaymentMethod(rawValue: rawValue)!)
                        }
                        .chartLegend(.hidden)
                        .frame(minHeight: 75)
                        
                        Grid(alignment: .leading) {
                            ForEach(totalIncomeByPaymentMethod, id: \.method) { item in
                                GridRow {
                                    PaymentMethod.colorFor(item.method)
                                        .frame(width: 8, height: 8)
                                        .clipShape(.circle)
                                    Text(item.method.rawValue)
                                    Text(item.totalAmount, format: .currency(code: "EUR").presentation(.isoCode))
                                        .signedAmountColor(.income)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(.black.opacity(0.2)))
                .padding(.bottom, 24)
                
                
                GridRow {
                    Text("Total expense")
                    Text(abs(totalExpense), format: .currency(code: "EUR").presentation(.isoCode))
                        .signedAmountColor(.expense)
                }
                .font(.title2)
                
                HStack {
                    
                    HStack {
                        
                        Chart {
                            ForEach(totalExpenseByType, id: \.type) { item in
                                SectorMark(
                                    angle: .value(item.type.rawValue, abs(item.totalAmount))
                                )
                                .foregroundStyle(by: .value("", item.type.rawValue))
                            }
                        }
                        .chartForegroundStyleScale { rawValue in
                            
                            TransactionType.colorFor(TransactionType(rawValue: rawValue)!)
                        }
                        .chartLegend(.hidden)
                        .frame(minHeight: 75)
                        
                        Grid(alignment: .leading) {
                            ForEach(totalExpenseByType, id: \.type) { item in
                                GridRow {
                                    TransactionType.colorFor(item.type)
                                        .frame(width: 8, height: 8)
                                        .clipShape(.circle)
                                    Text(item.type.rawValue)
                                    Text(abs(item.totalAmount), format: .currency(code: "EUR").presentation(.isoCode))
                                        .signedAmountColor(.expense)
                                }
                            }
                        }
                    }
                    
                    HStack {
                        
                        Chart {
                            ForEach(totalExpenseByPaymentMethod, id: \.method) { item in
                                SectorMark(
                                    angle: .value(item.method.rawValue, abs(item.totalAmount))
                                )
                                .foregroundStyle(by: .value("", item.method.rawValue))
                            }
                        }
                        .chartForegroundStyleScale { rawValue in
                            
                            PaymentMethod.colorFor(PaymentMethod(rawValue: rawValue)!)
                        }
                        .chartLegend(.hidden)
                        .frame(minHeight: 75)
                        
                        Grid(alignment: .leading) {
                            ForEach(totalExpenseByPaymentMethod, id: \.method) { item in
                                GridRow {
                                    PaymentMethod.colorFor(item.method)
                                        .frame(width: 8, height: 8)
                                        .clipShape(.circle)
                                    Text(item.method.rawValue)
                                    Text(abs(item.totalAmount), format: .currency(code: "EUR").presentation(.isoCode))
                                        .signedAmountColor(.expense)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(.black.opacity(0.2)))
                .padding(.bottom, 24)
                
                GridRow {
                    Text("Total result")
                    Text(abs(totalResult), format: .currency(code: "EUR").presentation(.isoCode))
                        .signedAmountColor(totalResult)
                }
                .font(.title)
            }
        }
    }
}
