//
//  ViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 18.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit

import Network

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
   var lamp = LampDevice(hostIP: "192.168.1.48", hostPort: 8888 )
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(listOfEffects.count)
        return listOfEffects.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        lamp.sendCommand(lamp: lamp, command: .eff, value: indexPath.row)
        lamp.effect = indexPath.row
        collectionOfEffects.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "effectCell", for: indexPath) as! EffectCollectionViewCell
        cell.nameOfEffect.text = listOfEffects[indexPath.row]
        cell.addBoxShadow()
        if lamp.connectionStatus ?? false {
            if indexPath.row == lamp.effect{
                       cell.layer.borderColor = UIColor.red.cgColor
                       cell.layer.borderWidth = 4
                   }else{
                       cell.layer.borderColor = UIColor.clear.cgColor
                       cell.layer.borderWidth = 0
                   }
        }
       
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIScreen.main.bounds.height != 568 {
            
             return CGSize(width: UIScreen.main.bounds.height / 4, height: UIScreen.main.bounds.height / 4)
            
        } else {
            return CGSize(width: UIScreen.main.bounds.height / 3, height: UIScreen.main.bounds.height / 5 - 10)
        }
    }

    @IBAction func settingsButton(_ sender: UIButton) {
    }

    @IBOutlet var statusLabel: UILabel!

    @IBOutlet var settingsButtonOut: UIButton!

    @IBOutlet var collectionOfEffects: UICollectionView!

    @IBOutlet var brightnessSlider: UISlider!
    
    @IBAction func brightSetValue(_ sender: UISlider) {
        
        lamp.sendCommand(lamp: lamp, command: .bri, value: Int(sender.value*256))
    }
    
    @IBOutlet var speedSlider: UISlider!

    @IBAction func speedSetValue(_ sender: UISlider) {
        lamp.sendCommand(lamp: lamp, command: .spd, value: Int(sender.value*256))
    }
    
    @IBOutlet var scaleSlider: UISlider!

    @IBAction func scaleSetValue(_ sender: UISlider) {
        lamp.sendCommand(lamp: lamp, command: .sca, value: Int(sender.value*256))
    }
    
    
    
    @IBAction func autoswitchingButton(_ sender: UIButton) {
    }

    @IBOutlet var autoswitchingButtonOut: UIButton!

    @IBAction func alarmClock(_ sender: UIButton) {
    }

    @IBOutlet var alarmClockOut: UIButton!

    @IBAction func timer(_ sender: UIButton) {
    }

    @IBOutlet var timerOut: UIButton!

    @IBAction func powerSwitch(_ sender: UISwitch) {
        lamp.sendCommand(lamp: lamp, command: .power, value: 0)
    }

    @IBOutlet var powerSwitchOut: UISwitch!

    @objc func updateInterface(){
        if lamp.powerStatus == true {
            powerSwitchOut.setOn(true, animated: true)
        } else {
            powerSwitchOut.setOn(false, animated: true)
        }
        brightnessSlider.setValue(Float(lamp.bright ?? 0)/256, animated: false)
        speedSlider.setValue(Float(lamp.speed ?? 0)/256, animated: false)
        scaleSlider.setValue(Float(lamp.scale ?? 0)/256, animated: false)
        if lamp.connectionStatus == true {
            statusLabel.text = "Лампа подключена"
            statusLabel.textColor = .green
        }else{
            statusLabel.text = "Лампа недоступна"
            statusLabel.textColor = .red
        }
        
    }
    
    @objc func fireTimer() {
        lamp = LampDevice(hostIP: "192.168.1.48", hostPort: 8888)
        updateInterface()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alarmClockOut.addBoxShadow()
        timerOut.addBoxShadow()
        autoswitchingButtonOut.addBoxShadow()
        updateInterface()
        _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateInterface), name: Notification.Name("updateInterface"), object: nil)
    }
}
