
import Foundation



@Observable
class ShippingController {
    
    
    private let orderStore: OrderStore
    
    
    init(orderStore: OrderStore) {
        self.orderStore = orderStore
    }
    
    
    public func orderDetails(forOrderWithId orderId: OrderSummary.ID) -> OrderDetails? {
        
        orderStore.orderDetails(forOrderWithId: orderId)
    }
    
    
    public func selectedShippingCost(forOrderWithId orderId: OrderSummary.ID) -> SelectedShippingCost? {
        
        let order = orderDetails(forOrderWithId: orderId)!
        
        let weight = order.totalWeight * orderWeightMarginRatio
        
        if order.shippingMethodId == shippingMethodId_France_LaPoste {
            
            if let band = shippingCostBandsFrance
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                var chooseLetter: Bool = false
                var chooseParcel: Bool = false
                let chooseParcelZB: Bool = false
                let chooseParcelZC: Bool = false
                
                var value: Decimal?
                
                if weight < 250 {
                    chooseLetter = true
                    value = band.letter?.bestPrice
                } else {
                    chooseParcel = true
                    value = band.priceParcel
                }
                
                var letterStamping: LetterStamping? = nil
                    
                if let priceLetter = band.letter {
                    
                    letterStamping = LetterStamping(
                    
                        useTimbresParMultiples: priceLetter.preferTimbresParMultiples,
                        useTimbres: priceLetter.preferCoverRefPriceWithTimbres,
                        usePostOffice: priceLetter.preferPostOffice,
                        nbTimbres: priceLetter.nbTimbres
                    )
                }
                
                return SelectedShippingCost(
                    maxWeight: band.maxWeight,
                    preferLetter: chooseLetter, preferParcel: chooseParcel,
                    preferParcelZB: chooseParcelZB, preferParcelZC: chooseParcelZC,
                    letterStamping: letterStamping,
                    value: value
                )
            }
            
            return nil
            
        } else if order.shippingMethodId == shippingMethodId_Europe_LaPoste {
            
            if let band = shippingCostBandsEurope
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                  
                var chooseLetter: Bool = false
                var chooseParcel: Bool = false
                let chooseParcelZB: Bool = false
                let chooseParcelZC: Bool = false
                
                var value: Decimal?
                
                if weight < 250 {
                    chooseLetter = true
                    value = band.letter?.bestPrice
                } else {
                    chooseParcel = true
                    value = band.priceParcel
                }
                
                var letterStamping: LetterStamping? = nil
                    
                if let priceLetter = band.letter {
                    
                    letterStamping = LetterStamping(
                        
                        useTimbresParMultiples: priceLetter.preferTimbresParMultiples,
                        useTimbres: priceLetter.preferCoverRefPriceWithTimbres,
                        usePostOffice: priceLetter.preferPostOffice,
                        nbTimbres: priceLetter.nbTimbres
                    )
                }
                
                return SelectedShippingCost(
                    maxWeight: band.maxWeight,
                    preferLetter: chooseLetter, preferParcel: chooseParcel,
                    preferParcelZB: chooseParcelZB, preferParcelZC: chooseParcelZC,
                    letterStamping: letterStamping,
                    value: value
                )
            }
            
            return nil
            
        } else if order.shippingMethodId == shippingMethodId_World_LaPoste {
            
            if let band = shippingCostBandsWorld
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                    
                var chooseLetter: Bool = false
                let chooseParcel: Bool = false
                var chooseParcelZB: Bool = false
                var chooseParcelZC: Bool = false
                
                var value: Decimal?
                
                if weight < 250 {
                    chooseLetter = true
                    value = band.letter?.bestPrice
                } else {
                    if ["US"].contains(order.shippingAddressCountryCode) {
                        chooseParcelZC = true
                        value = band.priceParcelZC
                    } else {
                        chooseParcelZB = true
                        value = band.priceParcelZB
                    }
                }
                
                var letterStamping: LetterStamping? = nil
                    
                if let priceLetter = band.letter {
                    
                    letterStamping = LetterStamping(
                        
                        useTimbresParMultiples: priceLetter.preferTimbresParMultiples,
                        useTimbres: priceLetter.preferCoverRefPriceWithTimbres,
                        usePostOffice: priceLetter.preferPostOffice,
                        nbTimbres: priceLetter.nbTimbres
                    )
                }
                
                return SelectedShippingCost(
                    maxWeight: band.maxWeight,
                    preferLetter: chooseLetter, preferParcel: chooseParcel,
                    preferParcelZB: chooseParcelZB, preferParcelZC: chooseParcelZC,
                    letterStamping: letterStamping,
                    value: value
                )
            }
            
            return nil
        }
        
        return nil
    }
    
    
    public func recommendedStampingMethod(forOrderWithId orderId: OrderSummary.ID) -> String {
        
        let selectedShippingCost = selectedShippingCost(forOrderWithId: orderId)
        let order = orderDetails(forOrderWithId: orderId)!
        
        var s = ""
        
        if let selectedLetterStamping = selectedShippingCost?.letterStamping {
            
            if selectedLetterStamping.usePostOffice {
                return "Bureau de poste"
            } else {
                s = "\(selectedLetterStamping.nbTimbres ?? 0) timbres"
                
                if order.shippingMethodId != shippingMethodId_France_LaPoste {
                    s += " international"
                }
                
                return s
            }
        }
        
        return s
    }
}
