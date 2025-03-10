
import SwiftUI



struct UploadedItemsView: View {
    
    
    @EnvironmentObject var app: AppController
    
    @State var searchText = ""
    
    
    var body: some View {
     
        let uploadedItems = app.uploadedItems
            .filter { $0.matches(searchText, app) }
            .sorted { $0.uploadDate > $1.uploadDate }
        
        LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
            
            ForEach(uploadedItems.grouppedByDay, id: \.day) { item in
                
                section(header: "􀐫 \(item.day)", items: item.elements)
            }
        }
        .searchable(text: $searchText, prompt: "Search items")
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
        .background(Color.windowBackgroundColor.opacity(0.90))
    }
}
