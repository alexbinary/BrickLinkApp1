
import SwiftUI



struct UploadContentView: View {
    
    
    @EnvironmentObject var appController: AppController

    @State var highlightedItemId: UploadItem.ID?
    @State var selectedItemId: UploadItem.ID?
    
    @State var addViewVisible: Bool = false
    
    
    var body: some View {
     
        VStack {
            
            if addViewVisible {
                
                UploadAddView()
                    .padding()
            }
            
            ScrollView {
                
                LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
                    
                    section(header: "􀋲 Items to upload", items: appController.uploadItems)
                    
                    section(header: "􀐫 Latest uploads", items: appController.uploadedItems)
                }
            }
        }
        .navigationTitle("Upload")
        .toolbar {
            Button {
                addViewVisible.toggle()
            } label: {
                Text("􀅼").padding(.horizontal)
            }
        }
    }
    
    
    @ViewBuilder
    func section(header: String, items: [UploadItem]) -> some View {
        
        Section {
            
            ForEach(items) { item in
                
                UploadItemView(uploadItem: item)
                    .padding([.leading, .trailing])
            }
            
            Color.clear.frame(width: 0, height: 24)
            
        } header: {
            
            headerView(header, secondaryText: "\(items.count) items")
        }
    }
    
    
    @ViewBuilder
    func section(header: String, items: [UploadedItem]) -> some View {
        
        Section {
            
            ForEach(items) { item in
                
                UploadedItemView(uploadedItem: item)
                    .padding([.leading, .trailing])
            }
            
            Color.clear.frame(width: 0, height: 24)
            
        } header: {
            
            headerView(header, secondaryText: "\(items.count) items")
        }
    }
    
    
    @ViewBuilder
    func headerView(_ primaryText: String, secondaryText: String = "") -> some View {
        
        HStack(spacing: 24) {
            Text(primaryText).font(.title3)
            Text(secondaryText).foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.90))
    }
}
