//
//  SearchAndAddLampViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 26.11.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit


class SearchAndAddLampViewController: UIViewController, MMLANScannerDelegate {
    @IBOutlet var lampSearchLabel: UILabel!

    @IBOutlet weak var searchAndAddLabel: UILabel!
    
    @IBOutlet weak var backArrowHeight: NSLayoutConstraint!
    
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    
    var lanScanner: MMLANScanner! // сканер устройств в локальной сети

    var timer = Timer()

    // когда найдено новое устройство, проверяется лампа ли это
    func lanScanDidFindNewDevice(_ device: MMDevice!) {
        if let listOfLamps = UserDefaults.standard.array(forKey: "listOfLamps") as? [String]{
            var arrayIP: [String] = []
            for element in listOfLamps{
                arrayIP.append(element.components(separatedBy: ":")[0])
            }
            if !arrayIP.contains(String(device.ipAddress)){
                LampDevice.scan(deviceIp: String(device.ipAddress))
            }
        }else{
            LampDevice.scan(deviceIp: String(device.ipAddress))
        }
        
    }

    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
        dismiss(animated: true)
        timer.invalidate()
    }

    func lanScanDidFailedToScan() {
        dismiss(animated: true)
        timer.invalidate()
        print("Failed to scan")
    }

    @IBAction func close(_ sender: UITapGestureRecognizer) {
        timer.invalidate()
        dismiss(animated: true)
    }

    @IBAction func returnToMainView(_ sender: UIButton) {
        timer.invalidate()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backArrowHeight.constant += self.view.safeAreaTop - 20
        headerViewHeight.constant += self.view.safeAreaTop - 20
        searchAndAddLabel.adjustsFontSizeToFitWidth = true
        lanScanner = MMLANScanner(delegate: self)
        lanScanner.start()
        var counter = 1
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            switch counter {
            case 1: self.lampSearchLabel.text = "Поиск лампы .."
                counter = 2
            case 2: self.lampSearchLabel.text = "Поиск лампы ..."
                counter = 3
            case 3: self.lampSearchLabel.text = "Поиск лампы ."
                counter = 1
            default: break
            }
        }
    }
}
