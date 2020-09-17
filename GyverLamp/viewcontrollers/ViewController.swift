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
    var lamp: LampDevice? // объект лампа

    // коллекция эффектов
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfEffects.count
    }

    // переключаем эффекты нажимая на ячейки
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let currentLamp = lamp {
            currentLamp.sendCommand(lamp: currentLamp, command: .eff, value: [indexPath.row])
            currentLamp.effect = indexPath.row
        }

        collectionOfEffects.reloadData()
    }

    // надписи ячейках и красная граница на выбранном эффекте
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

    // размеры ячеек
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIScreen.main.bounds.height != 568 {
            return CGSize(width: UIScreen.main.bounds.height / 4 + 20, height: UIScreen.main.bounds.height / 5)

        } else {
            return CGSize(width: UIScreen.main.bounds.height / 3 - 20, height: UIScreen.main.bounds.height / 5 - 65)
        }
    }

    // открываем страницу настроек
    @IBAction func settingsButton(_ sender: UIButton) {
        performSegue(withIdentifier: "settings", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Назад"
        navigationItem.backBarButtonItem = backItem
        switch segue.identifier {
        case "settings":
            let vc = segue.destination as? SettingsViewController
            vc?.lamp = lamp
        case "alarm":
            let vc = segue.destination as? AlarmViewController
            vc?.lamp = lamp
        case "timer":
            let vc = segue.destination as? TimerViewController
            vc?.lamp = lamp
        case "autoswitch":
            let vc = segue.destination as? AutoSwitchEffectViewController
            vc?.lamp = lamp
        default:
            break
        }
    }

    @IBOutlet var statusLabel: UILabel!

    @IBOutlet var settingsButtonOut: UIButton!

    @IBOutlet var collectionOfEffects: UICollectionView!

    @IBOutlet var brightnessSlider: UISlider!

    // регулировка яркости
    @IBAction func brightSetValue(_ sender: UISlider) {
        if let currentLamp = lamp {
            currentLamp.sendCommand(lamp: currentLamp, command: .bri, value: [Int(sender.value * 256)])
        }
    }

    @IBOutlet var speedSlider: UISlider!

    // регулировка скорости
    @IBAction func speedSetValue(_ sender: UISlider) {
        if let currentLamp = lamp {
            currentLamp.sendCommand(lamp: currentLamp, command: .spd, value: [Int(sender.value * 256)])
        }
    }

    @IBOutlet var scaleSlider: UISlider!
    // регулировка масштаба
    @IBAction func scaleSetValue(_ sender: UISlider) {
        if let currentLamp = lamp {
            currentLamp.sendCommand(lamp: currentLamp, command: .sca, value: [Int(sender.value * 256)])
        }
    }

    // открываем страницу автопереключения выбранных эффектов
    @IBAction func autoswitchingButton(_ sender: UIButton) {
        if lamp != nil {
            performSegue(withIdentifier: "autoswitch", sender: nil)
        }
    }

    @IBOutlet var autoswitchingButtonOut: UIButton!

    // открываем страницу будильников
    @IBAction func alarmClock(_ sender: UIButton) {
        if lamp != nil {
            performSegue(withIdentifier: "alarm", sender: nil)
        }
    }

    @IBOutlet var alarmClockOut: UIButton!

    // открываем страницу таймера
    @IBAction func timer(_ sender: UIButton) {
        if lamp != nil {
            performSegue(withIdentifier: "timer", sender: nil)
        }
    }

    @IBOutlet var timerOut: UIButton!

    // выключатель
    @IBAction func powerSwitch(_ sender: UISwitch) {
        if let currentLamp = lamp {
            if currentLamp.powerStatus ?? true {
                currentLamp.sendCommand(lamp: currentLamp, command: .power_off, value: [0])
            } else {
                currentLamp.sendCommand(lamp: currentLamp, command: .power_on, value: [0])
            }
        }
    }

    // выключатель кнопки на лампе
    @IBAction func buttonSwitch(_ sender: UISwitch) {
        if let currentLamp = lamp {
            if currentLamp.button ?? true {
                currentLamp.sendCommand(lamp: currentLamp, command: .button_off, value: [0])
            } else {
                currentLamp.sendCommand(lamp: currentLamp, command: .button_on, value: [0])
            }
        }
    }

    @IBOutlet var buttonSwitchOut: UISwitch!

    @IBOutlet var powerSwitchOut: UISwitch!

    // функция обновляет лампу при добавлении новой на странице настроек
    @objc func updateLamp(notification: Notification?) {
        guard let newLamp = notification?.object as? LampDevice else { return }
        lamp = newLamp
    }

    // фукнция удаляет текущую лампу
    @objc func deleteLamp() {
        lamp = nil
        UserDefaults.standard.removeObject(forKey: "hostIP")
        UserDefaults.standard.removeObject(forKey: "hostPort")
        UserDefaults.standard.synchronize()
        updateInterface()
    }

    // фукнция обновлфет инерфейс
    @objc func updateInterface() {
        if let currentLamp = lamp {
            collectionOfEffects.reloadData()
            if currentLamp.powerStatus == true { //проверка включяена лампа или нет
                powerSwitchOut.setOn(true, animated: true)
                if currentLamp.timer ?? false { // проверка включен таймер или нет
                    timerOut.titleLabel?.textColor = .orange

                } else {
                    timerOut.titleLabel?.textColor = .black
                }
                if currentLamp.favorite?.components(separatedBy: " ")[1] == "1" { // проверка включен режим автопереключения или нет
                    autoswitchingButtonOut.titleLabel?.textColor = .orange

                } else {
                    autoswitchingButtonOut.titleLabel?.textColor = .black
                }

            } else {
                powerSwitchOut.setOn(false, animated: true)
            }
            brightnessSlider.setValue(Float(currentLamp.bright ?? 0) / 256, animated: false) // установка значений слайдеров
            speedSlider.setValue(Float(currentLamp.speed ?? 0) / 256, animated: false)
            scaleSlider.setValue(Float(currentLamp.scale ?? 0) / 256, animated: false)
            if currentLamp.connectionStatus == true { // проверка доступа к лампе
                statusLabel.text = "Лампа подключена"
                statusLabel.textColor = .green
            } else {
                statusLabel.text = "Лампа недоступна"
                statusLabel.textColor = .red
            }
            if currentLamp.button ?? true {
                buttonSwitchOut.setOn(true, animated: true)
            } else {
                buttonSwitchOut.setOn(false, animated: true)
            }
        } else {
            statusLabel.text = "Лампа недоступна"
            statusLabel.textColor = .red
            buttonSwitchOut.setOn(false, animated: true)
            brightnessSlider.setValue(0, animated: false)
            speedSlider.setValue(0, animated: false)
            scaleSlider.setValue(0, animated: false)
            powerSwitchOut.setOn(false, animated: true)
        }
    }

    // каждый 5 секунд запрашиваем состояние лампы
    @objc func fireTimer() {
        if let currentLamp = lamp {
            currentLamp.updateStatus(lamp: currentLamp)
            updateInterface()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        alarmClockOut.addBoxShadow() // добавляем тень к кнопкам
        timerOut.addBoxShadow()
        autoswitchingButtonOut.addBoxShadow()
        statusLabel.adjustsFontSizeToFitWidth = true

        if let hostIP = UserDefaults.standard.string(forKey: "hostIP") {
            if let hostPort = UserDefaults.standard.string(forKey: "hostPort") {
                lamp = LampDevice(hostIP: NWEndpoint.Host(hostIP), hostPort: NWEndpoint.Port(hostPort) ?? 8888) //подключаем лампу
            }
        }

        _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true) // таймер, который каждый 5 секунд запрашивает лампу
        NotificationCenter.default.addObserver(self, selector: #selector(updateInterface), name: Notification.Name("updateInterface"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLamp), name: Notification.Name("updateLamp"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteLamp), name: Notification.Name("deleteLamp"), object: nil)
    }
}
