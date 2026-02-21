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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .onOpenURL{ url in
                    GIDSignIn.sharedInstance.handle(url)
                }
//                .onAppear {
//                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
//                        if let user = user {
//                            self.user = User(
//                                name: user.profile?.name ?? "Unknown",
//                                email: user.profile?.email ?? "",
//                                provider: .google)
//                        }
//                    }
//                }
        }
    }
}
