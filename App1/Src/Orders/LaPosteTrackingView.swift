
import SwiftUI


struct LaPosteTrackingView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let trackingNo: String
    
    @State var status: TrackingStatus? = nil
    
    
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
            .background(color.opacity(0.1))
            .cornerRadius(3)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(color.opacity(0.7), lineWidth: 0.5)
            )
            .onChange(of: trackingNo, initial: true) {
                Task {
                    status = await appController.laPosteTrackingStatus(forTrackingNo: trackingNo)
                }
            }
    }
}


#Preview {
    
    let dataFileUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath.appending("/data/data.json5"))
    let dataStore = DataStore(dataFileUrl: dataFileUrl)
    
    let blCredentials = BrickLinkAPICredentials(
        
        consumerKey: Secrets.BrickLink.consumerKey,
        consumerSecret: Secrets.BrickLink.consumerSecret,
        
        tokenValue: Secrets.BrickLink.tokenValue,
        tokenSecret: Secrets.BrickLink.tokenSecret
    )
    
    let appController = AppController(
        dataStore: dataStore, blCredentials: blCredentials
    )
    
    VStack {
        Group {
            LaPosteTrackingView(trackingNo: "88000043037721U")
            LaPosteTrackingView(trackingNo: "88000043037720W")
            LaPosteTrackingView(trackingNo: "8J01969640887")
        }.padding()
    }
    .environmentObject(appController)
}
