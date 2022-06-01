//
//  ArrayOfLamps.swift
//  GyverLamp
//
//  Created by Максим Казачков on 27.02.2021.
//  Copyright © 2021 Maksim Kazachkov. All rights reserved.
//

import Foundation
import Network

class ArrayOfLamps {
   
    var arrayOfLamps: [LampDevice] = []

    var mainLampIndex: Int?

    var necessaryToAlignTheParametersOfTheLamps = false

    var mainLampIsBlinking = false

    var slaveLamps: [LampDevice] {
        return arrayOfLamps.filter({ $0.flagLampIsControlled && ($0.hostIP != mainLamp?.hostIP) }) // отбираем ведомые лампы
    }

    var mainLamp: LampDevice? {
        if arrayOfLamps.count > 0, let index = mainLampIndex {
            return arrayOfLamps[index]
        } else {
            return nil
        }
    }

    var isListEmpty: Bool {
        return arrayOfLamps.isEmpty
    }

    var connectionStatusOfMainLamp: Bool {
        if let connection = mainLamp?.connectionStatus {
            return connection
        } else {
            return false
        }
    }

    func loadData() {
        if CoreDataService.fetchLamps().count > 0 {
            for (index, element) in CoreDataService.fetchLamps().enumerated() {
                let name = element.value(forKey: "name") as! String
                let ip = element.value(forKey: "ip") as! String
                let port = element.value(forKey: "port") as! String
                let effectsFromLamp = element.value(forKey: "flagEffects") as! Bool
                let listOfEffects = element.value(forKey: "listOfEffects") as! String
                let mainLamp = element.value(forKey: "mainLamp") as! Bool
                let flagLampIsControlled = element.value(forKey: "flagLampIsControlled") as! Bool
                var useSelectedEffectOnScreen = false
                if let useSelectedEffectOnScreenTemp = element.value(forKey: "useSelectedEffectOnScreen") as? Bool {
                    useSelectedEffectOnScreen = useSelectedEffectOnScreenTemp
                }
                var doNotForgetTheLampWhenTheConnectionIsLost = false
                if let doNotForgetTheLampWhenTheConnectionIsLostTemp = element.value(forKey: "doNotForgetTheLampWhenTheConnectionIsLost") as? Bool {
                    doNotForgetTheLampWhenTheConnectionIsLost = doNotForgetTheLampWhenTheConnectionIsLostTemp
                }

                if mainLamp {
                    mainLampIndex = index
                }

                arrayOfLamps.append(LampDevice(hostIP: NWEndpoint.Host(ip), hostPort: NWEndpoint.Port(port) ?? 8888, name: name, effectsFromLamp: effectsFromLamp, listOfEffects: listOfEffects.components(separatedBy: ";"), flagLampIsControlled: flagLampIsControlled, useSelectedEffectOnScreen: useSelectedEffectOnScreen, doNotForgetTheLampWhenTheConnectionIsLost: doNotForgetTheLampWhenTheConnectionIsLost))
            }
            UserDefaults.standard.setValue(true, forKey: "firstLaunchOfV11")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.arrayOfLamps.forEach({ lampDevice in
                    if (!lampDevice.connectionStatus) && (!lampDevice.doNotForgetTheLampWhenTheConnectionIsLost) {
                        lamps.removeLamp(lampDevice)
                    }
                })
            }
        }
            _ = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                print("Timer fire!")
                if let currentLamp = lamps.mainLamp {
                    currentLamp.updateStatus() // запрос состояние лампы
                }
            }
    }

    func alignLampsParametersAfterChangeEffect() {
        // выравниваем параметры яркости - скорости - масштаба на всех лампах
        necessaryToAlignTheParametersOfTheLamps = false
        if let flag = mainLamp?.flagLampIsControlled {
            if flag { // если главная лампа в группе, то остальные тоже получают команду
                slaveLamps.forEach({ device in
                    if let bright = mainLamp?.bright {
                        device.sendCommand(command: .bri, value: [bright])
                    }
                    if let speed = mainLamp?.speed {
                        device.sendCommand(command: .spd, value: [speed])
                    }
                    if let scale = mainLamp?.scale {
                        device.sendCommand(command: .sca, value: [scale])
                    }
                })
            }
        }
    }

    func alignLampParametersAfterNewLampAdded(_ lamp: LampDevice) {
        if let effect = mainLamp?.effect {
            lamp.sendCommand(command: .eff, value: [effect])
        }
        if let bright = mainLamp?.bright {
            lamp.sendCommand(command: .bri, value: [bright])
        }
        if let speed = mainLamp?.speed {
            lamp.sendCommand(command: .spd, value: [speed])
        }
        if let scale = mainLamp?.scale {
            lamp.sendCommand(command: .sca, value: [scale])
        }
    }

    func sendCommandToArrayOfLamps(command: CommandsToLamp, value: [Int], valueTxt: String = "", exceptFromTheMainLamp: Bool = false) {
        switch command {
        case .sca, .power_on, .power_off, .bri, .gbr, .spd, .eff:

            var newCommand = command

            if let commonBright = mainLamp?.commonBright {
                if commonBright && command == .bri {
                    newCommand = .gbr
                }
            }

            if !exceptFromTheMainLamp {
                mainLamp?.sendCommand(command: newCommand, value: value) // отправляем команду главной лампе
            }

            if let flag = mainLamp?.flagLampIsControlled {
                if flag { // если главная лампа в группе, то остальные тоже получают команду
                    slaveLamps.forEach({ device in
                        device.sendCommand(command: newCommand, value: value)
                    })
                }
            }

        default: break
        }
    }

    // установка основной лампы
    func setMainLamp(_ index: Int) {
        mainLampIndex = index // выбор основной лампы
        mainLamp?.lampBlink() // мигнуть этой лампой
        slaveLamps.forEach({ device in
            self.alignLampParametersAfterNewLampAdded(device)
        })
    }

    // проверка новая эта лампа или нет
    func checkIP(_ ip: String) -> Bool {
        if arrayOfLamps.contains(where: { "\($0.hostIP)" == ip }) {
            return true
        } else {
            return false
        }
    }

    // добавить новую лампу в список
    func updateArrayOfLamps(lamp: LampDevice) {
        if !checkIP("\(lamp.hostIP)") {
            arrayOfLamps.append(lamp)

            if lamp.hostIP != "192.168.4.1" {
                arrayOfLamps = arrayOfLamps.filter { devices in
                    devices.hostIP != "192.168.4.1"
                }
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("updateInterface"), object: nil)
                }
            }
            // timerStartAndStop()
            mainLampIndex = 0
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("newLampHasAdded"), object: lamp)
            }
        }
    }

    // удалить лампу из списка
    func removeLamp(_ lamp: LampDevice) {
        mainLampIndex = nil
        arrayOfLamps = arrayOfLamps.filter { devices in
            devices.hostIP != lamp.hostIP
        }

        NotificationCenter.default.post(name: Notification.Name("updateInterface"), object: nil)
        CoreDataService.deleteAllData()
        CoreDataService.save()
    }

    // переименовать лампу в списке
    func renameLamp(name: String, lamp: LampDevice) { // переименование лампы
        for element in arrayOfLamps {
            if element.hostIP == lamp.hostIP {
                element.name = name
            }
        }
        NotificationCenter.default.post(name: Notification.Name("updateInterface"), object: nil)
    }
}
