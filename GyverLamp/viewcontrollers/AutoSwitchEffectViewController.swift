//
//  AutoSwitchEffectViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 28.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit

class AutoSwitchEffectViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
   
    var lamp: LampDevice?
    var selectedEffects: [Int] = []
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfEffects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "autoswitch", for: indexPath) as! AutoSwitchEffectCollectionViewCell
        cell.label.text = listOfEffects[indexPath.row]
        cell.addBoxShadow()
        if selectedEffects.contains(indexPath.row){
            cell.layer.backgroundColor = UIColor.orange.cgColor
        }else{
            cell.layer.backgroundColor = UIColor.white.cgColor
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 200, height: 100)

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           print("Test")
        if !selectedEffects.contains(indexPath.row){
            selectedEffects.append(indexPath.row)
        }else{
            selectedEffects = selectedEffects.filter(){$0 != indexPath.row}
        }

           collectionView.reloadData()
       }

    
    @IBOutlet weak var intervalOut: UIButton!
    
    
    @IBAction func interval(_ sender: UIButton) {
    }
    
    
    @IBAction func randomTime(_ sender: UIButton) {
    }
    
    
    @IBOutlet weak var randomTimeOut: UIButton!
    
    
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var closeOut: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeOut.addBoxShadow()
        intervalOut.addBoxShadow()
        randomTimeOut.addBoxShadow()
    }
    

   

}
