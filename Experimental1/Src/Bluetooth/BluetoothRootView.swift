
import SwiftUI
import CoreBluetooth



struct BluetoothRootView: View {
    
    var controller = BluetoothController()
    
    @State var cmd = ""

    var body: some View {

        Button(controller.state ? "On" : "Off") {
            controller.toggle()
        }
        TextField("Cmd", text: $cmd).onSubmit {
            controller.writeCmd(cmd)
        }
    }
}



#Preview {
    BluetoothRootView()
}



@Observable
class BluetoothController: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var state: Bool = false
    
    private var manager: CBCentralManager!
    private let ledServiceUUID = CBUUID(string: "19B10000-E8F2-537E-4F6C-D104768A1214")
    private let switchCharacteristicUUID = CBUUID(string: "19B10001-E8F2-537E-4F6C-D104768A1214")
    private let cmdCharacteristicUUID = CBUUID(string: "19B10002-E8F2-537E-4F6C-D104768A1214")
    
    private var peripheral: CBPeripheral!
    private var switchCharacteristic: CBCharacteristic!
    private var cmdCharacteristic: CBCharacteristic!
    
    override init() {
        super.init()
        print("Starting bluetooth...")
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scan() {
        print("Scanning for peripherals...")
        manager.scanForPeripherals(withServices: [ledServiceUUID])
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("manager - state update: \(central.state)")
        if central.state == .poweredOn {
            scan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral != self.peripheral {
            print("manager - discovered new peripheral: \(peripheral.identifier)")
            self.peripheral = peripheral
            print("Connecting to peripheral...")
            manager.connect(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        print("manager - failed to connect to: \(peripheral.identifier)")
        if let error = error { print(error) }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("manager - connected to peripheral: \(peripheral.identifier)")
        peripheral.delegate = self
        peripheral.discoverServices([ledServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        print("manager - disconnected from peripheral: \(peripheral.identifier)")
        if let error = error { print(error) }
        self.peripheral = nil
        print("Scanning for peripherals...")
        manager.scanForPeripherals(withServices: [ledServiceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        print("peripheral: \(peripheral.identifier) - discovered services")
        if let error = error { print(error) }
        print((peripheral.services ?? []).map(\.uuid))
        if let ledService = peripheral.services?.first(where: { $0.uuid == ledServiceUUID }) {
            print("found ledService: \(ledService.uuid)")
            peripheral.discoverCharacteristics([switchCharacteristicUUID, cmdCharacteristicUUID], for: ledService)
        } else {
            print("ledService (\(ledServiceUUID)) not found")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        print("peripheral: \(peripheral.identifier) - service: \(service.uuid) - discovered characteristics")
        if let error = error { print(error) }
        print((service.characteristics ?? []).map(\.uuid))
        if let switchCharacteristic = service.characteristics?.first(where: { $0.uuid == switchCharacteristicUUID }) {
            print("found switchCharacteristic: \(switchCharacteristic.uuid)")
            self.switchCharacteristic = switchCharacteristic
        }
        if let cmdCharacteristic = service.characteristics?.first(where: { $0.uuid == cmdCharacteristicUUID }) {
            print("found cmdCharacteristic: \(cmdCharacteristic.uuid)")
            self.cmdCharacteristic = cmdCharacteristic
        }
    }
    
    func toggle() {
        state.toggle()
        writeSwitch(state ? 1 : 0)
    }
    
    func writeSwitch(_ n: UInt8) {
        var data = Data()
        data.append(contentsOf: [n])
        peripheral.writeValue(data, for: switchCharacteristic, type: .withResponse)
    }
    
    func writeCmd(_ str: String) {
        let data = str.data(using: .utf8)!
        peripheral.writeValue(data, for: cmdCharacteristic, type: .withResponse)
    }
}



extension CBManagerState: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .poweredOff:
            "poweredOff"
        case .poweredOn:
            "poweredOn"
        case .resetting:
            "resetting"
        case .unauthorized:
            "unauthorized"
        case .unknown:
            "unknown"
        case .unsupported:
            "unsupported"
        @unknown default:
            "unknown default"
        }
    }
}
