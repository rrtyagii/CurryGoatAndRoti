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
    @State private var topicIndex: [CardDetail] = []
    
    private var topicContent: some View {
        ZStack{
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
                        ForEach(topicIndex) { scrum in
                            NavigationLink (destination: TopicDetailView(scrum: scrum)){
                                CardView(scrum: scrum)
                                    .frame(width: 340, height: 150)
                            }
                        }
                    }
                }
            }
            .onAppear{
                if topicIndex.isEmpty{
                    topicIndex = TopicLoader.loadIndex()
                }
            }
        }
    }

    
    var body: some View {
        if #available(iOS 16.0, *){
            NavigationStack {
                topicContent
            }
        } else{
            NavigationView{
                topicContent
            }.navigationViewStyle(.stack)
        }
    }
}
//#Preview {
//    HomeScreen()
//        .environmentObject(AuthenticationManager(user: nil, isAuthenticated: false))
//        .environment(\.theme, .standard)
//}


////                Button("Sign Out") {
//                    authManager.signOut()
//                }
//                .buttonStyle(.borderedProminent)
//                .tint(theme.buttonColor)
