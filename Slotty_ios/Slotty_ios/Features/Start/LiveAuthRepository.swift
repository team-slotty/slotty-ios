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
    private let tokenStore: any TokenStore
    
    init(client: APIClient = APIClient(), tokenStore: any TokenStore = KeychainTokenStore()) {
        self.client = client
        self.tokenStore = tokenStore
    }
    
    /// Keychain에 토큰이 남아 있으면 저장된 로그인으로 본다
    /// 만료됐어도 첫 요청에서 재발급하고, 재발급도 실패하면 로그인 화면으로 돌아간다
    var hasSavedLogin: Bool {
        tokenStore.load() != nil
    }
    
    /// 로그인 - 성공하면 토큰을 저장하고, 서버가 INVALID_LOGIN을 보내면 아이디/비밀번호 오류
    func login(loginId: String, password: String) async throws {
        let response: TokenResponse
        do {
            let request = LoginRequest(loginId: loginId, password: password)
            response = try await client.post("/api/auth/login", body: request)
        } catch APIError.server(_, code: "INVALID_LOGIN", _) {
            throw AuthError.invalidCredentials
        }
        try tokenStore.save(AuthTokens(accessToken: response.accessToken, refreshToken: response.refreshToken))
    }
    
    /// 회원가입 - 성공하면 로그인처럼 토큰을 저장하고, 이미 쓰는 아이디면 AuthError.loginIdDuplicated
    func signUp(_ form: SignUpForm) async throws {
        let response: TokenResponse
        do {
            response = try await client.post("/api/auth/signup", body: SignUpRequest(form: form))
        } catch APIError.server(_, code: "LOGIN_ID_DUPLICATED", _) {
            throw AuthError.loginIdDuplicated
        }
        try tokenStore.save(AuthTokens(accessToken: response.accessToken, refreshToken: response.refreshToken))
    }
}
