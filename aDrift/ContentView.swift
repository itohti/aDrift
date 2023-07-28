//
//  ContentView.swift
//  GameProject
//
//  Created by Izdar Tohti on 7/9/23.
//
import CoreData
import SwiftUI

struct NavigationButton: View{
    var imageName : String
    
    var body: some View{
        VStack{
            Image(imageName)
                .resizable()
                .frame(width: 40, height: 40)
            Text(imageName)
        }
        .frame(width: 80, height: 80)
        .padding()
        .border(.black)
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    // when fully testing set playerExists to false and uncomment onAppear() located down at the end of Zstack
    let userDefaults = UserDefaults.standard
    @State private var playerExists = false
    @State private var stateOfHome = "a cramped place"
    @State private var lighting = 0.0
    @State private var isLighting = false
    @State private var isLit = false
    @State private var fireDecay = 0.0
    @State private var background = [Color(red: 0.0, green: 0.0, blue: 0.35), Color.blue]
    @State private var foreground = Color.white
    @State private var logs = [String]()
    @State private var playerInventory = [String: Int]()
    @State private var resetAlert = false
    @State private var housing = 0
    @State private var population = 0
    var totalPopulation: Int {
        return housing * 4
    }
    
    func checkPlayer(){
        // this function checks if a player exists already
        let fetchRequest : NSFetchRequest<Player> = Player.fetchRequest()
        do {
            let players = try moc.fetch(fetchRequest)
            // checks to see the a player exists already
            if (players.count == 0){
                // means the player does not exist
                playerExists = false
            }
            else{
                // means the player exists
                playerExists = true
                playerInventory = userDefaults.object(forKey: "playerInventory") as? [String: Int] ?? [:]
                logs = userDefaults.object(forKey: "logs") as? [String] ?? []
                housing = userDefaults.object(forKey: "housing") as? Int ?? 0
                population = userDefaults.object(forKey: "population") as? Int ?? 0
            }
        } catch{
            // something went wrong with fetching GameData
            print("Something went wrong")
        }
    }
    
    func createPlayer(){
        // if the player doesnt exists (meaning its a new game) this function will create a new player
        logs.append("You need to find warmth")
        let newPlayer = Player(context: moc)
        /*
         a player will start with:
         20 HP
         5 water
         0 food
         */
        newPlayer.health = 20
        newPlayer.water = 5
        newPlayer.food = 0
        // create playerInventory
        
        playerInventory["knife"] = 1
        playerInventory["tinderbox"] = 1
        do{
            // saves the newPlayer object into GameData
            try moc.save()
            userDefaults.set(playerInventory, forKey: "playerInventory")
            playerExists = true
        } catch{
            // error in trying to save
            print("There was an error in saving data")
        }
    }
    
    func lightFire(){
        // lighting the fire
        lighting += 1
        if (lighting == 5){
            isLighting.toggle()
            isLit = true
            changeTheme()
            fireDecay = 0
            lighting = 0
            save()
        }
    }
    
    func changeTheme(){
        // this function changes the theme of the game
        if (isLit){
            logs.append("The fire is lit")
            background = [Color.white, Color.orange]
            foreground = Color.black
        }
        else{
            logs.append("The fire died")
            background = [Color(red: 0.0, green: 0.0, blue: 0.35), Color.blue]
            foreground = Color.white
        }
    }
    
    func save(){
        // saves the game
        do{
            try moc.save()
            userDefaults.set(playerInventory, forKey: "playerInventory")
            userDefaults.set(logs, forKey: "logs")
            userDefaults.set(housing, forKey: "housing")
            userDefaults.set(population, forKey: "population")
        } catch{
            print("There was an error in saving data")
        }
    }
    
    func resetGame(){
        // resets the game
        let fetchRequest : NSFetchRequest<Player> = Player.fetchRequest()
        fetchRequest.fetchLimit = 1
        do{
            let players = try moc.fetch(fetchRequest)
            let player = players[0]
            moc.delete(player)
            try moc.save()
            userDefaults.removeObject(forKey: "playerInventory")
            userDefaults.removeObject(forKey: "logs")
            userDefaults.removeObject(forKey: "housing")
            userDefaults.removeObject(forKey: "population")
            logs = [String]()
            playerExists = false
            isLit = false
        } catch{
            print("Could not delete Player file")
        }
    }
    
    func fillHouse(){
        var group = Int.random(in: 1..<4)
        // Each housing can house 4 people.
        // first check to see if there is free space. To see get the number of housing multiply it by 4. if current pop is less than that number there is free space.
        if (population < totalPopulation){
            let chance = Int.random(in: 0..<10)
            // 1/5 chance to fill a house with 1-4 people
            if (chance == 1){
                if (population + group > totalPopulation){
                    group = totalPopulation - population
                    logs.append(group > 1 ? "\(group) survivors move in" : "\(group) person moved in")
                    population += group
                }
                else{
                    logs.append(group > 1 ? "\(group) survivors move in" : "\(group) person moved in")
                    population += group
                }
            }
        }
    }
    
    var body: some View {
        // when doing UI please make sure to structure it clean
        NavigationView{
            if (playerExists){
                let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                ZStack{
                    LinearGradient(colors: background, startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                    VStack(){
                        if (isLit){
                            Button("stoke fire"){
                                isLighting.toggle()
                                logs.append("You stoke the fire")
                            }
                            .onReceive(timer) { _ in
                                fireDecay += 1
                                if (fireDecay == 120){
                                    isLit.toggle()
                                    changeTheme()
                                }
                            }
                        }
                        else{
                            Button("light fire"){
                                isLighting.toggle()
                                logs.append("You light the fire")
                            }
                        }
                        // This is the progressview for lighting a fire
                        if (isLighting){
                            ProgressView("", value: lighting, total: 5)
                                .onReceive(timer) { _ in
                                    lightFire()
                                }
                        }
                        VStack(spacing: 50){
                            // Navigation buttons
                            HStack(spacing: 80){
                                NavigationLink(destination: Crafting(), label:{
                                    NavigationButton(imageName: "Crafting")
                                })
                                NavigationLink(destination: Supplies(), label:{
                                    NavigationButton(imageName: "Inventory")
                                })
                            }
                            HStack(spacing: 80){
                                NavigationLink(destination: Village(), label:{
                                    NavigationButton(imageName: "Village")
                                    
                                })
                                NavigationLink(destination: Stats(context: moc), label:{
                                    NavigationButton(imageName: "Stats")
                                    
                                })
                            }
                        }
                        .padding()
                        Button("Reset Game"){
                            resetAlert = true
                        }
                        .frame(width: 120, height: 30)
                        .foregroundColor(.black)
                        .border(.black)
                        ZStack{
                            List{
                                ForEach(logs.reversed(), id:\.self) {text in
                                    Text(text)
                                }
                            }
                            .scrollContentBackground(.hidden)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding()
                        }
                        .background(.ultraThinMaterial)
                    }
                    .navigationTitle(stateOfHome)
                    .navigationBarTitleDisplayMode(.inline)
                    .alert("Reset Game", isPresented: $resetAlert){
                        Button("No", role: .cancel){ }
                        Button("Yes", role: .destructive){
                            resetGame()
                        }
                    } message: {
                        Text("All your progress will be lost.")
                    }
                }
                .onReceive(timer){ _ in
                    fillHouse()
                }
            }
            else{
                // new game
                Button("Wake Up", action: createPlayer)
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
        .onAppear(perform: checkPlayer)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
