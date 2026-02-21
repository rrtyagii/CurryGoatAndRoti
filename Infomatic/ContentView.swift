//
//  ContentView.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/12/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        if authManager.isAuthenticated{
            MainAppView()
        } else{
            SignInView()
        }
    }
}

struct MainAppView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack {
            Text("Welcome, \(authManager.user?.name ?? "User")!")
            
            Button("Sign Out") {
                authManager.signOut()
            }
        }
    }
}
