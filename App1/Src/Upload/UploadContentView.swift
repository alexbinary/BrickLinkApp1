
import SwiftUI



struct UploadContentView: View {
    
    
    @EnvironmentObject var appController: AppController

    @State var highlightedItemId: UploadItem.ID?
    @State var selectedItemId: UploadItem.ID?
    
    @State var addViewVisible: Bool = false
    
    
    var body: some View {
     
        VStack {
            
            TabView {
                
                UploadUploadView(selectedItemId: $selectedItemId)
                    .tabItem {
                        Text("􀈧 Upload")
                    }
                
                if addViewVisible {
                    UploadAddView()
                        .tabItem {
                            Text("􀋲 Edit list")
                        }
                }
            }
            .padding()
            
            ScrollView {
                
                LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
                    
                    section(header: "􀋲 Items to upload", items: appController.uploadItems)
                    
                    section(header: "􀐫 Latest uploads", items: appController.uploadedItems)
                }
            }
            .padding([.horizontal, .bottom])
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
        
        if items.count > 0 {
            
            Section {
                
                ForEach(items) { item in
                    
                    itemView(item)
                }
                
                Color.clear.frame(width: 0, height: 24)
                
            } header: {
                
                headerView(header, secondaryText: "\(items.count) items")
            }
        }
    }
    
    
    @ViewBuilder
    func section(header: String, items: [UploadedItem]) -> some View {
        
        if items.count > 0 {
            
            Section {
                
                ForEach(items) { item in
                    
                    itemView(item)
                }
                
                Color.clear.frame(width: 0, height: 24)
                
            } header: {
                
                headerView(header, secondaryText: "\(items.count) items")
            }
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
    
    
    @ViewBuilder
    func itemView(_ item: UploadItem) -> some View {
        
        HStack(spacing: 48) {
                
            Grid(verticalSpacing: 0) {
                
                GridRow(alignment: .top) {
                    
                    AsyncImage(url: appController.imageUrl(forItemType: item.type, ref: item.ref, colorId: item.colorId))
                        .frame(minHeight: 70, maxHeight: 70, alignment: .top)
                        .frame(minWidth: 90, maxWidth: 90, alignment: .top)
                    
                    VStack(alignment: .leading) {
                        Text(item.ref).font(.caption).foregroundStyle(.secondary)
                        Text("name unavailable").lineLimit(nil).font(.title3).frame(width: 300, alignment: .leading).foregroundStyle(.secondary)
                        if !item.comment.isEmpty {
                            Text(item.comment.htmlUnescape())
                        }
                    }
                }
                
                GridRow {
                
                    Text(item.condition == "U" ? "USED" : "NEW").font(.title3).gridColumnAlignment(.center)
                    HStack {
                        appController.color(forLegoColorId: item.colorId).frame(width: 18, height: 18)
                        Text(appController.colorName(forLegoColorId: item.colorId))
                    }.gridColumnAlignment(.leading)
                }
            }
            
            Grid(alignment: .leading, horizontalSpacing: 24) {
                
                GridRow {
                    Text("Qty").font(.caption).foregroundStyle(.secondary)
                    Text("PU").font(.caption).foregroundStyle(.secondary)
                }
                
                GridRow(alignment: .bottom) {
                    Text("\(item.qty)").font(.title2).gridColumnAlignment(.center)
                    if let price = item.unitPrice {
                        Text(price, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4))).monospacedDigit().font(.title2)
                    }
                }
            }
            
            Button {
                appController.deleteUploadItem(item)
            } label: {
                Text("􀈑 Delete")
            }
        }
        .padding()
        .background(Color(nsColor: (highlightedItemId == item.id || selectedItemId == item.id) ? .secondarySystemFill : .tertiarySystemFill))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(nsColor: .tertiarySystemFill))
        )
        .onHover { hover in
            if hover {
                highlightedItemId = item.id
            } else if highlightedItemId == item.id {
                highlightedItemId = nil
            }
        }
        .onTapGesture {
            selectedItemId = item.id
        }
    }
    
    
    @ViewBuilder
    func itemView(_ item: UploadedItem) -> some View {
        
        HStack(spacing: 48) {
                
            Grid(verticalSpacing: 0) {
                
                GridRow(alignment: .top) {
                    
                    AsyncImage(url: appController.imageUrl(forItemType: item.type, ref: item.ref, colorId: item.colorId))
                        .frame(minHeight: 70, maxHeight: 70, alignment: .top)
                        .frame(minWidth: 90, maxWidth: 90, alignment: .top)
                    
                    VStack(alignment: .leading) {
                        Text(item.ref).font(.caption).foregroundStyle(.secondary)
                        Text("name unavailable").lineLimit(nil).font(.title3).frame(width: 300, alignment: .leading).foregroundStyle(.secondary)
                        if !item.comment.isEmpty {
                            Text(item.comment.htmlUnescape())
                        }
                    }
                }
                
                GridRow {
                
                    Text(item.condition == "U" ? "USED" : "NEW").font(.title3).gridColumnAlignment(.center)
                    HStack {
                        appController.color(forLegoColorId: item.colorId).frame(width: 18, height: 18)
                        Text(appController.colorName(forLegoColorId: item.colorId))
                    }.gridColumnAlignment(.leading)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Grid(alignment: .leading, horizontalSpacing: 24) {
                    
                    GridRow {
                        Text("Qty").font(.caption).foregroundStyle(.secondary)
                        Text("PU").font(.caption).foregroundStyle(.secondary)
                    }
                    
                    GridRow(alignment: .bottom) {
                        Text("\(item.qty)").font(.title2).gridColumnAlignment(.center)
                        if let price = item.unitPrice {
                            Text(price, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4))).monospacedDigit().font(.title2)
                        }
                    }
                }
                VStack(alignment: .leading) {
                    Text("Remarks").font(.caption).foregroundStyle(.secondary)
                    Text(item.remarks).font(.title2)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                
                VStack(alignment: .leading) {
                    Text("Inventory ID").font(.caption).foregroundStyle(.secondary)
                    Link("\(item.inventoryId)", destination: URL(string: "https://www.bricklink.com/v2/inventory_detail.page?invID=\(item.inventoryId)#/")!).font(.title2)
                }
                VStack(alignment: .leading) {
                    Text("Date").font(.caption).foregroundStyle(.secondary)
                    Text(item.uploadDate, format: .dateTime).font(.title2)
                }
            }
        }
        .padding()
        .background(Color(nsColor: .tertiarySystemFill))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(nsColor: .tertiarySystemFill))
        )
    }
}
