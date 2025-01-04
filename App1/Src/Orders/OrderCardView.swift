
import SwiftUI



struct OrderCardView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let orderId: OrderSummary.ID
    
    
    var body: some View {
        
        if let order = appController.orderSummary(forOrderWithId: orderId) {
            
            HStack {
                
                HStack(alignment: .top, spacing: 16) {
                    
                    VStack(alignment: .leading) {
                        
                        HStack {
                            Link(destination: URL(string: "https://www.bricklink.com/orderDetail.asp?ID=\(order.id)#/")!) {
                                Text(order.id).font(.title2)
                            }
                            Text(order.date, format: .dateTime).font(.title3)
                        }
                        
                        Text("")
                        
                        Grid(alignment: .leading) {
                            
                            GridRow {
                                Text("􀉩").gridColumnAlignment(.center)
                                Text(order.buyer)
                            }
                            
                            GridRow {
                                Text("􀍩").gridColumnAlignment(.center)
                                
                                HStack {
                                    Text("\(order.items) (\(order.lots))")
                                    Text(order.grandTotal, format: .currency(code: "EUR").presentation(.isoCode))
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        
                        HStack {
                            Text(order.status.rawValue).font(.title2)
                            Text(order.dateStatusChanged, format: .dateTime).font(.title3)
                        }
                        
                        Text("")
                        
                        HStack {
                            Text("Buyer:")
                            if let rating = appController.orderFeedbacks(forOrderWithId: order.id).buyerFeedback()?.rating {
                                if rating == 0 {
                                    Text("􀉿")
                                } else if rating == 2 {
                                    Text("􀊁")
                                } else {
                                    Text("Neutral")
                                }
                            }
                        }
                        HStack {
                            Text("Seller:")
                            if let rating = appController.orderFeedbacks(forOrderWithId: order.id).sellerFeedback()?.rating {
                                if rating == 0 {
                                    Text("􀉿")
                                } else if rating == 2 {
                                    Text("􀊁")
                                } else {
                                    Text("Neutral")
                                }
                            }
                        }
                    }
                }
                
                Grid(alignment: .leading) {
                    
                    switch appController.orderBusinessStatus(orderId) {
                    
                    case .pendingPayment:
                        
                        GridRow {
                            Text("Payment")
                            checkStatus(appController.orderChecklistPayment(orderId))
                        }
                        
                    case .validatePayment:
                        
                        GridRow {
                            Text("Income transaction")
                            checkStatus(appController.orderChecklistIncomeTransaction(orderId))
                        }
                        
                    case .readyForPicking:
                        
                        GridRow {
                            Text("Picked")
                            checkStatus(appController.orderChecklistPicking(orderId))
                        }
                        GridRow {
                            Text("Verification")
                            checkStatus(appController.orderChecklistVerification(orderId))
                        }
                        GridRow {
                            Text("Packed")
                            checkStatus(appController.orderChecklistPacked(orderId))
                        }
                        
                    case .readyToShip:
                        
                        GridRow {
                            Text("Shipped")
                            checkStatus(appController.orderChecklistShipped(orderId))
                        }
                        
                    case .validateShipping:
                        
                        GridRow {
                            Text("Tracking no")
                            checkStatus(appController.orderChecklistTrackingNo(orderId))
                        }
                        GridRow {
                            Text("Drive thru")
                            checkStatus(appController.orderChecklistDriveThru(orderId))
                        }
                        GridRow {
                            Text("Affranchissement")
                            checkStatus(appController.orderChecklistAffranchissement(orderId))
                        }
                        GridRow {
                            Text("Shipping transaction")
                            checkStatus(appController.orderChecklistShippingTransaction(orderId))
                        }
                        
                    case .inTransit:
                        
                        GridRow {
                            Text("Received")
                            checkStatus(appController.orderChecklistReceived(orderId))
                        }
                        
                    case .received:
                        
                        GridRow {
                            Text("Seller feedback")
                            checkStatus(appController.orderChecklistSellerFeedback(orderId))
                        }
                        
                    case .done, .closed:
                        
                        GridRow {
                            Text("Unchanged for 30+ days")
                            checkStatus(appController.orderChecklistUnchangedFor30Days(orderId))
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(nsColor: .tertiaryLabelColor))
            }
            .padding()
            .background(Color(nsColor: .quaternarySystemFill))
            .border(Color(nsColor: .tertiarySystemFill))
            .cornerRadius(6)
        }
    }
    
    
    @ViewBuilder
    func checkStatus(_ status: Bool) -> some View {
        if status {
            Text("􀁣").foregroundStyle(green)
        } else {
            Text("􀀀").foregroundStyle(red)
        }
    }
}
