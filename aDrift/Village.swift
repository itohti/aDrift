//
//  Village.swift
//  GameProject
//
//  Created by Izdar Tohti on 7/20/23.
//

import SwiftUI

struct Village: View {
    let userDefaults = UserDefaults.standard
    @State private var housing = 0
    @State private var population = 0
    @State private var playerInventory = [String:Int]()
    @State private var showHousingAlert = false
    @State private var isChopping = false
    @State private var chopping = 0.0
    @State private var logs = [String]()
    
    func fetchGameData(){
        // fetches game data
        logs = userDefaults.object(forKey: "logs") as? [String] ?? []
        population = userDefaults.object(forKey: "population") as? Int ?? 0
        housing = userDefaults.object(forKey: "housing") as? Int ?? 0
        playerInventory = userDefaults.object(forKey: "playerInventory") as? [String: Int] ?? [:]
    }
    
    func addHousing(){
        // adds housing if player has enough resources
        if (playerInventory["wood"] ?? 0 >= 100){
            playerInventory["wood"] = (playerInventory["wood"] ?? 0) - 100
            housing += 1
            save()
        }
        else{
            showHousingAlert = true
        }
    }
    
    func chopWood(){
        // adds 10 wood to player inventory
        chopping += 1
        if (chopping == 6){
            logs.append("+10 wood")
            playerInventory["wood"] = (playerInventory["wood"] ?? 0) + 10
            chopping = 0
            isChopping = false
            save()
        }
    }
    
    func save(){
        userDefaults.set(playerInventory, forKey: "playerInventory")
        userDefaults.set(housing, forKey: "housing")
        userDefaults.set(logs, forKey: "logs")
    }
    
    var body: some View {
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        VStack{
            HStack{
                Text("Housing: \(housing)")
                Spacer()
                Button("Build Hut"){
                    addHousing()
                }
                .frame(width: 100, height: 50)
                .border(.black)
            }
            .padding()
            VStack(alignment: .leading){
                Button("Chop Wood"){
                    isChopping = true
                }
                ProgressView("", value: chopping, total: 6)
                    .onReceive(timer){ _ in
                        if (isChopping){
                            chopWood()
                        }
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .offset(y:-300)
        .navigationTitle("village")
        .alert("Not Enough Resources", isPresented: $showHousingAlert) {
            Button("Dismiss", role: .cancel) { }
        } message: {
            Text("You currently have: \(playerInventory["wood"] ?? 0) wood but it costs 100 wood")
        }
        .onAppear(perform: fetchGameData)
    }
}

struct Village_Previews: PreviewProvider {
    static var previews: some View {
        Village()
    }
}
