//
//  AuthTokens.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/20/26.
//

import Foundation

/// 로그인하면 서버가 주는 토큰 두 개
struct AuthTokens: Equatable {
    /// 요청마다 헤더에 붙이는 토큰 (짧게 유효)
    let accessToken: String
    /// accessToken이 만료되면 새로 받을 때 쓰는 토큰 (길게 유효)
    let refreshToken: String
}
