//
//  SearchAndAddLampViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 26.11.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit

class SearchAndAddLampViewController: UIViewController, MMLANScannerDelegate {
    
    var label: String?
    
    var modeOfSearch = false
    
    @IBOutlet weak var backArrow: UIButton!
    
    @IBOutlet weak var lampSearchLabel: UILabel!

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
        searchButtonOut.alpha = 1
        if lamps.arrayOfLamps.isEmpty {
            searchButtonOut.isHidden = false
            if modeOfSearch {
                lampSearchLabel.text = lampNotFoundExt
                modeOfSearch = false
            }else{
                lampSearchLabel.text = lampNotFoundExt2
            }
            
        } else {
            if modeOfSearch{
                self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            }else{
                dismiss(animated: true)
            }
        }
    }

    func lanScanDidFailedToScan() {
        dismiss(animated: true)
        print("Failed to scan")
    }

    @IBAction func searchButton(_ sender: UIButton) {
        searchButtonOut.alpha = 0.5
        LampDevice.scan(deviceIp: "192.168.4.1")
        if modeOfSearch{
            self.lanScanner.start()
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if !lamps.checkIP("192.168.4.1") {
                    self.lanScanner.start()
                } else {
                    self.dismiss(animated: true)
                }
            }
        }
    }

    @IBOutlet var searchButtonOut: UIButton!

    @IBAction func close(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        lanScanner = MMLANScanner(delegate: self)
        if modeOfSearch{
            lampSearchLabel.text = connectPhoneToWiFi + (label ?? "") + andPressFind
            searchButtonOut.isHidden = false
        }else{
            if lamps.arrayOfLamps.isEmpty || !lamps.connectionStatusOfMainLamp{
                backArrow.isHidden = true
                LampDevice.scan(deviceIp: "192.168.4.1")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if !lamps.checkIP("192.168.4.1") {
                        self.lanScanner.start()
                    } else {
                        self.dismiss(animated: true)
                    }
                }
            } else {
                lanScanner.start()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backArrowHeight.constant += view.safeAreaTop + 20
        headerViewHeight.constant += view.safeAreaTop - 20
        searchAndAddLabel.adjustsFontSizeToFitWidth = true
        lampSearchLabel.adjustsFontSizeToFitWidth = true
      //  searchButtonOut.isHidden = false
       // lampSearchLabel.text = "Не удалось найти вашу лампу. Проверьте список сети wi-fi.\n Если в списке снова появилась сеть лампы, значит подключение к роутеру не произошло и Вам необходимо повторить процедуру заново. Подключитесь к Wi-fi сети лампы и нажмите кнопку ниже. \n Если Wi-fi еть лампы не появлилась в списке, нажмите Найти для повторного поиска."
    }
}
