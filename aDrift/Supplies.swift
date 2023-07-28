//
//  Supplies.swift
//  GameProject
//
//  Created by Izdar Tohti on 7/16/23.
//
import Foundation
import SwiftUI

struct Supplies: View{
    var playerInventory : [String: Int]
    var body: some View{
        Form{
            ForEach(Array(playerInventory.keys), id:\.self){ key in
                Text(key + ": \(playerInventory[key] ?? -1)")
            }
        }
    }
}


