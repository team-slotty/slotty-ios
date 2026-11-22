//
//  SavedLoginTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/21/26.
//

import Testing
@testable import Slotty

/// 앱을 켤 때 저장된 로그인이 있는지
@MainActor
struct SavedLoginTests {
    @Test func 토큰이_있으면_저장된_로그인이_있다() {
        let store = InMemoryTokenStore(tokens: AuthTokens(accessToken: "access-1", refreshToken: "refresh-1"))

        #expect(LiveAuthRepository(tokenStore: store).hasSavedLogin)
    }

    @Test func 토큰이_없으면_저장된_로그인이_없다() {
        #expect(!LiveAuthRepository(tokenStore: InMemoryTokenStore()).hasSavedLogin)
    }
}
