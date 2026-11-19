//
//  AuthRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/19/26.
//

import Foundation

/// 로그인/회원가입 약속
protocol AuthRepository {
    /// 로그인 - 아이디나 비밀번호가 틀리면 AuthError.invalidCredentials
    func login(loginId: String, password: String) async throws
    
    /// 회원가입 - 이미 쓰는 아이디면 AuthError.loginIdDuplicated
    func signUp(_ form: SignUpForm) async throws
}
