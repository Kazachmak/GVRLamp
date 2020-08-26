//
//  SettingsViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 18.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import Network
import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var lamp: LampDevice?
    var selectedRow: Int?

    var listOfLamps: [String] = [] {
        didSet {
            UserDefaults.standard.set(listOfLamps, forKey: "listOfLamps")
        }
    }

    @IBOutlet var tableView: UITableView!

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        _ = LampDevice(hostIP: NWEndpoint.Host((listOfLamps[indexPath.row].components(separatedBy: ":"))[0]), hostPort: NWEndpoint.Port((listOfLamps[indexPath.row].components(separatedBy: ":"))[1]) ?? 8888)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfLamps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "lampCell", for: indexPath) as! LampsTableViewCell
        cell.lampLabel.text = listOfLamps[indexPath.row]
        if let row = selectedRow {
            if indexPath.row == row {
                cell.layer.borderColor = UIColor.green.cgColor
                cell.layer.borderWidth = 4
                cell.layer.cornerRadius = 20
            } else {
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.layer.borderWidth = 0
            }
        }
        if let currentLamp = lamp {
            if cell.lampLabel.text == "\(currentLamp.hostIP ?? "0.0.0.0")" + ":" + "\(currentLamp.hostPort ?? 8888)" {
                cell.lampLabel.textColor = .red

            } else {
                cell.lampLabel.textColor = .black
            }
        }

        return cell
    }

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
                        //
                    }
                }
            }

        }))
        alert.addAction(UIAlertAction(title: "Отменить", style: .default, handler: { [weak alert] _ in

        }))

        present(alert, animated: true, completion: nil)
    }

    @IBOutlet var addButtonOut: UIButton!

    @IBAction func closeButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBOutlet var closeButtonOut: UIButton!

    @IBAction func removeButton(_ sender: UIButton) {
        if let row = selectedRow{
        listOfLamps.remove(at: row)
        }
        tableView.reloadData()
    }

    @IBOutlet var removeButtonOut: UIButton!

    @objc func updateLamp(notification: Notification?) {
        guard let newLamp = notification?.object as? LampDevice else { return }
        if !listOfLamps.contains("\(newLamp.hostIP ?? "0.0.0.0")" + ":" + "\(newLamp.hostPort ?? 8888)") {
            listOfLamps.append("\(newLamp.hostIP ?? "0.0.0.0")" + ":" + "\(newLamp.hostPort ?? 8888)")
        }
        tableView.reloadData()
    }

    @IBAction func scan(_ sender: UIButton) {
        LampDevice.scan()
    }

    @IBOutlet var scanOut: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        closeButtonOut.addBoxShadow()
        removeButtonOut.addBoxShadow()
        addButtonOut.addBoxShadow()
        scanOut.addBoxShadow()
        if let listOfLampTemp = UserDefaults.standard.array(forKey: "listOfLamps") {
            listOfLamps = listOfLampTemp as! [String]
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updateLamp), name: Notification.Name("updateLamp"), object: nil)
    }
}
