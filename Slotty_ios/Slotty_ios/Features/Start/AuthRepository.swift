//
//  AuthRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/19/26.
//

import Foundation

/// 로그인/회원가입 약속
protocol AuthRepository {
    /// 저장된 로그인이 있는지 - 있으면 앱을 켤 때 로그인 화면을 건너뛴다
    var hasSavedLogin: Bool { get }
    
    /// 로그인 - 아이디나 비밀번호가 틀리면 AuthError.invalidCredentials
    func login(loginId: String, password: String) async throws
    
    /// 회원가입 - 이미 쓰는 아이디면 AuthError.loginIdDuplicated
    func signUp(_ form: SignUpForm) async throws
    
    /// 로그아웃 - 실패해도 이 기기에서는 로그아웃된 상태가 된다
    func logout() async
}
