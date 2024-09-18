//
//  resappApp.swift
//  resapp
//
//  Created by Cody Hall on 9/18/24.
//

import SwiftUI

@main
struct resappApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
