//
//  Village.swift
//  GameProject
//
//  Created by Izdar Tohti on 7/20/23.
//

import SwiftUI

struct Village: View {
    let userDefaults = UserDefaults.standard
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @ObservedObject var gameManager : GameManager
    @State private var showHousingAlert = false
    @State private var isChopping = false
    @State private var chopping = 0.0
    
    func chopWood(){
        // adds 10 wood to player inventory
        chopping += 1
        if (chopping == 6){
            gameManager.playerInventory["wood"] = (gameManager.playerInventory["wood"] ?? 0) + 10
            chopping = 0
            isChopping = false
            gameManager.addLog(message: "You chop 10 wood")
        }
    }
    
    var body: some View {
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        VStack{
            HStack{
                Text("Housing: \(gameManager.housing)")
                Spacer()
                Button("Build Hut"){
                    gameManager.addHousing(showHousingAlert: &showHousingAlert)
                }
                .frame(width: 100, height: 50)
                .border(.black)
            }
            .padding()
            VStack(alignment: .leading){
                if (gameManager.housing != 0){
                    Text("Population: \(gameManager.population) / \(gameManager.totalPopulation)")
                    Text("Avaiable Workers: \(gameManager.availableWorkers)")
                }
                Button("Chop Wood"){
                    isChopping = true
                }
                ProgressView("", value: chopping, total: 6)
                    .onReceive(timer){ _ in
                        if (isChopping){
                            chopWood()
                        }
                    }
                    .padding(.trailing, 50)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            Form{
                ForEach(Array(gameManager.workers.keys).sorted(), id:\.self) { worker in
                    HStack{
                        Text(worker + ": \(gameManager.workers[worker] ?? 0)\nCost: \(gameManager.getCosts(worker: worker))\nGain: \(gameManager.getGains(worker: worker))")
                        Spacer()
                        Button(
                            action: { gameManager.decrementWorker(worker: worker) },
                            label: {
                                Image(systemName: "minus.rectangle")
                                    .resizable()
                                    .frame(width: 30, height: 25)
                            }
                        )
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(gameManager.getWorker(worker: worker) > 0 ? false : true)
                        Button(
                            action: { gameManager.incrementWorker(worker: worker)},
                            label: {
                                Image(systemName: "plus.rectangle")
                                    .resizable()
                                    .frame(width: 30, height: 25)
                            }
                        )
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(gameManager.availableWorkers > 0 ? false : true)
                    }
                }
            }
            Logs(logs: gameManager.logs)
        }
        .navigationTitle("village")
        .alert("Not Enough Resources", isPresented: $showHousingAlert) {
            Button("Dismiss", role: .cancel) { }
        } message: {
            Text("You currently have \(gameManager.playerInventory["wood"] ?? 0) wood but it costs \(gameManager.costOfHouse) wood")
        }
    }
}
