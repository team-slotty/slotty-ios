//
//  HistoryResponse.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 기록한 사람 - 이력 응답 공통
struct UserRef: Decodable {
    let userId: Int
    let name: String
}

/// 입출차 이력 응답 - GET /api/parking/history (첫 페이지 20건)
struct ParkingHistoryResponse: Decodable {
    let items: [Item]
    
    struct Item: Decodable {
        let recordId: Int
        let plateNumber: String
        let slotLabel: String
        let enteredAt: Date
        let enteredBy: UserRef?
        let enterMethod: String
        let exitedAt: Date?
        let exitedBy: UserRef?
        let exitMethod: String?
    }
    
    func toItems() -> [ParkingHistoryItem] {
        items.map {
            ParkingHistoryItem(
                id: $0.recordId, plateNumber: $0.plateNumber, spotLabel: $0.slotLabel,
                enteredAt: $0.enteredAt, enteredBy: $0.enteredBy?.name, enterMethod: $0.enterMethod,
                exitedAt: $0.exitedAt, exitedBy: $0.exitedBy?.name, exitMethod: $0.exitMethod
            )
        }
    }
}

/// 미확인 기록 목록 응답 - GET /api/unidentified-reports (관리자, 첫 페이지 20건)
struct UnidentifiedReportsResponse: Decodable {
    let items: [Item]
    
    struct Item: Decodable {
        let reportId: Int
        let slotLabel: String
        let plateNumber: String?
        let reportedBy: UserRef?
        let reportedAt: Date
        let resolvedAt: Date?
        let resolveType: String?
    }
    
    func toItems() -> [UnidentifiedReportItem] {
        items.map {
            UnidentifiedReportItem(
                id: $0.reportId, spotLabel: $0.slotLabel, plateNumber: $0.plateNumber,
                reportedBy: $0.reportedBy?.name, reportedAt: $0.reportedAt,
                resolvedAt: $0.resolvedAt, resolveType: $0.resolveType
            )
        }
    }
}
