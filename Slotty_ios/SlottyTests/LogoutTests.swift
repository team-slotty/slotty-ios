//
//  LogoutTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Testing
@testable import Slotty

/// 로그아웃 - 서버 요청 결과와 상관없이 기기의 토큰을 지운다
@MainActor
@Suite(.serialized)
struct LogoutTests {
    private let host = "logout.test"
    
    private func makeRepository(_ store: InMemoryTokenStore) -> LiveAuthRepository {
        let client = APIClient(baseURL: URL(string: "http://\(host)")!, session: StubURLProtocol.makeSession(), tokenStore: store)
        return LiveAuthRepository(client: client, tokenStore: store)
    }
    
    @Test func 로그아웃하면_토큰을_지운다() async {
        StubURLProtocol.handlers[host] = { request in
            request.url?.path == "/api/auth/logout" ? (204, "") : (404, "")
        }
        let store = InMemoryTokenStore(tokens: AuthTokens(accessToken: "access-1", refreshToken: "refresh-1"))
        
        await makeRepository(store).logout()
        
        #expect(store.tokens == nil)
    }
    
    @Test func 서버_요청이_실패해도_토큰을_지운다() async {
        StubURLProtocol.handlers[host] = { _ in (500, "") }
        let store = InMemoryTokenStore(tokens: AuthTokens(accessToken: "access-1", refreshToken: "refresh-1"))
        
        await makeRepository(store).logout()
        
        #expect(store.tokens == nil)
    }
}
