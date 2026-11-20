//
//  LiveAuthRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/20/26.
//

import Foundation

/// 서버와 통신하는 인증 저장소
struct LiveAuthRepository: AuthRepository {
    private let client: APIClient
    
    init(client: APIClient = APIClient()) {
        self.client = client
    }
    
    /// 로그인 - 서버가 INVALID_LOGIN을 보내면 아이디/비밀번호 오류
    func login(loginId: String, password: String) async throws {
        do {
            let request = LoginRequest(loginId: loginId, password: password)
            let _: TokenResponse = try await client.post("/api/auth/login", body: request)
        } catch APIError.server(_, code: "INVALID_LOGIN") {
            throw AuthError.invalidCredentials
        }
    }
    
    func signUp(_ form: SignUpForm) async throws {
        // 서버에 회원가입 API가 아직 없음
        throw AuthError.notSupported
    }
}
