//
//  MockVisitData.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/18/26.
//

import Foundation

/// 서버 없이 방문 화면을 만들기 위한 목 데이터 - 지금 시각 기준으로 예정/방문 중/지난 방문이 하나씩
enum MockVisitData {
    static var visits: [Visit] {
        let now = Date()
        let hour: TimeInterval = 60 * 60
        return [
            Visit(id: "visit1", plateNumber: "78마3456", startAt: now - hour, endAt: now + 3 * hour),
            Visit(id: "visit2", plateNumber: "56바7890", startAt: now + 24 * hour, endAt: now + 28 * hour),
            Visit(
                id: "visit3", plateNumber: "90사1234", startAt: now - 26 * hour, endAt: now - 22 * hour,
                endedAt: now - 23 * hour
            ),
        ]
    }
}
