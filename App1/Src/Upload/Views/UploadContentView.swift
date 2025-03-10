
import SwiftUI



struct UploadContentView: View {
    
    
    @EnvironmentObject var app: AppController

    @State var addViewVisible: Bool = false
    
    
    var body: some View {
     
        TabView {
            
            VStack {
                
                if addViewVisible {
                    
                    UploadAddView()
                        .padding()
                }
                
                ScrollView {
                    
                    LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
                        
                        let uploadItems = app.uploadItems
                        
                            .sorted { item1, item2 in
                                
                                let rem1 = app.inventory(for: item1)?.remarks ?? app.inventories(forAllColorsOf: item1).map { $0.remarks }.sorted().first
                                let rem2 = app.inventory(for: item2)?.remarks ?? app.inventories(forAllColorsOf: item2).map { $0.remarks }.sorted().first
                                
                                switch (rem1, rem2) {
                                    
                                case (nil, nil):
                                    return true
                                    
                                case (.some, nil):
                                    return true
                                    
                                case (nil, .some):
                                    return false
                                    
                                case (.some(let rem1), .some(let rem2)):
                                    return rem1 < rem2
                                }
                            }
                        
                        section(header: "􀋲 Items to upload", items: uploadItems)
                    }
                }
            }
            .toolbar {
                Button {
                    addViewVisible.toggle()
                } label: {
                    Text("􀅼").padding(.horizontal)
                }
            }
            .tabItem {
                Text("􀋲 Upload")
            }
            .tag("upload")
            
            ScrollView {
                UploadedItemsView()
            }
            .tabItem {
                Text("􀐫 History")
            }
            .tag("history")
        }
        .navigationTitle("Upload")
        .onAppear {
            Task {
                await app.reloadInventories()
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
