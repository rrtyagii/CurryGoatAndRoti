//
//  HomeScreen.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/21/26.
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.theme) var theme
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [theme.primaryColor, theme.secondaryColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Welcome, \(authManager.user?.name ?? "User")!")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(theme.textColor)

                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(CardDetail.sampleData) { scrum in
                            CardView(scrum: scrum)
                                .frame(width: 340, height: 190)
                        }
                    }
                }
                
                Button("Sign Out") {
                    authManager.signOut()
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.buttonColor)
            }
            .padding()
        }
    }
}

#Preview {
    HomeScreen()
        .environmentObject(AuthenticationManager(user: nil, isAuthenticated: false))
        .environment(\.theme, .standard)
}
