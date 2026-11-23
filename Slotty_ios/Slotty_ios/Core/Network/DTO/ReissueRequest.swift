//
//  ReissueRequest.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/21/26.
//

import Foundation

/// 토큰 재발급 요청 - POST /api/auth/reissue
struct ReissueRequest: Encodable {
    let refreshToken: String
}

/// 로그아웃 요청 - POST /api/auth/logout (서버가 이 refresh 토큰을 끝낸다, 응답 204)
struct LogoutRequest: Encodable {
    let refreshToken: String
}
