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
