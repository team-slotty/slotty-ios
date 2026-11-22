//
//  SessionExpiryTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/21/26.
//

import Foundation
import Testing
@testable import Slotty

/// 로그인이 풀렸을 때 토큰 지우기
@MainActor
struct SessionExpiryTests {
    private let tokens = AuthTokens(accessToken: "access-1", refreshToken: "refresh-1")
    
    @Test func UNAUTHORIZED면_토큰을_지운다() {
        let store = InMemoryTokenStore(tokens: tokens)
        let client = APIClient(tokenStore: store)
        
        client.expireSessionIfNeeded(.server(statusCode: 401, code: "UNAUTHORIZED", message: "로그인이 필요합니다."))
        
        #expect(store.tokens == nil)
    }
    
    @Test func 다른_실패면_토큰을_그대로_둔다() {
        let store = InMemoryTokenStore(tokens: tokens)
        let client = APIClient(tokenStore: store)
        
        client.expireSessionIfNeeded(.server(statusCode: 403, code: "NOT_IN_HOUSEHOLD", message: "세대에 소속된 사용자만 이용할 수 있습니다."))
        client.expireSessionIfNeeded(.badStatus(500))
        
        #expect(store.tokens == tokens)
    }
}
