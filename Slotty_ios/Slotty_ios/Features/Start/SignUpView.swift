//
//  SignUpView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/19/26.
//

import SwiftUI

/// 0-3 회원가입 : 아이디/비밀번호/이름/전화번호, 약관 동의, 연락처 공개
struct SignUpView: View {
    @State private var viewModel: SignUpViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: SignUpViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                LabeledInput(label: "아이디", placeholder: "영문, 숫자 4~30자", text: $viewModel.form.loginId)
                LabeledInput(label: "비밀번호", placeholder: "8~72자", text: $viewModel.form.password, isSecure: true)
                LabeledInput(
                    label: "비밀번호 확인", placeholder: "비밀번호 다시 입력",
                    text: $viewModel.form.passwordConfirm, isSecure: true
                )
                LabeledInput(label: "이름", placeholder: "홍길동", text: $viewModel.form.name)
                LabeledInput(
                    label: "전화번호", placeholder: "010-0000-0000",
                    text: $viewModel.form.phone, keyboard: .phonePad
                )
                VStack(alignment: .leading, spacing: 12) {
                    checkbox("[필수] 이용약관·개인정보 처리 동의", isOn: $viewModel.form.agreedToTerms)
                    checkbox("[선택] 차량번호 검색 시 이웃에게 연락처 공개", isOn: $viewModel.form.phonePublic)
                    Text("※ 연락처는 가려서 표시되고 [전화 걸기]로만 연결돼요")
                        .font(SlottyFont.caption)
                        .foregroundStyle(SlottyColor.secondary)
                }
                if let message = viewModel.errorMessage ?? viewModel.form.problem {
                    Text(message)
                        .font(SlottyFont.caption)
                        .foregroundStyle(SlottyColor.secondary)
                }
            }
            .padding(20)
        }
        .safeAreaInset(edge: .bottom) {
            Button("가입하기") {
                Task {
                    if await viewModel.signUp() {
                        dismiss()
                    }
                }
            }
            .buttonStyle(.slottyPrimary)
            .disabled(!viewModel.canSignUp)
            .padding(20)
            .background(SlottyColor.background)
        }
        .background(SlottyColor.background)
        .navigationTitle("회원가입")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    /// 네모 체크 상자 + 문구 - 누르면 켜고 끈다
    private func checkbox(_ title: String, isOn: Binding<Bool>) -> some View {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isOn.wrappedValue ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20))
                Text(title)
                    .font(SlottyFont.body)
            }
            .foregroundStyle(SlottyColor.primary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SignUpView(viewModel: SignUpViewModel(repository: MockAuthRepository()))
    }
}
