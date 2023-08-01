//
//  Equipable.swift
//  aDrift
//
//  Created by Izdar Tohti on 8/1/23.
//

import Foundation


protocol Equipable{
    func getCost() -> [String: Int]
    func getName() -> String
}
