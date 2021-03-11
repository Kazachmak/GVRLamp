//
//  lampDevice.swift
//  GyverLamp
//
//  Created by Максим Казачков on 19.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

// import Foundation
import Network
import UIKit

// команды, которые можно передать на лампу
enum CommandsToLamp: String {
    case power_on = "P_ON" // включить
    case power_off = "P_OFF" // выключить
    case eff = "EFF" // номер эффекта
    case get = "GET-" // запрос состояния
    case txt = "TXT-" // отправка бегущей стрjки
    case deb = "DEB"
    case bri = "BRI" // установка яркости
    case spd = "SPD" // установка скорости
    case sca = "SCA" // установка масштаба
    case gbr = "GBR" //
    case list = "LIST" // запрос списка эффектов
    case timer = "TMR_SET" // установка таймера
    case timer_get = "TMR_GET" // запрос состояния таймера
    case alarm_on
    case alarm_off
    case alarm = "ALM_SET" // установка будильника
    case button_on = "BTN ON" // включение кнопки на лампе
    case button_off = "BTN OFF" // отключение кнопки на лампе
    case dawn = "DAWN" // рассвет
    case fav_get = "FAV_GET" // набор эффектов для автопереключения запросить
    case fav_set = "FAV_SET" // набор эффектов для автопереключения установить
    case rnd = "RND_" //
}

class UDPClient {
    var connection: NWConnection?
    var listCounter = 0
    var timer = Timer()
    // подготовка сообщения для отправки в лампу
    func connectToUDP(messageToUDP: CommandsToLamp, lamp: LampDevice, value: [Int], valueTXT: String = "") {
        connection = NWConnection(host: lamp.hostIP, port: lamp.hostPort, using: .udp)
        connection?.stateUpdateHandler = { newState in
            // print("This is stateUpdateHandler:")
            switch newState {
            case .ready:
                print(self.makeCommandForLamp(command: messageToUDP, value: value, valueTXT: valueTXT))
                self.sendUDP(self.makeCommandForLamp(command: messageToUDP, value: value, valueTXT: valueTXT), lamp: lamp) // отправляем сообщение
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

    // отправка сообщения
    private func sendUDP(_ content: String, lamp: LampDevice) {
        let contentToSendUDP = content.data(using: String.Encoding.utf8)
        connection?.send(content: contentToSendUDP, completion: NWConnection.SendCompletion.contentProcessed(({ NWError in
            if NWError == nil {
                print("Data was sent to UDP")
                if content.contains("GET") && (!content.contains("TMR_GET")) && (!content.contains("FAV_GET")) && (lamp.hostIP == lamps.mainLamp?.hostIP) {
                    DispatchQueue.main.async {
                        // таймер срабатывает, если не пришло никакого ответа от лампы
                        self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in
                            lamp.connectionStatus = false
                            NotificationCenter.default.post(name: Notification.Name("updateInterface"), object: nil)

                        })
                    }
                }
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        })))
    }

    // формирователь команды
    private func makeCommandForLamp(command: CommandsToLamp, value: [Int], valueTXT: String = "") -> String {
        switch command {
        case .list: return command.rawValue + String(value[0])
        case .gbr, .button_on, .button_off, .power_on, .power_off, .deb, .fav_get: return command.rawValue
        case .get: var secondsPlusGMT: Int { return TimeZone.current.secondsFromGMT() }
            return command.rawValue + String(Int(Date().timeIntervalSince1970) + secondsPlusGMT)
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
        case .timer_get:
            return command.rawValue
        case .txt:
            return command.rawValue + valueTXT
        case .rnd:
            return command.rawValue
        }
    }

    // обработка полученных от лампы сообщений
    private func receiveUDP(lamp: LampDevice) {
        connection?.receiveMessage { data, _, isComplete, _ in
            if isComplete {
                if data != nil {
                    let backToString = String(decoding: data!, as: UTF8.self)
                    print("Received message: \(backToString)")

                    if backToString.contains("LIST") {
                        var arrayOfQuantity = backToString.components(separatedBy: ";")
                        if arrayOfQuantity.count > 1 {
                            if self.listCounter == 0 {
                                lamp.listOfEffects = []
                            }
                            self.listCounter += 1
                            arrayOfQuantity = arrayOfQuantity.filter { !$0.contains("LIST") }
                            for element in arrayOfQuantity {
                                lamp.listOfEffects.append(element.components(separatedBy: ",")[0])
                            }
                            lamp.effectsFromLamp = true
                        }
                    }

                    switch backToString.components(separatedBy: " ")[0] {
                    case "CURR":
                        if backToString.components(separatedBy: " ").count > 9 {
                            
                            lamp.connectionStatus = true
                            if backToString.components(separatedBy: " ")[5] == "0" {
                                if lamp.powerStatus ?? false{
                                    lamp.powerStatus = false
                                    if lamp.hostIP == lamps.mainLamp?.hostIP{
                                        lamps.sendCommandToArrayOfLamps(command: .power_off, value: [0])
                                    }
                                }
                                
                            } else {
                                if !(lamp.powerStatus ?? false) {
                                    lamp.powerStatus = true
                                    if lamp.hostIP == lamps.mainLamp?.hostIP{
                                        lamps.sendCommandToArrayOfLamps(command: .power_on, value: [0])
                                    }
                                }
                            }
                         
                        }
                            if backToString.components(separatedBy: " ")[8] == "1" {
                                lamp.timer = true
                            } else {
                                lamp.timer = false
                            }
                            if lamp.effect != Int(backToString.components(separatedBy: " ")[1]) {
                                lamp.effect = Int(backToString.components(separatedBy: " ")[1])
                                if lamp.hostIP == lamps.mainLamp?.hostIP {
                                    if let effect = lamp.effect {
                                        lamps.sendCommandToArrayOfLamps(command: .eff, value: [effect])
                                    }
                                }
                            }

                         //   if lamp.bright != Int(backToString.components(separatedBy: " ")[2]) {
                                lamp.bright = Int(backToString.components(separatedBy: " ")[2])
                             //   if lamp.hostIP == lamps.mainLamp?.hostIP {
                                  //  if let bright = lamp.bright {
                                       // lamps.sendCommandToArrayOfLamps(command: .bri, value: [bright])
                                  //  }
                               // }
                          //  }
                            
                          //  if lamp.speed != Int(backToString.components(separatedBy: " ")[3]) {
                                lamp.speed = Int(backToString.components(separatedBy: " ")[3])
                              //  if lamp.hostIP == lamps.mainLamp?.hostIP {
                                  //  if let speed = lamp.speed {
                                       // lamps.sendCommandToArrayOfLamps(command: .spd, value: [speed])
                                 //   }
                               // }
                        //    }
                            
                            //if lamp.scale != Int(backToString.components(separatedBy: " ")[4]) {
                                lamp.scale = Int(backToString.components(separatedBy: " ")[4])
                                //if lamp.hostIP == lamps.mainLamp?.hostIP {
                                 //   if let scale = lamp.scale {
                                      //  lamps.sendCommandToArrayOfLamps(command: .sca, value: [scale])
                                 //   }
                               // }
                         //   }
                            
                            

                            if backToString.components(separatedBy: " ")[9] == "1" {
                                lamp.button = true
                            } else {
                                lamp.button = false
                            }
                            lamp.currentTime = backToString.components(separatedBy: " ")[10][0 ..< 5].time()

                            lamps.updateArrayOfLamps(lamp: lamp)

                            if lamp.hostIP == lamps.mainLamp?.hostIP {
                                DispatchQueue.main.async {
                                    self.timer.invalidate()
                                    NotificationCenter.default.post(name: Notification.Name("updateInterface"), object: nil)
                                    CoreDataService.deleteAllData()
                                    CoreDataService.save()
                                }
                            }
                        

                    case "TMR":
                        if backToString.components(separatedBy: " ").count > 1 {
                            if backToString.components(separatedBy: " ")[1] == "1" {
                                lamp.timer = true
                                lamp.timerTime = Int(backToString.components(separatedBy: " ")[3]) ?? 0
                            } else {
                                lamp.timer = false
                            }
                        }

                    case "ALMS":
                        lamp.alarm = backToString
                        if backToString.components(separatedBy: " ").count > 15 {
                            lamp.dawn = Int(backToString.components(separatedBy: " ")[15])
                        }

                    case "FAV":
                        lamp.favorite = backToString
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("updateFavorite"), object: nil)
                        }

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
    static let listOfEffectsDefault = ["Конфетти", "Огонь", "Белый огонь", "Радуга вертикальная", "Радуга горизонтальная", "Радуга диагональная", "Смена цвета", "Безумие", "Облака", "Лава", "Плазма", "Радуга 3D", "Павлин", "Зебра", "Лес", "Океан", "Моноцвет", "Снегопад", "Метель", "Звездопад", "Матрица", "Светлячки", "Светлячки со шлейфом", "Пейнтбол", "Блуждающий кубик", "Белый свет"] // список эффектов по умолчанию
    var name: String // имя лампы
    let hostIP: NWEndpoint.Host // адрес
    let hostPort: NWEndpoint.Port // порт
    var connectionStatus: Bool = false // наличие соединения с лампой
    var powerStatus: Bool? // включено или выключено
    var timer: Bool? // таймер выключения
    var timerTime: Int = 0
    var button: Bool? // кнопка на лампе включена или выключена
    var alarm: String? // будильники
    var dawn: Int? // рассвет за сколько минут
    var favorite: String? // автопереключение эффектов
    var listOfEffects: [String] = listOfEffectsDefault // список эффектов
    var updateSliderFlag = true
    var effect: Int? // номер текущего эффекта
    var bright: Int? // значение яркости
    var speed: Int? // значение скорости
    var scale: Int? // значение масштаба
    var effectsFromLamp: Bool // использовать эффекты из лампы или нет
    var currentTime: Date? // время лампы
    var flagLampIsControlled: Bool // лампа входит в список управляемых или нет

    init(hostIP: NWEndpoint.Host, hostPort: NWEndpoint.Port, name: String, effectsFromLamp: Bool = true, listOfEffects: [String]?, flagLampIsControlled: Bool = false) {
        self.hostIP = hostIP
        self.hostPort = hostPort
        self.name = name
        self.effectsFromLamp = effectsFromLamp
        self.flagLampIsControlled = flagLampIsControlled

        if effectsFromLamp {
            getEffectsFromLamp(self.effectsFromLamp)
        }

        updateStatus() // запросить состояние лампы
        updateFavoriteStatus(lamp: self) // запросить состояние автопереключения
        sendCommand(command: .alarm_on, value: [0]) // запросить состоние будильника
        sendCommand(command: .timer_get, value: [0]) // запросить состояние таймера
    }

    func updateStatus() {
        let client = UDPClient()
        client.connectToUDP(messageToUDP: .get, lamp: self, value: [0]) // запрос состояние лампы
    }

    func updateFavoriteStatus(lamp: LampDevice) {
        let client = UDPClient()
        client.connectToUDP(messageToUDP: .fav_get, lamp: lamp, value: [0]) // запрос режима автопереключения
    }

    // запрос эффектов из лампы
    public func getEffectsFromLamp(_ get: Bool) {
        if get {
            let client = UDPClient()
            DispatchQueue.global(qos: .userInitiated).async {
                for element in 1 ... 3 {
                    let second: Double = 1000000
                    usleep(useconds_t(0.5 * second))
                    client.connectToUDP(messageToUDP: .list, lamp: self, value: [element])
                }
            }
        } else {
            listOfEffects = LampDevice.listOfEffectsDefault
            effectsFromLamp = false
        }
    }

    // отправка команды в лампу
    func sendCommand(command: CommandsToLamp, value: [Int], valueTXT: String = "") {
        let client = UDPClient()
        client.connectToUDP(messageToUDP: command, lamp: self, value: value, valueTXT: valueTXT)
    }

    // поиск ламп в локальной сети
    static func scan(deviceIp: String) {
        let client = UDPClient()
        client.connectToUDP(messageToUDP: .get, lamp: LampDevice(hostIP: NWEndpoint.Host(deviceIp), hostPort: 8888, name: deviceIp, listOfEffects: nil), value: [0])
    }
}
