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
    // lamp = LampDevice(hostIP: "192.168.1.48", hostPort: 8888 )
    var lamp: LampDevice?

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfEffects.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let currentLamp = lamp {
            currentLamp.sendCommand(lamp: currentLamp, command: .eff, value: indexPath.row)
            currentLamp.effect = indexPath.row
        }

        collectionOfEffects.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "effectCell", for: indexPath) as! EffectCollectionViewCell
        cell.nameOfEffect.text = listOfEffects[indexPath.row]
        cell.addBoxShadow()
        if let currentLamp = lamp {
            if currentLamp.connectionStatus ?? false {
                if indexPath.row == currentLamp.effect {
                    cell.layer.borderColor = UIColor.red.cgColor
                    cell.layer.borderWidth = 4
                } else {
                    cell.layer.borderColor = UIColor.clear.cgColor
                    cell.layer.borderWidth = 0
                }
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIScreen.main.bounds.height != 568 {
            return CGSize(width: UIScreen.main.bounds.height / 4 + 20, height: UIScreen.main.bounds.height / 7 - 40)

        } else {
            return CGSize(width: UIScreen.main.bounds.height / 3, height: UIScreen.main.bounds.height / 5 - 60)
        }
    }

    @IBAction func settingsButton(_ sender: UIButton) {
        performSegue(withIdentifier: "settings", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settings" {
            let vc = segue.destination as! SettingsViewController
            vc.lamp = lamp
        }
    }

    @IBOutlet var statusLabel: UILabel!

    @IBOutlet var settingsButtonOut: UIButton!

    @IBOutlet var collectionOfEffects: UICollectionView!

    @IBOutlet var brightnessSlider: UISlider!

    @IBAction func brightSetValue(_ sender: UISlider) {
        if let currentLamp = lamp {
            currentLamp.sendCommand(lamp: currentLamp, command: .bri, value: Int(sender.value * 256))
        }
    }

    @IBOutlet var speedSlider: UISlider!

    @IBAction func speedSetValue(_ sender: UISlider) {
        if let currentLamp = lamp {
            currentLamp.sendCommand(lamp: currentLamp, command: .spd, value: Int(sender.value * 256))
        }
    }

    @IBOutlet var scaleSlider: UISlider!

    @IBAction func scaleSetValue(_ sender: UISlider) {
        if let currentLamp = lamp {
            currentLamp.sendCommand(lamp: currentLamp, command: .sca, value: Int(sender.value * 256))
        }
    }

    @IBAction func autoswitchingButton(_ sender: UIButton) {
        if let currentLamp = lamp {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "autoswitching") as! AutoSwitchEffectViewController
            vc.lamp = currentLamp
            present(vc, animated: true, completion: nil)
        }
    }

    @IBOutlet var autoswitchingButtonOut: UIButton!

    @IBAction func alarmClock(_ sender: UIButton) {
        if let currentLamp = lamp {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "alarm") as! AlarmViewController
            vc.lamp = currentLamp
            present(vc, animated: true, completion: nil)
        }
    }

    @IBOutlet var alarmClockOut: UIButton!

    @IBAction func timer(_ sender: UIButton) {
        if lamp != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "timer") as! TimerViewController
            vc.lamp = lamp
            present(vc, animated: true, completion: nil)
        }
    }

    @IBOutlet var timerOut: UIButton!

    @IBAction func powerSwitch(_ sender: UISwitch) {
        if let currentLamp = lamp {
            currentLamp.sendCommand(lamp: currentLamp, command: .power, value: 0)
        }
    }

    
    @IBAction func buttonSwitch(_ sender: UISwitch) {
        if let currentLamp = lamp {
            if currentLamp.button ?? true{
                 currentLamp.sendCommand(lamp: currentLamp, command: .button_off, value: 0)
            }else{
                 currentLamp.sendCommand(lamp: currentLamp, command: .button_on, value: 0)
            }
           
        }
    }
    
    @IBOutlet weak var buttonSwitchOut: UISwitch!
    
    @IBOutlet var powerSwitchOut: UISwitch!

    @objc func updateLamp(notification: Notification?) {
        guard let newLamp = notification?.object as? LampDevice else { return }
        lamp = newLamp
    }

    @objc func updateInterface() {
        if let currentLamp = lamp {
            if currentLamp.powerStatus == true {
                powerSwitchOut.setOn(true, animated: true)
                if currentLamp.timer ?? false {
                    timerOut.blink(duration: 1.0, enabled: true)
                    
                } else {
                    timerOut.blink(enabled: false)
                }
            } else {
                powerSwitchOut.setOn(false, animated: true)
            }
            brightnessSlider.setValue(Float(currentLamp.bright ?? 0) / 256, animated: false)
            speedSlider.setValue(Float(currentLamp.speed ?? 0) / 256, animated: false)
            scaleSlider.setValue(Float(currentLamp.scale ?? 0) / 256, animated: false)
            if currentLamp.connectionStatus == true {
                statusLabel.text = "Лампа подключена"
                statusLabel.textColor = .green
            } else {
                statusLabel.text = "Лампа недоступна"
                statusLabel.textColor = .red
            }
            if currentLamp.button ?? true{
                buttonSwitchOut.setOn(true, animated: true)
            }else{
                buttonSwitchOut.setOn(false, animated: true)
            }
        }
    }

    @objc func fireTimer() {
        if let currentLamp = lamp {
            currentLamp.updateStatus(lamp: currentLamp)
            updateInterface()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        alarmClockOut.addBoxShadow()
        timerOut.addBoxShadow()
        autoswitchingButtonOut.addBoxShadow()
        statusLabel.adjustsFontSizeToFitWidth = true

        updateInterface()
        
        if let hostIP = UserDefaults.standard.string(forKey: "hostIP") {
            if let hostPort = UserDefaults.standard.string(forKey: "hostPort") {
                lamp = LampDevice(hostIP: NWEndpoint.Host(hostIP), hostPort: NWEndpoint.Port(hostPort) ?? 8888)
            }
        }

        _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(updateInterface), name: Notification.Name("updateInterface"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLamp), name: Notification.Name("updateLamp"), object: nil)
        
    }
}
