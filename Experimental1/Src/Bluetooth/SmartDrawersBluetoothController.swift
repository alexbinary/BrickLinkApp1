
import Foundation
import CoreBluetooth



@Observable
class SmartDrawersBluetoothController: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    
    var state: State
    
    enum State {
        case connecting
        case ready
    }
    
    
    private let drawerServiceUUID = CBUUID(string: "B4D0A874-5F62-4E84-B641-ED066B889790")
    private let drawerCharacteristicUUID = CBUUID(string: "9ED7D01A-EB96-486D-81C0-D511A1588389")
    private let repeatCharacteristicUUID = CBUUID(string: "5E4552A9-0ED6-4DA6-A36F-5114D5E496F5")
    
    private var manager: CBCentralManager!
    private var smartDrawersPeripheral: CBPeripheral?
    private var drawerCharacteristic: CBCharacteristic?
    private var repeatCharacteristic: CBCharacteristic?
    
    
    public var repeatCount: UInt8? = nil
    
    
    override init() {
        
        state = .connecting
        super.init()
        
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    private func scan() {
        
        print("Bluetooth scanning for peripherals...")
        manager.scanForPeripherals(withServices: [drawerServiceUUID])
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        print("Bluetooth state: \(central.state)")
        if central.state == .poweredOn {
            scan()
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if peripheral != self.smartDrawersPeripheral {
            
            print("Bluetooth peripheral \(peripheral.identifier) with RSSI \(RSSI)")
            self.smartDrawersPeripheral = peripheral
            
            print("Bluetooth connecting to peripheral \(peripheral.identifier)...")
            manager.connect(peripheral)
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("Bluetooth connected to peripheral \(peripheral.identifier)")
        peripheral.delegate = self
        peripheral.discoverServices([drawerServiceUUID])
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        
        print("Bluetooth failed to connect to peripheral \(peripheral.identifier)")
        if let error = error { print(error) }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        
        print("Bluetooth disconnected from peripheral \(peripheral.identifier)")
        if let error = error { print(error) }
        self.smartDrawersPeripheral = nil
        
        state = .connecting
        scan()
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        
        if let error = error { print(error) }
        
        if let drawerService = peripheral.services?.first(where: { $0.uuid == drawerServiceUUID }) {
            print("Bluetooth found drawer service")
            peripheral.discoverCharacteristics([drawerCharacteristicUUID, repeatCharacteristicUUID], for: drawerService)
        } else {
            print("Bluetooth error: drawer service (\(drawerServiceUUID)) not found on peripheral \(peripheral.identifier)")
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        
        if let error = error { print(error) }
        
        if let drawerCharacteristic = service.characteristics?.first(where: { $0.uuid == drawerCharacteristicUUID }) {
            
            print("Bluetooth found drawer characteristic")
            self.drawerCharacteristic = drawerCharacteristic
            
            print("Bluetooth ready to send commands")
            state = .ready
            
        } else {
            
            print("""
                Bluetooth error: drawer characteristic \(drawerCharacteristicUUID) not found \
                on drawer service (\(drawerServiceUUID)) \
                on peripheral \(peripheral.identifier)
                """)
        }
        
        if let repeatCharacteristic = service.characteristics?.first(where: { $0.uuid == repeatCharacteristicUUID }) {
            
            print("Bluetooth found repeat count characteristic")
            self.repeatCharacteristic = repeatCharacteristic
            
        } else {
            
            print("""
                Bluetooth error: repeat characteristic \(repeatCharacteristicUUID) not found \
                on drawer service (\(drawerServiceUUID)) \
                on peripheral \(peripheral.identifier)
                """)
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        
        print("Bluetooth did update value for characteristic \(characteristic.uuid)")
        
        if let error = error { print(error) }
        
        if characteristic.uuid == repeatCharacteristic?.uuid {
            
            if let count = characteristic.value?.first {
                
                print("Bluetooth updating repeat count to \(count)")
                repeatCount = UInt8(count)
                
            } else {
                
                print("Bluetooth could not read value from characteristic \(characteristic.uuid)")
            }
        }
    }
    
    
    func openDrawer(_ drawer: UInt8) {
        
        guard let peripheral = smartDrawersPeripheral, let drawerCharacteristic = drawerCharacteristic else {
            print("Bluetooth error: device not ready")
            return
        }
            
        print("Bluetooth sending drawer command: \(drawer)")
        var data = Data()
        data.append(contentsOf: [drawer])
        peripheral.writeValue(data, for: drawerCharacteristic, type: .withResponse)
    }
    
    
    func setRepeatCount(_ count: UInt8) {
        
        guard let peripheral = smartDrawersPeripheral, let repeatCharacteristic = repeatCharacteristic else {
            print("Bluetooth error: device not ready")
            return
        }
            
        print("Bluetooth writing repeat count: \(count)")
        var data = Data()
        data.append(contentsOf: [count])
        peripheral.writeValue(data, for: repeatCharacteristic, type: .withResponse)
        
        peripheral.readValue(for: repeatCharacteristic)
    }
    
    
    func readRepeatCount() {
        
        guard let peripheral = smartDrawersPeripheral, let repeatCharacteristic = repeatCharacteristic else {
            print("Bluetooth error: device not ready")
            return
        }
            
        peripheral.readValue(for: repeatCharacteristic)
    }
}
