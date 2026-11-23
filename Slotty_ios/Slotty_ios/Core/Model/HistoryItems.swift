//
//  HistoryItems.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 입출차 이력 한 건
struct ParkingHistoryItem: Identifiable, Equatable {
    let id: Int
    let plateNumber: String
    /// 예: 6번
    let spotLabel: String
    let enteredAt: Date
    /// 입차한 사람, 모르면 nil
    let enteredBy: String?
    /// 입차 방식 - 직접/알림/정정
    let enterMethod: String
    /// 출차 시각, 아직 주차 중이면 nil
    let exitedAt: Date?
    let exitedBy: String?
    /// 출차 방식 - 직접/알림/자동 정리, 주차 중이면 nil
    let exitMethod: String?
}

/// 미확인 차량 기록 한 건
struct UnidentifiedReportItem: Identifiable, Equatable {
    let id: Int
    let spotLabel: String
    /// 차량번호, 모르고 기록했으면 nil
    let plateNumber: String?
    let reportedBy: String?
    let reportedAt: Date
    /// 해제 시각, 아직 미확인이면 nil
    let resolvedAt: Date?
    /// 해제 방식 - 차량 떠남/내 차로 정정/자동 해제
    let resolveType: String?
}

extension ParkingHistoryItem {
    /// 서버 방식 글자를 화면 문구로
    static func methodLabel(_ method: String?) -> String {
        switch method {
        case "MANUAL": "직접"
        case "NOTIFICATION": "알림"
        case "CORRECTION": "정정"
        case "AUTO": "자동 정리"
        default: ""
        }
    }
}

extension UnidentifiedReportItem {
    /// 서버 해제 방식을 화면 문구로, 아직 미확인이면 "미확인"
    var resolveLabel: String {
        switch resolveType {
        case "LEFT": "차량 떠남"
        case "MINE": "내 차로 정정"
        case "AUTO": "자동 해제"
        default: "미확인"
        }
    }
}
