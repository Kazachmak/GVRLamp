//
//  extensions.swift
//  GyverLamp
//
//  Created by Максим Казачков on 18.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import Foundation
import UIKit


// добавление тени объекту
extension UIView {
    func addBoxShadow() {
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = 7.0
        layer.shadowOpacity = 1
        layer.masksToBounds = false
        layer.cornerRadius = 7
        layer.backgroundColor = UIColor.white.cgColor
    }
}


extension String {
    
    // проверка введенного ip-адреса
    func isValidIP() -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        let characterSet = CharacterSet(charactersIn: self)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    // проверка введенного порта
    func isValidPort() -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789")
        let characterSet = CharacterSet(charactersIn: self)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    // преобразование строки в дату
    func getTimeFromString() -> Date {
        let time = Int(self)
        let minutes = time ?? 0 % 60
        let hour = Int(time ?? 0 / 60)
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = hour
        components.minute = minutes
        return calendar.date(from: components)!
    }
}
// добавление черной границы объекту
extension UIView {
    func setBlackBorder(enabled: Bool = false) {
        if enabled {
            layer.borderColor = UIColor.black.cgColor
            layer.borderWidth = 4.0
        } else {
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0.0
        }
    }
}
// преобразование значения Bool в Int
extension Bool {
    func convertToInt() -> Int {
        if self {
            return 1
        } else {
            return 0
        }
    }
}

// преобразование значения [Bool] в [Int]
extension Array where Element == Bool{
    func convertToIntArray() ->[Int]{
        var array:[Int] = []
        for element in self{
            if element {
                array.append(1)
            }else{
                array.append(0)
            }
        }
        return array
    }
}


