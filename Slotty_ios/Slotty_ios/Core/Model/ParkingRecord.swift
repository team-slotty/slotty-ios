//
//  ParkingRecord.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/13/26.
//

import Foundation

// 주차면에 지금 서 있는 차의 입차 기록
struct ParkingRecord: Equatable {
    // 차량번호 - 미확인 차량은 번호를 모를 수 있어서 nil 가능
    var plateNumber: String?
    // 입차 시각
    var enteredAt: Date
    // 기록 방식
    var method: ParkingRecordMethod
}
