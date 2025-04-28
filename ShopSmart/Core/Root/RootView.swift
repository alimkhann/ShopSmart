//
//  RootView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 26/4/2025.
//

import SwiftUI

struct RootView: View {
    
    @State var showAuthenticationView: Bool = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                MainView(showAuthenticationView: $showAuthenticationView)
            }
        }
        .onAppear() {
            checkAuthStatus()
        }
        .fullScreenCover(isPresented: $showAuthenticationView) {
            NavigationStack {
                AuthenticationView(showAuthenticationView: $showAuthenticationView)
            }
        }
    }
    
    private func checkAuthStatus() {
        do {
            _ = try AuthenticationManager.shared.getAuthenticatedUser()
            showAuthenticationView = false
        } catch {
            showAuthenticationView = true
        }
    }
}

#Preview {
    RootView()
}
