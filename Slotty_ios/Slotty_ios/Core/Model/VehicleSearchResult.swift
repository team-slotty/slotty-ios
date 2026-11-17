//
//  VehicleSearchResult.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/17/26.
//

import Foundation

/// 차량번호 뒤 4자리로 찾은 차 한 대
struct VehicleSearchResult: Identifiable, Equatable {
    let id: String
    /// 가린 차량번호 (예: **가 3456) - 전체 번호는 받지 않는다
    let maskedPlateNumber: String
    /// 차와 연결된 세대 호수
    let unit: String
    /// 입주민 차인지 방문 차인지
    let kind: Kind
    /// 전화번호, 연락처를 공개하지 않은 세대면 nil
    let phoneNumber: String?
    
    enum Kind: Equatable {
        /// 입주민 차
        case resident
        /// 방문 차 - 방문 시간대
        case visitor(start: Date, end: Date)
    }
}

/// 한 번 검색한 결과 - 찾은 차들과 오늘 남은 검색 횟수
struct VehicleSearchResults: Equatable {
    let items: [VehicleSearchResult]
    let remainingCount: Int
}
