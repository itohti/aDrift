//
//  Stats.swift
//  aDrift
//
//  Created by Izdar Tohti on 7/28/23.
//

import SwiftUI
import CoreData

struct Stats: View {
    var moc : NSManagedObjectContext
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var player = Player()
    @State private var health = 0
    @State private var food = 0
    @State private var water = 0
    init(context: NSManagedObjectContext){
        self.moc = context
    }
    @State private var display = 20
    var upgrade = 10
    
    func fetchGameData(){
        let fetchRequest : NSFetchRequest<Player> = Player.fetchRequest()
        do{
            let players = try moc.fetch(fetchRequest)
            player = players[0]
            health = Int(player.health)
            food = Int(player.food)
            water = Int(player.water)
        } catch{
            print("Couldnt access Core Data")
        }
    }
    
    var body: some View {
        Form{
            Text("health: \(health)")
            Text("food: \(food)")
            Text("water: \(water)")
        }
        .onAppear(perform: fetchGameData)
        .onReceive(timer) { _ in
            fetchGameData()
        }
    }
}
