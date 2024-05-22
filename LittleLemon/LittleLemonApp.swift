//
//  LittleLemonApp.swift
//  LittleLemon
//
//  Created by Nouf Faisal  on 14/11/1445 AH.
//

import SwiftUI

@main
struct LittleLemonApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            Onboarding().environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

