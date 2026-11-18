//
//  Visit.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/18/26.
//

import Foundation

/// 우리 세대가 등록한 방문차량 한 건
struct Visit: Identifiable, Equatable {
    let id: String
    /// 방문 차량번호 (우리 세대 방문이라 가리지 않음)
    var plateNumber: String
    /// 방문 시작/종료 일시
    var startAt: Date
    var endAt: Date
    /// 지정한 주차면 번호, 지정하지 않았으면 nil
    var spotNumber: Int?
    /// [방문 종료]로 일찍 끝낸 시각, 누르지 않았으면 nil
    var endedAt: Date?
    
    /// 지금 상태 - 저장하지 않고 시각으로 계산한다
    func status(at now: Date = Date()) -> VisitStatus {
        if let endedAt, endedAt <= now {
            return .ended
        }
        if now < startAt {
            return .scheduled
        }
        if now < endAt {
            return .visiting
        }
        // 면을 지정했는데 종료 30분 후에도 [방문 종료]가 없으면 확인 필요
        if spotNumber != nil, now >= endAt.addingTimeInterval(30 * 60) {
            return .needsCheck
        }
        return .ended
    }
    
    /// 삭제할 수 있는지 - 시작 전 방문만
    func canDelete(at now: Date = Date()) -> Bool {
        status(at: now) == .scheduled
    }
    
    /// [방문 종료]를 누를 수 있는지 - 방문 중이거나 확인 필요
    func canEnd(at now: Date = Date()) -> Bool {
        [.visiting, .needsCheck].contains(status(at: now))
    }
}
