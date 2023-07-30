//
//  GameManager.swift
//  aDrift
//
//  Created by Izdar Tohti on 7/30/23.
//

import Foundation
import CoreData

class GameManager : ObservableObject{
    let userDefaults = UserDefaults.standard
    @Published var playerInventory = [String: Int]()
    @Published var housing = 0
    @Published var population = 0
    @Published var logs = [String]()
    var isModified = true
    
    
    var costOfHouse : Int{
        return 30 + pow(x: 2, y : housing)
    }
    var totalPopulation : Int {
        return housing * 4
    }
    
    func pow(x : Int, y : Int) -> Int{
        // pow function for me
        var output = x
        var i = 0
        if (y == 0){
            return 1
        }
        while (i < y - 1){
            output *= x
            i += 1
        }
        return output
    }
    
    init(){
        load()
    }
    
    func save(){
        userDefaults.set(playerInventory, forKey: "playerInventory")
        userDefaults.set(housing, forKey: "housing")
        userDefaults.set(population, forKey: "population")
        userDefaults.set(logs, forKey: "logs")
        isModified = true
    }
    
    func load(){
        if (isModified){
            playerInventory = userDefaults.object(forKey: "playerInventory") as? [String: Int] ?? [:]
            housing = userDefaults.object(forKey: "housing") as? Int ?? 0
            population = userDefaults.object(forKey: "population") as? Int ?? 0
            logs = userDefaults.object(forKey: "logs") as? [String] ?? []
            isModified = false
        }
    }
    
    func reset(){
        userDefaults.removeObject(forKey: "playerInventory")
        userDefaults.removeObject(forKey: "housing")
        userDefaults.removeObject(forKey: "population")
        userDefaults.removeObject(forKey: "logs")
        playerInventory = [String: Int]()
        housing = 0
        population = 0
        logs = [String]()
    }
    
    func addLog(message: String){
        // this function adds a message into the logs
        logs.append(message)
        save()
    }
    
    func addHousing(showHousingAlert : inout Bool){
        // adds housing if player has enough resources
        if (playerInventory["wood"] ?? 0 >= costOfHouse){
            playerInventory["wood"] = (playerInventory["wood"] ?? 0) - costOfHouse
            housing += 1
            save()
        }
        else{
            showHousingAlert = true
        }
    }
    
    func fillHouse(){
        var group = Int.random(in: 1..<4)
        // Each housing can house 4 people.
        // first check to see if there is free space. To see get the number of housing multiply it by 4. if current pop is less than that number there is free space.
        if (population < totalPopulation){
            let chance = Int.random(in: 0..<10)
            // 1/5 chance to fill a house with 1-4 people
            if (chance == 1){
                if (population + group > totalPopulation){
                    group = totalPopulation - population
                    addLog(message: group > 1 ? "\(group) survivors move in" : "\(group) person moved in")
                    population += group
                    save()
                }
                else{
                    addLog(message: group > 1 ? "\(group) survivors move in" : "\(group) person moved in")
                    population += group
                    save()
                }
            }
        }
    }

}
