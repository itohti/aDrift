//
//  GameManager.swift
//  aDrift
//
//  Created by Izdar Tohti on 7/30/23.
//

import Foundation
import CoreData
// manages the game data and provides actions for the player to do.
class GameManager : ObservableObject{
    let userDefaults = UserDefaults.standard
    @Published var playerInventory = [String: Int]()
    @Published var housing = 0
    @Published var population = 0
    @Published var logs = [String]()
    @Published var workers = [String: Int]()
    @Published var playerEquip = [Equipable]()
    var isModified = true
    
    
    var costOfHouse : Int{
        return 29 + pow(x: 2, y: housing)
    }
    var totalPopulation : Int{
        return housing * 4
    }
    var availableWorkers : Int{
        var working = 0
        for worker in Array(workers.keys){
            working += workers[worker] ?? 0
        }
        
        return population - working
    }
    
    init(){
        load()
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
    
    // saves the game
    func save(){
        userDefaults.set(playerInventory, forKey: "playerInventory")
        userDefaults.set(housing, forKey: "housing")
        userDefaults.set(population, forKey: "population")
        userDefaults.set(logs, forKey: "logs")
        userDefaults.set(workers, forKey: "workers")
        userDefaults.set(playerEquip, forKey: "playerEquip")
        isModified = true
    }
    
    // loads the game
    func load(){
        if (isModified){
            playerInventory = userDefaults.object(forKey: "playerInventory") as? [String: Int] ?? [:]
            housing = userDefaults.object(forKey: "housing") as? Int ?? 0
            population = userDefaults.object(forKey: "population") as? Int ?? 0
            logs = userDefaults.object(forKey: "logs") as? [String] ?? []
            workers = userDefaults.object(forKey: "workers") as? [String: Int] ?? [:]
            playerEquip = userDefaults.object(forKey: "playerEquip") as? [Equipable] ?? []
            isModified = false
        }
    }
    
    // resets the game
    func reset(){
        userDefaults.removeObject(forKey: "playerInventory")
        userDefaults.removeObject(forKey: "housing")
        userDefaults.removeObject(forKey: "population")
        userDefaults.removeObject(forKey: "logs")
        userDefaults.removeObject(forKey: "workers")
        userDefaults.removeObject(forKey: "playerEquip")
        playerInventory = [String: Int]()
        housing = 0
        population = 0
        logs = [String]()
        workers = [String: Int]()
        playerEquip = [Equipable]()
    }
    
    // gets the worker with the key value
    func getWorker(worker: String) -> Int{
        return workers[worker] ?? 0
    }
    
    // this function gets you huge
    // calculates all the gains from each worker and updates playerInventory
    func trade(){
        let listOfProfessions = getListOfProfessions()
        var listOfCosts = [String: Int]()
        var listOfGains = [String: Int]()
        for worker in Array(workers.keys){
            for profession in listOfProfessions{
                if (worker == profession.getName()){
                    let costs = profession.getCosts()
                    let gains = profession.getGains()
                    let quantity = workers[worker] ?? 0
                    var passed = 0
                    while(passed < quantity){
                        var pass = true
                        for cost in Array(costs.keys){
                            if ((playerInventory[cost] ?? 0) < (costs[cost] ?? 0)){
                                pass = false
                            }
                        }
                        if (!pass){
                            break
                        }
                        passed += 1
                    }
                    
                    for cost in Array(costs.keys){
                        playerInventory[cost] = (playerInventory[cost] ?? 0) - (costs[cost] ?? 0) * passed
                        listOfCosts[cost] = (costs[cost] ?? 0) * passed
                    }
                    for gain in Array(gains.keys){
                        playerInventory[gain] = (playerInventory[gain] ?? 0) + (gains[gain] ?? 0) * passed
                        listOfGains[gain] = (gains[gain] ?? 0) * passed
                    }
                }
            }
        }
        var gainOutput = "gained: "
        for (key, value) in listOfGains{
            if ((value - (listOfCosts[key] ?? 0)) > 0){
                gainOutput += key + ": \(value - (listOfCosts[key] ?? 0)) "
            }
        }
        if (gainOutput != "gained: "){
            addLog(message: gainOutput)
        }
    }
    
    func getCosts(worker: String) -> String{
        var output = ""
        let listOfProfessions = getListOfProfessions()
        for profession in listOfProfessions{
            if (worker == profession.getName()){
                let costs = profession.getCosts()
                let keys = costs.keys.sorted()
                for key in keys{
                    output = output + key + ": \((costs[key] ?? 0) * (workers[worker] ?? 0)) "
                }
                return output
            }
        }
        return output
    }
    
    func getGains(worker: String) -> String{
        var output = ""
        let listOfProfessions = getListOfProfessions()
        for profession in listOfProfessions{
            if (worker == profession.getName()){
                let gains = profession.getGains()
                let keys = gains.keys.sorted()
                for key in keys{
                    output = output + key + ": \((gains[key] ?? 0) * (workers[worker] ?? 0)) "
                }
                return output
            }
        }
        return output
    }
    
    // gets the list of professions
    func getListOfProfessions() -> Array<any Worker>{
        return [Hunter(), Woodcutter()]
    }
    
    func incrementWorker(worker: String){
        workers[worker] = (workers[worker] ?? 0) + 1
    }
    
    func decrementWorker(worker: String){
        workers[worker] = (workers[worker] ?? 0) - 1
    }
    
    // adds a message into the logs
    func addLog(message: String){
        logs.append(message)
        save()
    }
    
    // adds housing if player has enough resources
    func addHousing(showHousingAlert : inout Bool){
        if (playerInventory["wood"] ?? 0 >= costOfHouse){
            playerInventory["wood"] = (playerInventory["wood"] ?? 0) - costOfHouse
            housing += 1
            if (housing == 1){
                workers["hunter"] = 0
                workers["woodcutter"] = 0
                
                addLog(message: "people will notice the fire. they will come to seek shelter but they need to work for it.")
            }
            save()
        }
        else{
            showHousingAlert = true
        }
    }
    
    // fills any available space for people to move in
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
    
    func getListOfWeapons() -> [Weapon]{
        var weapons = [Weapon]()
        do{
            if let bundlePath = Bundle.main.path(forResource: "items", ofType: "json"){
                if let itemData = try String(contentsOfFile: bundlePath).data(using: .utf8){
                    if let json = try JSONSerialization.jsonObject(with: itemData, options: .mutableLeaves) as? [[String: Any]] {
                        for item in json{
                            if ((item["type"] as? String) == "Weapon"){
                                weapons.append(Weapon(durability: item["durability"] as? Int ?? 0, damage: item["damage"] as? Int ?? 0, cost: item["cost"] as? [String:Int] ?? [:], name: item["name"] as? String ?? ""))
                            }
                        }
                    }
                    else{
                        print(":(")
                    }
                }
            }
        } catch{
            print("Could not read the json file.")
        }
        return weapons
    }
    
    func getListOfEquipables() -> [String: Int]{
        let weapons = getListOfWeapons()
        var output : [String: Int] = [String: Int]()
        for (key, value) in playerInventory{
            for weapon in weapons{
                if (key == weapon.getName()){
                    output[key] = value
                }
            }
        }
        return output
    }
    
    func addEquipable(){
        // TODO: add the equipable into playerEquip and remove that item from playerInventory
    }
    
    func removeEquipable(){
        // TODO: remove the equipable from playerEquip and add that item into playerInventory
    }
    
    func checkCraftItem(item: Equipable, showAlert: inout Bool){
        let costs = item.getCost()
        for (key, value) in costs{
            if ((playerInventory[key] ?? 0) < value){
                showAlert = true
                break
            }
        }
    }
    
    func craftItem(itemName: String){
        let items = getListOfWeapons()
        for item in items{
            if (itemName == item.getName()){
                let costs = item.getCost()
                for (key, value) in costs{
                    playerInventory[key] = (playerInventory[key] ?? 0) - value
                }
                playerInventory[item.getName()] = (playerInventory[item.getName()] ?? 0) + 1
                addLog(message: "Crafted +1 \(item.getName())")
            }
        }
    }

}
