//
//  EffectTableViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 21.05.2021.
//  Copyright © 2021 Maksim Kazachkov. All rights reserved.
//

import UIKit

class EffectTableViewController: UITableViewController {

    // MARK: - Table view data source

    override func viewWillAppear(_ animated: Bool) {
        
        if let currentLamp = lamps.mainLamp{
            
            if currentLamp.useSelectedEffectOnScreen{
                let row = IndexPath(row: currentLamp.getEffectNumberFromSelectedList(currentLamp.listOfEffects[currentLamp.effect ?? 0]), section: 0)
                if currentLamp.listOfEffects.count > row.row{
                    self.tableView.scrollToRow(at: row, at: .middle , animated: true)
                }
            }else{
                let row = IndexPath(row: currentLamp.effect ?? 0, section: 0)
                if currentLamp.listOfEffects.count > row.row{
                    self.tableView.scrollToRow(at: row, at: .middle , animated: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lamps.mainLamp?.selectedEffectsNameList.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "effectCell", for: indexPath)
        cell.textLabel?.text = lamps.mainLamp?.getEffectName(indexPath.row)//selectedEffectsNameList[indexPath.row].components(separatedBy: ",")[0].incrementNumber
        if let effectNumber = lamps.mainLamp?.effect {
            if effectNumber == indexPath.row{
                cell.textLabel?.textColor = redColor
            }else{
                cell.textLabel?.textColor = .black
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentLamp = lamps.mainLamp {
            currentLamp.effect = indexPath.row
            currentLamp.updateSliderFlag = true
            lamps.sendCommandToArrayOfLamps(command: .eff, value: [currentLamp.getEffectNumber(currentLamp.selectedEffectsNameList[indexPath.row])])
            lamps.necessaryToAlignTheParametersOfTheLamps = true
        }
        dismiss(animated: true, completion: nil)
    }
    
}
