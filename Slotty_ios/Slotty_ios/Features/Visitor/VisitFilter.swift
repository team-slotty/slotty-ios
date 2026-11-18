//
//  VisitFilter.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/18/26.
//

import Foundation

/// 방문 차량 목록 위쪽 구분 - 예정 / 방문 중 / 지난 방문
enum VisitFilter: CaseIterable, Identifiable {
    case scheduled
    case visiting
    case ended
    
    var id: Self { self }
    
    /// 화면에 보여줄 이름
    var label: String {
        switch self {
        case .scheduled: "예정"
        case .visiting: "방문 중"
        case .ended: "지난 방문"
        }
    }
    
    /// 이 구분에 들어가는 상태인지 - 확인 필요는 아직 정리되지 않은 방문이라 방문 중에 둔다
    func contains(_ status: VisitStatus) -> Bool {
        switch self {
        case .scheduled: status == .scheduled
        case .visiting: status == .visiting || status == .needsCheck
        case .ended: status == .ended
        }
    }
}
