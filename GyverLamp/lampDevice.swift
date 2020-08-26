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

enum CommandsToLamp: String {
    case power = "POWER"
    case eff = "EFF"
    case get = "GET"
    case deb = "DEB"
    case bri = "BRI"
    case spd = "SPD"
    case sca = "SCA"
    case gbr = "GBR"
    case list = "LIST"
    case timer = "TMR_SET"
}

class UDPClient {
    var connection: NWConnection?

    // MARK: - UDP

    func connectToUDP(messageToUDP: CommandsToLamp, lamp: LampDevice, value: Int) {
        // Transmited message:

        connection = NWConnection(host: lamp.hostIP ?? "0.0.0.0", port: lamp.hostPort ?? 8888, using: .udp)
        connection?.stateUpdateHandler = { newState in
            // print("This is stateUpdateHandler:")
            switch newState {
            case .ready:
                print(self.makeCommandForLamp(command: messageToUDP, lamp: lamp, value: value))
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
                DispatchQueue.main.async { print("Data was sent to UDP")
                    
                }
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        })))
    }

    private func makeCommandForLamp(command: CommandsToLamp, lamp: LampDevice, value: Int) -> String {
        switch command {
        case .get, .gbr, .list: return command.rawValue
        case .power:

            if lamp.powerStatus == false {
                return "P_ON"
            } else {
                return "P_OFF"
            }
        case .eff:
            return "EFF" + String(value)
        case .deb:
            return "DEB"
        case .bri:
            return "BRI" + String(value)
        case .spd:
            return "SPD" + String(value)
        case .sca:
            return "SCA" + String(value)

        case .timer:
            switch value {
            case 0: return "TMR_SET" + " 0 " + String(value) + " 0"
            case 1: return "TMR_SET" + " 1 " + String(value) + " 60"
            case 2: return "TMR_SET" + " 1 " + String(value) + " 300"
            case 3: return "TMR_SET" + " 1 " + String(value) + " 600"
            case 4: return "TMR_SET" + " 1 " + String(value) + " 900"
            case 5: return "TMR_SET" + " 1 " + String(value) + " 1800"
            case 6: return "TMR_SET" + " 1 " + String(value) + " 2700"
            case 7: return "TMR_SET" + " 1 " + String(value) + " 3600"
            default:
                return "TMR_SET" + " 0 " + String(value) + " 0"
            }
        }
    }

    private func receiveUDP(lamp: LampDevice) {
        connection?.receiveMessage { data, _, isComplete, _ in
            if isComplete {
                if data != nil {
                    let backToString = String(decoding: data!, as: UTF8.self)
                    print("Received message: \(backToString)")

                    switch backToString.parseDataFromLamp()[0] {
                    case "CURR":
                        lamp.connectionStatus = true
                        if backToString.parseDataFromLamp()[5] == "0" {
                            lamp.powerStatus = false
                        } else {
                            lamp.powerStatus = true
                        }
                        if backToString.parseDataFromLamp()[8] == "1" {
                            lamp.timer = true
                        } else {
                            lamp.timer = false
                        }
                        lamp.effect = Int(backToString.parseDataFromLamp()[1])
                        lamp.bright = Int(backToString.parseDataFromLamp()[2])
                        lamp.speed = Int(backToString.parseDataFromLamp()[3])
                        lamp.scale = Int(backToString.parseDataFromLamp()[4])
                        UserDefaults.standard.set("\(lamp.hostIP ?? "0.0.0.0")", forKey: "hostIP")
                        UserDefaults.standard.set("\(lamp.hostPort ?? 8888)", forKey: "hostPort")
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("updateLamp"), object: lamp)
                            NotificationCenter.default.post(name: Notification.Name("updateInterface"), object: nil)
                        }
                        self.connection?.cancel()
                    case "TMR":
                        if backToString.parseDataFromLamp()[1] == "1" {
                            lamp.timer = true
                        } else {
                            lamp.timer = false
                        }

                    default: break
                    }

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
    var timer: Bool?

    var effect: Int?
    var bright: Int?
    var speed: Int?
    var scale: Int?

    init(hostIP: NWEndpoint.Host, hostPort: NWEndpoint.Port) {
        self.hostIP = hostIP
        self.hostPort = hostPort
        powerStatus = false
        connectionStatus = false
        timer = false
        effect = 0
        bright = 0
        scale = 0
        speed = 0

        updateStatus(lamp: self)
    }

    public func updateStatus(lamp: LampDevice) {
        let client = UDPClient()
        client.connectToUDP(messageToUDP: .get, lamp: lamp, value: 0)
    }

    public func sendCommand(lamp: LampDevice, command: CommandsToLamp, value: Int) {
        let client = UDPClient()

        client.connectToUDP(messageToUDP: command, lamp: lamp, value: value)
    }

    static func scan() {
        guard let deviceIp = UIDevice.current.getWiFiAddress() else {
            print("Can`t get local ip adress. Emmiting 'onError'")

            return
        }

        let client = UDPClient()

        let mask = deviceIp.split(separator: ".")

        for i in 1 ... 255 {
            let lampIp = "\(mask[0]).\(mask[1]).\(mask[2]).\(i)"

            client.connectToUDP(messageToUDP: .get, lamp: LampDevice(hostIP: NWEndpoint.Host(lampIp), hostPort: 8888), value: 0)
        }
    }
}
