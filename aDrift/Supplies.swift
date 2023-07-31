//
//  Supplies.swift
//  GameProject
//
//  Created by Izdar Tohti on 7/16/23.
//
import Foundation
import SwiftUI

struct Supplies: View{
    @ObservedObject var gameManager : GameManager
    
    var body: some View{
        Form{
            ForEach(Array(gameManager.playerInventory.keys).sorted(), id:\.self){ key in
                Text(key + ": \(gameManager.playerInventory[key] ?? -1)")
            }
        }
        .navigationTitle("inventory")
    }
}


