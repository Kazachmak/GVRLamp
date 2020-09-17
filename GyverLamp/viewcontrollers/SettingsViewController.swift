//
//  SettingsViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 18.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import Network
import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MMLANScannerDelegate {
    var lanScanner: MMLANScanner! // сканер устройств в локальной сети

    let activityView = UIActivityIndicatorView(style: .gray) // индикатор поиска ламп

    // когда найдено новое устройство, проверяется лампа ли это
    func lanScanDidFindNewDevice(_ device: MMDevice!) {
        LampDevice.scan(deviceIp: String(device.ipAddress))
    }

    // выключаем индикатор активности после завершения поиска
    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
        activityView.stopAnimating()
    }

    func lanScanDidFailedToScan() {
        activityView.stopAnimating()
        print("Failed to scan")
    }

    var lamp: LampDevice?
    var selectedRow: Int? // это номер выбранной лампы в списке

    var listOfLamps: [String] = [] {
        didSet {
            UserDefaults.standard.set(listOfLamps, forKey: "listOfLamps") // читаем из памяти список ламп
        }
    }

    @IBOutlet var tableView: UITableView!

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activityView.stopAnimating()
        selectedRow = indexPath.row
        _ = LampDevice(hostIP: NWEndpoint.Host((listOfLamps[indexPath.row].components(separatedBy: ":"))[0]), hostPort: NWEndpoint.Port((listOfLamps[indexPath.row].components(separatedBy: ":"))[1]) ?? 8888) // при нажатии на лампу выбираем её основной
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfLamps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "lampCell", for: indexPath) as! LampsTableViewCell
        cell.lampLabel.text = listOfLamps[indexPath.row]
        if let row = selectedRow {
            if indexPath.row == row {
                cell.layer.borderColor = UIColor.green.cgColor // нажатая лампа подсвечена зеленым
                cell.layer.borderWidth = 4
                cell.layer.cornerRadius = 20
            } else {
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.layer.borderWidth = 0
            }
        }
        if let currentLamp = lamp {
            if cell.lampLabel.text == "\(currentLamp.hostIP ?? "0.0.0.0")" + ":" + "\(currentLamp.hostPort ?? 8888)" {
                cell.lampLabel.textColor = .red // текущая лампа подсвечена красным

            } else {
                cell.lampLabel.textColor = .black
            }
        }

        return cell
    }

    // функция добавления новой лампы
    @IBAction func addButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Добавьте лампу", message: "Введите адрес и порт", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Введите IP-адрес"
        }

        alert.addTextField { textField in
            textField.placeholder = "Введите порт"
        }

        alert.addAction(UIAlertAction(title: "Добавить", style: .default, handler: { [weak alert] _ in
            if let textField = alert?.textFields?[0], let hostIP = textField.text {
                if let textField = alert?.textFields?[1], let hostPort = textField.text {
                    if hostIP.isValidIP() && hostPort.isValidPort() {
                        _ = LampDevice(hostIP: NWEndpoint.Host(hostIP), hostPort: NWEndpoint.Port(hostPort) ?? 8888)
                    }
                }
            }

        }))
        alert.addAction(UIAlertAction(title: "Отменить", style: .default, handler: { [weak alert] _ in

        }))

        present(alert, animated: true, completion: nil)
    }

    @IBOutlet var addButtonOut: UIButton!

    @IBOutlet var closeButtonOut: UIButton!

    // удаление лампы из списка
    @IBAction func removeButton(_ sender: UIButton) {
        if let row = selectedRow {
            listOfLamps.remove(at: row)
        }
        tableView.reloadData()
        lamp = nil
        NotificationCenter.default.post(name: Notification.Name("deleteLamp"), object: lamp)
    }

    @IBOutlet var removeButtonOut: UIButton!

    // добавляем лампу, если она доступна и её ещё нет в списке
    @objc func updateLamp(notification: Notification?) {
        guard let newLamp = notification?.object as? LampDevice else { return }
        if !listOfLamps.contains("\(newLamp.hostIP ?? "0.0.0.0")" + ":" + "\(newLamp.hostPort ?? 8888)") {
            listOfLamps.append("\(newLamp.hostIP ?? "0.0.0.0")" + ":" + "\(newLamp.hostPort ?? 8888)")
            lamp = newLamp
        }
        tableView.reloadData()
    }

    // запускаем поиск ламп в локальной сети
    @IBAction func scan(_ sender: UIButton) {
        lanScanner.start()
        activityView.center = view.center
        activityView.startAnimating()
        activityView.hidesWhenStopped = true
        view.addSubview(activityView)
    }

    @IBOutlet var scanOut: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        lanScanner = MMLANScanner(delegate: self)
        removeButtonOut.addBoxShadow()
        addButtonOut.addBoxShadow()
        scanOut.addBoxShadow()
        // читаем из памяти список сохранненых ламп
        if let listOfLampTemp = UserDefaults.standard.array(forKey: "listOfLamps") {
            listOfLamps = listOfLampTemp as! [String]
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updateLamp), name: Notification.Name("updateLamp"), object: nil)
    }
}
