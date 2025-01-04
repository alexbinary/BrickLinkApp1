
import SwiftUI



struct UploadContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    
    var body: some View {
     
        VStack {
            
            TabView {
                
                UploadListView()
                    .tabItem {
                        Text("􀋲 Edit list")
                    }
                
                UploadUploadView()
                    .tabItem {
                        Text("􀈧 Upload")
                    }
            }
            .padding()
            
            Table(appController.uploadItems) {
                
                TableColumn("Image") { item in
                    AsyncImage(url: appController.imageUrl(forItemType: item.type, ref: item.ref, colorId: item.colorId))
                        .frame(minHeight: 60)
                }
                
                TableColumn("Condition", value: \.condition)
                
                TableColumn("Color") { item in
                    HStack {
                        appController.color(forLegoColorId: item.colorId).frame(width: 18, height: 18)
                        Text(appController.colorName(forLegoColorId: item.colorId))
                    }
                }
                
                TableColumn("Ref", value: \.ref)
                
                TableColumn("Quantity") { item in
                    Text(item.qty, format: .number)
                }
                TableColumn("Price") { item in
                    if let price = item.unitPrice {
                        Text(price, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                    }
                }
                
                TableColumn("Comment", value: \.comment)
                
                TableColumn("Delete") { item in
                    HStack {
                        Button {
                            appController.deleteUploadItem(item)
                        } label: {
                            Text("􀈑 Delete")
                        }
                        Button {
                            appController.hoistUploadItem(item)
                        } label: {
                            Text("􁾨 Hoist")
                        }
                    }
                }
            }
        }
        .navigationTitle("Upload")
    }
}
