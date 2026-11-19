//
//  LabeledInput.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/19/26.
//

import SwiftUI

/// 이름표가 붙은 한 줄 입력칸 - 로그인/회원가입
struct LabeledInput: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    /// 비밀번호처럼 가려서 입력할지
    var isSecure = false
    /// 키보드 종류 (예: 전화번호는 .phonePad)
    var keyboard: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(SlottyFont.caption)
                .foregroundStyle(SlottyColor.secondary)
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(SlottyFont.body)
            .keyboardType(keyboard)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.horizontal, 14)
            .frame(height: 46)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(SlottyColor.line)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        LabeledInput(label: "아이디", placeholder: "아이디 입력", text: .constant(""))
        LabeledInput(label: "비밀번호", placeholder: "비밀번호 입력", text: .constant("1234"), isSecure: true)
    }
    .padding(20)
}
