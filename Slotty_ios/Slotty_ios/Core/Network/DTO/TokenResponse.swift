//
//  TokenResponse.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/20/26.
//

import Foundation

/// 로그인 응답 - 이후 요청에 쓰는 토큰 2개
struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
