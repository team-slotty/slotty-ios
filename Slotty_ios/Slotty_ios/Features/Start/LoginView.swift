//
//  LoginView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/19/26.
//

import SwiftUI

/// 0-2 로그인: 소개 그림과 문구, 아이디/비밀번호, 회원가입으로 가는 길
struct LoginView: View {
    @State private var viewModel: LoginViewModel
    /// 로그인에 성공했을 때
    let onLogin: () -> Void
    
    init(viewModel: LoginViewModel, onLogin: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onLogin = onLogin
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            illustration
                .padding(.top, 40)
                .padding(.bottom, 48)
            Text("우리 빌라 주차,\n앱 하나로")
                .font(SlottyFont.largeTitle)
                .foregroundStyle(SlottyColor.primary)
                .padding(.bottom, 8)
            Text("방문 차량 등록부터 주차 현황 확인까지")
                .font(SlottyFont.body)
                .foregroundStyle(SlottyColor.secondary)
            Spacer()
            VStack(spacing: 16) {
                LabeledInput(label: "아이디", placeholder: "아이디 입력", text: $viewModel.loginId)
                LabeledInput(label: "비밀번호", placeholder: "비밀번호 입력", text: $viewModel.password, isSecure: true)
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(SlottyFont.caption)
                        .foregroundStyle(SlottyColor.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Button("로그인") {
                    Task {
                        if await viewModel.login() {
                            onLogin()
                        }
                    }
                }
                .buttonStyle(.slottyPrimary)
                .disabled(!viewModel.canLogin)
                HStack(spacing: 8) {
                    Text("계정이 없으신가요?")
                        .foregroundStyle(SlottyColor.primary)
                    NavigationLink("회원가입") {
                        // 가입 응답으로 토큰을 받아서 로그인과 똑같이 처리한다
                        SignUpView(viewModel: viewModel.makeSignUpViewModel(), onSignUp: onLogin)
                    }
                    .foregroundStyle(SlottyColor.primary)
                }
                .font(SlottyFont.caption)
            }
        }
        .padding(20)
        .background(SlottyColor.background)
    }
    
    /// 주차면 5칸과 그 아래 진입로 - 한 칸만 노란 차
    private var illustration: some View {
        VStack(spacing: 16) {
            HStack(spacing: 4) {
                SlottyLogo(width: 58, carColor: SlottyColor.secondary, lineRatio: 0.06)
                SlottyLogo(width: 58, carColor: SlottyColor.secondary, lineRatio: 0.06)
                SlottyLogo(width: 58, carColor: nil, lineRatio: 0.06)
                SlottyLogo(width: 58, lineRatio: 0.06)
                SlottyLogo(width: 58, carColor: SlottyColor.secondary, lineRatio: 0.06)
            }
            HStack(spacing: 3) {
                ForEach(0..<24, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill([4, 5, 6, 7, 15, 16, 17].contains(index) ? SlottyColor.primary : SlottyColor.fill)
                        .frame(width: 9, height: 14)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        LoginView(viewModel: LoginViewModel(repository: MockAuthRepository())) {}
    }
}
