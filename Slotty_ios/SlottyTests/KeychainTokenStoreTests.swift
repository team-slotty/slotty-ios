//
//  KeychainTokenStoreTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/20/26.
//

import Foundation
import Testing
@testable import Slotty

/// Keychain 토큰 저장/읽기/삭제
@MainActor
struct KeychainTokenStoreTests {
    /// 앱 토큰이나 동시에 도는 다른 테스트와 섞이지 않게 테스트마다 다른 서비스 이름을 쓴다
    private let store = KeychainTokenStore(service: "com.slotty.auth.tests.\(UUID().uuidString)")
    
    @Test func 저장한_토큰을_다시_읽는다() throws {
        defer { store.clear() }
        let tokens = AuthTokens(accessToken: "access-1", refreshToken: "refresh-1")
        
        try store.save(tokens)
        
        #expect(store.load() == tokens)
    }
    
    @Test func 다시_저장하면_덮어쓴다() throws {
        defer { store.clear() }
        try store.save(AuthTokens(accessToken: "access-1", refreshToken: "refresh-1"))
        
        try store.save(AuthTokens(accessToken: "access-2", refreshToken: "refresh-2"))
        
        #expect(store.load()?.accessToken == "access-2")
    }
    
    @Test func 지우면_nil이다() throws {
        try store.save(AuthTokens(accessToken: "access-1", refreshToken: "refresh-1"))
        
        store.clear()
        
        #expect(store.load() == nil)
    }
}
