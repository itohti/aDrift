//
//  Woodcutter.swift
//  aDrift
//
//  Created by Izdar Tohti on 7/31/23.
//

import Foundation

class Woodcutter: Worker{
    var cost = [String: Int]()
    var gain = [String: Int]()
    let name = "woodcutter"
    
    init(){
        cost = ["fur": 5]
        gain = ["wood": 10]
    }
    
    func getCosts() -> [String: Int]{
        return cost
    }
    
    func getGains() -> [String: Int]{
        return gain
    }
    
    func getName() -> String {
        return name
    }
}
