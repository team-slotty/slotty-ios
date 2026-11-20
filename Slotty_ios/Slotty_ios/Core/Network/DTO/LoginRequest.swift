//
//  LoginRequest.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/20/26.
//

import Foundation

/// 로그인 요청 - POST /api/auth/login
struct LoginRequest: Encodable {
    let loginId: String
    let password: String
}
