//
//  Lamps.swift
//  GyverLamp
//
//  Created by Максим Казачков on 28.04.2021.
//  Copyright © 2021 Maksim Kazachkov. All rights reserved.
//

import Foundation
import UIKit

var isFirstLaunch = false

var lamps = ArrayOfLamps()

enum selectorFlag {
    case effects
    case days
    case dawn
}

let redColor = UIColor(red: 220.0 / 255.0, green: 78.0 / 255.0, blue: 65.0 / 255.0, alpha: 1)
let blackColor = UIColor(red: 32.0 / 255.0, green: 34.0 / 255.0, blue: 55.0 / 255.0, alpha: 1)
let violetColor = UIColor(red: 115.0 / 255.0, green: 112.0 / 255.0, blue: 249.0 / 255.0, alpha: 1)
