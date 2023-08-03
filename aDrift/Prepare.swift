//
//  Travel.swift
//  aDrift
//
//  Created by Izdar Tohti on 8/3/23.
//

import SwiftUI

struct Prepare: View {
    @ObservedObject var gameManager : GameManager
    @State private var isTravelling = false
    var body: some View {
        if (!isTravelling){
            VStack{
                HStack{
                    // TODO: fill this text view with the list of the player stats
                    Text("list of player stats")
                    Spacer()
                    Button("travel"){
                        isTravelling = true
                    }
                    .foregroundColor(.black)
                    .frame(width: 110, height: 60)
                    .border(.black)
                }
                .padding()
                Form{
                    ForEach(gameManager.getListOfEquipables().keys.sorted(), id:\.self) { item in
                        HStack{
                            Text("\(item)\n\(gameManager.getListOfEquipables()[item] ?? 0)")
                            Spacer()
                            Button {
                                
                            } label: {
                                Image(systemName: "minus.rectangle")
                                    .resizable()
                                    .frame(width: 30, height: 25)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            Button {
                                
                            } label: {
                                Image(systemName: "plus.rectangle")
                                    .resizable()
                                    .frame(width: 30, height: 25)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                Logs(logs: gameManager.logs)
            }
            .navigationTitle("prepare to travel")
        }
        else{
            Travel()
        }
    }
}
