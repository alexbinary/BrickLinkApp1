
import SwiftUI



struct ShippingCostInfo: View {
    
    
    let shippingMethodId: Int
    let selectedShippingCost: SelectedShippingCost?
    let selectedAffranchissement: SelectedAffranchissement?
    
    
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
            
            let shippingCostItems = {
                
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
                
                if let idx = allItems.firstIndex(where: { selectedShippingCost?.maxWeight == $0.maxWeight }) {
                    
                    let nextIdx = idx + 1
                    
                    return [allItems[idx], allItems[nextIdx]]
                }
                
                return allItems
            }()
            
            let affranchissementValuesItems = {
                
                let allItems = {
                    switch shippingMethodId {
                        
                    case shippingMethodId_France:
                        return affranchissementValuesFrance
                        
                    case shippingMethodId_Europe, shippingMethodId_World:
                        return affranchissementValuesWorld
                        
                    default:
                        return []
                    }
                }()
                
                if let idx = allItems.firstIndex(where: { selectedShippingCost?.maxWeight == $0.maxWeight }) {
                    
                    let nextIdx = idx + 1
                    
                    return [allItems[idx], allItems[nextIdx]]
                }
                
                return allItems
            }()
            
            Grid(alignment: .leading) {
                GridRow {
                    Text("")
                    ForEach(shippingCostItems) { item in
                        Text("\(item.minWeight)-\(item.maxWeight)g")
                    }
                }
                .foregroundStyle(.secondary)
                
                Color.clear.frame(width: 0, height: 3)
                GridRow {
                    Text("")
                    Text("Reference price").gridCellColumns(2)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                GridRow {
                    Text("􀍕").foregroundStyle(.secondary)
                    
                    ForEach(shippingCostItems) { item in
                        
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
                        
                        ForEach(shippingCostItems) { item in
                            
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
                        
                        ForEach(shippingCostItems) { item in
                            
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
                        
                        ForEach(shippingCostItems) { item in
                            
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
                
                Color.clear.frame(width: 0, height: 3)
                GridRow {
                    Text("")
                    Text("Stamping").gridCellColumns(2)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                GridRow {
                    
                    Text("􂙡").foregroundStyle(.secondary)
                    
                    ForEach(affranchissementValuesItems) { item in
                        
                        VStack(alignment: .leading) {
                            
                            let mul = {
                                if let m = item.timbresParMultiples {
                                    return Float(m)
                                }
                                let m = item.nbTimbresRequired
                                if m != 1 {
                                    return ceilf(m)
                                } else {
                                    return m
                                }
                            }()
                            Text(String(format: "%d stamps", mul))
                            
                            let price = item.timbresParMultiplesTotalPrice ?? item.nbTimbresRequiredTotalPrice
                            Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                        }
                        .fontWeight(selectedAffranchissement?.maxWeight == item.maxWeight ? .bold : .regular)
                        .foregroundStyle(selectedAffranchissement?.maxWeight == item.maxWeight ? .primary : .secondary)
                    }
                }
            }
            .monospacedDigit()
            
            Spacer()
            
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
        selectedShippingCost: SelectedShippingCost(maxWeight: 20, value: 2.35),
        selectedAffranchissement: SelectedAffranchissement(
            maxWeight: 20,
            useTimbresParMultiples: false,
            useTimbres: false,
            usePostOffice: false,
            nbTimbres: 0
        )
    )
}
