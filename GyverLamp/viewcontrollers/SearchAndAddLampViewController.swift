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

    func lanScanProgressPinged(_ pingedHosts: Float, from overallHosts: Int){
        self.lampSearchLabel.text = "Поиск лампы .. " + String(Int(pingedHosts)*100/overallHosts) + "%"
    }
    
    // когда найдено новое устройство, проверяется лампа ли это
    func lanScanDidFindNewDevice(_ device: MMDevice!) {
            if !lamps.checkIP(device.ipAddress){
                LampDevice.scan(deviceIp: device.ipAddress)
            }
    }

    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
        dismiss(animated: true)
    }

    func lanScanDidFailedToScan() {
        dismiss(animated: true)
        print("Failed to scan")
    }

    @IBAction func close(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }

    @IBAction func returnToMainView(_ sender: UIButton) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backArrowHeight.constant += self.view.safeAreaTop - 20
        headerViewHeight.constant += self.view.safeAreaTop - 20
        searchAndAddLabel.adjustsFontSizeToFitWidth = true
        lanScanner = MMLANScanner(delegate: self)
        lanScanner.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.dismiss(animated: true, completion: nil)
        }
       
    }
}
