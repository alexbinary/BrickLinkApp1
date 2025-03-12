
import SwiftUI



struct OrdersMainListItem: View {
    
    
    @EnvironmentObject
    var app: AppController
    
    let order: OrderSummary
    var macroStatus: OrderMacroStatus { app.macroStatus(forOrderWithId: order.id) }
    
    @State var hover: Bool = false
    
    
    var body: some View {
            
        HStack(spacing: 12) {
            
            HStack(alignment: .top, spacing: 16) {
                
                VStack(alignment: .leading, spacing: 18) {
                    
                    Grid(alignment: .leading, verticalSpacing: 0) {
                        
                        GridRow {
                            Text("order").captionSyle()
                            Text("placed").captionSyle()
                        }
                        
                        GridRow {
                            OrderLink(order) { Text(order.id) }
                                .font(.title2)
                                .monospacedDigit()
                            Text(order.date, format: .dateTime)
                                .frame(width: 150, alignment: .leading)
                                .monospacedDigit()
                        }
                    }
                    
                    Grid(alignment: .leading, verticalSpacing: 4) {
                        
                        GridRow {
                            Text("􀉩").foregroundStyle(.secondary).gridColumnAlignment(.center)
                            Text(order.buyer).gridCellColumns(3)
                        }
                        
                        GridRow {
                            Text("􀍩").foregroundStyle(.secondary).gridColumnAlignment(.center)
                            Text("\(order.items) (\(order.lots))").frame(width: 75, alignment: .leading)
                            
                            Text("􀖧").foregroundStyle(.secondary)
                            Text(order.grandTotal, format: .currency(code: "EUR").presentation(.isoCode)).monospacedDigit()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 18) {
                    
                    Grid(alignment: .leading, verticalSpacing: 0) {
                        
                        GridRow {
                            Text("status").captionSyle()
                            Text("changed").captionSyle()
                        }
                        GridRow {
                            Text(order.status.rawValue).font(.title3)
                            Text(order.dateStatusChanged, format: .dateTime).monospacedDigit()
                        }
                    }
                    
                    let tags = statusTags.limit(2)
                    
                    HStack(alignment: tags.count == 1 ? .bottom : .top, spacing: 24) {
                        
                        VStack(alignment: .leading) {
                            Text("feedback").captionSyle()
                            HStack(alignment: .firstTextBaseline, spacing: 12) {
                                
                                HStack {
                                    Text("Seller:")
                                    if let feedback = app.sellerFeedback(forOrderWithId: order.id) {
                                        FeedbackRating(feedback)
                                    }
                                }.frame(width: 100, alignment: .leading)
                                
                                HStack {
                                    Text("Buyer:")
                                    if let feedback = app.buyerFeedback(forOrderWithId: order.id) {
                                        FeedbackRating(feedback)
                                    }
                                }.frame(width: 100, alignment: .leading)
                            }
                        }
                        
                        VStack(alignment: .trailing) {
                            
                            ForEach(tags) { tagView($0) }
                            
                            if macroStatus == .inTransit, app.orderIsShippedWithLaPoste(orderId: order.id) {
                                LaPosteTrackingStatusIndicator(order: order)
                            }
                        }
                        .frame(width: 280, alignment: .trailing)
                    }
                }
            }
            
            DisclosureIndicator()
        }
        .padding()
        .roundedContainer(
            backgroundColor: hover ? .tertiarySystemFill : .windowBackgroundColor,
            borderColor: statusColor.opacity(0.25)
        )
        .onHover { self.hover = $0 }
    }
    
    
    @ViewBuilder
    func tagView(_ tag: OrderStatusTag) -> some View {
        
        HStack(spacing: 2) {
            
            Text(tag.text)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .roundedContainer(style: .tag(baseColor: tag.status.color))
            
            if let action = tag.action {
                Button("􀈟") { action() }
            }
        }
    }
    
    
    var statusColor: Color {
        
        switch macroStatus {
            
        case .validatePayment:
                .red
        case .pickAndPack:
                .red
        case .ship:
                .yellow
        case .inTransit:
                .orange
        case .inTransitFor30PlusDays:
                .orange
        case .received:
                .green
        case .giveFeedback:
                .green
        case .recentlyClosed:
                .green
        case .closed:
                .green
        }
    }
    
    
    var statusTags: [OrderStatusTag] {
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        var items: [OrderStatusTag] = []
        
        switch macroStatus {
        
        case .validatePayment:
            
            if !app.orderChecklistPayment(order.id) {
                items.append(OrderStatusTag(text: "Payment pending", status: .waitingOnExternalAction))
                
            } else if !app.orderChecklistIncomeTransaction(order.id) {
                items.append(OrderStatusTag(text: "Register payment transaction", status: .actionRequired))
            }
            
        case .pickAndPack:
            
            if !app.orderChecklistPicking(order.id) {
                
                let picked = app.pickedItems(forOrderWithId: order.id).count
                let total = app.orderItems(forOrderWithId: order.id).count
                
                let percent = floor(Double(picked)/Double(total)*100)
                items.append(OrderStatusTag(text: String(format: "%3.0f%% picked", percent), status: .actionRequired))
                
            } else if !app.orderChecklistVerification(order.id) {
                
                let verified = app.verifiedItems(forOrderWithId: order.id).count
                let total = app.orderItems(forOrderWithId: order.id).count
                
                let percent = floor(Double(verified)/Double(total)*100)
                items.append(OrderStatusTag(text: String(format: "%3.0f%% verified", percent), status: .actionRequired))
                
            } else if !app.orderChecklistPacked(order.id) {
                items.append(OrderStatusTag(text: "Not packed yet", status: .actionRequired))
            }
            
        case .ship:
            
            if !app.orderChecklistStamping(order.id) {
                items.append(OrderStatusTag(text: "Stamping not validated", status: .actionRequired))
            }
            if !app.orderChecklistShippingTransaction(order.id) {
                items.append(OrderStatusTag(text: "No shipping transaction", status: .actionRequired))
            }
            if !app.orderChecklistTrackingNo(order.id) {
                items.append(OrderStatusTag(text: "Missing tracking no", status: .actionRequired))
            }
            
            if !app.orderChecklistShipped(order.id) && !app.orderChecklistDriveThru(order.id) {
                items.append(OrderStatusTag(text: "Ship and send Drive thru", status: .actionRequired, action: {
                    Task {
                        await app.updateOrderStatus(orderId: order.id, status: .shipped)
                        await app.sendDriveThru(orderId: order.id)
                    }
                }))
            } else {
                if !app.orderChecklistShipped(order.id) {
                    items.append(OrderStatusTag(text: "Mark Shipped", status: .actionRequired))
                }
                if !app.orderChecklistDriveThru(order.id) {
                    items.append(OrderStatusTag(text: "Send Drive thru", status: .actionRequired))
                }
            }
            
        case .inTransit, .inTransitFor30PlusDays:
            
            let formattedDate = formatter.localizedString(for: order.dateStatusChanged, relativeTo: Date.now)
            items.append(OrderStatusTag(text: "Shipped \(formattedDate)", status: .waitingOnExternalAction))
            
            if app.orderChecklistUnchangedFor30Days(order.id) {
                items.append(OrderStatusTag(text: "Mark Completed and give feedback", status: .actionRequired, action: {
                    Task {
                        await app.updateOrderStatus(orderId: order.id, status: .completed)
                        await app.postPraiseOrderFeedback(orderId: order.id)
                    }
                }))
            }
            
        case .received:
                
            let formattedDate = formatter.localizedString(for: order.dateStatusChanged, relativeTo: Date.now)
            items.append(OrderStatusTag(text: "Received \(formattedDate)", status: .completed))
            
            items.append(OrderStatusTag(text: "Waiting Completed or buyer feedback", status: .waitingOnExternalAction))
        
        case .giveFeedback:
                
            let formattedDate = formatter.localizedString(for: order.dateStatusChanged, relativeTo: Date.now)
            if order.status == .completed {
                items.append(OrderStatusTag(text: "Completed \(formattedDate)", status: .completed))
            } else {
                items.append(OrderStatusTag(text: "Received \(formattedDate)", status: .completed))
            }
            
            items.append(OrderStatusTag(text: "Give feedback", status: .actionRequired, action: {
                Task {
                    await app.postPraiseOrderFeedback(orderId: order.id)
                }
            }))
            
        case .recentlyClosed, .closed:
            
            let formattedDate = formatter.localizedString(for: order.dateStatusChanged, relativeTo: Date.now)
            items.append(OrderStatusTag(text: "Closed \(formattedDate)", status: .completed))
        }
        
        return items
    }
}



extension View {
    
    
    @ViewBuilder func captionSyle() -> some View {
        
        self.font(.caption).foregroundStyle(.secondary)
    }
}



#Preview {
    let appController = AppController()
    let order = appController.orderSummaries.first!
    OrdersMainListItem(order: order)
        .environmentObject(appController)
}
