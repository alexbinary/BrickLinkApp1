
import SwiftUI



struct UploadItemView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let item: UploadItem
    
    @State var hover = false

    
    var body: some View {
     
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
        .background(Color(nsColor: hover ? .secondarySystemFill : .tertiarySystemFill))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(nsColor: .tertiarySystemFill))
        )
        .onHover { hover in
            self.hover = hover
        }
    }
}
