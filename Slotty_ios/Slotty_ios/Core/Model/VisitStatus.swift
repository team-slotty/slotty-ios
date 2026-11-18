//
//  VisitStatus.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/18/26.
//

import Foundation

/// 방문 한 건의 상태
enum VisitStatus: Equatable {
    /// 방문 예정 - 시작 시각 전
    case scheduled
    /// 방문 중 - 시작과 종료 사이
    case visiting
    /// 확인 필요 - 면 지정 방문이 종료 30분 후에도 정리되지 않음
    case needsCheck
    /// 지난 방문 - 종료됐거나 [방문 종료]를 누름
    case ended
    
    /// 화면에 보여줄 이름
    var label: String {
        switch self {
        case .scheduled: "방문 예정"
        case .visiting: "방문 중"
        case .needsCheck: "확인 필요"
        case .ended: "지난 방문"
        }
    }
}
