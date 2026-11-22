//
//  SignUpForm.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/19/26.
//

import Foundation

/// 회원가입 입력값과 입력 검사
struct SignUpForm: Equatable {
    var loginId = ""
    var password = ""
    var passwordConfirm = ""
    var name = ""
    var phone = ""
    /// [필수] 이용약관/개인정보 처리 동의
    var agreedToTerms = false
    /// [선택] 차량번호 검색 시 이웃에게 연락처 공개
    var phonePublic = false
    
    /// 앞뒤 공백을 뺀 이름
    var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }
    
    /// 하이픈 등을 뺀 전화번호 숫자
    var phoneDigits: String {
        phone.filter(\.isNumber)
    }
    
    /// 입력에 문제가 있으면 안내 문구, 없으면 nil - 위에서부터 걸리는 것 하나만
    var problem: String? {
        // 서버 규칙과 같게 - 아이디 4~30자, 비밀번호 8~72자
        if loginId.wholeMatch(of: /[A-Za-z0-9]{4,30}/) == nil {
            return "아이디는 영문, 숫자 4~30자로 입력해 주세요"
        }
        if !(8...72).contains(password.count) {
            return "비밀번호는 8~72자로 입력해 주세요"
        }
        if password != passwordConfirm {
            return "비밀번호가 서로 달라요"
        }
        if trimmedName.isEmpty {
            return "이름을 입력해 주세요"
        }
        if !phoneDigits.hasPrefix("01") || !(10...11).contains(phoneDigits.count) {
            return "전화번호를 확인해 주세요"
        }
        if !agreedToTerms {
            return "필수 약관에 동의해 주세요"
        }
        return nil
    }
}
