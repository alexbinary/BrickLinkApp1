
import SwiftUI



struct UploadHistoryItemView: View {
    
    
    @Environment(\.uploadStore)
    var uploadStore: UploadStoreProtocol!
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    
    let uploadedItem: UploadedItem
    
    
    @State var hover = false

    
    var body: some View {
        
        HStack(spacing: 48) {
            
            HStack(alignment: .top) {

                VStack(spacing: 0) {

                    CatalogImage(uploadedItem: uploadedItem)
                        .border(conditionColor, width: 2)
                    
                    Text(uploadedItem.condition.name.uppercased())
                        .font(.title3)
                        .foregroundStyle(conditionColor)
                        .fontWeight(.bold)
                }
                
                VStack(alignment: .leading, spacing: 4) {

                    HStack {
                        
                        Link(destination: catalog.url(forItemOfType: uploadedItem.type, ref: uploadedItem.ref, colorId: uploadedItem.colorId)!) {
                            Text(uploadedItem.ref)
                        }
                        
                        LegoColorView(uploadedItem: uploadedItem, style: .nameOnly)
                    }
                    .font(.caption)
                    
                    Group {
                        if let name = uploadedItem.name {
                            Text(name)
                        } else {
                            Text("name unknown").foregroundStyle(.secondary).italic()
                        }
                    }
                        .lineLimit(nil)
                        .font(.title3)
                        .frame(width: 300, alignment: .leading)
                    
                    if !(uploadedItem.comment ?? "").isEmpty {
                        Text((uploadedItem.comment ?? "").htmlUnescape())
                    }
                }
            }
                
            Grid(alignment: .leading, verticalSpacing: 12) {
                
                GridRow(alignment: .firstTextBaseline) {
                    Text("Inventory").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                    Link("\(uploadedItem.inventoryId)", destination: URL(string: "https://www.bricklink.com/v2/inventory_detail.page?invID=\(uploadedItem.inventoryId)#/")!)
                }
                
                GridRow(alignment: .firstTextBaseline) {
                    Text("Action").foregroundStyle(.secondary)
                    Text(uploadedItem.inventoryStatus == .created ? "Created 􀫸" : "Updated 􀅈")
                }
                
                GridRow(alignment: .firstTextBaseline) {
                    Text("Uploaded on").foregroundStyle(.secondary)
                    Text(uploadedItem.uploadDate, format: .dateTime)
                }
            }
            .frame(width: 200)
            
            Grid(alignment: .leading, verticalSpacing: 12) {
                
                GridRow(alignment: .firstTextBaseline) {
                    Text("Quantity").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                    if let qtyBefore = uploadedItem.qtyBefore {
                        Text("+\(uploadedItem.qtyAfter - qtyBefore)").font(.title2)
                        Text("(\(qtyBefore) 􁉂 \(uploadedItem.qtyAfter))")
                    } else {
                        Text("\(uploadedItem.qtyAfter)").font(.title2)
                    }
                }
                
                GridRow(alignment: .firstTextBaseline) {
                    Text("Unit price").foregroundStyle(.secondary)
                    
                    let priceAfterView = Text(uploadedItem.unitPriceAfter, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4))).monospacedDigit()
                    
                    if let priceBefore = uploadedItem.unitPriceBefore {
                        if priceBefore != uploadedItem.unitPriceAfter {
                            priceAfterView.font(.title2)
                            HStack(spacing: 0) {
                                Text("(")
                                Text(priceBefore, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4))).monospacedDigit()
                                Text(")")
                            }
                        } else {
                            priceAfterView
                            Text("(unchanged)")
                        }
                    } else {
                        priceAfterView.font(.title2)
                    }
                }
                
                GridRow(alignment: .firstTextBaseline) {
                    Text("Remarks").foregroundStyle(.secondary)
                    if let remarksBefore = uploadedItem.remarksBefore {
                        if remarksBefore != uploadedItem.remarksAfter {
                            Text(uploadedItem.remarksAfter).font(.title2)
                            Text("(\(remarksBefore))")
                        } else {
                            Text(uploadedItem.remarksAfter)
                            Text("(unchanged)")
                        }
                    } else {
                        Text(uploadedItem.remarksAfter).font(.title2)
                    }
                }
            }
            
            Spacer()
            
            Button {
                uploadStore.add(UploadItem(
                    type: uploadedItem.type,
                    ref: uploadedItem.ref,
                    name: uploadedItem.name,
                    colorId: uploadedItem.colorId,
                    qty: uploadedItem.qtyAfter - (uploadedItem.qtyBefore ?? 0),
                    condition: uploadedItem.condition,
                    comment: uploadedItem.comment,
                    unitPrice: uploadedItem.unitPriceAfter
                ))
            } label: {
                Text("􀋲 Add to upload items")
            }
            .fixedSize()
        }
        .padding()
        .roundedContainer(
            fill: hover ? .secondarySystemFill : .tertiarySystemFill,
            stroke: .tertiarySystemFill
        )
        .onHover { self.hover = $0 }
    }
    
    
    var conditionColor: Color {
        switch uploadedItem.condition {
        case .used: return .red
        case .new: return .blue
        }
    }
}
