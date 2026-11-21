//
//  InMemoryTokenStore.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/21/26.
//

import Foundation
@testable import Slotty

/// 테스트용 토큰 저장소 - Keychain 대신 메모리에만 둔다
final class InMemoryTokenStore: TokenStore {
    private(set) var tokens: AuthTokens?
    
    init(tokens: AuthTokens? = nil) {
        self.tokens = tokens
    }
    
    func save(_ tokens: AuthTokens) throws {
        self.tokens = tokens
    }
    
    func load() -> AuthTokens? {
        tokens
    }
    
    func clear() {
        tokens = nil
    }
}
