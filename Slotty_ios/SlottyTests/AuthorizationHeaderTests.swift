//
//  AuthorizationHeaderTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/21/26.
//

import Foundation
import Testing
@testable import Slotty

/// 요청에 로그인 토큰 붙이기
@MainActor
struct AuthorizationHeaderTests {
    private let request = URLRequest(url: URL(string: "http://localhost:8080/api/board")!)
    
    @Test func 토큰이_있으면_Bearer_헤더를_붙인다() {
        let store = InMemoryTokenStore(tokens: AuthTokens(accessToken: "access-1", refreshToken: "refresh-1"))
        let client = APIClient(tokenStore: store)
        
        let authorized = client.authorized(request)
        
        #expect(authorized.value(forHTTPHeaderField: "Authorization") == "Bearer access-1")
    }
    
    @Test func 토큰이_없으면_헤더를_붙이지_않는다() {
        let client = APIClient(tokenStore: InMemoryTokenStore())
        
        let authorized = client.authorized(request)
        
        #expect(authorized.value(forHTTPHeaderField: "Authorization") == nil)
    }
}
