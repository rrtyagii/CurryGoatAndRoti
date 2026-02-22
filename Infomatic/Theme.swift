//
//  Theme.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/21/26.
//

import SwiftUI

enum Theme{
    case standard
    case dark
    
    var primaryColor: Color{
        switch self{
        case .standard:
            return .themePrimary
        case .dark:
            return .black
        }
    }
    
    var secondaryColor: Color{
        switch self{
        case .standard:
            return .themeSecondary
        case .dark:
            return .gray
        }
    }
    
    var accentColor: Color {
        switch self {
        case .standard:
            return .themeAccent
        case .dark:
            return .blue
        }
    }
    
    var lightColor: Color {
        switch self {
        case .standard:
            return .themeLight
        case .dark:
            return .white
        }
    }
    
    var backgroundColor: Color {
        return primaryColor
    }
    
    var buttonColor: Color {
        return accentColor
    }
    
    var textColor: Color {
        return lightColor
    }
}
