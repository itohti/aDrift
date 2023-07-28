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
    @State private var playerInventory = [String:Int]()
    @State private var showHousingAlert = false
    
    func fetchGameData(){
        housing = userDefaults.object(forKey: "housing") as? Int ?? 0
        playerInventory = userDefaults.object(forKey: "playerInventory") as? [String: Int] ?? [:]
    }
    
    func addHousing(){
        if (playerInventory["wood"] ?? 0 >= 100){
            playerInventory["wood"] = (playerInventory["wood"] ?? 0) - 100
            housing += 1
            save()
        }
        else{
            showHousingAlert = true
        }
    }
    
    func save(){
        userDefaults.set(playerInventory, forKey: "playerInventory")
        userDefaults.set(housing, forKey: "housing")
    }
    
    var body: some View {
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
        }
        .offset(y:-300)
        .navigationTitle("Village")
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
