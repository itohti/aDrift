//
//  Crafting.swift
//  GameProject
//
//  Created by Izdar Tohti on 7/16/23.
//

import Foundation
import SwiftUI

struct Crafting: View{
    @ObservedObject var gameManager : GameManager = GameManager()
    @State private var showAlert = false
    @State private var unableToBuy = false
    @State private var itemSelected = ""
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
    var body: some View{
        VStack{
            ScrollView{
                Text("Weapons")
                    .font(.title)
                LazyVGrid(columns: columns, spacing: 10){
                    ForEach(gameManager.getListOfWeapons(), id:\.self) {item in
                        ZStack{
                            Rectangle()
                                .fill(.white)
                                .frame(width: 120, height: 60)
                                .border(.black)
                            Button("\(item.getName())\n\(item.printCost())"){
                                itemSelected = item.getName()
                                gameManager.checkCraftItem(item: item, showAlert: &unableToBuy)
                                showAlert = true
                            }
                            .foregroundColor(.black)
                        }
                    }
                }
                .padding(10)
            }
            Logs(logs: gameManager.logs)
        }
        .alert(unableToBuy ? "Not Enough Resources" : "Craft This Item?", isPresented: $showAlert){
            if (unableToBuy){
                Button("Dismiss", role: .cancel){ }
            }
            else{
                Button("No", role: .cancel){ }
                Button("Yes"){
                    gameManager.craftItem(itemName: itemSelected)
                }
            }
        } message: {
            unableToBuy ? Text("You don't have enought resources to craft \"\(itemSelected)\"") : Text("Do you want to craft \"\(itemSelected)\"?")
        }
    }
}

struct Crafting_Previews: PreviewProvider{
    static var previews: some View{
        Crafting()
    }
}
