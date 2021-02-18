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
                if content.contains("GET") && (!content.contains("TMR_GET")) && (!content.contains("FAV_GET")) {
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
                            LampDevice.updateListOfLamps(lamp: lamp, true)
                        }
                    }

                    switch backToString.components(separatedBy: " ")[0] {
                    case "CURR":
                        if backToString.components(separatedBy: " ").count > 9 {
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
                            lamp.currentTime = backToString.components(separatedBy: " ")[10][0 ..< 5].time()
                            DispatchQueue.main.async {
                                self.timer.invalidate()
                                LampDevice.updateListOfLamps(lamp: lamp)
                                NotificationCenter.default.post(name: Notification.Name("updateInterface"), object: lamp)
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
    var listOfEffects = listOfEffectsDefault
    var updateSliderFlag = true
    var effect: Int? // номер текущего эффекта
    var bright: Int? // значение яркости
    var speed: Int? // значение скорости
    var scale: Int? // значение масштаба
    var effectsFromLamp = false
    var currentTime: Date?

    init(hostIP: NWEndpoint.Host, hostPort: NWEndpoint.Port, name: String, effectsFromLamp: String, listOfEffects: [String] = LampDevice.listOfEffectsDefault) {
        self.hostIP = hostIP
        self.hostPort = hostPort
        self.name = name
        self.effectsFromLamp = effectsFromLamp.convertToBool()
        if self.effectsFromLamp {
            self.listOfEffects = listOfEffects
        }
        sendCommand(lamp: self, command: .get, value: [0]) // запросить состояние лампы
        updateFavoriteStatus(lamp: self) // запросить состояние автопереключения
        sendCommand(lamp: self, command: .alarm_on, value: [0]) // запросить состоние будильника
        sendCommand(lamp: self, command: .timer_get, value: [0]) // запросить состояние таймера
    }

    init?() {
        if let listOfLamps = UserDefaults.standard.array(forKey: "listOfLamps") as? [String], listOfLamps.count != 0 {
            var lampNumber = UserDefaults.standard.integer(forKey: "lampNumber") // читаем из памяти список ламп и номер выбранной лампы
            if lampNumber > listOfLamps.count - 1 {
                lampNumber = 0
            }
            name = listOfLamps[lampNumber].components(separatedBy: ":")[2]
            hostIP = NWEndpoint.Host((listOfLamps[lampNumber].components(separatedBy: ":"))[0])
            hostPort = NWEndpoint.Port((listOfLamps[lampNumber].components(separatedBy: ":"))[1]) ?? 8888
            effectsFromLamp = listOfLamps[lampNumber].components(separatedBy: ":")[3].convertToBool()
            if effectsFromLamp {
                listOfEffects = listOfLamps[lampNumber].components(separatedBy: ":")[4].components(separatedBy: ",")
            }
            sendCommand(lamp: self, command: .get, value: [0]) // запросить состояние лампы
            updateFavoriteStatus(lamp: self) // запросить состояние автопереключения
            sendCommand(lamp: self, command: .alarm_on, value: [0]) // запросить состоние будильника
            sendCommand(lamp: self, command: .timer_get, value: [0]) // запросить состоние будильника

        } else {
            return nil
        }
    }

    func deleteLamp() { // удаление лампы
        if let listOfLampTemp = UserDefaults.standard.array(forKey: "listOfLamps") as? [String] {
            let newListOfLamps = listOfLampTemp.filter({ $0.components(separatedBy: ":")[0] != "\(self.hostIP)" })
            UserDefaults.standard.set(newListOfLamps, forKey: "listOfLamps")
        }
    }

    func renameLamp(name: String) { // переименование лампы
        if let listOfLampTemp = UserDefaults.standard.array(forKey: "listOfLamps") as? [String] {
            let newListOfLamps = listOfLampTemp.filter({ $0.components(separatedBy: ":")[0] != "\(self.hostIP)" })
            UserDefaults.standard.set(newListOfLamps, forKey: "listOfLamps")
            _ = LampDevice(hostIP: hostIP, hostPort: hostPort, name: name, effectsFromLamp: effectsFromLamp.convertToString(), listOfEffects: listOfEffects)
        }
    }

    static func updateListOfLamps(lamp: LampDevice, _ beSureToUpdate: Bool = false) { // сохранияем новую лампу
        var listOfLamps: [String] = []

        if let listOfLampsTemp = UserDefaults.standard.array(forKey: "listOfLamps") as? [String] {
            listOfLamps = listOfLampsTemp
        }
        var flag = true

        listOfLamps.forEach {
            if $0.hasPrefix("\(lamp.hostIP)") {
                if $0.components(separatedBy: ":")[3] == lamp.effectsFromLamp.convertToString() {
                    flag = false
                }
            }
        }

        if flag || beSureToUpdate {
            listOfLamps = listOfLamps.filter { !$0.hasPrefix("\(lamp.hostIP)") } // удаляем лампу, если она в массиве
            if lamp.effectsFromLamp {
                listOfLamps.append("\(lamp.hostIP)" + ":" + "\(lamp.hostPort)" + ":" + "\(lamp.name)" + ":" + "1" + ":" + lamp.listOfEffects.joined(separator: ","))
            } else {
                listOfLamps.append("\(lamp.hostIP)" + ":" + "\(lamp.hostPort)" + ":" + "\(lamp.name)" + ":" + "0")
            }
            UserDefaults.standard.set(listOfLamps, forKey: "listOfLamps")
            if !beSureToUpdate{
                lamp.getEffectsFromLamp(true)
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("newLampHasAdded"), object: lamp)
            }
        }
    }

    public func updateStatus(lamp: LampDevice) {
        let client = UDPClient()
        client.connectToUDP(messageToUDP: .get, lamp: lamp, value: [0]) // запрос состояние лампы
    }

    public func updateFavoriteStatus(lamp: LampDevice) {
        let client = UDPClient()
        client.connectToUDP(messageToUDP: .fav_get, lamp: lamp, value: [0]) // запрос режима автопереключения
    }

    // запрос эффектов из лампы
    public func getEffectsFromLamp(_ get: Bool) {
        if get {
            effectsFromLamp = true
            let client = UDPClient()
            DispatchQueue.global(qos: .userInitiated).async {
                for element in 1 ... 3 {
                    client.connectToUDP(messageToUDP: .list, lamp: self, value: [element])
                    sleep(1)
                }
            }
        } else {
            listOfEffects = LampDevice.listOfEffectsDefault
            effectsFromLamp = false
        }
    }

    // отправка команды в лампу
    public func sendCommand(lamp: LampDevice, command: CommandsToLamp, value: [Int], valueTXT: String = "") {
        let client = UDPClient()
        client.connectToUDP(messageToUDP: command, lamp: lamp, value: value, valueTXT: valueTXT)
    }

    // поиск ламп в локальной сети
    static func scan(deviceIp: String) {
        let client = UDPClient()
        client.connectToUDP(messageToUDP: .get, lamp: LampDevice(hostIP: NWEndpoint.Host(deviceIp), hostPort: 8888, name: deviceIp, effectsFromLamp: "0"), value: [0])
    }
}
