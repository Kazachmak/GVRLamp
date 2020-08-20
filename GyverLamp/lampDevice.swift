//
//  lampDevice.swift
//  GyverLamp
//
//  Created by Максим Казачков on 19.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import Foundation
import Network
import UIKit

var listOfLamps = ["192.168.1.66:8888","192.168.1.69:8888"]



enum CommandsToLamp: String {
    case power = "POWER"
    case eff = "EFF"
    case get = "GET"
    case deb = "DEB"
    case bri = "BRI"
    case spd = "SPD"
    case sca = "SCA"
}

class UDPClient {
    var connection: NWConnection?

    // MARK: - UDP

    
    
    func connectToUDP(_ hostUDP: NWEndpoint.Host, _ portUDP: NWEndpoint.Port, messageToUDP: CommandsToLamp, lamp: LampDevice, value: Int) {
        // Transmited message:

        connection = NWConnection(host: hostUDP, port: portUDP, using: .udp)
        connection?.stateUpdateHandler = { newState in
            // print("This is stateUpdateHandler:")
            switch newState {
            case .ready:
                // print("State: Ready\n")
                self.sendUDP(self.makeCommandForLamp(command: messageToUDP, lamp: lamp, value: value))
                self.receiveUDP(lamp: lamp)
            case .setup: break
            // print("State: Setup\n")
            case .cancelled: break
            // print("State: Cancelled\n")
            case .preparing: break
            // print("State: Preparing\n")
            default: break
                // print("ERROR! State not defined!\n")
            }
        }

        connection?.start(queue: .global())
        
    }

    private func sendUDP(_ content: Data) {
        connection?.send(content: content, completion: NWConnection.SendCompletion.contentProcessed(({ NWError in
            if NWError == nil {
                print("Data was sent to UDP")
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        })))
    }

    private func sendUDP(_ content: String) {
        let contentToSendUDP = content.data(using: String.Encoding.utf8)
        connection?.send(content: contentToSendUDP, completion: NWConnection.SendCompletion.contentProcessed(({ NWError in
            if NWError == nil {
                DispatchQueue.main.async { print("Data was sent to UDP") }
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        })))
    }

    private func makeCommandForLamp(command: CommandsToLamp, lamp: LampDevice, value: Int) -> String {
        switch command {
        case .get: return command.rawValue
        case .power:

            if lamp.powerStatus == false {
                return "P_ON"
            } else {
                return "P_OFF"
            }
        case .eff:
            return "EFF"+String(value)
        case .deb:
            return "DEB"
        case .bri:
            return "BRI"+String(value)
        case .spd:
            return "SPD"+String(value)
        case .sca:
            return "SCA"+String(value)
        }
    }

    private func receiveUDP(lamp: LampDevice) {
        connection?.receiveMessage { data, _, isComplete, _ in
            if isComplete {
              
                if data != nil {
                    let backToString = String(decoding: data!, as: UTF8.self)
                    print("Received message: \(backToString)")
                    if !listOfLamps.contains("\(lamp.hostIP ?? "0.0.0.0")"+":"+"\( lamp.hostPort ?? 8888)"){
                        listOfLamps.append("\(lamp.hostIP ?? "0.0.0.0")"+":"+"\(lamp.hostPort ?? 8888)")
                    }
                    lamp.connectionStatus = true
                    if backToString.parseDataFromLamp()[5] == "0" {
                        lamp.powerStatus = false
                    } else {
                        lamp.powerStatus = true
                    }
                    lamp.effect = Int(backToString.parseDataFromLamp()[1])
                    lamp.bright = Int(backToString.parseDataFromLamp()[2])
                    lamp.speed = Int(backToString.parseDataFromLamp()[3])
                    lamp.scale = Int(backToString.parseDataFromLamp()[4])
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("updateInterface"), object: nil)
                        }
                    self.connection?.cancel()
                } else {
                    print("Data == nil")
                    self.connection?.cancel()
                }
            }
        }
    }
}

class LampDevice {
    let hostIP: NWEndpoint.Host?
    let hostPort: NWEndpoint.Port?
    var connectionStatus: Bool?
    var powerStatus: Bool?
    
    var effect: Int?
    var bright: Int?
    var speed: Int?
    var scale: Int?

    init(hostIP: NWEndpoint.Host, hostPort: NWEndpoint.Port) {
        self.hostIP = hostIP
        self.hostPort = hostPort
        powerStatus = false
        connectionStatus = false
        effect = 0
        bright = 0
        scale = 0
        speed = 0
        updateStatus(lamp: self)
    }

    public func updateStatus(lamp: LampDevice) {
        let client = UDPClient()
        client.connectToUDP(hostIP ?? "0.0.0.0", 8888, messageToUDP: .get, lamp: lamp, value: 0)
    }


    public func sendCommand(lamp: LampDevice, command: CommandsToLamp, value: Int) {
        let client = UDPClient()
        
        client.connectToUDP(hostIP ?? "0.0.0.0", 8888, messageToUDP: command, lamp: lamp, value: value)
        
    }
    
    
    /*
     static func scan() {
         guard let deviceIp = UIDevice.current.getWiFiAddress() else {
             print("Can`t get local ip adress. Emmiting 'onError'")

             return
         }

         let client = UDPClient()

         let mask = deviceIp.split(separator: ".")

         for i in 1 ... 255 {
             let lampIp = "\(mask[0]).\(mask[1]).\(mask[2]).\(i)"

             client.connectToUDP(NWEndpoint.Host.name(lampIp, nil), 8888)

         }

     }
     */
}
