
import SwiftUI



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



struct ShippingCostView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let order: OrderDetails
    
    
    var body: some View {
        
        Text("Shipping cost").font(.title2)
        
        HStack {
            Text("Tarifs La Poste 2025 - ")
            
            if order.shippingMethodId == shippingMethodId_France {
                Text("France")
            } else if order.shippingMethodId == shippingMethodId_Europe {
                Text("Europe")
            } else if order.shippingMethodId == shippingMethodId_World {
                Text("Monde")
            }
        }
        
        HStack {
            Text("Estimated shipping cost : ")
            
            if let selectedShippingCost = selectedShippingCost,
               let value = selectedShippingCost.value {
                
                Text(value, format: .currency(code: "EUR").presentation(.isoCode))
                
                Button {
                    appController.updateShippingCost(forOrderWithId: order.id, cost: value)
                } label: {
                    Text("Confirm shipping cost")
                }
                
                if let cost = appController.shippingCost(forOrderWithId: order.id) {
                    
                    HStack {
                        Text("Confirmed")
                        Text(cost, format: .currency(code: "EUR").presentation(.isoCode))
                    }
                }
            }
        }
        
        Table(of: ShippingCostTableRow.self, selection: .constant(selectedShippingCost?.maxWeight)) {
            
            TableColumn("Weight band") { item in
                Text("\(item.minWeight)-\(item.maxWeight)g")
            }
            TableColumn("Price letter with tracking") { item in
                if let price = item.priceLetter {
                    Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                        .fontWeight(selectedShippingCost?.maxWeight == item.maxWeight && selectedShippingCost?.chooseLetter ?? false ? .bold : .regular)
                }
            }
            
            if order.shippingMethodId == shippingMethodId_World {
                
                TableColumn("Price parcel ZB*") { item in
                    if let price = item.priceParcelZB {
                        Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                            .fontWeight(selectedShippingCost?.maxWeight == item.maxWeight && selectedShippingCost?.chooseParcelZB ?? false ? .bold : .regular)
                    }
                }
                TableColumn("Price parcel ZC*") { item in
                    if let price = item.priceParcelZC {
                        Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                            .fontWeight(selectedShippingCost?.maxWeight == item.maxWeight && selectedShippingCost?.chooseParcelZC ?? false ? .bold : .regular)
                    }
                }
                
            } else {
                
                TableColumn("Price parcel") { item in
                    if let price = item.priceParcel {
                        Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                            .fontWeight(selectedShippingCost?.maxWeight == item.maxWeight && selectedShippingCost?.chooseParcel ?? false ? .bold : .regular)
                    }
                }
            }
            
        } rows: {
            
            if order.shippingMethodId == shippingMethodId_France {
                
                ForEach(shippingCostFrance) { item in
                    TableRow(item)
                }
                
            } else if order.shippingMethodId == shippingMethodId_Europe {
                
                ForEach(shippingCostEurope) { item in
                    TableRow(item)
                }
                
            } else if order.shippingMethodId == shippingMethodId_World {
                
                ForEach(shippingCostWorld) { item in
                    TableRow(item)
                }
            }
        }
        .frame(minHeight: 250)
        
        if order.shippingMethodId == shippingMethodId_World {
            
            Text("""
                                    *Zone B : Europe de l'Est (hors UE et Russie), Norvège, Maghreb
                                    *Zone C : Autres destinations
                                """).font(.footnote)
        }
        
    }
    
    
    var selectedShippingCost: SelectedShippingCost? {
        
        let weight = order.totalWeight * orderWeightMarginRatio
        
        if order.shippingMethodId == shippingMethodId_France {
            
            if let cost = shippingCostFrance
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                var chooseLetter: Bool = false
                var chooseParcel: Bool = false
                let chooseParcelZB: Bool = false
                let chooseParcelZC: Bool = false
                
                var value: Float?
                
                if weight < 250 {
                    chooseLetter = true
                    value = cost.priceLetter
                } else {
                    chooseParcel = true
                    value = cost.priceParcel
                }
                
                return SelectedShippingCost(
                    maxWeight: cost.maxWeight,
                    chooseLetter: chooseLetter, chooseParcel: chooseParcel,
                    chooseParcelZB: chooseParcelZB, chooseParcelZC: chooseParcelZC,
                    value: value
                )
            }
            
        } else if order.shippingMethodId == shippingMethodId_Europe {
            
            if let cost = shippingCostEurope
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                var chooseLetter: Bool = false
                var chooseParcel: Bool = false
                let chooseParcelZB: Bool = false
                let chooseParcelZC: Bool = false
                
                var value: Float?
                
                if weight < 250 {
                    chooseLetter = true
                    value = cost.priceLetter
                } else {
                    chooseParcel = true
                    value = cost.priceParcel
                }
                
                return SelectedShippingCost(
                    maxWeight: cost.maxWeight,
                    chooseLetter: chooseLetter, chooseParcel: chooseParcel,
                    chooseParcelZB: chooseParcelZB, chooseParcelZC: chooseParcelZC,
                    value: value
                )
            }
            
        } else if order.shippingMethodId == shippingMethodId_World {
            
            if let cost = shippingCostWorld
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                var chooseLetter: Bool = false
                let chooseParcel: Bool = false
                var chooseParcelZB: Bool = false
                var chooseParcelZC: Bool = false
                
                var value: Float?
                
                if weight < 250 {
                    chooseLetter = true
                    value = cost.priceLetter
                } else {
                    if ["US"].contains(order.shippingAddressCountryCode) {
                        chooseParcelZC = true
                        value = cost.priceParcelZC
                    } else {
                        chooseParcelZB = true
                        value = cost.priceParcelZB
                    }
                }
                
                return SelectedShippingCost(
                    maxWeight: cost.maxWeight,
                    chooseLetter: chooseLetter, chooseParcel: chooseParcel,
                    chooseParcelZB: chooseParcelZB, chooseParcelZC: chooseParcelZC,
                    value: value
                )
            }
        }
        
        return nil
    }
}
