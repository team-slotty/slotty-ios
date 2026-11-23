//
//  SlotDetailResponse.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 면 상세 응답 - GET /api/parking-slots/{id} (가용시간과 지정된 방문만 쓴다)
struct SlotDetailResponse: Decodable {
    let availableWindow: AvailableWindow?
    let visit: Visit?
    
    struct AvailableWindow: Decodable {
        let allDay: Bool
        /// "HH:mm"
        let startTime: String?
        let endTime: String?
    }
    
    struct Visit: Decodable {
        let unitNumber: String
        let startAt: Date
        let endAt: Date
    }
    
    func toDetail() -> SpotDetail {
        SpotDetail(
            availableTime: availableWindow.map { window in
                window.allDay ? "종일" : "\(window.startTime ?? "")~\(window.endTime ?? "")"
            },
            visit: visit.map { visit in
                let start = visit.startAt.formatted(date: .omitted, time: .shortened)
                let end = visit.endAt.formatted(date: .omitted, time: .shortened)
                return "\(visit.unitNumber)호 방문 \(start)~\(end)"
            }
        )
    }
}
