//
//  AutoSwitchEffectViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 28.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit

class AutoSwitchEffectViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 360
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if senderTag == 1 {
            intervalSec = row
            intervalOut.setTitle("Интервал смены эффектов " + "\(intervalSec)" + " сек", for: .normal)
        } else {
            randomSec = row
            randomTimeOut.setTitle("+ случайное время от 0 до " + "\(randomSec)" + " сек", for: .normal)
        }
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }

    var toolBar = UIToolbar()
    var picker = UIPickerView()

    var lamp: LampDevice?
    var selectedEffects = [Bool](repeating: false, count: 26)
    var intervalSec = 0
    var randomSec = 0
    var senderTag = 0

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfEffects.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "autoswitch", for: indexPath) as! AutoSwitchEffectCollectionViewCell
        cell.label.text = listOfEffects[indexPath.row]
        cell.addBoxShadow()
        if selectedEffects[indexPath.row] {
            cell.layer.backgroundColor = UIColor.orange.cgColor
        } else {
            cell.layer.backgroundColor = UIColor.white.cgColor
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !selectedEffects[indexPath.row] {
            selectedEffects[indexPath.row] = true
        } else {
            selectedEffects[indexPath.row] = false
        }

        collectionView.reloadData()
    }

    @IBOutlet var intervalOut: UIButton!

    func openPickerView() {
        picker = UIPickerView()
        picker.delegate = self
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        view.addSubview(picker)

        toolBar = UIToolbar(frame: CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        view.addSubview(toolBar)
    }

    @IBAction func interval(_ sender: UIButton) {
        senderTag = sender.tag
        openPickerView()
    }

    @objc func onDoneButtonTapped() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }

    @IBAction func randomTime(_ sender: UIButton) {
        senderTag = sender.tag
        openPickerView()
    }

    @IBOutlet var randomTimeOut: UIButton!

    @IBOutlet var favOnOut: UISwitch!

    @IBAction func favOn(_ sender: UISwitch) {
        if let currentLamp = lamp {
            var array = [favOnOut.isOn.convertToInt(), intervalSec, randomSec, favAlwaysOnOut.isOn.convertToInt()]
            array.append(contentsOf: selectedEffects.convertToIntArray())
            currentLamp.sendCommand(lamp: currentLamp, command: .fav_set, value: array)
        }
    }

    @IBOutlet var favAlwaysOnOut: UISwitch!

    @IBAction func favAlwaysOn(_ sender: UISwitch) {
        if let currentLamp = lamp {
            var array = [1, intervalSec, randomSec, favAlwaysOnOut.isOn.convertToInt()]
            array.append(contentsOf: selectedEffects.convertToIntArray())
            currentLamp.sendCommand(lamp: currentLamp, command: .fav_set, value: array)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        picker.dataSource = self
        intervalOut.addBoxShadow()
        randomTimeOut.addBoxShadow()
        intervalOut.titleLabel?.adjustsFontSizeToFitWidth = true
        randomTimeOut.titleLabel?.adjustsFontSizeToFitWidth = true
        if let currentLamp = lamp {
            if currentLamp.favorite?.components(separatedBy: " ")[1] == "1" {
                favOnOut.setOn(true, animated: false)
            }
            if currentLamp.favorite?.components(separatedBy: " ")[4] == "1" {
                favAlwaysOnOut.setOn(true, animated: false)
            }
            if let intervalSec = currentLamp.favorite?.components(separatedBy: " ")[2] {
                intervalOut.setTitle("Интервал смены эффектов " + "\(intervalSec)" + " сек", for: .normal)
            }
            if let randomSec = currentLamp.favorite?.components(separatedBy: " ")[3] {
                randomTimeOut.setTitle("+ случайное время от 0 до " + "\(randomSec)" + " сек", for: .normal)
            }

            if let arrayOfSelectedEffect = currentLamp.favorite?.components(separatedBy: " ")[4 ... 25] {
                for (index, element) in arrayOfSelectedEffect.enumerated() {
                    if element == "1" {
                        selectedEffects[index] = true
                    }
                }
            }
        }
    }
}
