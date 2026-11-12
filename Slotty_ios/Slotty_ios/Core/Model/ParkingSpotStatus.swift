//
//  ParkingSpotStatus.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/12/26.
//

import Foundation

/// 주차면 하나의 현재 상태
enum ParkingSpotStatus: Equatable {
    /// 사용 중 · 배정 세대 차량이 주차돼 있음
    case occupied
    /// 방문 중 · 방문 차량이 주차돼 있음
    case visiting
    /// 미확인 · 누구 차인지 모르는 차량이 있음
    case unconfirmed
    /// 확인 필요
    case needsCheck
    /// 비어 있음(가용) · 주인이 비워 둔 시간이라 다른 세대가 쓸 수 있음
    case available
    /// 빈 면
    case empty

    /// 화면에 보여줄 이름
    var label: String {
        switch self {
        case .occupied: "사용 중"
        case .visiting: "방문 중"
        case .unconfirmed: "미확인"
        case .needsCheck: "확인 필요"
        case .available: "비어 있음(가용)"
        case .empty: "빈 면"
        }
    }

    /// 차가 서 있어서 입차할 수 없는 상태인지
    var isOccupied: Bool {
        switch self {
        case .occupied, .visiting, .unconfirmed, .needsCheck: true
        case .available, .empty: false
        }
    }
}
