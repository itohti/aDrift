//
//  GameProjectApp.swift
//  GameProject
//
//  Created by Izdar Tohti on 7/9/23.
//

import SwiftUI

@main
struct aDriftApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
