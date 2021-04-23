//
//  ViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 18.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import MIBlurPopup
import Network
import SimpleAnimation
import TactileSlider
import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate {
    var timer = Timer()

    @IBOutlet var picker: UIPickerView!

    @IBOutlet var pickerView: UIView!

    @IBOutlet var viewWithButtons: UIView!

    @IBOutlet var brightPercent: UILabel!

    @IBOutlet var speedPercent: UILabel!

    @IBOutlet var scalePercent: UILabel!

    @IBOutlet var topInterval: NSLayoutConstraint!

    @IBOutlet var errorMessageHeight: NSLayoutConstraint!

    @IBOutlet var errorMessage: UIButton!

    @IBAction func openSettings(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "lampsettings") as! LampSettingsViewController
        if lamps.arrayOfLamps.count > 0 {
            vc.lamp = lamps.mainLamp
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
    }

    var heightOfPickerViewConstraint: NSLayoutConstraint?

    @IBOutlet var heightOfViewWithButtons: NSLayoutConstraint!

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let currentLamp = lamps.mainLamp {
            return currentLamp.listOfEffects.count
        } else {
            return LampDevice.listOfEffectsDefault.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let currentLamp = lamps.mainLamp {
            if currentLamp.listOfEffects.count >= row {
                return "\(currentLamp.getEffectName(row))"
            } else {
                return ""
            }
        } else {
            return LampDevice.listOfEffectsDefault[row]
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let currentLamp = lamps.mainLamp {
            currentLamp.effect = row
            currentLamp.updateSliderFlag = true
            lamps.sendCommandToArrayOfLamps(command: .eff, value: [row])
            lamps.necessaryToAlignTheParametersOfTheLamps = true
        }
    }

    private func changeEffectByButton(_ step: Int) {
        if let currentLamp = lamps.mainLamp {
            currentLamp.updateSliderFlag = true
            currentLamp.updatePickerFlag = true
            if let effect = currentLamp.effect{
                currentLamp.effect = effect + step
                lamps.sendCommandToArrayOfLamps(command: .eff, value: [effect + step])
                lamps.necessaryToAlignTheParametersOfTheLamps = true
                
            }
        }
    }

    @IBOutlet var leftPickerImage: UIImageView!

    @IBOutlet var rightPickerImage: UIImageView!

    @IBAction func leftPickerButton(_ sender: UIButton) {
        changeEffectByButton(-1)
    }

    @IBAction func rightPickerButton(_ sender: UIButton) {
        changeEffectByButton(1)
    }

    @IBOutlet var leftPickerButtonInteractionOut: UIButton!

    @IBOutlet var rightPickerButtonInteractionOut: UIButton!

    // открываем страницу настроек
    @IBAction func settingsButton(_ sender: UIButton) {
        performSegue(withIdentifier: "settings", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "settings":
            _ = segue.destination as? SettingsViewController
        case "alarm":
            let vc = segue.destination as? AlarmViewController
            vc?.lamp = lamps.mainLamp
        case "timer":
            let vc = segue.destination as? TimerViewController
            vc?.lamp = lamps.mainLamp
        case "autoswitch":
            let vc = segue.destination as? LampSettingsViewController
            vc?.lamp = lamps.mainLamp
        case "bright", "speed", "scale":
            guard let popupViewController = segue.destination as? EmptyViewController else { return }
            popupViewController.customBlurEffectStyle = .light
            popupViewController.customAnimationDuration = 0.5
            popupViewController.customInitialScaleAmmount = 0.5
            switch segue.identifier {
            case "bright": popupViewController.command = .bri
            case "speed": popupViewController.command = .spd
            case "scale": popupViewController.command = .sca
            default: break
            }

            popupViewController.lamp = lamps.mainLamp

        default:
            break
        }
    }

    @IBOutlet var statusLabel: UILabel!

    @IBAction func tapStatusLabel(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "settings", sender: nil)
    }

    @IBOutlet var settingsButtonOut: UIButton!

    // регулировка яркости
    @IBOutlet var brightnessSlider: TactileSlider!

    @IBAction func brightSetValue(_ sender: TactileSlider) {
        lamps.mainLamp?.updateSliderFlag = false
        // lamps.mainLamp?.sendCommand(command: .bri, value: [Int(sender.value)])
        lamps.sendCommandToArrayOfLamps(command: .bri, value: [Int(sender.value)])
    }

    @IBAction func longPressSlider(_ sender: UILongPressGestureRecognizer) {
        performSegue(withIdentifier: "bright", sender: sender)
    }

    // регулировка скорости
    @IBOutlet var speedSlider: TactileSlider!

    @IBAction func speedSetValue(_ sender: TactileSlider) {
        lamps.mainLamp?.updateSliderFlag = false
        lamps.sendCommandToArrayOfLamps(command: .spd, value: [Int(sender.value)])
    }

    @IBAction func longPressSpeedSlider(_ sender: UILongPressGestureRecognizer) {
        performSegue(withIdentifier: "speed", sender: sender)
    }

    // регулировка масштаба

    @IBOutlet var scaleSlider: TactileSlider!

    @IBAction func scaleSetValue(_ sender: TactileSlider) {
        lamps.mainLamp?.updateSliderFlag = false
        // lamps.mainLamp?.sendCommand(command: .sca, value: [Int(sender.value)])
        lamps.sendCommandToArrayOfLamps(command: .sca, value: [Int(sender.value)])
    }

    @IBAction func longPressScaleSlider(_ sender: UILongPressGestureRecognizer) {
        performSegue(withIdentifier: "scale", sender: sender)
    }

    // открываем страницу будильников
    @IBAction func alarmClock(_ sender: UIButton) {
        performSegue(withIdentifier: "alarm", sender: nil)
    }

    @IBOutlet var alarmClockOut: UIButton!

    // открываем страницу таймера
    @IBAction func timer(_ sender: UIButton) {
        performSegue(withIdentifier: "timer", sender: nil)
    }

    @IBOutlet var timerOut: UIButton!

    @IBOutlet var timerLabel: UILabel!

    private func displayTimer(_ status: Bool) {
        if let currentlamp = lamps.mainLamp {
            if status && (currentlamp.timerTime > 0) {
                timerOut.alpha = 1
                timerLabel.alpha = 1
                if !timer.isValid {
                    updateTimerLabel()
                    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
                }
            } else {
                timerOut.alpha = 0.5
                timerLabel.alpha = 0.5
                timerLabel.text = "Выкл."
                timer.invalidate()
            }
        }
    }

    @IBOutlet var alarmLabel: UILabel!

    private func displayAlarm(_ alarmString: String) {
        let array = alarmString.components(separatedBy: " ")
        let alarms = array[1 ..< 8]
        if alarms.contains("1") {
            alarmLabel.alpha = 1
            alarmClockOut.alpha = 1
            alarmLabel.text = "Вкл."
        } else {
            alarmLabel.alpha = 0.5
            alarmClockOut.alpha = 0.5
            alarmLabel.text = "Выкл."
        }
    }

    // выключатель
    @IBAction func onOffButton(_ sender: UIButton) {
        if let currentLamp = lamps.mainLamp {
            if currentLamp.powerStatus {
                lamps.sendCommandToArrayOfLamps(command: .power_off, value: [0])
                currentLamp.powerStatus = false
            } else {
                lamps.sendCommandToArrayOfLamps(command: .power_on, value: [0])
                currentLamp.powerStatus = true
            }
        }
    }

    @IBOutlet var onOffButttonOut: UIButton!

    // фукнция обновляет инерфейс
    @objc func updateInterface() {
        if let currentLamp = lamps.mainLamp {
            
            picker.delegate = self
            if currentLamp.updateSliderFlag {
                updateSlider()
            }
           
            if let bright = currentLamp.bright {
                brightPercent.text = String(bright * 100 / 255)
            }
            if let speed = currentLamp.speed {
                speedPercent.text = String(speed * 100 / 255)
            }
            if let scale = currentLamp.scale {
                scalePercent.text = String(scale * 100 / 255)
            }

            statusLabel.text = currentLamp.name
            if let effectNumber = currentLamp.effect {
                if currentLamp.updatePickerFlag{
                    picker.selectRow(effectNumber, inComponent: 0, animated: false)
                    currentLamp.updatePickerFlag = false
                }
            }

            if currentLamp.connectionStatus { // проверка доступа к лампе
                removeOffView()
                statusLabel.textColor = blackColor
                if currentLamp.powerStatus == true { // проверка включена лампа или нет
                    onOffButttonOut.setImage(UIImage(named: "onOff2.png"), for: .normal)
                    if errorMessageHeight.constant != 0 {
                        leftPickerImage.shake(toward: .top, amount: 0.1, duration: 1, delay: 0.5)
                        rightPickerImage.shake(toward: .top, amount: 0.1, duration: 1, delay: 0.5)
                        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                            self.errorMessageHeight.constant = 0
                        })
                    }
                } else {
                    onOffButttonOut.setImage(UIImage(named: "onOff3.png"), for: .normal)
                    errorMessage.setTitle("Лампа выключена", for: .normal)
                    if errorMessageHeight.constant != 24 {
                        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                            self.errorMessageHeight.constant = 24
                        })
                    }
                }

            } else {
                statusLabel.textColor = .gray
                UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.errorMessage.isUserInteractionEnabled = false
                    self.errorMessageHeight.constant = 24
                    self.errorMessage.setTitle("Нет подключения к лампе", for: .normal)
                    //self.addOffView()

                })
            }

            // проверка таймера
            if let timer = currentLamp.timer {
                displayTimer(timer)
            }

            if let alarms = currentLamp.alarm {
                displayAlarm(alarms)
            }

            if let favorite = currentLamp.favorite {
                if favorite.components(separatedBy: " ")[1] == "1" {
                    errorMessage.isUserInteractionEnabled = true
                    UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: { [self] in
                        self.errorMessageHeight.constant = 24
                        self.errorMessage.setTitle("Автопереключение", for: .normal)
                    })
                }
            }

        } else {
            errorMessage.isUserInteractionEnabled = false
            statusLabel.text = "Цветолампа"
            statusLabel.textColor = .gray
            UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: { [self] in
                errorMessageHeight.constant = 24
                self.errorMessage.setTitle("Нет подключения к лампе", for: .normal)
                addOffView()
            })
        }
    }

    private func addOffView() {
        if view.viewWithTag(101) == nil {
            let offView = UIView(frame: CGRect(x: 0, y: pickerView.frame.maxY, width: view.frame.width, height: view.frame.height - pickerView.frame.maxY))
            offView.backgroundColor = UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1)
            offView.alpha = 0.5
            offView.tag = 101
            view.addSubview(offView)
        }
    }

    private func removeOffView() {
        if let viewWithTag = view.viewWithTag(101) {
            viewWithTag.removeFromSuperview()
        }
    }

    private func updateSlider() {
        if let bright = lamps.mainLamp?.bright {
            brightnessSlider.setValue(Float(bright), animated: false)
        }
        if let speed = lamps.mainLamp?.speed {
            speedSlider.setValue(Float(speed), animated: false)
        }
        if let scale = lamps.mainLamp?.scale {
            scaleSlider.setValue(Float(scale), animated: false)
        }
        lamps.mainLamp?.updateSliderFlag = false
    }

    override func viewWillAppear(_ animated: Bool) {
        lamps.mainLamp?.updatePickerFlag = true
        lamps.mainLamp?.updateSliderFlag = true
        if lamps.mainLamp?.connectionStatus ?? false { // проверка соединения с лампой
            if lamps.mainLamp?.powerStatus == true { // проверка включена лампа или нет
                leftPickerImage.shake(toward: .top, amount: 0.1, duration: 1, delay: 0.5)
                rightPickerImage.shake(toward: .top, amount: 0.1, duration: 1, delay: 0.5)
            }
        }
        updateInterface()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addOffView()
        errorMessage.layer.zPosition = 2
        leftPickerButtonInteractionOut.layer.zPosition = 2
        rightPickerButtonInteractionOut.layer.zPosition = 2
        statusLabel.adjustsFontSizeToFitWidth = true
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification
                    , object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateInterface), name: Notification.Name("updateInterface"), object: nil)

        timerOut.imageView?.contentMode = .scaleAspectFit
        alarmClockOut.imageView?.contentMode = .scaleAspectFit
        onOffButttonOut.imageView?.contentMode = .scaleAspectFit
        let img2 = UIImage(named: "background.png")
        viewWithButtons.layer.contents = img2?.cgImage
        onOffButttonOut.layer.zPosition = 2
        if UIScreen.main.bounds.height < 569 {
            heightOfViewWithButtons.constant = 70
            heightOfPickerViewConstraint = pickerView.heightAnchor.constraint(equalToConstant: 150)
            heightOfPickerViewConstraint?.isActive = true
        }
        let imageGradient = UIImage.gradientImageWithBounds(bounds: brightnessSlider.frame)
        brightnessSlider.tintColor = UIColor(patternImage: imageGradient)
        speedSlider.tintColor = UIColor(patternImage: imageGradient)
        scaleSlider.tintColor = UIColor(patternImage: imageGradient)
       
    }
    
    @objc private func appMovedToForeground() {
        lamps.mainLamp?.updatePickerFlag = true
        lamps.mainLamp?.updateSliderFlag = true
        print("App moved to ForeGround!")
    }
    
    @objc func updateTimerLabel() {
        
            if let currentLamp = lamps.mainLamp {

                timerLabel.text = currentLamp.timerTime.timeFormatted() // will show timer
               
                if currentLamp.timerTime != 0 {
                    currentLamp.timerTime -= 1 // decrease counter timer
                   
                } else {
                    timer.invalidate()
                }
        }
    }

    override func viewDidLayoutSubviews() {
        brightnessSlider.addImage(image: UIImage(named: "brightness.png")!, frame: CGRect(x: 22, y: brightnessSlider.frame.height - 60, width: 26, height: 26))
        speedSlider.addImage(image: UIImage(named: "speed.png")!, frame: CGRect(x: 19, y: brightnessSlider.frame.height - 60, width: 32, height: 18))
        scaleSlider.addImage(image: UIImage(named: "scale.png")!, frame: CGRect(x: 25, y: brightnessSlider.frame.height - 60, width: 20, height: 20))
    }
}
