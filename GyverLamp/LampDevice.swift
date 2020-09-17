//
//  lampDevice.swift
//  GyverLamp
//
//  Created by Максим Казачков on 19.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

//import Foundation
import Network
import UIKit

// команды, которые можно передать на лампу
enum CommandsToLamp: String {
    case power_on = "P_ON"
    case power_off = "P_OFF"
    case eff = "EFF"
    case get = "GET"
    case deb = "DEB"
    case bri = "BRI"
    case spd = "SPD"
    case sca = "SCA"
    case gbr = "GBR"
    case list = "LIST"
    case timer = "TMR_SET"
    case alarm_on
    case alarm_off
    case alarm = "ALM_SET"
    case button_on = "BTN ON"
    case button_off = "BTN OFF"
    case dawn = "DAWN"
    case fav_get = "FAV_GET"
    case fav_set = "FAV_SET"
}

class UDPClient {
    
    var connection: NWConnection?
    
    // подготовка сообщения для отправки в лампу
    func connectToUDP(messageToUDP: CommandsToLamp, lamp: LampDevice, value: [Int]) {

        connection = NWConnection(host: lamp.hostIP ?? "0.0.0.0", port: lamp.hostPort ?? 8888, using: .udp)
        connection?.stateUpdateHandler = { newState in
            // print("This is stateUpdateHandler:")
            switch newState {
            case .ready:
                //print(self.makeCommandForLamp(command: messageToUDP, lamp: lamp, value: value))
                self.sendUDP(self.makeCommandForLamp(command: messageToUDP, value: value)) // отправляем сообщение
                self.receiveUDP(lamp: lamp) // принимаем сообщение

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

    //отправка сообщения
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

    //формирователь команды
    private func makeCommandForLamp(command: CommandsToLamp, value: [Int]) -> String {
        switch command {
        case .list: return command.rawValue + String(value[0])
        case .get, .gbr, .button_on, .button_off, .fav_get, .power_on, .power_off, .deb: return command.rawValue
        case .eff:
            return command.rawValue + String(value[0])
        case .bri:
            return command.rawValue + String(value[0])
        case .spd:
            return command.rawValue + String(value[0])
        case .sca:
            return command.rawValue + String(value[0])
        case .alarm_on: return "ALM_SET" + String(value[0]) + " ON"
        case .alarm_off: return "ALM_SET" + String(value[0]) + " OFF"
        case .timer:
            switch value[0] {
            case 0: return command.rawValue + " 0 " + String(value[0]) + " 0"
            case 1: return command.rawValue + " 1 " + String(value[0]) + " 60"
            case 2: return command.rawValue + " 1 " + String(value[0]) + " 300"
            case 3: return command.rawValue + " 1 " + String(value[0]) + " 600"
            case 4: return command.rawValue + " 1 " + String(value[0]) + " 900"
            case 5: return command.rawValue + " 1 " + String(value[0]) + " 1800"
            case 6: return command.rawValue + " 1 " + String(value[0]) + " 2700"
            case 7: return command.rawValue + " 1 " + String(value[0]) + " 3600"
            default:
                return command.rawValue + " 0 " + String(value[0]) + " 0"
            }

        case .dawn:
            return command.rawValue + String(value[0])
        case .alarm:
            return command.rawValue + String(value[0]) + " " + String(value[1])
        case .fav_set:
            var str = ""
            for element in value {
                str.append(String(element) + " ")
            }
            return command.rawValue + " " + str
        }
    }

    // обработка полученных от лампы сообщений
    private func receiveUDP(lamp: LampDevice) {
        connection?.receiveMessage { data, _, isComplete, _ in
            if isComplete {
                if data != nil {
                    let backToString = String(decoding: data!, as: UTF8.self)
                    print("Received message: \(backToString)")

                    /*
                     if backToString.contains("LIST"){
                         var arrayOfQuantity = backToString.components(separatedBy: ";")
                         arrayOfQuantity.removeFirst()
                         for element in arrayOfQuantity{
                             lamp.listOfEffects.append(element.components(separatedBy: ",")[0])
                         }

                     }
                     */

                    switch backToString.components(separatedBy: " ")[0] {
                    case "CURR":
                        lamp.connectionStatus = true
                        if backToString.components(separatedBy: " ")[5] == "0" {
                            lamp.powerStatus = false
                        } else {
                            lamp.powerStatus = true
                        }
                        if backToString.components(separatedBy: " ")[8] == "1" {
                            lamp.timer = true
                        } else {
                            lamp.timer = false
                        }
                        lamp.effect = Int(backToString.components(separatedBy: " ")[1])
                        lamp.bright = Int(backToString.components(separatedBy: " ")[2])
                        lamp.speed = Int(backToString.components(separatedBy: " ")[3])
                        lamp.scale = Int(backToString.components(separatedBy: " ")[4])
                        if backToString.components(separatedBy: " ")[9] == "1" {
                            lamp.button = true
                        } else {
                            lamp.button = false
                        }
                        UserDefaults.standard.set("\(lamp.hostIP ?? "0.0.0.0")", forKey: "hostIP")
                        UserDefaults.standard.set("\(lamp.hostPort ?? 8888)", forKey: "hostPort")
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("updateLamp"), object: lamp)
                            NotificationCenter.default.post(name: Notification.Name("updateInterface"), object: nil)
                        }

                    case "TMR":
                        if backToString.components(separatedBy: " ")[1] == "1" {
                            lamp.timer = true
                        } else {
                            lamp.timer = false
                        }

                    case "ALMS":
                        lamp.alarm = backToString
                        lamp.dawn = Int(backToString.components(separatedBy: " ")[15])
                    case "FAV":
                        lamp.favorite = backToString

                    default: break
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

class LampDevice { // объект лампа
    let hostIP: NWEndpoint.Host? // адрес
    let hostPort: NWEndpoint.Port? // порт
    var connectionStatus: Bool? // наличие соединения с лампой
    var powerStatus: Bool? // включено или выключено
    var timer: Bool? // таймер
    var button: Bool? // кнопка на лампе включена или выключена
    var alarm: String? // будильники
    var dawn: Int? //
    var favorite: String? // автопереключение эффектов
    // var listOfEffects: [String] = []

    var effect: Int? // номер текущего эффекта
    var bright: Int? // значение яркости
    var speed: Int? // значение скорости
    var scale: Int? // значение масштаба

    init(hostIP: NWEndpoint.Host, hostPort: NWEndpoint.Port) {
        self.hostIP = hostIP
        self.hostPort = hostPort

        updateStatus(lamp: self) // запросить состояние лампы
        // updateListOfEffects(lamp: self)
    }

    public func updateStatus(lamp: LampDevice) {
        let client = UDPClient()
        client.connectToUDP(messageToUDP: .get, lamp: lamp, value: [0]) // запрос состояние лампы
        client.connectToUDP(messageToUDP: .fav_get, lamp: lamp, value: [0]) // запрос режима автопереключения
    }

    // запрос эффектов из лампы, сейчас не реализовано
    public func updateListOfEffects(lamp: LampDevice) {
        let client = UDPClient()
        client.connectToUDP(messageToUDP: .list, lamp: lamp, value: [1])
        client.connectToUDP(messageToUDP: .list, lamp: lamp, value: [2])
        client.connectToUDP(messageToUDP: .list, lamp: lamp, value: [3])
    }

    // отправка команды в лампу
    public func sendCommand(lamp: LampDevice, command: CommandsToLamp, value: [Int]) {
        let client = UDPClient()
        client.connectToUDP(messageToUDP: command, lamp: lamp, value: value)
    }

    //поиск ламп в локальной сети
    static func scan(deviceIp: String) {
        let client = UDPClient()
        print(deviceIp)
        client.connectToUDP(messageToUDP: .get, lamp: LampDevice(hostIP: NWEndpoint.Host(deviceIp), hostPort: 8888), value: [0])
        
    }
}
