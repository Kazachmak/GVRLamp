//
//  extensions.swift
//  GyverLamp
//
//  Created by Максим Казачков on 18.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import Foundation
import UIKit

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

extension UIDevice {
    func getWiFiAddress() -> String? {
        var address: String?

        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if name == "en0" {
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }
}

extension String {
    func parseDataFromLamp() -> [String] {
        return components(separatedBy: " ")
    }

    func isValidIP() -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.") // Here change this characters based on your requirement
        let characterSet = CharacterSet(charactersIn: self)
        return allowedCharacters.isSuperset(of: characterSet)
    }

    func isValidPort() -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789") // Here change this characters based on your requirement
        let characterSet = CharacterSet(charactersIn: self)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func getTimeFromString()->Date{
     let time = Int(self)
        let minutes = time ?? 0%60
        let hour = Int(time ?? 0/60)
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = hour
        components.minute = minutes
        return calendar.date(from: components)!
                
    }
}

extension UIView {
    func blink(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, alpha: CGFloat = 0.1, enabled: Bool = false) {
        if enabled{
            UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut, .repeat, .autoreverse, .allowUserInteraction,], animations: {
                       self.alpha = alpha
                   })
        }else{
            self.layer.removeAllAnimations()
            self.alpha = 1.0
        }
       
    }
}

extension UIView{
    func setBlackBorder(enabled: Bool = false){
        if enabled {
            self.layer.borderColor = UIColor.black.cgColor
            self.layer.borderWidth = 4.0
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.borderWidth = 0.0
        }
    }
}


