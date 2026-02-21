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
            
            let name = userCredential.fullName?.givenName ?? "Apple User"
            let email = userCredential.email
            
            authManager.signIn(with: .apple, name: name, email: email)
        }
//        if let userCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            print(userCredential.user)
//            if userCredential.authorizedScopes.contains(.fullName) && userCredential.authorizedScopes.contains(.email) {
//                print(userCredential.fullName?.givenName ?? "No given name")
//                authManager.signIn(with: .apple, name: name, email: user)
//            }
//        }
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
        
//        if let rootViewController = getRootViewController(){
//            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController){
//                signInResult, error in
//                guard let result = signInResult else {
//                    return
//                }
//                self.user = User.init(name: result.user.profile?.name ?? "")
//            }
//        }
    }
    
    var body: some View {
        VStack {
            Image("InfomaticLogo")
                .renderingMode(.original)
                .resizable()
                .frame(width: 250, height: 250)
                .padding(.bottom, 20)

//            Button(action: handleGoogleSignInButton) {
//                HStack {
//                    Image("google_logo") // Ensure you have a small Google 'G' icon in Assets
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 18, height: 18)
//                    
//                    Text("Continue with Google")
//                        .font(.system(size: 19, weight: .medium))
//                }
//                .foregroundColor(.black)
//                .frame(maxWidth: .infinity) // Centers the content
//                .frame(height: 50)
//                .background(Color.white)
//                .cornerRadius(8)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                )
//            }
//            .padding(.horizontal)
            
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

#Preview {
    SignInView()
        .environmentObject(AuthenticationManager(user: nil, isAuthenticated: false))
}


//func getRootViewController()->UIViewController? {
//    guard let scene = UIApplication.shared.connectedScenes.first as?
//            UIWindowScene,
//          let rootViewController = scene.windows.first?.rootViewController else {
//        return nil
//    }
//    return getVisibleViewController(from: rootViewController)
//}
//
//private func getVisibleViewController(from vc: UIViewController) -> UIViewController{
//    if let nav = vc as? UINavigationController{
//        return getVisibleViewController(from: nav.visibleViewController!)
//    }
//    if let tab = vc as? UITabBarController {
//        return getVisibleViewController(from: tab.selectedViewController!)
//    }
//    if let presented = vc.presentedViewController{
//        return getVisibleViewController(from: presented)
//    }
//    return vc
//}
