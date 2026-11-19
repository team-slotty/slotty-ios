//
//  File.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/19/26.
//

import Foundation
import Observation

/// 로그인 화면의 입력과 동작
@Observable
final class LoginViewModel {
    var loginId = ""
    var password = ""
    /// 화면에 띄울 오류 문구 - 없으면 nil
    private(set) var errorMessage: String?
    /// 로그인 요청 중인지
    private(set) var isLoggingIn = false
    
    private let repository: any AuthRepository
    
    init(repository: any AuthRepository) {
        self.repository = repository
    }
    
    /// 두 칸이 모두 채워졌고 요청 중이 아닐 때만 [로그인]을 누를 수 있다
    var canLogin: Bool {
        !loginId.isEmpty && !password.isEmpty && !isLoggingIn
    }
    
    /// 로그인 - 성공하면 true
    func login() async -> Bool {
        isLoggingIn = true
        defer { isLoggingIn = false }
        do {
            try await repository.login(loginId: loginId, password: password)
            errorMessage = nil
            return true
        } catch AuthError.invalidCredentials {
            errorMessage = "아이디 또는 비밀번호가 맞지 않아요"
            return false
        } catch {
            errorMessage = "로그인하지 못했어요"
            return false
        }
    }
}
