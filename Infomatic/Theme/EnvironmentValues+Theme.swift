//
//  EnvironmentValues+Theme.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/21/26.
//

import SwiftUI

private struct ThemeKey: EnvironmentKey{
    static let defaultValue: Theme = .standard
}

extension EnvironmentValues{
    var theme: Theme{
        get {self[ThemeKey.self] }
        set {self[ThemeKey.self] = newValue}
    }
}

struct EnvironmentValues_Theme: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    EnvironmentValues_Theme()
}
