//
//  SignInView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 25/4/2025.
//

import SwiftUI

@MainActor
final class SignUpViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws {
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            print("No username, email, or password provided.")
            return
        }
        
        
        try await AuthenticationManager.shared.signUp(username: username, email: email, password: password)
    }
}

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject private var viewModel = SignUpViewModel()
    @Binding var showAuthenticationView: Bool
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: 16) {
                    Text("🛒")
                        .font(.system(size: 80))
                        .padding(.bottom, 8)
                    
                    Text("ShopSmart")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                }
                .padding(.bottom, 36)
                
                Text("Sign Up")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .padding(.bottom, 24)
                
                VStack(spacing: 16) {
                    CustomTextField(placeholder: "username", text: $viewModel.username)
                    
                    CustomTextField(placeholder: "email", text: $viewModel.email)
                    
                    CustomTextField(placeholder: "password", text: $viewModel.password, isSecure: true)
                    
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.signUp()
                                showAuthenticationView = false
                            } catch {
                                print(error)
                            }
                        }
                    }) {
                        PrimaryButtonStyleView(content: "Sign Up")
                    }
                }
                
                Spacer()
            }
        }
        .padding(.top, 64)
        .padding(.horizontal, 24)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.primary)
            }
        })
    }
}


#Preview {
    SignUpView(showAuthenticationView: .constant(false))
}
