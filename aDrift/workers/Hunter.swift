//
//  hunter.swift
//  aDrift
//
//  Created by Izdar Tohti on 7/31/23.
//

import Foundation

class Hunter: Worker{
    var cost : [String: Int] = [:]
    var gain : [String: Int] = [:]
    let name = "hunter"
    
    init(){
        cost = ["wood" : 5]
        gain = ["meat" : 10, "fur" : 5]
    }
    
    func getGains() -> [String: Int]{
        return gain
    }
    
    func getCosts() -> [String: Int]{
        return cost
    }
    
    func getName() -> String{
        return name
    }
}
