//
//  NavbarView.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/25/26.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct NavbarView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.theme) var theme
    
    var body: some View {
        let baseTabView = TabView {
            HomeScreen()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            Text("Search")
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            Text("Bookmark")
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark")
                }
            
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .tint(theme.accentColor)

        if #available(iOS 16.0, *) {
            baseTabView
                .toolbarBackground(theme.primaryColor, for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
        } else {
            baseTabView
                .onAppear {
                    #if os(iOS)
                    let appearance = UITabBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = UIColor(theme.primaryColor)
                    UITabBar.appearance().standardAppearance = appearance
                    if #available(iOS 15.0, *) {
                        UITabBar.appearance().scrollEdgeAppearance = appearance
                    }
                    #endif
                }
        }
    }
}
