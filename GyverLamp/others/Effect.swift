//
//  Effect.swift
//  GyverLamp
//
//  Created by Максим Казачков on 06.01.2022.
//  Copyright © 2022 Maksim Kazachkov. All rights reserved.
//

import Foundation

struct Effect {
    let name: String
    let id: Int
    let maxSpeed: Int
    let minSpeed: Int
    let maxScale: Int
    let minScale: Int

    var speedRange: Int {
        let range = maxSpeed - minSpeed
        if range == 0 {
            return 100
        } else {
            return range
        }
    }

    var scaleRange: Int {
        get {
            let range = maxScale - minScale
            if range == 0 {
                return 100
            } else {
                return range
            }
        }
    }

    init(_ str: String) {
        self.name = str.components(separatedBy: ",")[0].components(separatedBy: ".")[1]
        self.id = Int(str.components(separatedBy: ",")[0].components(separatedBy: ".")[0]) ?? 0
        self.maxSpeed = Effect.getMaxSpeed(str.components(separatedBy: ",")[2])
        self.minSpeed = Effect.getMinSpeed(str.components(separatedBy: ",")[1])
        self.maxScale = Effect.getMaxScale(str.components(separatedBy: ",")[4])
        self.minScale = Effect.getMinScale(str.components(separatedBy: ",")[3])
    }

    /*
     func percentageOfValue(_ command: CommandsToLamp)->String{
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
     */

    static func getMaxSpeed(_ str: String) -> Int {
        var maxSpeed = 255
        if str.components(separatedBy: ",").count > 2 {
            guard let speed = Int(str.components(separatedBy: ",")[2]) else {
                return maxSpeed
            }
            maxSpeed = speed
        }
        return maxSpeed
    }

    static func getMinSpeed(_ str: String) -> Int {
        var minSpeed = 0
        if str.components(separatedBy: ",").count > 1 {
            guard let speed = Int(str.components(separatedBy: ",")[1]) else {
                return minSpeed
            }
            minSpeed = speed
        }
        return minSpeed
    }

    static func getMaxScale(_ str: String) -> Int {
        var maxScale = 255
        if str.components(separatedBy: ",").count > 4 {
            guard let scale = Int(str.components(separatedBy: ",")[4]) else {
                return maxScale
            }
            maxScale = scale
        }
        return maxScale
    }

    static func getMinScale(_ str: String) -> Int {
        var minScale = 0
        if str.components(separatedBy: ",").count > 3 {
            guard let scale = Int(str.components(separatedBy: ",")[3]) else {
                return minScale
            }
            minScale = scale
        }
        return minScale
    }
}
