//
//  SignInView.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/16/26.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

struct SignInView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.theme) var theme
    
    private var rootViewController: UIViewController? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first?.rootViewController
    }

    private func handleSuccessfulLogin(with authorization: ASAuthorization) {
        print("Apple Sign In Clicked")
        if let userCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            print("\(String(describing: userCredential.fullName?.givenName))")
            let name = userCredential.fullName?.givenName ?? "Apple User"
            
            let email = userCredential.email
            
            authManager.signIn(with: .apple, name: name, email: email)
        }
    }
        
    private func handleLoginError(with error: Error) {
        print("Could not authenticate: \(error.localizedDescription)")
    }
    
    private func handleGoogleSignInButton() {
        print("Google Sign In Clicked")
        
        guard let rootVC = rootViewController else {return}
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC){ [weak authManager] signInResult, error in
            if let error = error{
                handleLoginError(with: error)
                return
            }
            guard let result = signInResult else {return}
            
            let name = result.user.profile?.name ?? "Google User"
            let email = result.user.profile?.email
            
            authManager?.signIn(with: .google, name: name, email: email)
        }
    }
    
    var body: some View {
        ZStack{
            LinearGradient(colors: [theme.primaryColor, theme.secondaryColor], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            
            VStack {
                Image("InfomaticLogo")
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 250, height: 250)
                    .padding(.bottom, 20)
                
                GoogleSignInButton(
                    scheme: .dark,
                    style: .standard,
                    state: .normal,
                    action: handleGoogleSignInButton
                )
                    .frame(height: 50)
                    .padding(.horizontal)
                
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        handleSuccessfulLogin(with: authorization)
                    case .failure(let error):
                        handleLoginError(with: error)
                    }
                }
                .frame(height: 50)
                .padding()
                .signInWithAppleButtonStyle(.black)
            }
            .frame(maxWidth:300)
            .padding(.vertical, 80)
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthenticationManager(user: nil, isAuthenticated: false))
        .environment(\.theme, .standard)
}
