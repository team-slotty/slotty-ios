//
//  SignUpRequest.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation

/// 회원가입 요청 - POST /api/auth/signup (응답은 로그인과 같은 토큰 두 개)
struct SignUpRequest: Encodable {
    let loginId: String
    let password: String
    let name: String
    /// 숫자만 (서버는 하이픈이 있어도 받는다)
    let phone: String
    /// 차량번호 검색 시 이웃에게 연락처 공개
    let phonePublic: Bool
}

extension SignUpRequest {
    /// 입력 폼에서 요청 만들기 - 이름은 앞뒤 공백, 전화번호는 하이픈을 뺀다
    init(form: SignUpForm) {
        self.init(
            loginId: form.loginId,
            password: form.password,
            name: form.trimmedName,
            phone: form.phoneDigits,
            phonePublic: form.phonePublic
        )
    }
}
