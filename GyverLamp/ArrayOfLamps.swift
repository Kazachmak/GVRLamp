//
//  ArrayOfLamps.swift
//  GyverLamp
//
//  Created by Максим Казачков on 27.02.2021.
//  Copyright © 2021 Maksim Kazachkov. All rights reserved.
//

import Foundation
import Network

var lamps = ArrayOfLamps()

class ArrayOfLamps {
    
    

    var arrayOfLamps: [LampDevice]
    

    var mainLampIndex: Int?

    var mainLamp: LampDevice? {
        if arrayOfLamps.count > 0, let index = mainLampIndex {
            return arrayOfLamps[index]
        } else {
            return nil
        }
    }

    init() {
        arrayOfLamps = []
        
       
    }

    func loadData(){
        if CoreDataService.fetchLamps().count > 0 {
            
            for (index, element) in CoreDataService.fetchLamps().enumerated() {
                
                let name = element.value(forKey: "name") as! String
                let ip = element.value(forKey: "ip") as! String
                let port = element.value(forKey: "port") as! String
                let effectsFromLamp = element.value(forKey: "flagEffects") as! Bool
                let listOfEffects = element.value(forKey: "listOfEffects") as! String
                let mainLamp = element.value(forKey: "mainLamp") as! Bool
                let flagLampIsControlled = element.value(forKey: "flagLampIsControlled") as! Bool
                
                if mainLamp {
                    mainLampIndex = index
                }
                
                arrayOfLamps.append(LampDevice(hostIP: NWEndpoint.Host(ip), hostPort: NWEndpoint.Port(port) ?? 8888, name: name, effectsFromLamp: effectsFromLamp, listOfEffects: listOfEffects.components(separatedBy: ",") , flagLampIsControlled: flagLampIsControlled))
                
            }
            if mainLampIndex == nil{
                mainLampIndex = 0
            }
            timerStartAndStop(true)
        }
    }
    
    private func timerStartAndStop(_ start: Bool) {
        var timer = Timer()
        if start {
            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                if let currentLamp = lamps.mainLamp {
                    currentLamp.updateStatus() // запрос состояние лампы
                }
            }
        } else {
            timer.invalidate()
        }
    }

    func sendCommandToArrayOfLamps(command: CommandsToLamp, value: [Int], valueTxt: String = "", exceptFromTheMainLamp: Bool = false) {
        switch command {
        case .sca, .power_on, .power_off, .bri, .spd, .eff:
            for element in arrayOfLamps {
                if (element.flagLampIsControlled)||(element.hostIP == mainLamp?.hostIP){
                    
                    if exceptFromTheMainLamp{
                        if (element.hostIP != mainLamp?.hostIP){
                            element.sendCommand(command: command, value: value)
                            let second: Double = 1000000
                            usleep(useconds_t(0.1 * second))
                        }
                    }else{
                        element.sendCommand(command: command, value: value)
                    }
                    
                    if (command == .eff)&&(element.hostIP != mainLamp?.hostIP ){
                        if let bright = mainLamp?.bright{
                            element.sendCommand(command: .bri, value: [bright])
                        }
                        if let speed = mainLamp?.speed{
                            element.sendCommand(command: .spd, value: [speed])
                        }
                        if let scale = mainLamp?.scale{
                            element.sendCommand(command: .sca, value: [scale])
                        }
                    }
                }
                
            }
        default: break
        }
    }

    func setMainLamp(_ index: Int) {
        mainLampIndex = index
        arrayOfLamps[index].flagLampIsControlled = true
        self.timerStartAndStop(true)
    }

    func checkIP(_ ip: String) -> Bool {
        for element in arrayOfLamps {
            if "\(element.hostIP)" == ip {
                return true
            }
        }
        return false
    }

    func updateArrayOfLamps(lamp: LampDevice) {
        if !checkIP("\(lamp.hostIP)") {
            arrayOfLamps.append(lamp)
            if arrayOfLamps.count == 1 {
                timerStartAndStop(true)
                mainLampIndex = 0
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("newLampHasAdded"), object: lamp)
            }
        }
    }
    
    func removeLamp(_ lamp: LampDevice){
        self.timerStartAndStop(false)
        mainLampIndex = nil
        self.arrayOfLamps = arrayOfLamps.filter{ devices in
            return devices.hostIP != lamp.hostIP
          }
        NotificationCenter.default.post(name: Notification.Name("updateInterface"), object: nil)
        CoreDataService.deleteAllData()
        CoreDataService.save()
        
    }
    
    func renameLamp(name: String, lamp: LampDevice) { // переименование лампы
        for element in self.arrayOfLamps{
            if element.hostIP == lamp.hostIP{
                element.name = name
            }
        }
    }
    
}
