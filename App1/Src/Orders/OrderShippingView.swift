
import SwiftUI



struct OrderShippingView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let orderId: OrderDetails.ID
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
                
            if let order = appController.orderDetails(forOrderWithId: orderId) {
                
                HStack(alignment: .top, spacing: 48) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                
                        HeaderTitleView(label: "􀅴 Address")
                        
                        VStack(alignment: .leading) {
                            Text(order.shippingAddressName)
                            Text(order.shippingAddress).fixedSize(horizontal: false, vertical: true)
                            Text(order.shippingAddressCountryCode)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HeaderTitleView(label: "􀭭 Weight")
                        
                        Grid(alignment: .leading) {
                            
                            GridRow {
                                Text("Actual :")
                                Text("\(String(format: "%.0f", order.totalWeight))g")
                            }
                            GridRow {
                                Text("Charged :")
                                Text("\(String(format: "%.0f", order.totalWeight * orderWeightMarginRatio))g")
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HeaderTitleView(label: "􀖧 Shipping")
                        
                        Grid(alignment: .leading) {
                            
                            GridRow {
                                Text("Method :")
                                Text(order.shippingMethodName ?? "")
                            }
                            
                            GridRow {
                                Text("Price :")
                                Text(order.shippingCost, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                            }
                        }
                    }
                }
                
                Divider()
                
                HStack(alignment: .top, spacing: 48) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HeaderTitleView(label: "􀐚 Packing & Stamping")
                        
                        Grid(alignment: .leading, verticalSpacing: 8) {
                            
                            GridRow {
                                Text("Recommended method :")
                                
                                HStack {
                                    Toggle("letter", isOn: .constant(selectedShippingCost?.chooseLetter ?? false))
                                    Toggle("parcel", isOn: .constant(selectedShippingCost?.chooseParcel ?? false))
                                }
                            }
                            
                            GridRow {
                                Text("Shipping cost :")
                                
                                var shippingCostEditValue = appController.shippingCost(forOrderWithId: order.id) ?? 0
                                
                                let shippingCostBinding = Binding<Float> {
                                    return shippingCostEditValue
                                } set: { newValue in
                                    shippingCostEditValue = newValue
                                }
                                
                                TextField("Shipping cost", value: shippingCostBinding,
                                          format: .currency(code: "EUR").presentation(.isoCode)
                                )
                                .onSubmit {
                                    appController.updateShippingCost(forOrderWithId: order.id, cost: shippingCostEditValue)
                                }
                                .frame(maxWidth: 120)
                                
                                HStack {
                                    Button {
                                        Task {
                                            appController.updateShippingCost(forOrderWithId: order.id, cost: shippingCostEditValue)
                                        }
                                    } label: {
                                        Text("Save")
                                    }
                                    
                                    if let selectedShippingCost = selectedShippingCost,
                                       let shippingCostPredictedValue = selectedShippingCost.value {
                                        
                                        Button {
                                            appController.updateShippingCost(forOrderWithId: order.id, cost: shippingCostPredictedValue)
                                        } label: {
                                            HStack {
                                                Text("Predicted:")
                                                Text(shippingCostPredictedValue, format: .currency(code: "EUR").presentation(.isoCode))
                                            }
                                        }
                                    }
                                }
                            }
                            
                            GridRow {
                                Text("Stamping :")
                                
                                let recommendedMethod = {
                                    
                                    var s = ""
                                    
                                    if let selectedAffranchissement = selectedAffranchissement {
                                        
                                        if selectedAffranchissement.usePostOffice {
                                            return "Bureau de poste"
                                        } else {
                                            s = "\(selectedAffranchissement.nbTimbres) timbres"
                                            
                                            if order.shippingMethodId != shippingMethodId_France {
                                                s += " international"
                                            }
                                            
                                            return s
                                        }
                                    }
                                    
                                    return s
                                }()
                                
                                if let confirmedMethod = appController.affranchissement(forOrderWithId: order.id) {
                                    Text(confirmedMethod)
                                } else {
                                    Text("")
                                }
                                
                                HStack {
                                    Button {
                                        appController.updateAffranchissement(forOrderWithId: order.id, method: recommendedMethod)
                                    } label: {
                                        Text("Recommended: \(recommendedMethod)")
                                    }
                                    
                                    if recommendedMethod != "Bureau de poste" {
                                        Button {
                                            appController.updateAffranchissement(forOrderWithId: order.id, method: "Bureau de poste")
                                        } label: {
                                            Text("Bureau de poste")
                                        }
                                    }
                                }
                            }
                            
                            GridRow {
                                Text("")
                                Text("")
                                HStack {
                                    Button {
                                        self.appController.validateOrderWithoutStamping(orderId: order.id)
                                    } label: {
                                        Text("Validate without stamping")
                                    }
                                    if let date = appController.dateOrderValidatedWithoutStamping(orderId: order.id) {
                                        Text("Validated without stamping on")
                                        Text(date, format: .dateTime)
                                    }
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HeaderTitleView(label: "􁁾 Shipping")
                        
                        Grid(alignment: .leading, verticalSpacing: 8) {
                            
                            GridRow {
                                
                                Text("Tracking no :")
                                
                                var trackingNoEditValue = order.trackingNo
                                
                                let trackingNoBinding = Binding<String> {
                                    return trackingNoEditValue ?? ""
                                } set: { newValue in
                                    trackingNoEditValue = newValue
                                }
                                
                                TextField("Tracking No", text: trackingNoBinding)
                                    .onSubmit {
                                        Task {
                                            await appController.updateTrackingNo(forOrderWithId: order.id, trackingNo: trackingNoEditValue ?? "")
                                        }
                                    }
                                    .frame(maxWidth: 140)
                                
                                Button {
                                    Task {
                                        await appController.updateTrackingNo(forOrderWithId: order.id, trackingNo: trackingNoEditValue ?? "")
                                    }
                                } label: {
                                    Text("Save")
                                }
                            }
                            
                            GridRow {
                                
                                Text("Drive thru :")
                                
                                if order.driveThruSent {
                                    Text("sent")
                                } else {
                                    Text("not sent")
                                }
                                
                                Button {
                                    Task {
                                        await appController.sendDriveThru(orderId: order.id)
                                    }
                                } label: {
                                    Text("Send")
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                Color.clear.frame(width: 0, height: 48)
                    
                let title = "􀅴 Tarifs La Poste 2025 - " + {
                    
                    if order.shippingMethodId == shippingMethodId_France {
                        return "France"
                    } else if order.shippingMethodId == shippingMethodId_Europe {
                        return "Europe"
                    } else if order.shippingMethodId == shippingMethodId_World {
                        return "Monde"
                    }
                    return ""
                }()
                HeaderTitleView(label: title)
                
                Grid(alignment: .leading) {
                    GridRow {
                        Text("Timbre").font(.caption).foregroundStyle(.secondary)
                        Text("Suivi").font(.caption).foregroundStyle(.secondary)
                    }
                    GridRow {
                        Text(
                            order.shippingMethodId == shippingMethodId_France ? priceTimbreFrance : priceTimbreWorld,
                            format: .currency(code: "EUR").presentation(.isoCode)
                        )
                        Text(
                            order.shippingMethodId == shippingMethodId_France ? priceTrackingFrance : priceTrackingWorld,
                            format: .currency(code: "EUR").presentation(.isoCode)
                        )
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
        }
        .padding()
        .task {
            await parallel([
                { await loadOrder() },
                { await loadOrderItems() },
            ])
        }
        .onChange(of: orderId) { oldValue, newValue in
            Task {
                await parallel([
                    { await loadOrder() },
                    { await loadOrderItems() },
                ])
            }
        }
    }
    
    
    func loadOrder() async {
        
        await appController.loadOrderDetailsIfMissing(forOrderWithId: orderId)
    }
    
    
    func loadOrderItems() async {
        
        await appController.loadOrderItemsIfMissing(forOrderWithId: orderId)
    }
    
    
    var selectedShippingCost: SelectedShippingCost? {
        
        guard let order = appController.orderDetails(forOrderWithId: orderId) else {
            return nil
        }
        
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
    
    
    var selectedAffranchissement: SelectedAffranchissement? {
        
        guard let order = appController.orderDetails(forOrderWithId: orderId) else {
            return nil
        }
        
        let weight = order.totalWeight * orderWeightMarginRatio
        
        if order.shippingMethodId == shippingMethodId_France {
            
            if let aff = affranchissementValuesFrance
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                return SelectedAffranchissement(
                    maxWeight: aff.maxWeight,
                    
                    useTimbresParMultiples: aff.preferTimbresParMultiples,
                    useTimbres: aff.preferTimbres,
                    usePostOffice: !aff.preferTimbresParMultiples && !aff.preferTimbres,
                    
                    nbTimbres: aff.preferTimbres ? Int(ceil(aff.nbTimbresRequired)) : aff.preferTimbresParMultiples ? aff.timbresParMultiples ?? 0 : 0
                )
            }
            
        } else {
            
            if let aff = affranchissementValuesWorld
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                return SelectedAffranchissement(
                    maxWeight: aff.maxWeight,
                    
                    useTimbresParMultiples: aff.preferTimbresParMultiples,
                    useTimbres: aff.preferTimbres,
                    usePostOffice: !aff.preferTimbresParMultiples && !aff.preferTimbres,
                    
                    nbTimbres: aff.preferTimbres ? Int(ceil(aff.nbTimbresRequired)) : aff.preferTimbresParMultiples ? aff.timbresParMultiples ?? 0 : 0
                )
            }
        }
        
        return nil
    }
}



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
