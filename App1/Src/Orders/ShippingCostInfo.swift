
import SwiftUI



struct ShippingCostInfo: View {
    
    
    let shippingMethodId: Int
    let selectedShippingCost: SelectedShippingCost?
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            let title = "􀅴 Tarifs La Poste 2025 - " + {
                
                if shippingMethodId == shippingMethodId_France {
                    return "France"
                } else if shippingMethodId == shippingMethodId_Europe {
                    return "Europe"
                } else if shippingMethodId == shippingMethodId_World {
                    return "Monde"
                }
                return ""
            }()
            HeaderTitleView(label: title)
            
            let allItems = {
                switch shippingMethodId {
                    
                case shippingMethodId_France:
                    return shippingCostFrance
                    
                case shippingMethodId_Europe:
                    return shippingCostEurope
                    
                case shippingMethodId_World:
                    return shippingCostWorld
                    
                default:
                    return []
                }
            }()
            
            let items = {
                
                if let idx = allItems.firstIndex(where: { selectedShippingCost?.maxWeight == $0.maxWeight }) {
                    
                    let nextIdx = idx + 1
                    
                    return [allItems[idx], allItems[nextIdx]]
                }
                
                return allItems
            }()
            
            Grid(alignment: .leading) {
                GridRow {
                    Text("")
                    ForEach(items) { item in
                        Text("\(item.minWeight)-\(item.maxWeight)g")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                GridRow {
                    Text("􀍕").foregroundStyle(.secondary)
                    
                    ForEach(items) { item in
                        
                        Group{
                            if let price = item.priceLetter {
                                Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                                    .fontWeight(selectedShippingCost?.maxWeight == item.maxWeight && selectedShippingCost?.chooseLetter ?? false ? .bold : .regular)
                            } else {
                                Text("")
                            }
                        }
                        .foregroundStyle(selectedShippingCost?.maxWeight == item.maxWeight ? .primary : .secondary)
                    }
                }
                
                if shippingMethodId == shippingMethodId_World {
                    
                    GridRow {
                        Text("􀐚ZB").foregroundStyle(.secondary)
                        
                        ForEach(items) { item in
                            
                            Group {
                                if let price = item.priceParcelZB {
                                    Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                                        .fontWeight(selectedShippingCost?.maxWeight == item.maxWeight && selectedShippingCost?.chooseParcelZB ?? false ? .bold : .regular)
                                } else {
                                    Text("")
                                }
                            }
                            .foregroundStyle(selectedShippingCost?.maxWeight == item.maxWeight ? .primary : .secondary)
                        }
                    }
                    
                    GridRow {
                        Text("􀐚ZC").foregroundStyle(.secondary)
                        
                        ForEach(items) { item in
                            
                            Group {
                                if let price = item.priceParcelZC {
                                    Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                                        .fontWeight(selectedShippingCost?.maxWeight == item.maxWeight && selectedShippingCost?.chooseParcelZC ?? false ? .bold : .regular)
                                } else {
                                    Text("")
                                }
                            }
                            .foregroundStyle(selectedShippingCost?.maxWeight == item.maxWeight ? .primary : .secondary)
                        }
                    }
                    
                } else {
                    
                    GridRow {
                        Text("􀐚").foregroundStyle(.secondary)
                        
                        ForEach(items) { item in
                            
                            Group {
                                if let price = item.priceParcel {
                                    Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                                        .fontWeight(selectedShippingCost?.maxWeight == item.maxWeight && selectedShippingCost?.chooseParcel ?? false ? .bold : .regular)
                                } else {
                                    Text("")
                                }
                            }
                            .foregroundStyle(selectedShippingCost?.maxWeight == item.maxWeight ? .primary : .secondary)
                        }
                    }
                }
            }
            .monospacedDigit()
            
            VStack(alignment: .leading) {
                
                let stamp = (shippingMethodId == shippingMethodId_France ? priceTimbreFrance : priceTimbreWorld)
                    .formatted(.currency(code: "EUR").presentation(.isoCode))
                
                let tracking = (shippingMethodId == shippingMethodId_France ? priceTrackingFrance : priceTrackingWorld)
                    .formatted(.currency(code: "EUR").presentation(.isoCode))
                
                Text("Timbre: \(stamp) - Suivi: \(tracking)").font(.footnote)
                
                if shippingMethodId == shippingMethodId_World {
                    
                    Text("""
                            ZB : Europe de l'Est (hors UE et Russie), Norvège, Maghreb
                            ZC : Autres destinations
                            """).font(.footnote)
                }
            }
        }
    }
}



#Preview {
    ShippingCostInfo(
        shippingMethodId: shippingMethodId_France,
        selectedShippingCost: SelectedShippingCost(maxWeight: 20, value: 2.35))
}
