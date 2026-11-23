//
//  VehicleSearchResponse.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 차량번호 검색 응답 - GET /api/vehicles/search?plate=
struct VehicleSearchResponse: Decodable {
    /// 오늘 남은 검색 횟수 (하루 20회)
    let remainingToday: Int
    /// 최대 10건 - 입주민 차량 먼저, 남은 자리에 방문차량
    let results: [Result]
    
    struct Result: Decodable {
        /// RESIDENT(입주민) / VISIT(방문)
        let type: String
        let unitNumber: String
        let plateLast4: String
        /// 내 세대 차량/방문일 때만 전체 번호, 그 외 null
        let plateNumber: String?
        /// 방문 시간 - 볼 권한이 없으면 null
        let visit: VisitInfo?
        let contact: Contact
    }
    
    struct VisitInfo: Decodable {
        let startAt: Date
        let endAt: Date
    }
    
    struct Contact: Decodable {
        /// 연락처 공개에 동의했을 때만 true
        let canCall: Bool
        let phone: String?
    }
}

extension VehicleSearchResponse {
    /// 앱 모델로 변환 - 남의 차는 전체 번호 대신 뒤 4자리만 보여 준다
    func toResults() -> VehicleSearchResults {
        let items = results.enumerated().map { index, result in
            VehicleSearchResult(
                id: "\(index)-\(result.type)-\(result.unitNumber)",
                maskedPlateNumber: result.plateNumber ?? "**\(result.plateLast4)",
                unit: result.unitNumber,
                kind: result.type == "VISIT"
                ? .visitor(start: result.visit?.startAt, end: result.visit?.endAt)
                : .resident,
                phoneNumber: result.contact.canCall ? result.contact.phone : nil
            )
        }
        return VehicleSearchResults(items: items, remainingCount: remainingToday)
    }
}
