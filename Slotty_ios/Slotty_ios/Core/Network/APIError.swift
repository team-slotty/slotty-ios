//
//  APIError.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/16/26.
//

import Foundation

/// 서버 통신 중 생기는 에러
enum APIError: Error {
    /// 200번대가 아닌 응답 (상태 코드)
    case badStatus(Int)
}
