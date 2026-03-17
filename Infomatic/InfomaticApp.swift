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
    @StateObject private var topicLibrary = TopicLibrary()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(dataManager)
                .environment(\.managedObjectContext, dataManager.context)
                .environment(\.theme, .standard)
                .environmentObject(topicLibrary)
                .onOpenURL{ url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
