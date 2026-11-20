//
//  APIError.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/16/26.
//

import Foundation

/// 서버 통신 중 생기는 에러
enum APIError: Error, Equatable {
    /// 200번대가 아닌 응답 (상태 코드)
    case badStatus(Int)
    /// 서버가 에러 응답으로 알려 준 실패 (상태 코드, 에러 code - 예: INVALID_LOGIN)
    case server(statusCode: Int, code: String)
}
