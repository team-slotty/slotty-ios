//
//  CheckInOptions.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation

/// 입차할 때 고를 수 있는 면 - 빈 내 배정 면 -> 빈 공용 면 순서
struct CheckInOptions: Equatable {
    /// 고를 수 있는 면 번호 (찬 면, 남의 배정 면은 없음)
    let spotNumbers: [Int]
    /// 처음 골라 둘 면, 없으면 nil
    let suggestedSpotNumber: Int?
    /// 배정 면이 모두 차 있는지 - true면 "배정 면이 사용 중이에요" 안내
    let assignedAllOccupied: Bool
}
