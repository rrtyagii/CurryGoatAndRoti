//
//  InfomaticApp.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/12/26.
//

import SwiftUI
import GoogleSignIn
import AuthenticationServices

@main
struct InfomaticApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(dataManager)
                .environment(\.theme, .standard)
                .onOpenURL{ url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
