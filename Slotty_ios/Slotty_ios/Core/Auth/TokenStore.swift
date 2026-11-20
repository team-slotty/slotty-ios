//
//  TokenStore.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/20/26.
//

import Foundation

/// 로그인 토큰을 저장/읽기/삭제하는 약속
protocol TokenStore {
    /// 저장 - 이미 있으면 덮어쓴다
    func save(_ tokens: AuthTokens) throws
    /// 저장된 토큰, 없으면 nil
    func load() -> AuthTokens?
    /// 삭제 - 로그아웃이나 토큰 만료 때
    func clear()
}
