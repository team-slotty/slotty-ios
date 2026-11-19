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
    
    func login(loginId: String, password: String) async throws {
        guard accounts[loginId] == password else {
            throw AuthError.invalidCredentials
        }
    }
}
