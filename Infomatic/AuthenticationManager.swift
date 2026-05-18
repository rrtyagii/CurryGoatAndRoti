//
//  AuthenticationManager.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/18/26.
//

import SwiftUI
import Combine
import GoogleSignIn
import AuthenticationServices


//You need a class that conforms to ObservableObject (or uses the newer @Observable macro in iOS 17+) if you want SwiftUI views to automatically update when properties within that class change.

class AuthenticationManager: ObservableObject {
    
    // ObservableObject is a protocol for class based data models and this protocol enables automatic UI updates for the "Published" properties.
    
    @Published var user: User?
    @Published var isAuthenticated: Bool = false
    
    init(){ //empty constructor
        self.user = nil
        self.isAuthenticated = false
        restoreGoogleSignIn()
    }
    
    init(user: User?, isAuthenticated: Bool) { // parametrized constructor
        self.user = user
        self.isAuthenticated = isAuthenticated
    }
    
    func signIn(with provider: AuthProvider, name: String, email: String?) {
        self.user = User(name: name, email: email, provider: provider)
        self.isAuthenticated = true
    }
    
    func signOut() {
        if user?.provider == .google {
            GIDSignIn.sharedInstance.signOut()
        }
        
        self.user = nil
        self.isAuthenticated = false
    }
    
    
    private func restoreGoogleSignIn(){
        // restorePreviousSignIn --> tries to sign in users who've previously logged in
        GIDSignIn.sharedInstance.restorePreviousSignIn{[weak self] user, error in
            guard let self = self, let user = user, error == nil else { return }
            
            self.signIn(with: .google, name: user.profile?.name ?? "Google User", email: user.profile?.email ?? "Google User Email")
            
        }
    }
}

struct User {
    var name: String
    var email: String?
    var provider: AuthProvider = AuthProvider.apple
}

enum AuthProvider {
    case google
    case apple
    case none
}
