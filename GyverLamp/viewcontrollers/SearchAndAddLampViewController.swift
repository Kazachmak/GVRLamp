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

    @IBOutlet var searchAndAddLabel: UILabel!

    @IBOutlet var backArrowHeight: NSLayoutConstraint!

    @IBOutlet var headerViewHeight: NSLayoutConstraint!

    var lanScanner: MMLANScanner! // сканер устройств в локальной сети

    func lanScanProgressPinged(_ pingedHosts: Float, from overallHosts: Int) {
        lampSearchLabel.text = searchingForLamp + String(Int(pingedHosts) * 100 / overallHosts) + "%"
    }

    // когда найдено новое устройство, проверяется лампа ли это
    func lanScanDidFindNewDevice(_ device: MMDevice!) {
        if !lamps.checkIP(device.ipAddress) {
            LampDevice.scan(deviceIp: device.ipAddress)
        }
    }

    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
        if isFirstLaunch && lamps.arrayOfLamps.isEmpty {
            // create the alert
            let alert = UIAlertController(title: lampNotFound, message: " «Лампы не обнаружены. Подключитесь к WiFi сети лампы и нажмите \"Найти\" или \"Добавьте лампу вручную\"", preferredStyle: UIAlertController.Style.alert)
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: openSettings, style: UIAlertAction.Style.default, handler: { _ in UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil) }))
            // show the alert
            present(alert, animated: true, completion: nil)
        } else {
            dismiss(animated: true)
        }
    }

    func lanScanDidFailedToScan() {
        dismiss(animated: true)
        print("Failed to scan")
    }

    @IBAction func close(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        lanScanner = MMLANScanner(delegate: self)
        if isFirstLaunch {
            LampDevice.scan(deviceIp: "192.168.4.1")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if !lamps.checkIP("192.168.4.1") {
                    self.lanScanner.start()
                } else {
                    self.dismiss(animated: true)
                }
            }
        } else {
            lanScanner.start()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backArrowHeight.constant += view.safeAreaTop - 20
        headerViewHeight.constant += view.safeAreaTop - 20
        searchAndAddLabel.adjustsFontSizeToFitWidth = true
    }
}
