//
//  SliderFullScreenViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 28.11.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import TactileSlider
import UIKit

class SliderFullScreenViewController: UIViewController {
    var lamp: LampDevice?

    var command: CommandsToLamp?

    @IBOutlet var icon: UIImageView!

    @IBOutlet var valueLabel: UILabel!

    @IBOutlet var percentageLabel: UILabel!

    @IBOutlet var slider: TactileSlider!

    @IBAction func minusButton(_ sender: UIButton) {
        if let currentLamp = lamp, let commandToSend = command {
            if slider.value > 0 {
            switch commandToSend {
            case .bri: currentLamp.sendCommand(lamp: currentLamp, command: commandToSend, value: [Int(slider.value) - 1])
            case .spd: currentLamp.sendCommand(lamp: currentLamp, command: commandToSend, value: [Int(slider.value) - 1])
            case .sca: currentLamp.sendCommand(lamp: currentLamp, command: commandToSend, value: [Int(slider.value) - 1])
            default: break
            }
            slider.setValue(slider.value - 1, animated: true)
            }
        }
    }

    @IBAction func plusButton(_ sender: UIButton) {
        if let currentLamp = lamp, let commandToSend = command {
            if slider.value < 255{
                switch commandToSend {
                case .bri: currentLamp.sendCommand(lamp: currentLamp, command: commandToSend, value: [Int(slider.value) + 1])
                case .spd: currentLamp.sendCommand(lamp: currentLamp, command: commandToSend, value: [Int(slider.value) + 1])
                case .sca: currentLamp.sendCommand(lamp: currentLamp, command: commandToSend, value: [Int(slider.value) + 1])
                default: break
                }
                slider.setValue(slider.value + 1, animated: true)
            }
        }
    }

    @IBAction func dismissTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    
    
    @IBAction func valueChange(_ sender: TactileSlider) {
        if let currentLamp = lamp, let commandToSend = command {
            currentLamp.sendCommand(lamp: currentLamp, command: commandToSend, value: [Int(sender.value)])
            currentLamp.updateSliderFlag = true
        }
    }

    private func selectDataFromLamp(command: CommandsToLamp) -> Int? {
        var returnValue: Int?
        if let currentLamp = lamp {
            switch command {
            case .bri:
                if let value = currentLamp.bright {
                    returnValue = value
                }
            case .spd:
                if let value = currentLamp.speed {
                    returnValue = value
                }
            case .sca:
                if let value = currentLamp.scale {
                    returnValue = value
                }
            default: break
            }
        }
        return returnValue
    }

    @objc func updateInterface() {
        if let value = selectDataFromLamp(command: command!) {
            valueLabel.text = String(value)
            percentageLabel.text = String(value * 100 / 255) + "%"
            
        }
        if let currentCommand = command {
            switch currentCommand {
            case .bri: icon.image = UIImage(named: "brightness_big.png")
            case .spd: icon.image = UIImage(named: "speed_big.png")
            case .sca: icon.image = UIImage(named: "scale_big.png")
            default: break
            }
        }
    }

    func setLamp(lamp: LampDevice, command: CommandsToLamp) {
        self.lamp = lamp
        self.command = command
        if let value = selectDataFromLamp(command: command) {
            slider.setValue(Float(value), animated: false)
        }
        updateInterface()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateInterface), name: Notification.Name("updateInterface"), object: nil)
    }
}
