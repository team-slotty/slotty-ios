//
//  SettingsView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import SwiftUI

/// 6-4 설정 - 연락처 공개, 로그아웃, 탈퇴
struct SettingsView: View {
    let authRepository: any AuthRepository
    @State private var viewModel: SettingsViewModel
    /// 로그아웃을 확인 중인지
    @State private var isConfirmingLogout = false
    /// 탈퇴를 확인 중인지
    @State private var isConfirmingWithdraw = false
    /// 로그아웃/탈퇴 요청 중인지 - 버튼을 두 번 누르지 않게
    @State private var isLoggingOut = false

    init(authRepository: any AuthRepository, accountRepository: any AccountRepository) {
        self.authRepository = authRepository
        _viewModel = State(initialValue: SettingsViewModel(repository: accountRepository))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let phonePublic = viewModel.phonePublic {
                Toggle("차량번호 검색 시 연락처 공개", isOn: Binding(
                    get: { phonePublic },
                    set: { isOn in Task { await viewModel.setPhonePublic(isOn) } }
                ))
                .font(SlottyFont.body)
                Text("※ 연락처는 가려서 표시되고 [전화 걸기]로만 연결돼요")
                    .font(SlottyFont.caption)
                    .foregroundStyle(SlottyColor.secondary)
            }
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(SlottyFont.caption)
                    .foregroundStyle(SlottyColor.secondary)
            }
            Spacer()
            Button("로그아웃") {
                isConfirmingLogout = true
            }
            .buttonStyle(.slottySecondary)
            .disabled(isLoggingOut)
            Button("탈퇴하기") {
                isConfirmingWithdraw = true
            }
            .font(SlottyFont.caption)
            .foregroundStyle(SlottyColor.secondary)
            .frame(maxWidth: .infinity)
            .disabled(isLoggingOut)
        }
        .padding(20)
        .background(SlottyColor.background)
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
        .confirmationDialog("로그아웃할까요?", isPresented: $isConfirmingLogout, titleVisibility: .visible) {
            Button("로그아웃", role: .destructive) {
                Task { await logout() }
            }
        }
        .confirmationDialog("탈퇴할까요?", isPresented: $isConfirmingWithdraw, titleVisibility: .visible) {
            Button("탈퇴", role: .destructive) {
                Task { await withdraw() }
            }
        } message: {
            Text("계정과 내 정보가 삭제되고 되돌릴 수 없어요")
        }
    }

    /// 토큰을 지운 뒤 로그인이 풀렸다고 알린다 - 앱이 받아서 로그인 화면으로 돌아간다
    private func logout() async {
        isLoggingOut = true
        await authRepository.logout()
        NotificationCenter.default.post(name: .sessionExpired, object: nil)
    }

    /// 탈퇴에 성공하면 로그아웃처럼 로그인 화면으로
    private func withdraw() async {
        isLoggingOut = true
        if await viewModel.withdraw() {
            NotificationCenter.default.post(name: .sessionExpired, object: nil)
        } else {
            isLoggingOut = false
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(authRepository: MockAuthRepository(), accountRepository: MockAccountRepository())
    }
}
