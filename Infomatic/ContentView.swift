//
//  ContentView.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/12/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var topicLibrary: TopicLibrary
    
    var body: some View {
        if authManager.isAuthenticated{
            NavbarView()
                .environmentObject(topicLibrary)
        } else{
            SignInView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager(user: nil, isAuthenticated: false))
        .environment(\.theme, .standard)
}
