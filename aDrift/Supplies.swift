//
//  Supplies.swift
//  GameProject
//
//  Created by Izdar Tohti on 7/16/23.
//
import Foundation
import SwiftUI

struct Supplies: View{
    let userDefaults = UserDefaults.standard
    @State private var playerInventory = [String: Int]()
    
    func fetchGameData(){
        playerInventory = userDefaults.object(forKey: "playerInventory") as? [String: Int] ?? [:]
    }
    
    var body: some View{
        Form{
            ForEach(Array(playerInventory.keys), id:\.self){ key in
                Text(key + ": \(playerInventory[key] ?? -1)")
            }
        }
        .onAppear(perform: fetchGameData)
    }
}


