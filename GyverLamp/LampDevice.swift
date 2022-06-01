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
    case blank = ""
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
                        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
                            // print("Lost connections")
                            if lamp.lostConnectionFirstTime {
                                lamp.connectionStatus = false
                                NotificationCenter.default.post(name: Notification.Name("updateInterface"), object: nil)
                            } else {
                                lamp.lostConnectionFirstTime = true
                            }

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
        case .button_on, .button_off, .power_on, .power_off, .deb, .fav_get: return command.rawValue
        case .get: var secondsPlusGMT: Int { return TimeZone.current.secondsFromGMT() }
            return command.rawValue + String(Int(Date().timeIntervalSince1970) + secondsPlusGMT)
        case .eff:
            return command.rawValue + String(value[0])
        case .bri, .gbr:
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
        case .blank:
            return valueTXT
        case .rnd:
            return command.rawValue
        }
    }

    // обработка полученных от лампы сообщений
    private func receiveUDP(lamp: LampDevice) {
        connection?.receiveMessage { [self] data, _, isComplete, _ in
            if isComplete {
                if data != nil {
                    lamp.connectionStatus = true
                    let backToString = String(decoding: data!, as: UTF8.self)
                    print("Received message: \(backToString)")

                    if backToString.contains("LIST") {
                        var arrayOfQuantity = backToString.components(separatedBy: ";")
                        if arrayOfQuantity.count > 1 {
                            if self.listCounter == 0 {
                                lamp.listOfEffects = []
                                lamp.newListOfEffects = []
                            }
                            self.listCounter += 1
                            arrayOfQuantity = arrayOfQuantity.filter { !$0.contains("LIST") }
                            for element in arrayOfQuantity {
                                lamp.listOfEffects.append(element)
                                lamp.newListOfEffects?.append(Effect(element))
                            }
                            lamp.effectsFromLamp = true
                            DispatchQueue.main.async {
                                CoreDataService.deleteAllData()
                                CoreDataService.save()
                            }
                        }
                    }

                    switch backToString.components(separatedBy: " ")[0] {
                    case "CURR":
                        if backToString.components(separatedBy: " ").count > 9 {
                            if backToString.components(separatedBy: " ")[5] == "0" {
                                if lamp.powerStatus {
                                    lamp.powerStatus = false
                                    if lamp.hostIP == lamps.mainLamp?.hostIP {
                                        lamps.sendCommandToArrayOfLamps(command: .power_off, value: [0], exceptFromTheMainLamp: true)
                                    }
                                }

                            } else {
                                if !lamp.powerStatus {
                                    lamp.powerStatus = true
                                    if lamp.hostIP == lamps.mainLamp?.hostIP {
                                        lamps.sendCommandToArrayOfLamps(command: .power_on, value: [0], exceptFromTheMainLamp: true)
                                    }
                                }
                            }
                            lamp.timer = backToString.components(separatedBy: " ")[8].convertToBool()

                            if lamp.effect != Int(backToString.components(separatedBy: " ")[1]) {
                                lamp.effect = Int(backToString.components(separatedBy: " ")[1])
                                if lamp.hostIP == lamps.mainLamp?.hostIP {
                                    if let effect = lamp.effect {
                                        lamps.sendCommandToArrayOfLamps(command: .eff, value: [effect], exceptFromTheMainLamp: true)
                                        lamps.necessaryToAlignTheParametersOfTheLamps = true
                                    }
                                }
                            }

                            if (lamp.bright != Int(backToString.components(separatedBy: " ")[2])) && (lamp.speed != Int(backToString.components(separatedBy: " ")[3])) && (lamp.scale != Int(backToString.components(separatedBy: " ")[4])) {
                                print("Test update slider")
                                lamp.updateSliderFlag = true
                            }

                            lamp.bright = Int(backToString.components(separatedBy: " ")[2])

                            lamp.speed = Int(backToString.components(separatedBy: " ")[3])

                            lamp.scale = Int(backToString.components(separatedBy: " ")[4])

                            lamp.espMode = backToString.components(separatedBy: " ")[6].convertToBool()

                            lamp.button = backToString.components(separatedBy: " ")[9].convertToBool()

                            lamp.currentTime = backToString.components(separatedBy: " ")[10][0 ..< 5].time()
                        }
                        lamps.updateArrayOfLamps(lamp: lamp)

                        if lamp.hostIP == lamps.mainLamp?.hostIP {
                            self.timer.invalidate()
                            lamp.lostConnectionFirstTime = false
                            DispatchQueue.main.async {
                                if lamps.necessaryToAlignTheParametersOfTheLamps {
                                    lamps.alignLampsParametersAfterChangeEffect()
                                }
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
                                // lamp.timerCount()
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
                        let range = (lamp.favorite?.components(separatedBy: " ").count ?? 0) - 1
                        if let arrayOfSelectedEffect = lamp.favorite?.components(separatedBy: " ")[5 ... range] {
                            lamp.selectedEffects = [Bool](repeating: false, count: arrayOfSelectedEffect.count)
                            for (index, element) in arrayOfSelectedEffect.enumerated() {
                                if element == "1" {
                                    lamp.selectedEffects[index] = true
                                }
                            }
                        }
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
    var powerStatus: Bool = false // включено или выключено
    var timer: Bool? // таймер выключения
    var timerTime: Int = 0
    var button: Bool? // кнопка на лампе включена или выключена
    var alarm: String? // будильники
    var dawn: Int? // рассвет за сколько минут
    var favorite: String? // автопереключение эффектов
    var listOfEffects: [String] = listOfEffectsDefault // список эффектов

    var newListOfEffects: [Effect]?

    var updateSliderFlag = false
    var effect: Int? // номер текущего эффекта
    var bright: Int? // значение яркости
    var speed: Int? // значение скорости
    var scale: Int? // значение масштаба
    var effectsFromLamp: Bool // использовать эффекты из лампы или нет
    var currentTime: Date? // время лампы
    var flagLampIsControlled: Bool // лампа входит в список управляемых или нет
    var lostConnectionFirstTime = false // сколько раз не получен сигнал от лампы
    lazy var selectedEffects = [Bool](repeating: false, count: self.listOfEffects.count)
    var useSelectedEffectOnScreen: Bool = false // показывать на экране только выбранные эффекты
    var espMode = false
    var commonBright = false

    var doNotForgetTheLampWhenTheConnectionIsLost = false
    
    var selectedEffectsNameList: [String] {
        if useSelectedEffectOnScreen {
            let arrayOfNames = zip(selectedEffects, listOfEffects).filter { $0.0 }.map { $1 }
            return arrayOfNames
        } else {
            return listOfEffects
        }
    }

    func getEffectName(_ number: Int) -> String{
        let names = self.selectedEffectsNameList[number].components(separatedBy: ",")[0]
        let multiNames = (names.onlyLetters).components(separatedBy: "|")
        
        if multiNames.count > 1{
            let systemLang = Locale.current.languageCode
            switch systemLang{
            case "en": return String(number + 1) + ". " + multiNames[0]
            case "ru": return String(number + 1) + ". " + multiNames[1]
            case "uk": return String(number + 1) + ". " + multiNames[2]
            case .none:
                return String(number + 1) + ". "  + multiNames[0]
            case .some(_):
                return String(number + 1) + ". "  + multiNames[0]
            }
        }else{
            return String(number + 1) + ". " + multiNames[0]
        }
    }
    
    
    func getEffectNumber(_ name: String) -> Int {
        return listOfEffects.firstIndex(where: { $0.components(separatedBy: ",")[0] == name.components(separatedBy: ",")[0] }) ?? 0
    }

    func getEffectNumberFromSelectedList(_ name: String) -> Int {
        let result = zip(selectedEffects, listOfEffects).filter { $0.0 }.map { $1 }
        return result.firstIndex(where: { $0.components(separatedBy: ",")[0] == name.components(separatedBy: ",")[0] }) ?? 0
    }

    func getMaxSpeed(_ index: Int) -> Int {
        var maxSpeed = 255
        if listOfEffects.count > index {
            if listOfEffects[index].components(separatedBy: ",").count > 2 {
                guard let speed = Int(listOfEffects[index].components(separatedBy: ",")[2]) else {
                    return maxSpeed
                }
                maxSpeed = speed
            }
            return maxSpeed
        } else {
            return maxSpeed
        }
    }

    func getMinSpeed(_ index: Int) -> Int {
        var minSpeed = 0
        if listOfEffects.count > index {
            if listOfEffects[index].components(separatedBy: ",").count > 1 {
                guard let speed = Int(listOfEffects[index].components(separatedBy: ",")[1]) else {
                    return minSpeed
                }
                minSpeed = speed
            }
            return minSpeed
        } else {
            return minSpeed
        }
    }

    func getSpeedRange(_ index: Int) -> Int {
        let range = getMaxSpeed(index) - getMinSpeed(index)
        if range == 0 {
            return 100
        } else {
            return range
        }
    }

    func getMaxScale(_ index: Int) -> Int {
        var maxScale = 255
        if listOfEffects.count > index {
            if listOfEffects[index].components(separatedBy: ",").count > 4 {
                guard let scale = Int(listOfEffects[index].components(separatedBy: ",")[4]) else {
                    return maxScale
                }
                maxScale = scale
            }
            return maxScale
        } else {
            return maxScale
        }
    }

    func getMinScale(_ index: Int) -> Int {
        var minScale = 0
        if listOfEffects.count > index {
            if listOfEffects[index].components(separatedBy: ",").count > 3 {
                guard let scale = Int(listOfEffects[index].components(separatedBy: ",")[3]) else {
                    return minScale
                }
                minScale = scale
            }
            return minScale
        } else {
            return minScale
        }
    }

    func getScaleRange(_ index: Int) -> Int {
        let range = getMaxScale(index) - getMinScale(index)
        if range == 0 {
            return 100
        } else {
            return range
        }
    }

    func percentageOfValue(_ command: CommandsToLamp) -> String {
        switch command {
        case .bri:
            return String(((bright ?? 0) * 100 / 255).checkPercentage())
        case .sca:
            return String((((scale ?? 0) - getMinScale(effect ?? 0)) * 100 / getScaleRange(effect ?? 0)).checkPercentage())
        case .spd:
            return String((((speed ?? 0) - getMinSpeed(effect ?? 0)) * 100 / getSpeedRange(effect ?? 0)).checkPercentage())
        default:
            return "?"
        }
    }

    init(hostIP: NWEndpoint.Host, hostPort: NWEndpoint.Port, name: String, effectsFromLamp: Bool = true, listOfEffects: [String], flagLampIsControlled: Bool = false, newLamp: Bool = false, useSelectedEffectOnScreen: Bool = false, doNotForgetTheLampWhenTheConnectionIsLost: Bool = false) {
        self.hostIP = hostIP
        self.hostPort = hostPort
        self.name = name
        self.effectsFromLamp = effectsFromLamp
        self.flagLampIsControlled = flagLampIsControlled
        self.listOfEffects = listOfEffects
        self.useSelectedEffectOnScreen = useSelectedEffectOnScreen
        self.doNotForgetTheLampWhenTheConnectionIsLost = doNotForgetTheLampWhenTheConnectionIsLost
        if newLamp {
            getEffectsFromLamp(effectsFromLamp)
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
        _ = LampDevice(hostIP: NWEndpoint.Host(deviceIp), hostPort: 8888, name: deviceIp, listOfEffects: LampDevice.listOfEffectsDefault, newLamp: true)
    }

    func lampBlink() {
        if powerStatus {
            if let tempBright = bright {
                sendCommand(command: .bri, value: [0])
                bright = 0
                let second: Double = 1000000
                usleep(useconds_t(0.3 * second))
                sendCommand(command: .bri, value: [tempBright])
                bright = tempBright
            }
        } else {
            sendCommand(command: .power_on, value: [0])
            powerStatus = true
            let second: Double = 1000000
            usleep(useconds_t(0.3 * second))
            sendCommand(command: .power_off, value: [0])
            powerStatus = false
        }
    }
}
