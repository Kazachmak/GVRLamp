//
//  SearchAndAddLampViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 26.11.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import MMLanScan
import UIKit

class SearchAndAddLampViewController: UIViewController, MMLANScannerDelegate {
    var label: String?

    var modeOfSearch: ModeOfSearch = .firstStartSearch

    

    @IBOutlet var searchLampTextLabel: UITextView!

    @IBAction func searchLampLabelTouch(_ sender: UITapGestureRecognizer) {
        switch searchLampTextLabel.text {
        case lampNotFoundExt1:
            searchLampTextLabel.text = lampNotFoundExt
          //  searchButtonOut.isHidden = true

        case lampNotFoundExt: searchLampTextLabel.text = lampNotFoundExt1
                //  searchButtonOut.isHidden = false

        default: break
        }
    }

    @IBOutlet var searchAndAddLabel: UILabel!

    
    @IBOutlet var headerViewHeight: NSLayoutConstraint!

    var lanScanner: MMLANScanner! // сканер устройств в локальной сети

    func lanScanProgressPinged(_ pingedHosts: Float, from overallHosts: Int) {
        searchLampTextLabel.textAlignment = .center
        searchLampTextLabel.text = searchingForLamp + String(Int(pingedHosts) * 100 / overallHosts) + "%"
    }

    // когда найдено новое устройство, проверяется лампа ли это
    func lanScanDidFindNewDevice(_ device: MMDevice!) {
        if !lamps.checkIP(device.ipAddress) {
            LampDevice.scan(deviceIp: device.ipAddress)
        }
    }

    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
        searchButtonOut.alpha = 1
        searchButtonOut.isHidden = false
        searchLampTextLabel.textAlignment = .left
        if lamps.arrayOfLamps.isEmpty {
           
            switch modeOfSearch {
            case .searchInRouterMode:
                searchLampTextLabel.text = lampNotFoundExt1
            case .searchInSpotMode, .firstStartSearch:
                searchLampTextLabel.text = lampNotFoundExt2
            }
        } else {
            view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        }
    }

    func lanScanDidFailedToScan() {
        //view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        print("Failed to scan")
    }

    @IBAction func searchButton(_ sender: UIButton) {
        self.searchButtonOut.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            
            LampDevice.scan(deviceIp: "192.168.4.1")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !lamps.checkIP("192.168.4.1") {
                    self.lanScanner.start()
                } else {
                   // if self.modeOfSearch == .searchInRouterMode {
                        
                    //} else {
                        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                   // }
                }
            }
        }
        
    }

    @IBOutlet var searchButtonOut: UIButton!

    

    override func viewDidAppear(_ animated: Bool) {
        lanScanner = MMLANScanner(delegate: self)
        searchButtonOut.isHidden = false
        switch modeOfSearch {
        case .firstStartSearch:
            searchButtonOut.isHidden = true
            if lamps.arrayOfLamps.isEmpty || !lamps.connectionStatusOfMainLamp {
                
                LampDevice.scan(deviceIp: "192.168.4.1")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if !lamps.checkIP("192.168.4.1") {
                        self.lanScanner.start()
                    } else {
                        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                    }
                }
            } else {
                lanScanner.start()
            }
        case .searchInRouterMode:
            
            searchLampTextLabel.textAlignment = .left
            searchLampTextLabel.text = connectPhoneToWiFi + (label ?? "") + andPressFind
        case .searchInSpotMode:
            
            searchLampTextLabel.textAlignment = .left
            searchLampTextLabel.text = connectPhoneToWiFi + "Led Lamp" + andPressFind
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //  backArrowHeight.constant += view.safeAreaTop + 20
        //  headerViewHeight.constant += view.safeAreaTop - 20
        searchAndAddLabel.adjustsFontSizeToFitWidth = true
        searchLampTextLabel.textAlignment = .left

        // searchLampTextLabel.text = lampNotFoundExt
        // searchButtonOut.isHidden = false
    }
}
