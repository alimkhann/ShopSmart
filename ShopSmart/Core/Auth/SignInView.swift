//
//  SignInView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 25/4/2025.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject private var viewModel = SignInViewModel()
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
                
                Text("Sign In")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .padding(.bottom, 24)
                
                VStack(spacing: 16) {
                    CustomTextField(placeholder: "email", text: $viewModel.email)
                    
                    CustomTextField(placeholder: "password", text: $viewModel.password, isSecure: true)
                    
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.signIn()
                                showAuthenticationView = false
                            } catch {
                                print(error)
                            }
                        }
                    }) {
                        if viewModel.isSigningIn {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign In")
                        }
                    }
                    .disabled(viewModel.isSigningIn)
                    .foregroundStyle(.background)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(viewModel.isSigningIn ? Color.gray : Color.primary)
                    .cornerRadius(8)
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
    NavigationStack {
        SignInView(showAuthenticationView: .constant(false))
    }
}
