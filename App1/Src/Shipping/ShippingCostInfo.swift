
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
            
            let bands = {
                
                let allBands = {
                    switch shippingMethodId {
                        
                    case shippingMethodId_France:
                        return shippingCostBandsFrance
                        
                    case shippingMethodId_Europe:
                        return shippingCostBandsEurope
                        
                    case shippingMethodId_World:
                        return shippingCostBandsWorld
                        
                    default:
                        return []
                    }
                }()
                
                var bands: [ShippingCostBand] = []
                
                if let idx = allBands.firstIndex(where: { selectedShippingCost?.maxWeight == $0.maxWeight }) {
                    bands.append(allBands[idx])
                    
                    let nextIdx = idx + 1
                    if nextIdx < allBands.count {
                        bands.append(allBands[nextIdx])
                    }
                }
                
                return bands
            }()
            
            Grid(alignment: .leading) {
                GridRow {
                    Text("")
                    ForEach(bands) { band in
                        Text("\(band.minWeight)-\(band.maxWeight)g")
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
                    
                    ForEach(bands) { band in
                        
                        Group{
                            if let price = band.letter?.tarifRef {
                                Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                                    .fontWeight(selectedShippingCost?.maxWeight == band.maxWeight && selectedShippingCost?.chooseLetter ?? false ? .bold : .regular)
                            } else {
                                Text("")
                            }
                        }
                        .foregroundStyle(selectedShippingCost?.maxWeight == band.maxWeight ? .primary : .secondary)
                    }
                }
                
                if shippingMethodId == shippingMethodId_World {
                    
                    GridRow {
                        Text("􀐚ZB").foregroundStyle(.secondary)
                        
                        ForEach(bands) { band in
                            
                            Group {
                                if let price = band.priceParcelZB {
                                    Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                                        .fontWeight(selectedShippingCost?.maxWeight == band.maxWeight && selectedShippingCost?.chooseParcelZB ?? false ? .bold : .regular)
                                } else {
                                    Text("")
                                }
                            }
                            .foregroundStyle(selectedShippingCost?.maxWeight == band.maxWeight ? .primary : .secondary)
                        }
                    }
                    
                    GridRow {
                        Text("􀐚ZC").foregroundStyle(.secondary)
                        
                        ForEach(bands) { band in
                            
                            Group {
                                if let price = band.priceParcelZC {
                                    Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                                        .fontWeight(selectedShippingCost?.maxWeight == band.maxWeight && selectedShippingCost?.chooseParcelZC ?? false ? .bold : .regular)
                                } else {
                                    Text("")
                                }
                            }
                            .foregroundStyle(selectedShippingCost?.maxWeight == band.maxWeight ? .primary : .secondary)
                        }
                    }
                    
                } else {
                    
                    GridRow {
                        Text("􀐚").foregroundStyle(.secondary)
                        
                        ForEach(bands) { band in
                            
                            Group {
                                if let price = band.priceParcel {
                                    Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                                        .fontWeight(selectedShippingCost?.maxWeight == band.maxWeight && selectedShippingCost?.chooseParcel ?? false ? .bold : .regular)
                                } else {
                                    Text("")
                                }
                            }
                            .foregroundStyle(selectedShippingCost?.maxWeight == band.maxWeight ? .primary : .secondary)
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
                    
                    ForEach(bands) { band in
                        
                        if let priceLetter = band.letter {
                            
                            VStack(alignment: .leading) {
                                
                                let mul = {
                                    if let m = priceLetter.timbresParMultiples {
                                        return Float(m)
                                    }
                                    let m = priceLetter.nbTimbresRequired
                                    if m != 1 {
                                        return ceilf(m)
                                    } else {
                                        return m
                                    }
                                }()
                                Text(String(format: "%d stamps", mul))
                                
                                let price = priceLetter.timbresParMultiplesTotalPrice ?? priceLetter.nbTimbresRequiredTotalPrice
                                Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                            }
                            .fontWeight(selectedShippingCost?.maxWeight == band.maxWeight ? .bold : .regular)
                            .foregroundStyle(selectedShippingCost?.maxWeight == band.maxWeight ? .primary : .secondary)
                            
                        } else {
                            
                           Text("")
                        }
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
        selectedShippingCost: SelectedShippingCost(
            maxWeight: 20,
            letterStamping: LetterStamping(
                useTimbresParMultiples: false,
                useTimbres: false,
                usePostOffice: false,
                nbTimbres: 0
            ),
            value: 2.35
        )
    )
}
