
import SwiftUI


struct LaPosteTrackingView: View {
    
    
    let status: LaPosteTrackingStatus?
    
    
    var body: some View {
     
        let color: Color = {
            switch status {
            case .none:
                    .gray
            case .noData:
                    .red
            case .inTransit:
                    .yellow
            case .delivered:
                    .green
            }
        }()
        
        Text("La Poste: \(status?.rawValue ?? "")")
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .roundedContainer(style: .tag(baseColor: color))
    }
}


#Preview {
    
    VStack {
        Group {
            LaPosteTrackingView(status: nil)
            LaPosteTrackingView(status: .noData)
            LaPosteTrackingView(status: .inTransit)
            LaPosteTrackingView(status: .delivered)
        }.padding()
    }
}
