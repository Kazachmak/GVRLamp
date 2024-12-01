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

    var timer: Timer?

    @IBOutlet var icon: UIImageView!

    @IBOutlet var valueLabel: UILabel!

    @IBOutlet var percentageLabel: UILabel!

    @IBOutlet var slider: TactileSlider!

    // однократное нажатие на кнопку минус
    @IBAction func minusButton(_ sender: UIButton) {
        if let currentLamp = lamp, let commandToSend = command {
            if slider.value > 0 {
                sendNewValueWhenButtonPressed(-1, lamp: currentLamp, command: commandToSend)
            }
        }
    }

    // долгое нажатие на кнопку минус
    @IBAction func minusButtonLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [self] _ in
                if let currentLamp = lamp, let commandToSend = command {
                    if slider.value > 0 {
                        self.sendNewValueWhenButtonPressed(-1, lamp: currentLamp, command: commandToSend)
                    }
                }
            })
        } else if sender.state == .ended || sender.state == .cancelled {
            print("FINISHED UP LONG PRESS")
            timer?.invalidate()
            timer = nil
        }
    }

    // однократное нажатие на кнопку плюс
    @IBAction func plusButton(_ sender: UIButton) {
        if let currentLamp = lamp, let commandToSend = command {
            if slider.value < 255 {
                sendNewValueWhenButtonPressed(+1, lamp: currentLamp, command: commandToSend)
            }
        }
    }

    // долгое нажатие на кнопку плюс
    @IBAction func plusButtonLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [self] _ in
                if let currentLamp = lamp, let commandToSend = command {
                    if slider.value < 255 {
                        self.sendNewValueWhenButtonPressed(+1, lamp: currentLamp, command: commandToSend)
                    }
                }

            })
        } else if sender.state == .ended || sender.state == .cancelled {
            print("FINISHED UP LONG PRESS")
            timer?.invalidate()
            timer = nil
        }
    }

    // отправка нового значения в лампу
    private func sendNewValueWhenButtonPressed(_ value: Int, lamp: LampDevice, command: CommandsToLamp) {
        lamps.sendCommandToArrayOfLamps(command: command, value: [Int(slider.value) + value])
        slider.setValue(slider.value + Float(value), animated: true)
    }

    // закрыть экран
    @IBAction func dismissTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    // передача значений при движении ползунком
    @IBAction func valueChange(_ sender: TactileSlider) {
        if let currentLamp = lamp, let commandToSend = command {
            lamps.sendCommandToArrayOfLamps(command: commandToSend, value: [Int(sender.value)])
            currentLamp.updateSliderFlag = true
        }
    }

    // извлекаем информацию из объекта "лампа"
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

    // обновление интерфейса
    @objc func updateInterface() {
        if let value = selectDataFromLamp(command: command!), let currentLamp = lamp {
            valueLabel.text = String(value)

            switch command {
            case .spd:
                percentageLabel.text = currentLamp.percentageOfValue(.spd) + "%"
            case .sca:
                percentageLabel.text = currentLamp.percentageOfValue(.sca) + "%"
            case .bri:
                percentageLabel.text = currentLamp.percentageOfValue(.bri) + "%"
            default: break
            }

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

    // устанавливаем ползунок в начальное значение
    func setLamp(lamp: LampDevice, command: CommandsToLamp) {
        self.lamp = lamp
        self.command = command
        switch command {
        case .spd:
            let maxSpeed = lamp.getMaxSpeed(lamp.effect ?? 0)
            slider.maximum = Float(maxSpeed)
            let minSpeed = lamp.getMinSpeed(lamp.effect ?? 0)
            slider.minimum = Float(minSpeed)
        case .sca:
            let maxScale = lamp.getMaxScale(lamp.effect ?? 0)
            slider.maximum = Float(maxScale)
            let minScale = lamp.getMinScale(lamp.effect ?? 0)
            slider.minimum = Float(minScale)
        default:
            break
        }

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
