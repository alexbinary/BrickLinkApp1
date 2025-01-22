
import SwiftUI



struct UploadedItemsView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    
    var body: some View {
     
        LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
            
            let uploadedItems = appController.uploadedItems
                .sorted { $0.uploadDate > $1.uploadDate }
            
            section(header: "􀐫 Latest uploads", items: uploadedItems)
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
