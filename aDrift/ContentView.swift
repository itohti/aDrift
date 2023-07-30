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
    @ObservedObject var gameManager = GameManager()
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
    @State private var resetAlert = false
    var totalPopulation: Int {
        return gameManager.housing * 4
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
                gameManager.load()
            }
        } catch{
            // something went wrong with fetching GameData
            print("Something went wrong")
        }
    }
    
    func createPlayer(){
        // if the player doesnt exists (meaning its a new game) this function will create a new player
        gameManager.addLog(message: "You need to find warmth")
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
        
        gameManager.playerInventory["knife"] = 1
        gameManager.playerInventory["tinderbox"] = 1
        gameManager.save()
        playerExists = true
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
            gameManager.save()
            CoreSave()
        }
    }
    
    func changeTheme(){
        // this function changes the theme of the game
        if (isLit){
            gameManager.addLog(message: "The fire is lit")
            background = [Color.white, Color.orange]
            foreground = Color.black
        }
        else{
            gameManager.addLog(message: "The fire died")
            background = [Color(red: 0.0, green: 0.0, blue: 0.35), Color.blue]
            foreground = Color.white
        }
    }
    
    func CoreSave(){
        // saves the game
        do{
            try moc.save()
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
            gameManager.reset()
            playerExists = false
            isLit = false
        } catch{
            print("Could not delete Player file")
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
                                gameManager.addLog(message: "You stoke the fire")
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
                                gameManager.addLog(message: "You light the fire")
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
                                NavigationLink(destination: Village(gameManager: gameManager), label:{
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
                        Logs(logs: gameManager.logs)
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
                    gameManager.fillHouse()
                    gameManager.load()
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
