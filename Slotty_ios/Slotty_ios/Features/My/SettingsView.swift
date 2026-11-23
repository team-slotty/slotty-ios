//
//  SettingsView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import SwiftUI

/// 6-4 설정 - 로그아웃
struct SettingsView: View {
    let authRepository: any AuthRepository
    /// 로그아웃을 확인 중인지
    @State private var isConfirmingLogout = false
    /// 로그아웃 요청 중인지 - 버튼을 두 번 누르지 않게
    @State private var isLoggingOut = false
    
    var body: some View {
        VStack(spacing: 16) {
            Button("로그아웃") {
                isConfirmingLogout = true
            }
            .buttonStyle(.slottySecondary)
            .disabled(isLoggingOut)
            Spacer()
        }
        .padding(20)
        .background(SlottyColor.background)
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("로그아웃할까요?", isPresented: $isConfirmingLogout, titleVisibility: .visible) {
            Button("로그아웃", role: .destructive) {
                Task { await logout() }
            }
        }
    }
    
    /// 토큰을 지운 뒤 로그인이 풀렸다고 알린다 - 앱이 받아서 로그인 화면으로 돌아간다
    private func logout() async {
        isLoggingOut = true
        await authRepository.logout()
        NotificationCenter.default.post(name: .sessionExpired, object: nil)
    }
}

#Preview {
    NavigationStack {
        SettingsView(authRepository: MockAuthRepository())
    }
}
