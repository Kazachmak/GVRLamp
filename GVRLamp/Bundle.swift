//
//  Bundle.swift
//  GyverLamp
//
//  Created by Максим Казачков on 06.08.2021.
//  Copyright © 2021 Maksim Kazachkov. All rights reserved.
//

import Foundation
var _bundle: UInt8 = 0

class BundleEx: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let bundle: Bundle? = objc_getAssociatedObject(self, &_bundle) as? Bundle

        if let temp = bundle {
            return temp.localizedString(forKey: key, value: value, table: tableName)
        } else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
    }
}

public extension Bundle {
    class func setLanguage(_ language: String?) {
        let oneToken: String = "your app bundle id"

        DispatchQueue.once(token: oneToken) {
            print("Do This Once!")
            object_setClass(Bundle.main, BundleEx.self as AnyClass)
        }

        if let temp = language {
            objc_setAssociatedObject(Bundle.main, &_bundle, Bundle(path: Bundle.main.path(forResource: temp, ofType: "lproj")!), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } else {
            objc_setAssociatedObject(Bundle.main, &_bundle, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension DispatchQueue {
    private static var _onceTracker = [String]()

    class func once(token: String, block: () -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }

        if _onceTracker.contains(token) {
            return
        }

        _onceTracker.append(token)
        block()
    }
}

extension Bundle {
    static func swizzleLocalization() {
        let orginalSelector = #selector(localizedString(forKey:value:table:))
        guard let orginalMethod = class_getInstanceMethod(self, orginalSelector) else { return }

        let mySelector = #selector(myLocaLizedString(forKey:value:table:))
        guard let myMethod = class_getInstanceMethod(self, mySelector) else { return }

        if class_addMethod(self, orginalSelector, method_getImplementation(myMethod), method_getTypeEncoding(myMethod)) {
            class_replaceMethod(self, mySelector, method_getImplementation(orginalMethod), method_getTypeEncoding(orginalMethod))
        } else {
            method_exchangeImplementations(orginalMethod, myMethod)
        }
    }

    @objc private func myLocaLizedString(forKey key: String,
                                         value: String?,
                                         table: String?) -> String {
        return Bundle.main.myLocaLizedString(forKey: key, value: value, table: table)
    }
}
