//
//  MockAuthRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/19/26.
//

import Foundation

/// 목 데이터로 동작하는 인증 저장소
/// 로컬 시드의 사용자 1번(101호) 아이디로 로그인할 수 있다
final class MockAuthRepository: AuthRepository {
    /// 아이디 -> 비밀번호
    private var accounts = ["kim101": "slotty1234"]
    
    /// 목 저장소는 로그인을 기억하지 않는다 - 앱을 켤 때마다 로그인
    var hasSavedLogin: Bool { false }
    
    func login(loginId: String, password: String) async throws {
        guard accounts[loginId] == password else {
            throw AuthError.invalidCredentials
        }
    }
    
    /// 가입한 계정은 앱이 켜져 있는 동안 로그인에 쓸 수 있다
    func signUp(_ form: SignUpForm) async throws {
        guard accounts[form.loginId] == nil else {
            throw AuthError.loginIdDuplicated
        }
        accounts[form.loginId] = form.password
    }
    
    /// 목 저장소는 로그인을 기억하지 않아서 할 일이 없다
    func logout() async {}
}
