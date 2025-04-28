//
//  WelcomeView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 25/4/2025.
//

import SwiftUI

struct AuthenticationView: View {
    
    @Binding var showAuthenticationView: Bool
    
    var body: some View {
        VStack {
            VStack(spacing: 16) {
                Text("🛒")
                    .font(.system(size: 80))
                    .padding(.bottom, 8)
                
                Text("ShopSmart")
                    .font(.system(size: 24))
                    .fontWeight(.bold)
                
                Text("Collaborative Shopping Lists")
                    .font(.subheadline)
                    .fontWeight(.light)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                NavigationLink {
                    SignUpView(showAuthenticationView: $showAuthenticationView)
                } label: {
                    PrimaryButtonStyleView(content: "Get Started")
                }
                
                NavigationLink {
                    SignInView(showAuthenticationView: $showAuthenticationView)
                } label: {
                    SecondaryButtonStyleView(content: "I already have an account")
                }
            }
            
        }
        .padding(.horizontal, 24)
        .padding(.top, 96)
        .padding(.bottom, 12)
        .navigationBarHidden(true)
    }
}

#Preview {
    AuthenticationView(showAuthenticationView: .constant(false))
}
