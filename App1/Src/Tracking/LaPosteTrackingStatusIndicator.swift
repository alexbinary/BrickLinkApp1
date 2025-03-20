
import SwiftUI


struct LaPosteTrackingStatusIndicator: View {
    
    
    @Environment(TrackingStore.self)
    var trackingStore
    
    
    let order: OrderSummary
    var status: LaPosteTrackingStatus? { trackingStore.laPosteTrackingStatus(forOrderWithId: order.id) }
    
    
    var body: some View {
        
        Text("La Poste: \(status?.rawValue ?? "")")
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .roundedContainer(style: .tag(baseColor: color))
            .onChange(of: order, initial: true) { Task {
                await trackingStore.reloadLaPosteTrackingStatus(forOrderWithId: order.id)
            }}
    }
    
    
    var color: Color {
        switch status {
        case .none: .gray
        case .noData: .red
        case .inTransit: .yellow
        case .delivered: .green
        }
    }
}


#Preview {
    
    let stores = createStores()
    
    let orderStore = stores.order
    let trackingStore = stores.tracking
    
    let order = orderStore.orderSummaries.first!
    
    VStack {
        Group {
            LaPosteTrackingStatusIndicator(order: order)
            LaPosteTrackingStatusIndicator(order: order)
            LaPosteTrackingStatusIndicator(order: order)
            LaPosteTrackingStatusIndicator(order: order)
        }.padding()
    }
    .environment(trackingStore)
}
