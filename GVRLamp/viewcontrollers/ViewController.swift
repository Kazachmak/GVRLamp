//
//  ViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 18.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import MagicTimer
import MIBlurPopup
import Network
import SimpleAnimation
import TactileSlider
import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate {

    var isFirstLaunch = true

    @IBOutlet var timer: MagicTimerView!

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
        if !lamps.arrayOfLamps.isEmpty {
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
            if currentLamp.selectedEffectsNameList.isEmpty {
                return 1
            } else {
                return currentLamp.selectedEffectsNameList.count
            }
        } else {
            return LampDevice.listOfEffectsDefault.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = PaddingLabel()
        if let v = view {
            label = v as! PaddingLabel
        } else {
            label = PaddingLabel(frame: CGRect(x: 0, y: 0, width: pickerView.frame.width, height: 400))
        }

        label.font = UIFont.systemFont(ofSize: 22)

        if let currentLamp = lamps.mainLamp {
            if currentLamp.selectedEffectsNameList.isEmpty {
                label.text = youMustSelectEffects
            } else {
                label.text = currentLamp.getEffectName(row, nameList: currentLamp.selectedEffectsNameList)
            }
        } else {
            label.text = LampDevice.listOfEffectsDefault[row]
        }
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.paddingLeft = 10
        label.paddingRight = 10
        if lamps.mainLamp?.selectedEffectsNameList.count == 0 {
            label.numberOfLines = 0
        } else {
            label.numberOfLines = 1
        }
        label.sizeToFit()
        return label
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if let currentLamp = lamps.mainLamp {
            if currentLamp.selectedEffectsNameList.isEmpty {
                return 80.0
            } else {
                return 30.0
            }
        } else {
            return 30.0
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let currentLamp = lamps.mainLamp {
            if !currentLamp.selectedEffectsNameList.isEmpty {
                currentLamp.effect = row
                currentLamp.updateSliderFlag = true
                lamps.sendCommandToArrayOfLamps(command: .eff, value: [currentLamp.getEffectNumber(currentLamp.selectedEffectsNameList[row])])
                lamps.necessaryToAlignTheParametersOfTheLamps = true
            } else {
                openSelector(.effects, lamp: currentLamp)
            }
        }
    }

    @IBOutlet weak var overlayPickerButtonOut: UIButton!

    @IBAction func overlayPickerButton(_ sender: UIButton) {
        if let currentLamp = lamps.mainLamp {
            if currentLamp.selectedEffectsNameList.isEmpty {
                openSelector(.effects, lamp: currentLamp)
            }
        }
    }

    @IBAction func touchPick(_ sender: UILongPressGestureRecognizer) {
        if let currentLamp = lamps.mainLamp {
            if currentLamp.selectedEffectsNameList.isEmpty {
                openSelector(.effects, lamp: currentLamp)
            } else {
                performSegue(withIdentifier: "effects", sender: sender)
            }
        }
    }

    private func changeEffectByButton(_ step: Int) {
        if let currentLamp = lamps.mainLamp {
            currentLamp.updateSliderFlag = true
            if let effect = currentLamp.effect {
                var number = 0
                let effectName = currentLamp.listOfEffects[effect]
                for (index, element) in currentLamp.selectedEffectsNameList.enumerated() {
                    if element == effectName {
                        number = index
                    }
                }
                if number + step > -1 && number + step < currentLamp.selectedEffectsNameList.count {
                    let nextEffect = currentLamp.getEffectNumber(currentLamp.selectedEffectsNameList[number + step])
                    currentLamp.effect = nextEffect
                    lamps.sendCommandToArrayOfLamps(command: .eff, value: [nextEffect])
                    lamps.necessaryToAlignTheParametersOfTheLamps = true
                }
            }
        }
    }

    @IBOutlet var leftPickerImage: UIImageView!

    @IBOutlet var rightPickerImage: UIImageView!

    @IBAction func toggleFavoriteEffects(_ sender: UIButton) {
        if !lamps.arrayOfLamps.isEmpty {
            if sender.image(for: .normal) == UIImage(named: "heart.png") {
                sender.setImage(UIImage(named: "heart2.png"), for: .normal)
                lamps.mainLamp?.useSelectedEffectOnScreen = true
                if lamps.mainLamp?.selectedEffectsNameList.count == 0 {
                    overlayPickerButtonOut.isHidden = false
                } else {
                    overlayPickerButtonOut.isHidden = true
                }

                picker.delegate = self
            } else {
                overlayPickerButtonOut.isHidden = true
                sender.setImage(UIImage(named: "heart.png"), for: .normal)
                lamps.mainLamp?.useSelectedEffectOnScreen = false
                picker.delegate = self
            }
        }
    }
    @IBOutlet var toggleFavoriteEffectsOut: UIButton!

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
        if !lamps.arrayOfLamps.isEmpty {
            lamps.mainLamp?.lampBlink()
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "lampsettings") as! LampSettingsViewController
            vc.lamp = lamps.mainLamp
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "settings", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "settings":
            _ = segue.destination as? SettingsViewController
        case "alarm":
            _ = segue.destination as? AlarmViewController
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

        case "effects":
            guard let popupViewController = segue.destination as? Empty2ViewController else { return }
            popupViewController.customBlurEffectStyle = .light
            popupViewController.customAnimationDuration = 0.5
            popupViewController.customInitialScaleAmmount = 0.5

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
                switch timer.currentState {
                case .none:
                    timer.isHidden = false
                    timer.defaultValue = currentlamp.timerTime
                    timer.mode = .countDown(fromSeconds: TimeInterval(currentlamp.timerTime))
                    timer.startCounting()
                case .fired:
                    break
                case .stopped:
                    timerOut.alpha = 0.5
                    timerLabel.alpha = 0.5
                    timerLabel.text = offTitle
                    timer.isHidden = true
                case .restarted:
                    break
                }
            } else {
                timerOut.alpha = 0.5
                timerLabel.alpha = 0.5
                timerLabel.text = offTitle
                timer.isHidden = true
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
            alarmLabel.text = onTitle
        } else {
            alarmLabel.alpha = 0.5
            alarmClockOut.alpha = 0.5
            alarmLabel.text = offTitle
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
            self.picker.delegate = self
            if currentLamp.updateSliderFlag {
                updateSlider()
            }

            if let effectNumber = currentLamp.effect {
                if currentLamp.useSelectedEffectOnScreen {
                    let newEffectNumber = currentLamp.getEffectNumberFromSelectedList(currentLamp.listOfEffects[effectNumber])
                    picker.selectRow(newEffectNumber, inComponent: 0, animated: false)
                } else {
                    picker.selectRow(effectNumber, inComponent: 0, animated: false)
                }
            }

            brightPercent.text = currentLamp.percentageOfValue(.bri)

            speedPercent.text = currentLamp.percentageOfValue(.spd)

            scalePercent.text = currentLamp.percentageOfValue(.sca)

            statusLabel.text = currentLamp.name

            if currentLamp.connectionStatus { // проверка доступа к лампе
                removeOffView()
                statusLabel.textColor = blackColor
                if currentLamp.useSelectedEffectOnScreen {
                    toggleFavoriteEffectsOut.setImage(UIImage(named: "heart2.png"), for: .normal)
                } else {
                    toggleFavoriteEffectsOut.setImage(UIImage(named: "heart.png"), for: .normal)
                }
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
                    errorMessage.setTitle(lampOff, for: .normal)
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
                    self.errorMessage.setTitle(lampIsNotConnected, for: .normal)
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
                    if let effectNumber = currentLamp.effect {
                        picker.selectRow(effectNumber, inComponent: 0, animated: false)
                    }
                    updateSlider()
                    UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: { [self] in
                        self.errorMessageHeight.constant = 24
                        self.errorMessage.setTitle(autoSwitch, for: .normal)
                    })
                }
            }

        } else {
            errorMessage.isUserInteractionEnabled = false
            statusLabel.text = colorLamp
            statusLabel.textColor = .gray
            UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: { [self] in
                errorMessageHeight.constant = 24
                self.errorMessage.setTitle(lampIsNotConnected, for: .normal)
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
            if let maxSpeed = lamps.mainLamp?.getMaxSpeed(lamps.mainLamp?.effect ?? 0) {
                speedSlider.maximum = Float(maxSpeed)
            }
            if let minSpeed = lamps.mainLamp?.getMinSpeed(lamps.mainLamp?.effect ?? 0) {
                speedSlider.minimum = Float(minSpeed)
            }
            speedSlider.setValue(Float(speed), animated: false)
        }
        if let scale = lamps.mainLamp?.scale {
            if let maxScale = lamps.mainLamp?.getMaxScale(lamps.mainLamp?.effect ?? 0) {
                scaleSlider.maximum = Float(maxScale)
            }
            if let minScale = lamps.mainLamp?.getMinScale(lamps.mainLamp?.effect ?? 0) {
                scaleSlider.minimum = Float(minScale)
            }
            scaleSlider.setValue(Float(scale), animated: false)
        }
        lamps.mainLamp?.updateSliderFlag = false
    }

    override func viewWillAppear(_ animated: Bool) {
        self.picker.delegate = self
        if lamps.mainLamp?.connectionStatus ?? false { // проверка соединения с лампой
            if lamps.mainLamp?.powerStatus == true { // проверка включена лампа или нет
                leftPickerImage.shake(toward: .top, amount: 0.1, duration: 1, delay: 0.5)
                rightPickerImage.shake(toward: .top, amount: 0.1, duration: 1, delay: 0.5)
            }
        }
        lamps.mainLamp?.updateSliderFlag = true
        if lamps.mainLamp?.selectedEffectsNameList.count == 0 {
            overlayPickerButtonOut.isHidden = false
        } else {
            overlayPickerButtonOut.isHidden = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if (lamps.isListEmpty || !lamps.connectionStatusOfMainLamp) && isFirstLaunch {
            performSegue(withIdentifier: "searchAndAdd2", sender: nil)
        } else {
            if lamps.isListEmpty {
                performSegue(withIdentifier: "settings", sender: nil)
            }
        }
        isFirstLaunch = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addOffView()
        errorMessage.layer.zPosition = 2
        leftPickerButtonInteractionOut.layer.zPosition = 2
        rightPickerButtonInteractionOut.layer.zPosition = 2
        statusLabel.adjustsFontSizeToFitWidth = true
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
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
        if let currentLamp = lamps.mainLamp {
            if currentLamp.useSelectedEffectOnScreen {
                toggleFavoriteEffectsOut.setImage(UIImage(named: "heart2.png"), for: .normal)
            } else {
                toggleFavoriteEffectsOut.setImage(UIImage(named: "heart.png"), for: .normal)
            }
        }
        timer.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        timer.textColor = violetColor
        DispatchQueue.main.async {
            let systemLang = Locale.current.languageCode
            if let storedLocale = UserDefaults.standard.string(forKey: "storedLocale") {
                if storedLocale != systemLang {
                    let alert = UIAlertController(title: systemLangWasChange, message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "English", style: .default, handler: { _ in
                        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
                        UserDefaults.standard.synchronize()
                        self.showAlertAboutNeedToRestart()
                    }))
                    alert.addAction(UIAlertAction(title: "Русский", style: .default, handler: { _ in
                        UserDefaults.standard.set(["ru"], forKey: "AppleLanguages")
                        UserDefaults.standard.synchronize()
                        self.showAlertAboutNeedToRestart()
                    }))
                    alert.addAction(UIAlertAction(title: "Український", style: .default, handler: { _ in
                        UserDefaults.standard.set(["uk"], forKey: "AppleLanguages")
                        UserDefaults.standard.synchronize()
                        self.showAlertAboutNeedToRestart()
                    }))
                    alert.addAction(UIAlertAction(title: closePopUp, style: .default, handler: { _ in

                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    @objc private func appMovedToForeground() {
        lamps.mainLamp?.updateSliderFlag = true
        print("App moved to ForeGround!")
    }

    override func viewDidLayoutSubviews() {
        let systemLang = Locale.current.languageCode
        UserDefaults.standard.set(systemLang, forKey: "storedLocale")
        brightnessSlider.addImage(image: UIImage(named: "brightness.png")!, frame: CGRect(x: 22, y: brightnessSlider.frame.height - 60, width: 26, height: 26))
        speedSlider.addImage(image: UIImage(named: "speed.png")!, frame: CGRect(x: 19, y: brightnessSlider.frame.height - 60, width: 32, height: 18))
        scaleSlider.addImage(image: UIImage(named: "scale.png")!, frame: CGRect(x: 25, y: brightnessSlider.frame.height - 60, width: 20, height: 20))
    }
}
