
import Foundation



struct ShippingCostTableRow: Identifiable {
    
    var id: Int { maxWeight }
    let minWeight: Int
    let maxWeight: Int
    let priceLetter: Float?
    var priceParcel: Float? = nil
    var priceParcelZB: Float? = nil
    var priceParcelZC: Float? = nil
}


struct SelectedShippingCost {
    
    let maxWeight: Int
    var chooseLetter: Bool = false
    var chooseParcel: Bool = false
    var chooseParcelZB: Bool = false
    var chooseParcelZC: Bool = false
    let value: Float?
}



let shippingMethodId_France = 289751
let shippingMethodId_Europe = 290360
let shippingMethodId_World = 185519


let shippingCostFrance = [
    
    ShippingCostTableRow(
        minWeight: 0, maxWeight: 20,
        priceLetter: 1.89, priceParcel: 5.25
    ),
    ShippingCostTableRow(
        minWeight: 20, maxWeight: 100,
        priceLetter: 3.28, priceParcel: 5.25
    ),
    ShippingCostTableRow(
        minWeight: 100, maxWeight: 250,
        priceLetter: 5.22, priceParcel: 5.25
    ),
    ShippingCostTableRow(
        minWeight: 250, maxWeight: 500,
        priceLetter: 7.20, priceParcel: 7.35
    ),
    ShippingCostTableRow(
        minWeight: 500, maxWeight: 750,
        priceLetter: 8.90, priceParcel: 8.65
    ),
    ShippingCostTableRow(
        minWeight: 750, maxWeight: 1000,
        priceLetter: 8.90, priceParcel: 9.40
    ),
    ShippingCostTableRow(
        minWeight: 1000, maxWeight: 2000,
        priceLetter: 10.75, priceParcel: 10.70
    ),
    ShippingCostTableRow(
        minWeight: 2000, maxWeight: 5000,
        priceLetter: nil, priceParcel: 16.60
    ),
]

let shippingCostEurope = [
    
    ShippingCostTableRow(
        minWeight: 0, maxWeight: 20,
        priceLetter: 4.90, priceParcel: 14.85
    ),
    ShippingCostTableRow(
        minWeight: 20, maxWeight: 100,
        priceLetter: 7.30, priceParcel: 14.85
    ),
    ShippingCostTableRow(
        minWeight: 100, maxWeight: 250,
        priceLetter: 13.60, priceParcel: 14.85
    ),
    ShippingCostTableRow(
        minWeight: 250, maxWeight: 500,
        priceLetter: 18.30, priceParcel: 14.85
    ),
    ShippingCostTableRow(
        minWeight: 500, maxWeight: 750,
        priceLetter: 32.30, priceParcel: 18.45
    ),
    ShippingCostTableRow(
        minWeight: 750, maxWeight: 1000,
        priceLetter: 32.30, priceParcel: 18.45
    ),
    ShippingCostTableRow(
        minWeight: 1000, maxWeight: 2000,
        priceLetter: 32.30, priceParcel: 20.90
    ),
    ShippingCostTableRow(
        minWeight: 2000, maxWeight: 5000,
        priceLetter: nil, priceParcel: 26.80
    ),
]

let shippingCostWorld = [
    
    ShippingCostTableRow(
        minWeight: 0, maxWeight: 20,
        priceLetter: 4.90, priceParcelZB: 22.70, priceParcelZC: 33.50
    ),
    ShippingCostTableRow(
        minWeight: 20, maxWeight: 100,
        priceLetter: 7.30, priceParcelZB: 22.70, priceParcelZC: 33.50
    ),
    ShippingCostTableRow(
        minWeight: 100, maxWeight: 250,
        priceLetter: 13.60, priceParcelZB: 22.70, priceParcelZC: 33.50
    ),
    ShippingCostTableRow(
        minWeight: 250, maxWeight: 500,
        priceLetter: 18.30, priceParcelZB: 22.70, priceParcelZC: 33.50
    ),
    ShippingCostTableRow(
        minWeight: 500, maxWeight: 750,
        priceLetter: 32.30, priceParcelZB: 27.10, priceParcelZC: 37.30
    ),
    ShippingCostTableRow(
        minWeight: 750, maxWeight: 1000,
        priceLetter: 32.30, priceParcelZB: 29.65, priceParcelZC: 51.40
    ),
    ShippingCostTableRow(
        minWeight: 1000, maxWeight: 2000,
        priceLetter: 32.30, priceParcelZB: 29.65, priceParcelZC: 51.40
    ),
    ShippingCostTableRow(
        minWeight: 2000, maxWeight: 5000,
        priceLetter: nil, priceParcelZB: 38.00, priceParcelZC: 75.00
    ),
]


struct AffranchissementTableRow: Identifiable {
    
    var id: Int { maxWeight }
    
    let minWeight: Int
    let maxWeight: Int
    
    let priceTimbre: Float
    let priceTracking: Float
    
    let tarifRef: Float
    
    let timbresParMultiples: Int?
    var timbresParMultiplesTotalPrice: Float? {
        guard let n = self.timbresParMultiples else { return nil }
        return Float(n) * priceTimbre + priceTracking
    }
    
    var nbTimbresRequired: Float {
        (self.tarifRef - priceTracking)/priceTimbre
    }
    var nbTimbresRequiredTotalPrice: Float {
        ceilf(nbTimbresRequired) * priceTimbre + priceTracking
    }
    
    var preferTimbresParMultiples: Bool {
        timbresParMultiplesTotalPrice != nil && timbresParMultiplesTotalPrice! <= tarifRef
    }
    var preferTimbres: Bool {
        nbTimbresRequiredTotalPrice <= tarifRef
    }
}


struct SelectedAffranchissement {
    
    let maxWeight: Int
    
    let useTimbresParMultiples: Bool
    let useTimbres: Bool
    let usePostOffice: Bool
    
    let nbTimbres: Int
}


let priceTimbreFrance: Float = 1.39
let priceTrackingFrance: Float = 0.50

let priceTimbreWorld: Float = 2.10
let priceTrackingWorld: Float = 2.80


let affranchissementValuesFrance = [

    AffranchissementTableRow(
        minWeight: 0, maxWeight: 20,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 1.89, timbresParMultiples: 1
    ),
    AffranchissementTableRow(
        minWeight: 20, maxWeight: 100,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 3.28, timbresParMultiples: 2
    ),
    AffranchissementTableRow(
        minWeight: 100, maxWeight: 250,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 5.22, timbresParMultiples: nil
    ),
    AffranchissementTableRow(
        minWeight: 250, maxWeight: 500,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 7.20, timbresParMultiples: nil
    ),
    AffranchissementTableRow(
        minWeight: 500, maxWeight: 750,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 8.90, timbresParMultiples: nil
    ),
    AffranchissementTableRow(
        minWeight: 750, maxWeight: 1000,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 8.90, timbresParMultiples: nil
    ),
    AffranchissementTableRow(
        minWeight: 1000, maxWeight: 2000,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 10.75, timbresParMultiples: nil
    ),
]

let affranchissementValuesWorld = [

    AffranchissementTableRow(
        minWeight: 0, maxWeight: 20,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 4.90, timbresParMultiples: 1
    ),
    AffranchissementTableRow(
        minWeight: 20, maxWeight: 100,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 7.30, timbresParMultiples: 2
    ),
    AffranchissementTableRow(
        minWeight: 100, maxWeight: 250,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 13.60, timbresParMultiples: 5
    ),
    AffranchissementTableRow(
        minWeight: 250, maxWeight: 500,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 18.30, timbresParMultiples: 8
    ),
    AffranchissementTableRow(
        minWeight: 500, maxWeight: 750,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 32.30, timbresParMultiples: nil
    ),
    AffranchissementTableRow(
        minWeight: 750, maxWeight: 1000,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 32.30, timbresParMultiples: nil
    ),
    AffranchissementTableRow(
        minWeight: 1000, maxWeight: 2000,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 32.30, timbresParMultiples: nil
    ),
]
