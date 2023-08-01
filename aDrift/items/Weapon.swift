//
//  Equipable.swift
//  aDrift
//
//  Created by Izdar Tohti on 8/1/23.
//

import Foundation

class Weapon: Hashable, Comparable, Equipable{
    var durability : Int
    var damage : Int
    var cost : [String: Int]
    var name : String
    
    init(durability: Int, damage: Int, cost: [String: Int], name: String){
        self.durability = durability
        self.damage = damage
        self.cost = cost
        self.name = name
    }
    
    func getDurability() -> Int {
        return durability
    }
    
    func getDamage() -> Int{
        return damage
    }
    
    func getCost() -> [String: Int]{
        return cost
    }
    
    func getName() -> String{
        return name
    }
    
    func printCost() -> String{
        var output = ""
        let keys = cost.keys.sorted()
        for key in keys{
            output += key + ": \(cost[key] ?? 0) "
        }
        return output
    }
    
    func use(){
        durability -= 1
    }
}

extension Weapon{
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.getName())
    }
    
    static func == (lhs: Weapon, rhs: Weapon) -> Bool{
        if (lhs.getName() == rhs.getName()){
            return true
        }
        else{
            return false
        }
    }
    
    static func < (lhs: Weapon, rhs: Weapon) -> Bool{
        if (lhs.getName() < rhs.getName()){
            return true
        }
        else{
            return false
        }
    }
}
