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
// EnvironemntObject here means that NavbarView expects an evironment object ( state modification and prop drilling ) from the parent. This view expects that the instance already exists in the higher up heirarchy of the swift UI. Swift UI injects it so that we can have shared state.
    
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.theme) var theme
    
    var body: some View {
        let baseTabView = TabView {
            HomeScreen()
                .tabItem {
                    Label("Learn", systemImage: "book")
                }           
            BookmarkView()
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark")
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
