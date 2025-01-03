
import SwiftUI



struct OrderCardView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let orderId: OrderSummary.ID
    let disclosureIndicatorVisible: Bool
    
    
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
                    
                    GridRow {
                        Text("Paid")
                        if appController.orderIsPaid(orderId) {
                            Text("􀁣").foregroundStyle(Color(NSColor(red: 0.3, green: 0.6, blue: 0.3, alpha: 1)))
                        } else {
                            Text("􀀀").foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if disclosureIndicatorVisible {
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(nsColor: .tertiaryLabelColor))
                }
            }
            .padding()
            .background(Color(nsColor: .quaternarySystemFill))
            .border(Color(nsColor: .tertiarySystemFill))
            .cornerRadius(6)
        }
    }
}
