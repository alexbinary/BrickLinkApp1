
import SwiftUI



struct LaPosteTrackingStatusIndicator: View {
    
    
    @Environment(TrackingStore.self)
    var trackingStore
    
    
    let order: Order
    var status: LaPosteTrackingStatus? { trackingStore.laPosteTrackingStatus(for: order) }
    var updating: Bool { trackingStore.isLoadingLaPosteTrackingStatus(for: order) }
    
    
    var body: some View {
        
        Text(updating ? "updating..." : "La Poste: \(status?.rawValue ?? "")")
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .roundedContainer(style: .tag(baseColor: color))
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
    
    let env = createEnv()
    let order = env.stores.order.orders.first!
    
    VStack {
        Group {
            LaPosteTrackingStatusIndicator(order: order)
        }.padding()
    }
    .inject(env)
}
