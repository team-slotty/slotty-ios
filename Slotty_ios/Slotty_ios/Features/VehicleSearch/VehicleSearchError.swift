//
//  VehicleSearchError.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/17/26.
//

import Foundation

/// 차량 검색 중에 생길 수 있는 오류
enum VehicleSearchError: Error, Equatable {
    /// 오늘 검색 횟수를 다 씀
    case limitExceeded
    /// 서버에 아직 없는 기능
    case notSupported
}
