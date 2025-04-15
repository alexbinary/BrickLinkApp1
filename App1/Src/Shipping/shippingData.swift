
import Foundation



struct ShippingCostBand: Identifiable, Sendable {
    
    var id: Int { maxWeight }
    
    let minWeight: Int
    let maxWeight: Int
    
    let letter: LetterCost?
    
    var priceParcel: Decimal? = nil
    var priceParcelZB: Decimal? = nil
    var priceParcelZC: Decimal? = nil
}


struct LetterCost: Sendable {
    
    let refPrice: Decimal
    
    let priceTimbre: Decimal
    let priceTracking: Decimal
    
    
    var minNbTimbresToCoverRefPrice: Int {
        let raw = (self.refPrice - priceTracking)/priceTimbre
        return Int(ceilf(NSDecimalNumber(decimal: raw).floatValue))
    }
    var priceTimbresToCoverRefPrice: Decimal {
        Decimal(minNbTimbresToCoverRefPrice) * priceTimbre + priceTracking
    }
    
    
    let timbresParMultiples: Int?
    
    var priceTimbresParMultiples: Decimal? {
        if let n = self.timbresParMultiples {
            return Decimal(n) * priceTimbre + priceTracking
        } else {
            return nil
        }
    }
    
    
    var preferTimbresParMultiples: Bool {
        if let n = priceTimbresParMultiples {
            return n < refPrice
        } else {
            return false
        }
    }
    var preferCoverRefPriceWithTimbres: Bool {
        priceTimbresToCoverRefPrice <= refPrice
    }
    var preferPostOffice: Bool {
        !preferTimbresParMultiples && !preferCoverRefPriceWithTimbres
    }

    var bestPrice: Decimal {
        if preferTimbresParMultiples, let p = priceTimbresParMultiples {
            return p
        }
        if preferCoverRefPriceWithTimbres {
            return priceTimbresToCoverRefPrice
        }
        return refPrice
    }
    var nbTimbres: Int? {
        if preferTimbresParMultiples, let n = timbresParMultiples {
            return n
        }
        if preferCoverRefPriceWithTimbres {
            return minNbTimbresToCoverRefPrice
        }
        return nil
    }
}



struct SelectedShippingCost {
    
    let maxWeight: Int
    
    var preferLetter: Bool
    var preferParcel: Bool
    var preferParcelZB: Bool
    var preferParcelZC: Bool
    
    let letterStamping: LetterStamping?
    
    let value: Decimal?
    
    
    init(maxWeight: Int, preferLetter: Bool = false, preferParcel: Bool = false, preferParcelZB: Bool = false, preferParcelZC: Bool = false, letterStamping: LetterStamping?, value: Decimal?) {
        self.maxWeight = maxWeight
        self.preferLetter = preferLetter
        self.preferParcel = preferParcel
        self.preferParcelZB = preferParcelZB
        self.preferParcelZC = preferParcelZC
        self.letterStamping = letterStamping
        self.value = value
    }
}


struct LetterStamping {
    
    let useTimbresParMultiples: Bool
    let useTimbres: Bool
    let usePostOffice: Bool
    
    let nbTimbres: Int?
    
    init(useTimbresParMultiples: Bool, useTimbres: Bool, usePostOffice: Bool, nbTimbres: Int?) {
        self.useTimbresParMultiples = useTimbresParMultiples
        self.useTimbres = useTimbres
        self.usePostOffice = usePostOffice
        self.nbTimbres = nbTimbres
    }
}



let shippingMethodId_France_LaPoste = 289751
let shippingMethodId_France_MondialRelay = 330666
let shippingMethodId_Europe_LaPoste = 290360
let shippingMethodId_World_LaPoste = 185519

let shippingMethodIds_LaPoste = [
    shippingMethodId_France_LaPoste,
    shippingMethodId_Europe_LaPoste,
    shippingMethodId_World_LaPoste,
]
let shippingMethodIds_MondialRelay = [
    shippingMethodId_France_MondialRelay,
]

let shippingMethodIds_France = [
    shippingMethodId_France_LaPoste,
    shippingMethodId_France_MondialRelay,
]


let priceTimbreFrance: Decimal = 1.39
let priceTrackingFrance: Decimal = 0.50

let priceTimbreWorld: Decimal = 2.10
let priceTrackingWorld: Decimal = 2.80


let shippingCostBandsFrance = [
    
    ShippingCostBand(
        minWeight: 0,
        maxWeight: 20,
        letter: LetterCost(
            refPrice: 1.89,
            priceTimbre: priceTimbreFrance,
            priceTracking: priceTrackingFrance,
            timbresParMultiples: 1
        ),
        priceParcel: 5.25
    ),
    ShippingCostBand(
        minWeight: 20,
        maxWeight: 100,
        letter: LetterCost(
            refPrice: 3.28,
            priceTimbre: priceTimbreFrance,
            priceTracking: priceTrackingFrance,
            timbresParMultiples: 2
        ),
        priceParcel: 5.25
    ),
    ShippingCostBand(
        minWeight: 100,
        maxWeight: 250,
        letter: LetterCost(
            refPrice: 5.22,
            priceTimbre: priceTimbreFrance,
            priceTracking: priceTrackingFrance,
            timbresParMultiples: nil
        ),
        priceParcel: 5.25
    ),
    ShippingCostBand(
        minWeight: 250,
        maxWeight: 500,
        letter: LetterCost(
            refPrice: 7.20,
            priceTimbre: priceTimbreFrance,
            priceTracking: priceTrackingFrance,
            timbresParMultiples: nil
        ),
        priceParcel: 7.35
    ),
    ShippingCostBand(
        minWeight: 500,
        maxWeight: 750,
        letter: LetterCost(
            refPrice: 8.90,
            priceTimbre: priceTimbreFrance,
            priceTracking: priceTrackingFrance,
            timbresParMultiples: nil
        ),
        priceParcel: 8.65
    ),
    ShippingCostBand(
        minWeight: 750,
        maxWeight: 1000,
        letter: LetterCost(
            refPrice: 8.90,
            priceTimbre: priceTimbreFrance,
            priceTracking: priceTrackingFrance,
            timbresParMultiples: nil
        ),
        priceParcel: 9.40
    ),
    ShippingCostBand(
        minWeight: 1000,
        maxWeight: 2000,
        letter: LetterCost(
            refPrice: 10.75,
            priceTimbre: priceTimbreFrance,
            priceTracking: priceTrackingFrance,
            timbresParMultiples: nil
        ),
        priceParcel: 10.70
    ),
    ShippingCostBand(
        minWeight: 2000,
        maxWeight: 5000,
        letter: nil,
        priceParcel: 16.60
    )
]


let shippingCostBandsEurope = [
    
    ShippingCostBand(
        minWeight: 0,
        maxWeight: 20,
        letter: LetterCost(
            refPrice: 4.90,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: 1
        ),
        priceParcel: 14.85
    ),
    ShippingCostBand(
        minWeight: 20,
        maxWeight: 100,
        letter: LetterCost(
            refPrice: 7.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: 2
        ),
        priceParcel: 14.85
    ),
    ShippingCostBand(
        minWeight: 100,
        maxWeight: 250,
        letter: LetterCost(
            refPrice: 13.60,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: 5
        ),
        priceParcel: 14.85
    ),
    ShippingCostBand(
        minWeight: 250,
        maxWeight: 500,
        letter: LetterCost(
            refPrice: 18.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: 8
        ),
        priceParcel: 14.85
    ),
    ShippingCostBand(
        minWeight: 500,
        maxWeight: 750,
        letter: LetterCost(
            refPrice: 32.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: nil
        ),
        priceParcel: 18.45
    ),
    ShippingCostBand(
        minWeight: 750,
        maxWeight: 1000,
        letter: LetterCost(
            refPrice: 32.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: nil
        ),
        priceParcel: 18.45
    ),
    ShippingCostBand(
        minWeight: 1000,
        maxWeight: 2000,
        letter: LetterCost(
            refPrice: 32.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: nil
        ),
        priceParcel: 20.90
    ),
    ShippingCostBand(
        minWeight: 2000,
        maxWeight: 5000,
        letter: nil,
        priceParcel: 26.80
    ),
]


let shippingCostBandsWorld = [
    
    ShippingCostBand(
        minWeight: 0,
        maxWeight: 20,
        letter: LetterCost(
            refPrice: 4.90,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: 1
        ),
        priceParcelZB: 22.70, priceParcelZC: 33.50
    ),
    ShippingCostBand(
        minWeight: 20,
        maxWeight: 100,
        letter: LetterCost(
            refPrice: 7.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: 2
        ),
        priceParcelZB: 22.70, priceParcelZC: 33.50
    ),
    ShippingCostBand(
        minWeight: 100,
        maxWeight: 250,
        letter: LetterCost(
            refPrice: 13.60,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: 5
        ),
        priceParcelZB: 22.70, priceParcelZC: 33.50
    ),
    ShippingCostBand(
        minWeight: 250,
        maxWeight: 500,
        letter: LetterCost(
            refPrice: 18.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: 8
        ),
        priceParcelZB: 22.70, priceParcelZC: 33.50
    ),
    ShippingCostBand(
        minWeight: 500,
        maxWeight: 750,
        letter: LetterCost(
            refPrice: 32.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: nil
        ),
        priceParcelZB: 27.10, priceParcelZC: 37.30
    ),
    ShippingCostBand(
        minWeight: 750,
        maxWeight: 1000,
        letter: LetterCost(
            refPrice: 32.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: nil
        ),
        priceParcelZB: 29.65, priceParcelZC: 51.40
    ),
    ShippingCostBand(
        minWeight: 1000,
        maxWeight: 2000,
        letter: LetterCost(
            refPrice: 32.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: nil
        ),
        priceParcelZB: 29.65, priceParcelZC: 51.40
    ),
    ShippingCostBand(
        minWeight: 2000,
        maxWeight: 5000,
        letter: nil,
        priceParcelZB: 38.00, priceParcelZC: 75.00
    ),
]



let orderWeightMarginRatio: Float = 1.2
