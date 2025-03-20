
import SwiftUI



struct OrdersMainListItem: View {
    
    
    @Environment(OrderStore.self)
    var orderStore
    
    @Environment(PickingStore.self)
    var pickingStore
    
    @Environment(FeedbackStore.self)
    var feedbackStore
    
    @Environment(OrderChecklistStore.self)
    var orderChecklistStore
    
    
    let order: OrderSummary
    var macroStatus: OrderMacroStatus { orderStore.macroStatus(forOrderWithId: order.id) }
    
    
    @State var hover: Bool = false
    
    
    var body: some View {
            
        HStack(spacing: 12) {
            
            HStack(alignment: .top, spacing: 16) {
                
                VStack(alignment: .leading, spacing: 18) {
                    
                    Grid(alignment: .leading, verticalSpacing: 0) {
                        
                        GridRow {
                            Text("order").captionStyle()
                            Text("placed").captionStyle()
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
                            Text("status").captionStyle()
                            Text("changed").captionStyle()
                        }
                        GridRow {
                            Text(order.status.rawValue).font(.title3)
                            Text(order.dateStatusChanged, format: .dateTime).monospacedDigit()
                        }
                    }
                    
                    let tags = statusTags.limit(2)
                    
                    HStack(alignment: tags.count == 1 ? .bottom : .top, spacing: 24) {
                        
                        VStack(alignment: .leading) {
                            Text("feedback").captionStyle()
                            HStack(alignment: .firstTextBaseline, spacing: 12) {
                                
                                HStack {
                                    Text("Seller:")
                                    if let feedback = feedbackStore.sellerFeedback(forOrderWithId: order.id) {
                                        FeedbackRating(feedback)
                                    }
                                }.frame(width: 100, alignment: .leading)
                                
                                HStack {
                                    Text("Buyer:")
                                    if let feedback = feedbackStore.buyerFeedback(forOrderWithId: order.id) {
                                        FeedbackRating(feedback)
                                    }
                                }.frame(width: 100, alignment: .leading)
                            }
                        }
                        
                        VStack(alignment: .trailing) {
                            
                            ForEach(tags) { tagView($0) }
                            
                            if macroStatus == .inTransit, orderStore.orderDetails(forOrderWithId: order.id)!.isShippedWithLaPoste {
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
            fill: hover ? .tertiarySystemFill : .windowBackgroundColor,
            stroke: statusColor.opacity(0.25)
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
            
            if !orderChecklistStore.orderChecklistPayment(order.id) {
                items.append(OrderStatusTag(text: "Payment pending", status: .waitingOnExternalAction))
                
            } else if !orderChecklistStore.orderChecklistIncomeTransaction(order.id) {
                items.append(OrderStatusTag(text: "Register payment transaction", status: .actionRequired))
            }
            
        case .pickAndPack:
            
            if !orderChecklistStore.orderChecklistPicking(order.id) {
                
                let progress = pickingStore.pickingProgress(forOrderWithId: order.id)
                items.append(OrderStatusTag(text: "\(progress) picked", status: .actionRequired))
                
            } else if !orderChecklistStore.orderChecklistVerification(order.id) {
                
                let progress = pickingStore.pickingVerificationProgress(forOrderWithId: order.id)
                items.append(OrderStatusTag(text: "\(progress) verified", status: .actionRequired))
                
            } else if !orderChecklistStore.orderChecklistPacked(order.id) {
                items.append(OrderStatusTag(text: "Not packed yet", status: .actionRequired))
            }
            
        case .ship:
            
            if !orderChecklistStore.orderChecklistStamping(order.id) {
                items.append(OrderStatusTag(text: "Stamping not validated", status: .actionRequired))
            }
            if !orderChecklistStore.orderChecklistShippingTransaction(order.id) {
                items.append(OrderStatusTag(text: "No shipping transaction", status: .actionRequired))
            }
            if !orderChecklistStore.orderChecklistTrackingNo(order.id) {
                items.append(OrderStatusTag(text: "Missing tracking no", status: .actionRequired))
            }
            
            if !orderChecklistStore.orderChecklistShipped(order.id) && !orderChecklistStore.orderChecklistDriveThru(order.id) {
                items.append(OrderStatusTag(text: "Ship and send Drive thru", status: .actionRequired, action: {
                    Task {
                        await orderStore.updateOrderStatus(orderId: order.id, status: .shipped)
                        await orderStore.sendDriveThru(orderId: order.id)
                    }
                }))
            } else {
                if !orderChecklistStore.orderChecklistShipped(order.id) {
                    items.append(OrderStatusTag(text: "Mark Shipped", status: .actionRequired))
                }
                if !orderChecklistStore.orderChecklistDriveThru(order.id) {
                    items.append(OrderStatusTag(text: "Send Drive thru", status: .actionRequired))
                }
            }
            
        case .inTransit, .inTransitFor30PlusDays:
            
            let formattedDate = formatter.localizedString(for: order.dateStatusChanged, relativeTo: Date.now)
            items.append(OrderStatusTag(text: "Shipped \(formattedDate)", status: .waitingOnExternalAction))
            
            if orderChecklistStore.orderChecklistUnchangedFor30Days(order.id) {
                items.append(OrderStatusTag(text: "Mark Completed and give feedback", status: .actionRequired, action: {
                    Task {
                        await orderStore.updateOrderStatus(orderId: order.id, status: .completed)
                        await feedbackStore.postPraiseFeedback(forOrderWithId: order.id)
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
                    await feedbackStore.postPraiseFeedback(forOrderWithId: order.id)
                }
            }))
            
        case .recentlyClosed, .closed:
            
            let formattedDate = formatter.localizedString(for: order.dateStatusChanged, relativeTo: Date.now)
            items.append(OrderStatusTag(text: "Closed \(formattedDate)", status: .completed))
        }
        
        return items
    }
}



#Preview {
    
    let stores = createStores()
    
    let orderStore = stores.order
    let pickingStore = stores.picking
    let feedbackStore = stores.feedback
    let orderChecklistStore = stores.orderChecklist
    
    let order = orderStore.orderSummaries.first!
    
    OrdersMainListItem(order: order)
        .environment(orderStore)
        .environment(pickingStore)
        .environment(feedbackStore)
        .environment(orderChecklistStore)
}
