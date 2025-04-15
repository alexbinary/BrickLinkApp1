
import SwiftUI




struct ShippingCostInfo: View {
    
    
    let shippingMethodId: Int
    let selectedShippingCost: SelectedShippingCost?
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            let scope = {
                
                if shippingMethodId == shippingMethodId_France_LaPoste {
                    return "France"
                } else if shippingMethodId == shippingMethodId_Europe_LaPoste {
                    return "Europe"
                } else if shippingMethodId == shippingMethodId_World_LaPoste {
                    return "Monde"
                }
                return ""
            }()
            
            HeaderTitleView(label: "􀅴 Tarifs La Poste 2025")
            
            let bands = {
                
                let allBands = {
                    switch shippingMethodId {
                        
                    case shippingMethodId_France_LaPoste:
                        return shippingCostBandsFrance
                        
                    case shippingMethodId_Europe_LaPoste:
                        return shippingCostBandsEurope
                        
                    case shippingMethodId_World_LaPoste:
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
                    
                    let prevIdx = idx - 1
                    if prevIdx >= 0 {
                        bands.insert(allBands[prevIdx], at: 0)
                    }
                }
                
                return bands
            }()
            
            Grid(alignment: .leading) {
                GridRow {
                    Text("\(scope)")
                    ForEach(bands) { band in
                        Text("\(band.minWeight)-\(band.maxWeight)g")
                    }
                }
                .foregroundStyle(.secondary)
                
                Color.clear.frame(width: 0, height: 0)
                
                GridRow {
                    Text("􀍕").foregroundStyle(.secondary)
                    
                    ForEach(bands) { band in
                        
                        let activeBand = selectedShippingCost?.maxWeight == band.maxWeight
                        let preferred = selectedShippingCost?.preferLetter ?? false
                        
                        Group{
                            if let price = band.letter?.refPrice {
                                Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                            } else {
                                Text("-")
                            }
                        }
                        .fontWeight(activeBand && preferred ? .bold : .regular)
                        .foregroundStyle(activeBand ? .primary : .secondary)
                    }
                }
                
                if shippingMethodId == shippingMethodId_World_LaPoste {
                    
                    GridRow {
                        Text("􀐚ZB").foregroundStyle(.secondary)
                        
                        ForEach(bands) { band in
                            
                            let activeBand = selectedShippingCost?.maxWeight == band.maxWeight
                            let preferred = selectedShippingCost?.preferParcelZB ?? false
                            
                            Group {
                                if let price = band.priceParcelZB {
                                    Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                                } else {
                                    Text("-")
                                }
                            }
                            .fontWeight(activeBand && preferred ? .bold : .regular)
                            .foregroundStyle(activeBand ? .primary : .secondary)
                        }
                    }
                    
                    GridRow {
                        Text("􀐚ZC").foregroundStyle(.secondary)
                        
                        ForEach(bands) { band in
                            
                            let activeBand = selectedShippingCost?.maxWeight == band.maxWeight
                            let preferred = selectedShippingCost?.preferParcelZC ?? false
                            
                            Group {
                                if let price = band.priceParcelZC {
                                    Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                                } else {
                                    Text("-")
                                }
                            }
                            .fontWeight(activeBand && preferred ? .bold : .regular)
                            .foregroundStyle(activeBand ? .primary : .secondary)
                        }
                    }
                    
                } else {
                    
                    GridRow {
                        Text("􀐚").foregroundStyle(.secondary)
                        
                        ForEach(bands) { band in
                            
                            let activeBand = selectedShippingCost?.maxWeight == band.maxWeight
                            let preferred = selectedShippingCost?.preferParcel ?? false
                            
                            Group {
                                if let price = band.priceParcel {
                                    Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                                } else {
                                    Text("-")
                                }
                            }
                            .fontWeight(activeBand && preferred ? .bold : .regular)
                            .foregroundStyle(activeBand ? .primary : .secondary)
                        }
                    }
                }
                
                Color.clear.frame(width: 0, height: 0)
                
                GridRow {
                    
                    Text("􂙡").foregroundStyle(.secondary)
                    
                    ForEach(bands) { band in
                        
                        let activeBand = selectedShippingCost?.maxWeight == band.maxWeight
                        let preferred = selectedShippingCost?.preferLetter ?? false
                        
                        if let priceLetter = band.letter {
                            
                            VStack(alignment: .leading) {
                                
                                if let n = priceLetter.nbTimbres {
                                    
                                    let text = {
                                        
                                        var text = String(format: "%d stamps", n)
                                        if priceLetter.preferTimbresParMultiples {
                                            text += "*"
                                        }
                                        return text
                                    }()
                                    Text(text)
                                } else {
                                    Text("post office")
                                }
                                
                                let price = priceLetter.bestPrice
                                Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                            }
                            .fontWeight(activeBand && preferred ? .bold : .regular)
                            .foregroundStyle(activeBand ? .primary : .secondary)
                            
                        } else {
                            
                           Text("-")
                        }
                    }
                }
            }
            .monospacedDigit()
            
            Spacer()
            
            VStack(alignment: .leading) {
                
                let stamp = (shippingMethodId == shippingMethodId_France_LaPoste ? priceTimbreFrance : priceTimbreWorld)
                    .formatted(.currency(code: "EUR").presentation(.isoCode))
                
                let tracking = (shippingMethodId == shippingMethodId_France_LaPoste ? priceTrackingFrance : priceTrackingWorld)
                    .formatted(.currency(code: "EUR").presentation(.isoCode))
                
                Text("Timbre: \(stamp) - Suivi: \(tracking)").font(.footnote)
                
                if shippingMethodId == shippingMethodId_World_LaPoste {
                    
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
        shippingMethodId: shippingMethodId_France_LaPoste,
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
