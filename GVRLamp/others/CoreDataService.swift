//
//  CoreDataService.swift
//  Slwatch
//
//  Created by Максим Казачков on 27.05.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import CoreData
import Foundation
import UIKit
import  Network

class CoreDataService {

    class func fetchLamps() -> [NSManagedObject] {
        var allLamps: [NSManagedObject] = []

        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return allLamps
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Lamp")
        do {
            allLamps = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return allLamps
    }

    class func deleteAllData() {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Lamp")
        fetchRequest.returnsObjectsAsFaults = false

        do {
            let arrUsrObj = try managedContext.fetch(fetchRequest)
            for usrObj in arrUsrObj as! [NSManagedObject] {
                managedContext.delete(usrObj)
            }
            try managedContext.save() // don't forget
        } catch let error as NSError {
            print("delete fail--", error)
        }

    }

    class func save() {
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext =
            appDelegate.persistentContainer.viewContext

        for (index, element) in lamps.arrayOfLamps.enumerated() {
            let entity =
                NSEntityDescription.entity(forEntityName: "Lamp",
                                           in: managedContext)!

            let newLamp = NSManagedObject(entity: entity,
                                          insertInto: managedContext)
            if index == lamps.mainLampIndex {
                newLamp.setValue(true, forKeyPath: "mainLamp")
            } else {
                newLamp.setValue(false, forKey: "mainLamp")
            }

            newLamp.setValue(element.name, forKeyPath: "name")
            newLamp.setValue("\(element.hostIP)", forKey: "ip")
            newLamp.setValue("\(element.hostPort)", forKey: "port")
            newLamp.setValue(element.effectsFromLamp, forKey: "flagEffects")
            newLamp.setValue(element.listOfEffects.joined(separator: ";"), forKey: "listOfEffects")
            newLamp.setValue(element.flagLampIsControlled, forKey: "flagLampIsControlled")
            newLamp.setValue(element.useSelectedEffectOnScreen, forKey: "useSelectedEffectOnScreen")
            newLamp.setValue(element.doNotForgetTheLampWhenTheConnectionIsLost, forKey: "doNotForgetTheLampWhenTheConnectionIsLost")
            do {
                try managedContext.save()

            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")

            }
        }

    }

}
