//
//  extensions.swift
//  GyverLamp
//
//  Created by Максим Казачков on 18.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import Foundation
import UIKit

enum selectorFlag {
    case effects
    case days
    case dawn
}

let redColor = UIColor(red: 220.0 / 255.0, green: 78.0 / 255.0, blue: 65.0 / 255.0, alpha: 1)
let blackColor = UIColor(red: 32.0 / 255.0, green: 34.0 / 255.0, blue: 55.0 / 255.0, alpha: 1)


extension UIView {
    // добавление тени объекту
    func addBoxShadow() {
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = 7.0
        layer.shadowOpacity = 1
        layer.masksToBounds = false
        layer.cornerRadius = 7
        layer.backgroundColor = UIColor.white.cgColor
    }
    // высота safearea сверху
    var safeAreaTop: CGFloat {
        if let window = UIApplication.shared.keyWindowInConnectedScenes {
            return window.safeAreaInsets.top
        }
        return 0
    }
}

extension UIApplication {
    var keyWindowInConnectedScenes: UIWindow? {
        return windows.first(where: { $0.isKeyWindow })
    }
}

extension String {
    // проверка введенного ip-адреса
    func isValidIP() -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        let characterSet = CharacterSet(charactersIn: self)
        return (allowedCharacters.isSuperset(of: characterSet)) && (self != "")
    }

    // проверка введенного порта
    func isValidPort() -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789")
        let characterSet = CharacterSet(charactersIn: self)
        return allowedCharacters.isSuperset(of: characterSet) && (self != "")
    }

    // преобразование строки в дату
    func getTimeFromString() -> Date {
        let time = Int(self)
        let minutes = (time ?? 0) % 60
        let hour = Int((time ?? 0) / 60)
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

    func addImage(image: UIImage, frame: CGRect) {
        if let viewWithTag = self.viewWithTag(321) {
            viewWithTag.removeFromSuperview()
        }
        let imageView = UIImageView(image: image)
        imageView.frame = frame
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 321
        addSubview(imageView)
        bringSubviewToFront(imageView)
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

    func convertToString() -> String {
        if self {
            return "1"
        } else {
            return "0"
        }
    }
}

extension String {
    func convertToBool() -> Bool {
        if self == "1" {
            return true
        } else {
            return false
        }
    }

    func time() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let currentDate = dateFormatter.date(from: self) {
            return currentDate
        } else {
            print("Не удалось конвертировать")
            return nil
        }
    }

}

// преобразование значения [Bool] в [Int]
extension Array where Element == Bool {
    func convertToIntArray() -> [Int] {
        var array: [Int] = []
        for element in self {
            if element {
                array.append(1)
            } else {
                array.append(0)
            }
        }
        return array
    }
}

// преобразование значения [Int] в [Bool]
extension Array where Element == Int {
    func convertToBoolArray() -> [Bool] {
        var array: [Bool] = []
        for element in self {
            if element == 1 {
                array.append(true)
            } else {
                array.append(false)
            }
        }
        return array
    }
}

extension UIImage {
    static func gradientImageWithBounds(bounds: CGRect) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: bounds.height + 30)
        gradientLayer.colors = [UIColor(red: 103.0 / 255.0, green: 40.0 / 255.0, blue: 199.0 / 255.0, alpha: 1).cgColor, UIColor(red: 115.0 / 255.0, green: 112.0 / 255.0, blue: 249.0 / 255.0, alpha: 1).cgColor]
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func openSelector(_ flag: selectorFlag, selectedEffects: [Bool]? = nil, selectedDays: [Bool]? = nil, selectedDawn: Int? = nil, lamp: LampDevice) {
        let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "selector") as! SelectorViewController
        addChild(popvc)
        popvc.flag = flag
        if let effects = selectedEffects {
            popvc.selectedEffects = effects
        }
        if let dawn = selectedDawn {
            popvc.selectedDawn = dawn
        }
        if let days = selectedDays {
            popvc.selectedDays = days
        }
        popvc.lamp = lamp
        let width = view.frame.width
        let height = view.frame.height
        popvc.view.frame = CGRect(x: 0, y: 0, width: Int(width), height: Int(height))
        popvc.view.center = view.center
        view.addSubview(popvc.view)
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))
        leftView = paddingView
        leftViewMode = .always
    }

    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))
        rightView = paddingView
        rightViewMode = .always
    }
}

extension Int {
    func timeFormatted() -> String {
        let seconds: Int = self % 60
        let minutes: Int = (self / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension UIButton {
    func addRightIcon(image: UIImage, xConstrait: CGFloat) {
        if let subview = viewWithTag(999) {
            subview.removeFromSuperview()
        }
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.contentMode = .scaleAspectFit
        imageView.tag = 999
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: titleLabel!.trailingAnchor, constant: xConstrait),
            imageView.centerYAnchor.constraint(equalTo: titleLabel!.centerYAnchor, constant: 0),
            imageView.widthAnchor.constraint(equalToConstant: 12),
            imageView.heightAnchor.constraint(equalToConstant: 12),
        ])
    }
}

extension String {
    var length: Int {
        return count
    }

    subscript(i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript(r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

extension UILabel {
    func blink() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options:[.repeat,.autoreverse],
                             animations:{ self.alpha=0.0}, completion: nil)
    }
}

extension UIViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {

        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))

        self.present(alert, animated: true, completion: nil)
    }
}
