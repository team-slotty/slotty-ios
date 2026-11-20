//
//  ErrorResponse.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/20/26.
//

import Foundation

/// 서버 에러 응답 - code로 어떤 실패인지 구분한다
struct ErrorResponse: Decodable {
    /// 예: INVALID_LOGIN, UNAUTHORIZED
    let code: String
    let message: String
}
